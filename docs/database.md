# MYA — Schéma de base de données

**Projet :** MYA — Move Your Ass  
**Document :** Modèle de données local (Drift) et distant (Supabase)  
**Version :** 1.0  
**Dernière mise à jour :** 2026-08-23  
**Statut :** Référence pour l'implémentation D2–D3 et D14–D15

---

# 1. Vue d'ensemble : deux bases, deux rôles

MYA utilise **deux bases de données distinctes** qui ne doivent pas être confondues :

```
┌──────────────────────────────────────────────────────────────────┐
│  BASE LOCALE (Drift / SQLite)                                    │
│  Fichier sur le PC ou le téléphone de l'utilisateur            │
│                                                                  │
│  Rôle : source de vérité pour l'interface                      │
│  Utilisable : TOUJOURS, même sans Internet ni compte             │
│  Tables : tasks, user_settings, sync_operations                │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                    SyncService (optionnel)
                    uniquement si connecté + Internet
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│  BASE DISTANTE (Supabase / PostgreSQL)                           │
│  Serveur dans le cloud                                           │
│                                                                  │
│  Rôle : copie synchronisée entre appareils                       │
│  Utilisable : seulement avec compte + connexion                  │
│  Tables : tasks, user_settings                                   │
└──────────────────────────────────────────────────────────────────┘
```

| Question | Réponse |
|---|---|
| L'utilisateur a-t-il besoin de Supabase ? | **Non** — utilisation locale possible sans compte |
| Où sont les tâches affichées à l'écran ? | **Toujours depuis SQLite local** |
| À quoi sert Supabase ? | Sync entre PC et téléphone |
| Quand créer le projet Supabase ? | Avant D13 (auth), pas avant |

---

# 2. Diagramme des entités

```
┌─────────────────────┐         ┌─────────────────────┐
│       tasks         │         │   user_settings     │
├─────────────────────┤         ├─────────────────────┤
│ id (UUID) PK        │         │ user_id PK          │
│ user_id (nullable   │         │ category_labels...  │
│   en local)         │         │ humor_enabled       │
│ title               │         │ history_retention   │
│ status              │         │ notification_style  │
│ category            │         │ theme_preference    │
│ planned_date        │         │ updated_at          │
│ reminder_at         │         └─────────────────────┘
│ sort_order          │
│ sync_version        │         ┌─────────────────────┐
│ created_at          │         │  sync_operations    │
│ updated_at          │         │  (LOCAL UNIQUEMENT) │
│ completed_at        │         ├─────────────────────┤
│ deleted_at          │         │ id PK               │
│ sync_status         │         │ entity_type         │
└─────────────────────┘         │ entity_id           │
                                │ operation           │
┌─────────────────────┐         │ payload (JSON)      │
│  device_settings    │         │ status              │
│  (shared_preferences│         │ retry_count         │
│   UNIQUEMENT)       │         │ created_at          │
├─────────────────────┤         └─────────────────────┘
│ bubble_x, bubble_y  │
│ always_on_top       │
│ startup_enabled     │
│ global_hotkey       │
│ theme (optionnel)   │
└─────────────────────┘
```

---

# 3. Table `tasks`

Stocke les pense-bêtes. Présente en **local (Drift)** et **distant (Supabase)**.

## 3.1 Colonnes

| Colonne | Type local (Drift) | Type distant (PostgreSQL) | Nullable | Description |
|---|---|---|---|---|
| `id` | `TEXT` (UUID) | `UUID` | Non | Identifiant global, généré localement à la création |
| `user_id` | `TEXT` | `UUID` | Oui (local) / Non (cloud) | `NULL` tant que l'utilisateur n'est pas connecté |
| `title` | `TEXT` | `TEXT` | Non | Texte de la tâche |
| `status` | `TEXT` | `task_status` ENUM | Non | `active`, `completed`, `deleted` |
| `category` | `TEXT` | `task_category` ENUM | Non | `must_do`, `today`, `next`, `someday` |
| `planned_date` | `TEXT` | `DATE` | Oui | Date seule, format `YYYY-MM-DD` |
| `reminder_at` | `INTEGER` (ms epoch) | `TIMESTAMPTZ` | Oui | Date+heure du rappel, en UTC côté serveur |
| `sort_order` | `INTEGER` | `INTEGER` | Non | Ordre d'affichage dans une catégorie |
| `sync_version` | `INTEGER` | `INTEGER` | Non | Incrémenté à chaque modification locale |
| `created_at` | `INTEGER` (ms epoch) | `TIMESTAMPTZ` | Non | Date de création |
| `updated_at` | `INTEGER` (ms epoch) | `TIMESTAMPTZ` | Non | Dernière modification (utilisé pour LWW) |
| `completed_at` | `INTEGER` (ms epoch) | `TIMESTAMPTZ` | Oui | Date de complétion |
| `deleted_at` | `INTEGER` (ms epoch) | `TIMESTAMPTZ` | Oui | Soft delete pour la sync |
| `sync_status` | `TEXT` | — | Non | **Local uniquement** : `synced`, `pending`, `failed` |

## 3.2 Règles métier

- `title` ne peut pas être vide après trim
- `status = completed` implique `completed_at` renseigné
- `status = deleted` implique `deleted_at` renseigné
- `category = today` peut être persistée si l'utilisateur déplace manuellement une tâche dans AUJOURD'HUI
- L'affichage dans AUJOURD'HUI peut aussi être **calculé** sans modifier `category` (voir `TaskDisplayService`)

## 3.3 Index locaux (Drift)

```sql
CREATE INDEX idx_tasks_status ON tasks(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_sync_status ON tasks(sync_status) WHERE sync_status = 'pending';
CREATE INDEX idx_tasks_planned_date ON tasks(planned_date) WHERE status = 'active';
```

## 3.4 Ce qui n'est PAS dans `tasks` (reporté post-MVP)

Les colonnes suivantes du cahier technique initial sont **volontairement absentes** au MVP :

```
application_path    → post-MVP (ADR-021)
application_name    → post-MVP
application_icon    → post-MVP
```

---

# 4. Table `user_settings`

Préférences synchronisées entre appareils. Une ligne par utilisateur.

## 4.1 Colonnes

| Colonne | Type | Défaut | Description |
|---|---|---|---|
| `user_id` | UUID / TEXT | — | Clé primaire, liée à `auth.users` |
| `category_label_must_do` | TEXT | `BOUGE TON GROS CUL` | Libellé personnalisé |
| `category_label_today` | TEXT | `AUJOURD'HUI` | Libellé personnalisé |
| `category_label_next` | TEXT | `ENSUITE` | Libellé personnalisé |
| `category_label_someday` | TEXT | `À FAIRE SI J'AI LE TEMPS` | Libellé personnalisé |
| `humor_enabled` | BOOLEAN | `true` | Ton humoristique activé |
| `history_retention_days` | INTEGER | `7` | Durée conservation historique (max 7) |
| `notification_style` | TEXT | `normal` | `normal`, `humorous`, `brutal` |
| `theme_preference` | TEXT | `system` | `system`, `light`, `dark` |
| `updated_at` | TIMESTAMPTZ | `now()` | Pour LWW sur les paramètres |

## 4.2 Comportement

- Créée automatiquement à l'inscription (trigger Supabase)
- En local : une ligne avec `user_id = NULL` tant que pas connecté ; remplacée/fusionnée à la connexion
- Les libellés de catégories sont synchronisés ; la logique interne (`must_do`, etc.) ne change pas

---

# 5. Table `sync_operations` (local uniquement)

File d'attente des modifications à envoyer au serveur. **N'existe pas sur Supabase.**

| Colonne | Type | Description |
|---|---|---|
| `id` | TEXT (UUID) | Identifiant de l'opération |
| `entity_type` | TEXT | `task` ou `user_settings` |
| `entity_id` | TEXT | UUID de l'entité concernée |
| `operation` | TEXT | `create`, `update`, `complete`, `delete` |
| `payload` | TEXT (JSON) | Snapshot de l'entité au moment de l'opération |
| `status` | TEXT | `pending`, `in_progress`, `sent`, `failed` |
| `retry_count` | INTEGER | Nombre de tentatives |
| `created_at` | INTEGER | Timestamp de création |
| `last_attempt_at` | INTEGER | Dernière tentative d'envoi |

## 5.1 Cycle de vie

```
Modification locale
    ↓
sync_operations.status = 'pending'
tasks.sync_status = 'pending'
    ↓
SyncService envoie au serveur
    ↓
Succès → status = 'sent', tasks.sync_status = 'synced'
Échec  → status = 'failed', retry_count++
```

---

# 6. Paramètres appareil (pas en base SQL)

Stockés dans **shared_preferences** uniquement (ADR-007). Jamais synchronisés.

| Clé | Type | Description |
|---|---|---|
| `bubble_x` | double | Position X pastille |
| `bubble_y` | double | Position Y pastille |
| `bubble_snap` | string | `free`, `snapLeft`, `snapRight` |
| `bubble_visible` | bool | Pastille affichée ou masquée |
| `always_on_top` | bool | Mode toujours au-dessus |
| `startup_enabled` | bool | Démarrage avec Windows |
| `global_hotkey` | string | JSON du raccourci configuré |
| `panel_expanded` | bool | Panneau ouvert ou réduit |

---

# 7. Schéma Drift (référence Dart)

Ce code sera implémenté dans `lib/data/local/database.dart` lors de D3.
Il est documenté ici comme référence.

```dart
/// Table des tâches — miroir local du modèle cloud.
/// L'UI lit TOUJOURS depuis cette table, jamais depuis Supabase directement.
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get status => text()();           // active | completed | deleted
  TextColumn get category => text()();         // must_do | today | next | someday
  TextColumn get plannedDate => text().nullable()();  // YYYY-MM-DD
  IntColumn get reminderAt => integer().nullable()();   // ms since epoch UTC
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// File de synchronisation — locale uniquement, jamais envoyée telle quelle au serveur.
class SyncOperations extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get lastAttemptAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Préférences utilisateur synchronisables.
class UserSettings extends Table {
  TextColumn get userId => text().nullable()();
  TextColumn get categoryLabelMustDo =>
      text().withDefault(const Constant('BOUGE TON GROS CUL'))();
  TextColumn get categoryLabelToday =>
      text().withDefault(const Constant('AUJOURD\'HUI'))();
  TextColumn get categoryLabelNext =>
      text().withDefault(const Constant('ENSUITE'))();
  TextColumn get categoryLabelSomeday =>
      text().withDefault(const Constant('À FAIRE SI J\'AI LE TEMPS'))();
  BoolColumn get humorEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get historyRetentionDays =>
      integer().withDefault(const Constant(7))();
  TextColumn get notificationStyle =>
      text().withDefault(const Constant('normal'))();
  TextColumn get themePreference =>
      text().withDefault(const Constant('system'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {userId};
}
```

---

# 8. Mapping local ↔ Supabase

## 8.1 Tasks

| Champ Drift | Champ Supabase | Conversion |
|---|---|---|
| `id` | `id` | UUID string ↔ UUID |
| `userId` | `user_id` | null local → défini à l'upload |
| `title` | `title` | direct |
| `status` | `status` | direct (enum) |
| `category` | `category` | direct (enum) |
| `plannedDate` | `planned_date` | `YYYY-MM-DD` ↔ DATE |
| `reminderAt` | `reminder_at` | ms epoch ↔ TIMESTAMPTZ UTC |
| `sortOrder` | `sort_order` | direct |
| `syncVersion` | `sync_version` | direct |
| `createdAt` | `created_at` | ms epoch ↔ TIMESTAMPTZ UTC |
| `updatedAt` | `updated_at` | ms epoch ↔ TIMESTAMPTZ UTC |
| `completedAt` | `completed_at` | ms epoch ↔ TIMESTAMPTZ UTC |
| `deletedAt` | `deleted_at` | ms epoch ↔ TIMESTAMPTZ UTC |
| `syncStatus` | — | local uniquement |

## 8.2 Conversion des dates

```dart
// Date seule (planned_date) — pas de fuseau horaire
String toPlannedDateString(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

// Timestamp avec heure — toujours UTC en stockage
int toUtcMillis(DateTime dt) => dt.toUtc().millisecondsSinceEpoch;
DateTime fromUtcMillis(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
```

---

# 9. Configuration Supabase — guide pas à pas

> Tu n'as pas besoin de faire cela maintenant si tu n'es pas encore à D13.
> Le SQL est prêt dans `supabase/migrations/001_initial_schema.sql`.

## Étape 1 — Créer le projet

1. [supabase.com](https://supabase.com) → **New project**
2. Nom : `mya-dev`
3. Région : **West EU (Paris)** si disponible
4. Mot de passe DB : génère et sauvegarde dans un gestionnaire de mots de passe

## Étape 2 — Exécuter le schéma SQL

1. **SQL Editor** → **New query**
2. Copier le contenu de [`supabase/migrations/001_initial_schema.sql`](../supabase/migrations/001_initial_schema.sql)
3. **Run**
4. Vérifier : **Table Editor** → tables `tasks` et `user_settings` visibles

## Étape 3 — Activer l'authentification OAuth (plus tard, D13)

Dans **Authentication → Providers** :

| Provider | À activer | Notes |
|---|---|---|
| Google | Oui | Client ID/Secret Google Cloud Console |
| Apple | Oui (pour iOS) | Apple Developer |
| Microsoft | Oui (pour Windows) | Azure AD app registration |

## Étape 4 — Récupérer les clés API

**Project Settings → API** :

```
Project URL  → SUPABASE_URL
anon public  → SUPABASE_ANON_KEY
```

Copier `.env.example` en `.env` et remplir les valeurs.

## Étape 5 — Vérifier RLS

Dans **Authentication → Policies**, confirmer que chaque table a des politiques actives.
Ou exécuter :

```sql
SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';
```

`rowsecurity` doit être `true` pour `tasks` et `user_settings`.

---

# 10. Migrations futures

Toute modification du schéma doit suivre ce processus :

1. Ajouter un fichier `supabase/migrations/00X_description.sql`
2. Mettre à jour le schéma Drift + migration Drift
3. Mettre à jour ce document
4. Ajouter une entrée dans `docs/decisions.md` si le changement est significatif

Format de nommage : `001_initial_schema.sql`, `002_add_field_xyz.sql`, etc.

---

# 11. Nettoyage et historique

| Règle | Valeur |
|---|---|
| Tâches terminées conservées | `history_retention_days` (défaut 7, max 7) |
| Soft delete (`deleted_at`) conservé | 30 jours avant purge physique locale |
| Purge serveur des soft deletes | 90 jours (configurable, job futur) |
| Tâches orphelines (user_id null local) | Rattachées à l'utilisateur à la première connexion |

Le nettoyage est effectué par `TaskHistoryService` (domaine), pas par la base directement.

---

# 12. Références

| Document | Contenu |
|---|---|
| [`synchronization.md`](synchronization.md) | Flux de sync, conflits, Realtime |
| [`decisions.md`](decisions.md) | ADR-007 (Drift), ADR-015/016 (LWW, fusion) |
| [`architecture.md`](architecture.md) | Couches et principes local-first |
| [`../supabase/migrations/001_initial_schema.sql`](../supabase/migrations/001_initial_schema.sql) | SQL à exécuter dans Supabase |
