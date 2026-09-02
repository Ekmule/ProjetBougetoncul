# MYA — Stratégie de synchronisation

**Projet :** MYA — Move Your Ass  
**Document :** Synchronisation offline-first  
**Version :** 1.0  
**Dernière mise à jour :** 2026-08-23  
**Statut :** Référence pour l'implémentation D14–D15

---

# 1. Principe fondamental

```
L'utilisateur modifie → SQLite d'abord → UI immédiate → sync ensuite
```

L'interface ne lit **jamais** Supabase directement. Supabase est une **réplique distante** de ce qui est déjà en local.

---

# 2. Modes de fonctionnement

## Mode 1 — Local seul (par défaut)

```
Installation
    ↓
Création de tâches → SQLite
    ↓
Utilisation normale
    ↓
Aucun appel réseau
```

- `user_id` = `NULL` en local
- `sync_status` = `pending` (en attente d'une future connexion)
- `sync_operations` accumule les changements

## Mode 2 — Connecté + en ligne

```
Modification locale → SQLite → sync_operations
    ↓
SyncService détecte réseau + session
    ↓
Upload vers Supabase
    ↓
Realtime notifie les autres appareils
    ↓
Autres appareils appliquent en local
```

## Mode 3 — Connecté + hors ligne

```
Modification locale → SQLite → sync_operations (pending)
    ↓
Pas de réseau → rien n'est envoyé
    ↓
Reconnexion → SyncService traite la file
```

Aucune donnée n'est perdue. La file grandit tant que le réseau est absent.

---

# 3. Flux détaillé : création d'une tâche

```
Utilisateur tape "Acheter du pain" + Entrée
        │
        ▼
CreateTask (application layer)
        │
        ▼
TaskRepository.create()
        │
        ├──► SQLite : INSERT task (id=UUID, sync_status='pending')
        │
        ├──► sync_operations : INSERT (operation='create', payload=task JSON)
        │
        └──► UI mise à jour immédiatement (Riverpod notifie)
                │
                ▼ (si connecté + en ligne, en arrière-plan)
        SyncService.processQueue()
                │
                ▼
        Supabase : INSERT INTO tasks (...)
                │
                ▼
        SQLite : sync_status = 'synced'
        sync_operations : status = 'sent'
```

**Temps perçu par l'utilisateur :** instantané (SQLite uniquement).

---

# 4. Flux détaillé : réception d'un changement distant

```
Autre appareil modifie une tâche
        │
        ▼
Supabase Realtime → événement reçu par SyncService
        │
        ▼
SyncConflictResolver.resolve(localTask, remoteTask)
        │
        ├──► Gagnant = version à appliquer (LWW)
        │
        ▼
SQLite : UPDATE task
        │
        ▼
UI mise à jour (Riverpod)
```

---

# 5. Résolution des conflits (ADR-015)

## 5.1 Algorithme Last Write Wins

```dart
/// Pseudo-code — à implémenter dans SyncConflictResolver
Task resolve(Task local, Task remote, SyncOperation? pendingOp) {
  // 1. Opération locale non envoyée → local gagne toujours
  if (pendingOp != null && pendingOp.status == 'pending') {
    return local;
  }

  // 2. Suppression distante plus récente → suppression gagne
  if (remote.deletedAt != null) {
    if (local.deletedAt == null || remote.deletedAt > local.deletedAt) {
      return remote;
    }
  }

  // 3. Suppression locale plus récente → idem
  if (local.deletedAt != null) {
    if (remote.deletedAt == null || local.deletedAt > remote.deletedAt) {
      return local;
    }
  }

  // 4. Comparer updatedAt (millisecondes UTC)
  if (remote.updatedAt > local.updatedAt) return remote;
  if (local.updatedAt > remote.updatedAt) return local;

  // 5. Égalité → local gagne (tie-breaker déterministe)
  return local;
}
```

## 5.2 Cas limites

| Situation | Résolution |
|---|---|
| PC termine une tâche, téléphone modifie le titre (hors ligne) | Celui avec `updatedAt` le plus récent gagne intégralement |
| Suppression sur PC, modification sur téléphone hors ligne | Suppression gagne si `deletedAt` > `updatedAt` distant |
| Deux créations avec UUID différents | Pas de conflit — deux tâches distinctes |
| Même UUID, première sync | Fusion par UUID (ADR-016) |

---

# 6. Fusion première connexion (ADR-016)

Déclenchée une seule fois, lors du premier login d'un appareil.

```
Première connexion
        │
        ▼
Récupérer toutes les tâches cloud (SELECT * FROM tasks WHERE user_id = auth.uid())
        │
        ▼
Pour chaque tâche locale (user_id était NULL) :
        │
        ├── UUID absent du cloud → UPLOAD + user_id = auth.uid()
        │
        └── UUID présent dans le cloud → LWW(local, remote)
        │
        ▼
Pour chaque tâche cloud absente en local :
        │
        └── INSERT en local
        │
        ▼
Rattacher user_id sur toutes les tâches locales
        │
        ▼
Marquer fusion terminée (flag local : first_sync_done = true)
```

**Règle absolue :** jamais de `DELETE` silencieux des tâches locales.

---

# 7. File de synchronisation (`sync_operations`)

## 7.1 Quand créer une opération

| Action utilisateur | `operation` | `entity_type` |
|---|---|---|
| Créer une tâche | `create` | `task` |
| Modifier titre/catégorie/date | `update` | `task` |
| Cocher une tâche | `complete` | `task` |
| Supprimer une tâche | `delete` | `task` |
| Modifier libellé catégorie | `update` | `user_settings` |

## 7.2 Traitement de la file

```
SyncService.processQueue() :
  1. SELECT * FROM sync_operations WHERE status = 'pending' ORDER BY created_at
  2. Pour chaque opération :
     a. status = 'in_progress'
     b. Envoyer à Supabase (upsert / delete)
     c. Succès → status = 'sent'
     d. Échec → status = 'failed', retry_count++
  3. Si retry_count > 5 → status = 'failed' permanent, log erreur
```

## 7.3 Déduplication

Si plusieurs opérations `update` existent pour la même entité avant envoi, elles peuvent être fusionnées en une seule (payload = dernière version).

---

# 8. Realtime Supabase

## 8.1 Abonnement

```dart
/// Écouter uniquement les tâches de l'utilisateur connecté.
/// Le filtre user_id est garanti par RLS côté serveur.
supabase
  .channel('mya_tasks')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'tasks',
    callback: (payload) => syncService.onRemoteChange(payload),
  )
  .subscribe();
```

## 8.2 Événements traités

| Événement Realtime | Action locale |
|---|---|
| `INSERT` | Insérer si UUID absent, sinon LWW |
| `UPDATE` | LWW avec version locale |
| `DELETE` | Soft delete local (`deleted_at`) |

## 8.3 Quand s'abonner

- À la connexion utilisateur
- Se désabonner à la déconnexion
- Ne pas maintenir de connexion Realtime permanente si l'app est en arrière-plan (mobile)

---

# 9. Détection réseau

Package : `connectivity_plus`

| État | Comportement SyncService |
|---|---|
| `online` | Traiter la file immédiatement |
| `offline` | Ne rien envoyer, continuer à accumuler |
| `online` (reconnexion) | Traiter toute la file + pull des changements distants |

```dart
/// Le réseau ne bloque jamais l'UI.
/// SyncService écoute les changements de connectivité en arrière-plan.
connectivity.onConnectivityChanged.listen((result) {
  if (result != ConnectivityResult.none) {
    syncService.processQueue();
    syncService.pullRemoteChanges();
  }
});
```

---

# 10. Rappels et synchronisation

Les rappels sont **locaux**. Le serveur stocke `reminder_at`, mais c'est l'appareil qui programme la notification.

```
Sync reçoit tâche avec reminder_at
        │
        ▼
NotificationService.scheduleReminder(task)
        │
        ▼
Si reminder_at modifié → annuler ancien + programmer nouveau
Si tâche supprimée/terminée → annuler rappel
```

Chaque appareil gère ses propres notifications indépendamment.

---

# 11. Déconnexion

```
Utilisateur se déconnecte
        │
        ▼
Arrêter Realtime
        │
        ▼
Les tâches locales RESTENT (pas de suppression)
        │
        ▼
user_id reste en local (données conservées)
        │
        ▼
Nouvelles tâches : user_id = NULL, sync_status = 'pending'
```

L'utilisateur peut continuer à utiliser MYA hors compte après déconnexion.

---

# 12. Suppression de compte

```
Utilisateur demande suppression compte
        │
        ▼
Supabase : DELETE auth.users (cascade sur tasks + user_settings via FK)
        │
        ▼
Local : supprimer toutes les tâches liées à ce user_id
        │
        ▼
Conserver ou effacer selon choix utilisateur (tout effacer vs garder local)
```

Détail de l'UX à définir avant publication (ADR-025).

---

# 13. Tests de synchronisation obligatoires

| Scénario | Résultat attendu |
|---|---|
| Créer tâche hors ligne → reconnecter | Tâche uploadée, visible sur autre appareil |
| Modifier sur PC → Realtime → téléphone | Modification visible sur téléphone |
| Conflit simultané hors ligne | LWW appliqué, pas de doublon |
| Première connexion avec tâches locales | Fusion sans perte |
| Suppression sur PC, téléphone hors ligne | Suppression propagée à la reconnexion |
| Déconnexion | Tâches locales conservées |

---

# 14. Références

| Document | Contenu |
|---|---|
| [`database.md`](database.md) | Schéma tables, mapping local ↔ cloud |
| [`decisions.md`](decisions.md) | ADR-015 (LWW), ADR-016 (fusion) |
| [`architecture.md`](architecture.md) | Couches et SyncService |
