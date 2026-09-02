# MYA — Architecture technique

**Projet :** MYA — Move Your Ass  
**Document :** Architecture technique  
**Version :** 1.0  
**Statut :** Référence obligatoire avant toute modification du code  
**Dernière mise à jour :** 2026-08-23

---

# 1. Objectif de ce document

Ce document définit **comment** MYA doit être construit.

Il est plus prescriptif que les cahiers des charges : il fixe l'architecture pour éviter que le code dérive en cours de développement.

**Règle pour tout développeur humain ou agent IA :**

1. Lire ce document avant toute modification architecturale
2. Respecter les responsabilités de chaque couche
3. Ne pas ajouter de dépendance importante sans la documenter dans `docs/decisions.md`
4. Ne pas modifier le modèle de données sans mettre à jour `docs/database.md`
5. Toute décision contraire à ce document doit être explicitement enregistrée dans `docs/decisions.md`

---

# 2. Philosophie générale

MYA est un **pense-bête discret**, pas un gestionnaire de projet.

| Principe | Signification |
|---|---|
| Local-first | L'app fonctionne immédiatement sans Internet |
| Rapidité | 1 saisie + validation pour créer une tâche |
| Faible pression | Pas de compteur, pas de gamification, pas de culpabilisation |
| Simplicité | La complexité technique reste invisible pour l'utilisateur |
| Multiplateforme | Maximum de code partagé, intégrations natives ciblées |

> L'utilisateur doit pouvoir créer ou consulter une tâche immédiatement, même hors connexion.

---

# 3. Périmètre MVP

## 3.1 Inclus dans le MVP

### Windows (priorité 1)
- Pastille flottante + déplacement + ancrage aux bords
- Panneau de tâches (survol / clic)
- Always-on-Top, masquage, démarrage automatique
- Raccourci global (`Ctrl + Alt + Space`)
- Création rapide, catégories, dates, rappels
- Tâches terminées + historique (7 jours max)
- Stockage local

### Mobile (priorité 2 et 3)
- **Android** : CRUD complet, dates, rappels, notifications, sync
- **iOS** : si faisable sans contraintes excessives (nécessite macOS pour build/sign) ; sinon reporté ou abandonné

### Synchronisation
- Compte optionnel (utilisation locale sans compte possible)
- Auth Google / Apple / Microsoft via Supabase
- Sync offline-first PC ↔ mobile
- Fonctionnement hors connexion + sync à la reconnexion

## 3.2 Exclu du MVP (reporté volontairement)

| Fonctionnalité | Raison |
|---|---|
| Widgets Android/iOS | Complexité native élevée — après D16/D17 |
| Applications Windows associées (`.exe`) | Fonctionnalité locale complexe — accélérer le time-to-market |
| Sous-tâches, récurrence, projets, Kanban | Hors philosophie produit |
| Personnalité avancée des notifications | Version ultérieure |
| Analytics | Pas d'analytics intrusive au MVP |

---

# 4. Priorité des plateformes

```
Phase 1 — Windows     (pastille = différenciateur principal)
Phase 2 — Android     (mobile le plus accessible à développer)
Phase 3 — iOS         (conditionnel : si contraintes Apple trop lourdes → abandon)
Phase 4 — Widgets     (post-MVP)
```

La **pastille Windows** doit être prototypée et validée **avant** d'investir dans le reste du produit.

---

# 5. Architecture générale

```
                        ┌───────────────────────────┐
                        │         SUPABASE          │
                        │  Auth · PostgreSQL · RLS  │
                        │         Realtime          │
                        └─────────────┬─────────────┘
                                      │
                              SyncService
                                      │
             ┌────────────────────────┴────────────────────────┐
             │                                                 │
       ┌─────▼─────┐                                     ┌─────▼─────┐
       │  WINDOWS  │                                     │  MOBILE   │
       │  Flutter  │                                     │  Flutter  │
       └─────┬─────┘                                     └─────┬─────┘
             │                                                 │
       ┌─────┼─────────────┐                         ┌──────────┼──────────┐
       │     │             │                         │          │          │
    SQLite  Window      Hotkey                    SQLite  Notification  (Widget)
    (Drift) Service    Service                    (Drift)  Service     post-MVP
       │     │             │                         │          │
       └─────┴─────────────┘                         └──────────┴──────────┘
```

**Règle fondamentale :** Flutter n'est pas la plateforme. C'est la couche UI et logique commune. Les fonctionnalités système passent par des services plateforme abstraits.

---

# 6. Couches applicatives

```
Presentation  →  widgets, pages, navigation
Application   →  orchestration des actions utilisateur (use cases)
Domain        →  règles métier, entités, interfaces repository
Data          →  SQLite, Supabase, file de sync
Platform      →  Windows / Android / iOS natif
```

## 6.1 Dépendances autorisées

```
features/
   ↓
application/
   ↓
domain/          ← testable sans Flutter
   ↑
data/            implémente les interfaces du domain
platform/        implémente les services natifs
```

## 6.2 Interdictions

```dart
// ❌ INTERDIT — widget qui appelle Supabase directement
Supabase.instance.client.from('tasks').select();

// ✅ CORRECT
ref.read(taskRepositoryProvider).getTasks();
```

```dart
// ❌ INTERDIT — widget qui appelle l'API Windows
SetWindowPos(...);

// ✅ CORRECT
ref.read(windowServiceProvider).setAlwaysOnTop(true);
```

---

# 7. Structure du code (`lib/`)

```
lib/
├── main.dart
│
├── app/                    # Bootstrap : thème, routeur, providers racine
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/                   # Utilitaires transverses (sans logique métier)
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   └── utils/
│
├── domain/                 # Cœur métier — AUCUNE dépendance Flutter/Supabase
│   ├── entities/
│   ├── repositories/       # Interfaces abstraites
│   └── services/           # Logique métier pure (dates, catégories, etc.)
│
├── application/            # Use cases (CreateTask, CompleteTask, SyncTasks…)
│   ├── tasks/
│   ├── sync/
│   ├── reminders/
│   └── authentication/
│
├── data/                   # Implémentations concrètes
│   ├── local/              # Drift / SQLite
│   ├── remote/             # Supabase
│   ├── models/             # DTOs (mapping entité ↔ DB)
│   └── repositories/       # Implémentations des interfaces domain
│
├── features/               # UI organisée par fonctionnalité
│   ├── home/
│   ├── tasks/
│   ├── quick_add/
│   ├── floating_bubble/    # Windows uniquement
│   ├── settings/
│   └── authentication/
│
└── platform/               # Code natif par OS (derrière des interfaces)
    ├── windows/
    ├── android/
    └── ios/
```

---

# 8. Modèle de domaine

## 8.1 Entité `Task`

```
Task
├── id              UUID — généré localement dès la création
├── userId          null si pas encore connecté
├── title           obligatoire
├── status          active | completed | deleted
├── category        must_do | today | next | someday  (identifiant stable)
├── plannedDate     date seule, sans heure (optionnel)
├── reminderAt      date + heure (optionnel)
├── createdAt
├── updatedAt
├── completedAt
├── sortOrder
├── syncVersion
└── deletedAt       soft delete pour la synchronisation
```

## 8.2 Catégories

Les **identifiants internes** ne changent jamais. Seuls les **libellés affichés** sont personnalisables.

| Identifiant | Libellé par défaut |
|---|---|
| `must_do` | BOUGE TON GROS CUL |
| `today` | AUJOURD'HUI |
| `next` | ENSUITE |
| `someday` | À FAIRE SI J'AI LE TEMPS |

## 8.3 Règle critique : catégorie persistée vs catégorie affichée

Une tâche avec `category = next` et `plannedDate = aujourd'hui` s'**affiche** dans AUJOURD'HUI mais sa catégorie **persistée** reste `next`.

Cette logique vit **uniquement** dans `domain/services/task_display_service.dart` (nom indicatif). Elle ne doit jamais être dupliquée dans les widgets.

Priorité d'affichage (à centraliser) :

```
1. Terminée
2. En retard (plannedDate < today, status active)
3. Urgente manuelle (must_do)
4. Prévue aujourd'hui (plannedDate == today)
5. Catégorie manuelle next
6. Catégorie manuelle someday
```

## 8.4 Date ≠ Rappel

- `plannedDate` = « je prévois cette tâche ce jour-là » (pas de notification automatique)
- `reminderAt` = « préviens-moi à ce moment » (notification système)

---

# 9. Persistance locale

## 9.1 Choix recommandé : Drift (SQLite)

| Critère | Drift |
|---|---|
| Type | SQLite avec génération de code Dart type-safe |
| Offline | Natif |
| Migrations | Supportées |
| Plateformes | Windows, Android, iOS |
| Testabilité | Base en mémoire pour les tests |

**Statut :** FIGÉ — voir ADR-007 dans `docs/decisions.md`.

## 9.2 Principe local-first

```
Action utilisateur
    ↓
Écriture SQLite immédiate
    ↓
UI mise à jour (instantané)
    ↓
Opération ajoutée à la file de sync
    ↓
Envoi Supabase (quand réseau disponible)
```

L'utilisateur ne doit **jamais** attendre le serveur pour voir sa tâche.

---

# 10. Synchronisation (vue d'ensemble)

Le détail complet sera dans `docs/synchronization.md` (P4+).

## 10.1 File locale

```
SyncOperation
├── id
├── entityId
├── entityType        (ex: "task")
├── operation         create | update | complete | delete
├── payload
├── createdAt
├── retryCount
└── status            pending | sent | failed
```

## 10.2 Stratégie de conflit (MVP)

**Last Write Wins** basé sur `updatedAt`, avec protection des opérations locales non synchronisées.

Les suppressions utilisent `deletedAt` (soft delete) pour propager la suppression aux autres appareils.

## 10.3 Fusion première connexion

Les UUID sont générés localement. À la première connexion :

- UUID absent du cloud → upload
- UUID déjà présent → comparaison `updatedAt`
- **Les données locales ne sont jamais supprimées silencieusement**

## 10.4 Mode sans compte

```
Installation → création de tâches → stockage local uniquement
Connexion ultérieure → fusion locale + cloud
```

---

# 11. Backend : Supabase

## 11.1 Pourquoi Supabase pour MYA

| Besoin MYA | Supabase |
|---|---|
| Auth multi-fournisseur (Google/Apple/Microsoft) | ✅ SDK Flutter officiel |
| Base relationnelle (tâches structurées) | ✅ PostgreSQL |
| Sécurité par utilisateur | ✅ Row Level Security |
| Sync quasi temps réel | ✅ Realtime |
| Coût MVP faible | ✅ Tier gratuit généreux |
| Évolutivité commerciale | ✅ Self-hostable, pricing prévisible |

## 11.2 Alternatives évaluées

| Solution | Avantage | Inconvénient pour MYA |
|---|---|---|
| **Firebase** | Mature, bon SDK | NoSQL (moins adapté aux tâches relationnelles), vendor lock-in Google |
| **Appwrite** | Open source | Écosystème Flutter moins mature, moins de références production |
| **Backend custom** | Contrôle total | Coût et temps de dev élevés pour un solo dev |
| **Supabase self-hosted** | Pas de dépendance SaaS | Ops supplémentaires — option si le SaaS devient trop cher |

**Décision :** Supabase est retenu pour le MVP. La migration vers self-hosted reste possible (PostgreSQL standard). Réévaluation avant mise en vente commerciale.

## 11.3 Ce que Supabase ne doit PAS faire

- Supabase n'est **pas** la source de lecture de l'UI
- Les widgets ne appellent **jamais** Supabase directement
- Le serveur ne déclenche **pas** les notifications locales (c'est le rôle de l'appareil)

---

# 12. Gestion d'état : Riverpod

## 12.1 Pourquoi Riverpod

| Critère | Riverpod |
|---|---|
| Courbe d'apprentissage | Modérée, documentation excellente |
| Testabilité | Providers facilement mockables |
| Architecture | S'intègre naturellement avec Repository pattern |
| Rebuilds UI | Granulaires (pas de rebuild inutile) |
| Communauté | Large, active en 2026 |

**Statut :** FIGÉ — voir ADR-006 dans `docs/decisions.md`.

## 12.2 Organisation des providers

```
tasksProvider              → liste des tâches actives
taskRepositoryProvider     → injection du repository
syncServiceProvider        → service de synchronisation
settingsProvider           → préférences utilisateur
windowServiceProvider      → pastille Windows (Windows only)
```

**Règle :** un provider par responsabilité. Pas de `AppStateProvider` géant.

---

# 13. Pastille Windows

Fonctionnalité la plus distinctive et la plus risquée techniquement.

## 13.1 Architecture

```
FloatingBubbleWidget (Flutter)
        ↓
FloatingBubbleController
        ↓
WindowService (interface)
        ↓
WindowsWindowService (implémentation)
        ↓
API Windows native / plugin
```

## 13.2 Responsabilités de `WindowService`

- Position et taille de la fenêtre
- Always-on-Top
- Visibilité (masquage)
- Ancrage aux bords de l'écran
- Mémorisation de la position
- Ouverture/fermeture du panneau

## 13.3 Position par défaut

- Côté gauche ou droit de l'écran
- Environ 80 % de la hauteur
- Configurable par l'utilisateur

## 13.4 Raccourci global

Défaut : `Ctrl + Alt + Space` → ouvre la création rapide.

Implémentation via `hotkey_manager` ou plugin natif Windows, derrière `HotkeyService`.

## 13.5 Critères de validation du prototype (P5)

- Pastille stable, ne gêne pas l'utilisation Windows
- Déplacement et ancrage fonctionnels
- Panneau s'ouvre rapidement
- Always-on-Top fonctionne
- Raccourci global fonctionne
- Une seule instance de l'application
- Consommation CPU/mémoire raisonnable

---

# 14. Mobile

## 14.1 Écran principal

Priorité : champ de saisie visible immédiatement.

```
+ Ajouter un pense-bête
[________________________]
```

## 14.2 Notifications

Abstraites derrière `NotificationService` :

```dart
abstract class NotificationService {
  Future<void> scheduleReminder(Task task);
  Future<void> cancelReminder(String taskId);
}
```

## 14.3 Widgets (post-MVP)

Les widgets Android/iOS sont des composants **natifs** (pas des widgets Flutter). Ils lisent un stockage partagé avec l'app principale. Détails dans `docs/android.md` et `docs/ios.md` (à créer).

---

# 15. Design et thème

Pas d'identité graphique définie. Le MVP utilise un **thème minimal et efficace** :

- Fond sombre ou clair selon préférence système
- Typographie système (pas de police custom au MVP)
- Couleurs par catégorie (rouge/orange/jaune/gris) — sobres
- Pas d'animations complexes au MVP
- Interface épurée : liste + saisie, rien de superflu

Le fichier `lib/app/theme.dart` centralise toutes les constantes visuelles.

---

# 16. Conventions de code et lisibilité

Ce projet est développé avec l'aide de Cursor par un développeur **non spécialiste Flutter**. Le code doit rester compréhensible sans lire des milliers de lignes.

## 16.1 Commentaires obligatoires

Chaque fichier commence par un en-tête :

```dart
/// Gère l'affichage des tâches par catégorie.
///
/// Responsabilité : calculer dans quelle section afficher une tâche
/// (ex: une tâche "next" avec date = aujourd'hui → section AUJOURD'HUI).
///
/// Ne pas mettre de logique d'affichage ici — seulement le calcul de catégorie.
```

Chaque classe publique a un commentaire `///` expliquant son rôle en une phrase.

## 16.2 Nommage

| Élément | Convention | Exemple |
|---|---|---|
| Fichiers | snake_case | `task_repository.dart` |
| Classes | PascalCase | `TaskRepository` |
| Variables | camelCase | `plannedDate` |
| Constantes | camelCase ou SCREAMING | `defaultReminderDuration` |
| Providers | nom + Provider | `tasksProvider` |

## 16.3 Taille des fichiers

- **Maximum ~200 lignes** par fichier (sauf généré)
- Si un fichier dépasse 150 lignes → envisager de le découper
- Un widget = une responsabilité visuelle

## 16.4 Pas de magie

```dart
// ❌ Éviter — logique métier cachée dans le widget
class TaskCard extends StatelessWidget {
  Widget build(context) {
    final isOverdue = task.plannedDate!.isBefore(DateTime.now()); // logique ici
  }
}

// ✅ Préférer — logique dans le domaine, widget simple
class TaskCard extends ConsumerWidget {
  Widget build(context, ref) {
    final displayState = ref.watch(taskDisplayStateProvider(task.id));
    // le widget ne fait qu'afficher displayState
  }
}
```

## 16.5 Tests des règles métier

Les services du domaine (`TaskDisplayService`, `TaskDateService`, etc.) doivent avoir des tests unitaires **sans lancer l'UI Flutter**.

---

# 17. Sécurité

- Toutes les données cloud protégées par **Supabase Auth + RLS**
- Principe RLS : `user_id = auth.uid()`
- Aucun secret dans le code source ou Git (`.env` local, non commité)
- Les logs ne contiennent jamais le contenu des tâches en production
- RGPD : minimisation des données, droit de suppression du compte

---

# 18. Ordre de développement

Ne **pas** commencer par Supabase. L'ordre validé :

```
1.  Projet Flutter + structure lib/
2.  Modèle Task + entités domaine
3.  Stockage local (Drift)
4.  Interface principale (liste par catégories)
5.  Création rapide
6.  Catégories + déplacement manuel
7.  Dates + logique AUJOURD'HUI / retard
8.  Tâches terminées + historique
9.  Rappels locaux (notifications)
10. Pastille Windows
11. Always-on-Top + barre système + démarrage auto
12. Paramètres
13. Authentification (Supabase)
14. Backend Supabase (tables, RLS, migrations)
15. Synchronisation offline-first
16. Application Android
17. Application iOS (si faisable)
--- post-MVP ---
18. Widgets mobile
19. Applications Windows associées
```

---

# 19. Documentation complémentaire

| Fichier | Contenu | Statut |
|---|---|---|
| `docs/functional-spec.md` | Cahier des charges fonctionnel | ✅ |
| `docs/technical-spec.md` | Cahier des charges technique | ✅ |
| `docs/architecture.md` | Ce document | ✅ |
| `docs/decisions.md` | Choix techniques figés (ADR-001 à ADR-025) | ✅ |
| `docs/database.md` | Schéma tables, mapping local ↔ cloud | ✅ |
| `docs/synchronization.md` | Stratégie sync détaillée | ✅ |
| `docs/windows.md` | Spécificités pastille Windows | ✅ P5 |
| `docs/android.md` | Spécificités Android | ⏳ Avant D16 |
| `docs/ios.md` | Spécificités iOS | ⏳ Avant D17 |
| `docs/deployment.md` | Publication stores | ⏳ Avant bêta |

---

# 20. Règles pour Cursor

Avant toute modification importante :

1. Lire `docs/architecture.md`
2. Lire le document fonctionnel pertinent
3. Vérifier `docs/decisions.md`
4. Identifier les couches concernées
5. Modifier uniquement les fichiers nécessaires
6. Ajouter des commentaires `///` sur le code nouveau
7. Produire des tests pour les règles métier
8. Signaler les incertitudes techniques

**Cursor ne doit jamais décider seul de :**
- Remplacer Flutter, Supabase, Drift ou Riverpod
- Modifier le modèle de synchronisation
- Ajouter une fonctionnalité hors MVP sans demande explicite
- Créer un service monolithique (`AppManager`, `GlobalState`, etc.)

---

# 21. Décisions validées vs en attente

## Validées (2026-08-23)

| Décision | Choix |
|---|---|
| Framework | Flutter / Dart |
| Priorité plateformes | Windows → Android → iOS (conditionnel) |
| Architecture | Local-first + sync cloud |
| Backend MVP | Supabase |
| Auth | Google / Apple / Microsoft |
| Pastille Windows | Oui, cœur du produit |
| Widgets mobile | Post-MVP |
| Apps Windows associées | Post-MVP |
| Sous-tâches / récurrence / projets | Non |
| Design | Thème minimal, pas d'identité graphique au MVP |
| Compte | Optionnel (local sans compte possible) |
| Gestion d'état | Riverpod |
| Base locale | Drift / SQLite |
| Fenêtres Windows | window_manager |
| Raccourcis globaux | hotkey_manager |
| Barre système Windows | tray_manager |
| Démarrage auto Windows | launch_at_startup |
| Instance unique | flutter_alone |
| Notifications | flutter_local_notifications |
| Navigation | go_router |
| Conflits sync | Last Write Wins (updatedAt) |
| Survol pastille | Aperçu 400 ms / clic = panneau complet |

## En attente (avant publication)

| Point | Livrable |
|---|---|
| Politique confidentialité | Avant publication (ADR-025) |
| Modèle économique | Avant bêta (ADR-024) |

---

# 22. Règle finale

L'architecture de MYA repose sur quatre piliers :

1. **Local-first** — fonctionne sans Internet
2. **Multiplateforme** — maximum de code partagé
3. **Native quand nécessaire** — pastille, notifications, widgets
4. **Simplicité** — l'utilisateur voit une pastille, des tâches, et un moyen rapide de s'en souvenir

> Une petite pastille, quelques tâches, et zéro usine à gaz.
