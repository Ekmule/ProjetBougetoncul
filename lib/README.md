# Structure du code MYA (`lib/`)

Ce dossier suit l'architecture décrite dans [`docs/architecture.md`](../docs/architecture.md).

## Couches

| Dossier | Rôle |
|---|---|
| `app/` | Bootstrap, thème, routeur go_router |
| `core/` | Constantes, erreurs, extensions, utilitaires |
| `domain/` | Entités et interfaces — **sans Flutter ni Supabase** |
| `application/` | Use cases Riverpod (tasks, sync, auth…) |
| `data/` | Drift, Supabase, implémentations des repositories |
| `features/` | UI par fonctionnalité |
| `platform/` | Code natif Windows / Android / iOS |

## Règle de dépendance

```
features → application → domain ← data
                ↑
            platform (via interfaces)
```

Les widgets ne parlent jamais directement à SQLite, Supabase ou `window_manager`.

## Phase D1 (actuelle)

- Structure complète + stubs pour les phases futures
- Navigation via `go_router`
- Prototype Windows (pastille) conservé dans `features/floating_bubble/`

## Phase D2

- Entité `Task` complète (Equatable, sync, soft delete)
- Enums `TaskStatus`, `SyncStatus`, `TaskCategoryId` + mapping DB
- Factory `Task.createNew`, méthodes `complete()`, `softDelete()`, `touch()`
- Tests unitaires domaine dans `test/domain/`

## Phase D3

- Drift/SQLite : tables `tasks`, `sync_operations`, `user_settings`
- `DriftTaskRepository` + `TaskMapper` + `DateCodec`
- `TasksNotifier` lit/écrit via le repository (stream réactif)
- Seed au premier lancement via `DatabaseSeeder`

## Phase D4

- `TasksScreen` — interface principale plein écran (Android)
- Widgets partagés : `TaskCategoryList`, `TaskListTile`
- `taskListStateProvider` — regroupement centralisé pour pastille + écran principal
- Pastille Windows réutilise les mêmes widgets via `TaskPanel`

## Phase D5

- Module `features/quick_add/` — formulaire unifié, options repliables
- `QuickAddPresenter` — dialogue (Windows) + bottom sheet (mobile FAB)
- `QuickAddInlineBar` — saisie inline 1 champ + Entrée
- Raccourci Ctrl+Alt+Space → dialogue enrichi

## Phase D6

- `TaskCategoryService` — déplacement manuel (catégorie persistée)
- Menu « Déplacer vers… » sur chaque tâche active
- `TasksNotifier.moveTaskToCategory()` — persistance Drift

## Phase D7

- `TaskDateService` — dates planifiées, retard, aujourd'hui
- Menu calendrier : Aujourd'hui, Demain, Choisir, Effacer
- Affichage `📅 25 août` + surbrillance retard
- Déplacement vers AUJOURD'HUI → `category` + `plannedDate` du jour

## Phase D8

- `TaskHistoryService` — rétention 7 jours max (configurable en D12)
- Section **TERMINÉES** filtrée + triée par date
- Purge automatique des tâches expirées (soft delete)
- **Réouvrir** une tâche terminée (clic sur ✓)

## Phase D9

- `TaskReminderService` — logique métier des rappels (`reminderAt`)
- `NotificationService` + `flutter_local_notifications` (ADR-013)
- `ReminderService` — synchronise DB ↔ notifications locales
- Menu cloche : Dans 1 h, Demain 9h, Choisir, Effacer
- Affichage `🔔 25 août à 14h00` + annulation auto si terminée/supprimée

## Phase D10

- `DeviceSettingsStore` — position pastille, visibilité, Always-on-Top (shared_preferences)
- `WindowsTrayService` — icône barre système + menu (ADR-010)
- `WindowsStartupService` — démarrage avec Windows (ADR-011, désactivé par défaut)
- Pastille masquable via tray, position restaurée au lancement

## Phase D11

- `AlwaysOnTopService` — bascule centralisée + persistance
- Réapplication AOT après resize/show (workaround `window_manager`)
- Clic en dehors → réduction panneau (ADR-018)
- Libellés FR « Toujours au-dessus » + bordure ambre sur la pastille

## Phase D12

- `GlobalHotkeyNotifier` — raccourci configurable (JSON en shared_preferences)
- `HotkeySettingsDialog` — enregistrement via `HotKeyRecorder`
- Menu tray « Raccourci : … » + libellé dynamique dans le panneau
- Défaut **Ctrl+Alt+Espace** (ADR-009)

## Phase D13 (actuelle)

- `AuthService` + `SupabaseAuthService` / `NoOpAuthService`
- OAuth Google, Apple, Microsoft via navigateur (PKCE + deep link)
- `AuthSettingsDialog` — connexion / déconnexion depuis le menu tray
- Mode local conservé sans compte ; clés via `--dart-define-from-file=.env.json`

## Prochaines phases

- Synchronisation : **D14–D15**
