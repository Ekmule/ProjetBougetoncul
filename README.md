# MYA — Move Your Ass

Application de pense-bête multiplateforme (Windows, Android, iOS).

> Savoir rapidement ce qu'il faut faire, sans usine à gaz.

---

## État du projet

| Phase | Statut |
|---|---|
| Cahiers des charges | ✅ Terminé |
| Architecture | ✅ `docs/architecture.md` |
| Décisions techniques | ✅ `docs/decisions.md` (25 ADR) |
| Schéma base de données | ✅ `docs/database.md` + SQL Supabase |
| Synchronisation | ✅ `docs/synchronization.md` |
| Prototype Windows (P5) | ✅ Pastille fonctionnelle |
| **D1 — Scaffold Flutter** | ✅ Structure `lib/`, go_router, lint, CI |
| **D2 — Modèle domaine** | ✅ Entité `Task` complète + tests |
| **D3 — Drift (SQLite)** | ✅ Persistance locale + repository |
| **D4 — Interface principale** | ✅ Liste par catégories + widgets partagés |
| **D5 — Création rapide** | ✅ Module quick_add unifié |
| **D6 — Catégories + déplacement** | ✅ Menu déplacement manuel |
| **D7 — Dates + AUJOURD'HUI** | ✅ Dates planifiées + affichage auto |
| **D8 — Terminées + historique** | ✅ Rétention 7j + purge + réouverture |
| **D9 — Rappels locaux** | ✅ Notifications + menu cloche |
| **D10 — Pastille Windows** | ✅ Tray + persistance + démarrage auto |
| **D11 — Always-On-Top** | ✅ Service central + réapplication robuste |
| **D12 — Raccourci global** | ✅ Configurable + persistance JSON |
| **D13 — Authentification** | ✅ Supabase OAuth + mode local |
| D14 — Backend Supabase | ⏳ À venir |

---

## Documentation

Toute la documentation technique se trouve dans le dossier [`docs/`](docs/) :

| Fichier | Contenu |
|---|---|
| [`functional-spec.md`](docs/functional-spec.md) | Vision produit, UX, catégories, MVP fonctionnel |
| [`technical-spec.md`](docs/technical-spec.md) | Stack technique, modèle de données, ordre de dev |
| [`architecture.md`](docs/architecture.md) | **Référence architecturale** — à lire avant tout code |
| [`decisions.md`](docs/decisions.md) | 25 décisions techniques figées (ADR) |
| [`database.md`](docs/database.md) | Schéma Drift local + Supabase, guide configuration |
| [`windows.md`](docs/windows.md) | Prototype pastille Windows + guide lancement |

---

## Principes clés

1. **Local-first** — l'app fonctionne sans Internet
2. **Windows en premier** — la pastille flottante est le cœur du produit
3. **Simplicité** — 1 saisie + validation pour créer une tâche
4. **Pas d'usine à gaz** — pas de projets, sous-tâches, Kanban, gamification

---

## Ordre de développement

```
Préparation (docs, schéma, prototype Windows)
        ↓
App offline Windows complète
        ↓
Auth + synchronisation Supabase
        ↓
Android
        ↓
iOS (si faisable)
        ↓
Widgets mobile (post-MVP)
```

---

## Lancer l'application

**Prérequis :** Flutter dans `E:\flutter\bin` (pas dans un chemin avec accent), Visual Studio Build Tools, **Mode développeur** activé.

```powershell
cd E:\Project-Repo\ProjetBougetoncul
.\scripts\run-windows.ps1
```

Ou manuellement :

```powershell
$env:FLUTTER_ROOT = "E:\flutter"
$env:PUB_CACHE = "E:\pub-cache"
$env:Path = "E:\flutter\bin;" + $env:Path
flutter run -d windows
```

> Si ton profil Windows contient un accent (ex. `ékmule`), Flutter **ne doit pas** être dans `AppData\Local\flutter`.
> Voir [`docs/windows.md`](docs/windows.md) section 10.

Voir [`docs/windows.md`](docs/windows.md) pour le détail et le dépannage.

| Composant | Choix |
|---|---|
| Framework | Flutter / Dart |
| Base locale | Drift / SQLite |
| Gestion d'état | Riverpod |
| Navigation | go_router |
| Fenêtres Windows | window_manager |
| Backend | Supabase (PostgreSQL + Auth + Realtime) |
| Windows natif | Plugins pour pastille, Always-on-Top, raccourcis |

---

## Pour les développeurs (et Cursor)

Avant toute modification du code :

1. Lire [`docs/architecture.md`](docs/architecture.md)
2. Vérifier [`docs/decisions.md`](docs/decisions.md) *(quand disponible)*
3. Respecter les couches : `features → application → domain → data`
4. Ne jamais appeler Supabase ou l'API Windows directement depuis un widget

---

## Licence

À définir avant publication commerciale.
