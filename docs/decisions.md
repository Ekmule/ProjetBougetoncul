# MYA — Décisions techniques (ADR)

**Projet :** MYA — Move Your Ass  
**Document :** Architecture Decision Records  
**Version :** 1.0  
**Dernière mise à jour :** 2026-08-23  
**Statut :** Référence obligatoire — toute modification nécessite une nouvelle entrée ADR

---

# Comment lire ce document

Chaque décision suit le format :

| Champ | Description |
|---|---|
| **Décision** | Ce qui est choisi |
| **Contexte** | Pourquoi la question se pose |
| **Options** | Alternatives évaluées |
| **Choix** | Solution retenue |
| **Raison** | Justification |
| **Conséquences** | Impacts positifs et négatifs |
| **Date** | Quand la décision a été prise |

Les décisions marquées **FIGÉ** ne doivent pas être modifiées sans nouvelle entrée ADR datée.

---

# Table des décisions

| ID | Sujet | Statut |
|---|---|---|
| ADR-001 | Périmètre MVP | FIGÉ |
| ADR-002 | Priorité des plateformes | FIGÉ |
| ADR-003 | Framework Flutter | FIGÉ |
| ADR-004 | Architecture local-first | FIGÉ |
| ADR-005 | Backend Supabase | FIGÉ |
| ADR-006 | Gestion d'état Riverpod | FIGÉ |
| ADR-007 | Base locale Drift | FIGÉ |
| ADR-008 | Fenêtres Windows | FIGÉ |
| ADR-009 | Raccourcis globaux | FIGÉ |
| ADR-010 | Barre système Windows | FIGÉ |
| ADR-011 | Démarrage automatique Windows | FIGÉ |
| ADR-012 | Instance unique Windows | FIGÉ |
| ADR-013 | Notifications locales | FIGÉ |
| ADR-014 | Navigation go_router | FIGÉ |
| ADR-015 | Conflits de synchronisation | FIGÉ |
| ADR-016 | Fusion première connexion | FIGÉ |
| ADR-017 | Priorité d'affichage des catégories | FIGÉ |
| ADR-018 | Comportement survol pastille | FIGÉ |
| ADR-019 | Design UI minimal | FIGÉ |
| ADR-020 | Widgets mobile | FIGÉ (reporté) |
| ADR-021 | Apps Windows associées | FIGÉ (reporté) |
| ADR-022 | Packages utilitaires | FIGÉ |
| ADR-023 | Schéma PostgreSQL | FIGÉ |
| ADR-024 | Modèle économique | EN ATTENTE → avant publication |
| ADR-025 | Politique de confidentialité | EN ATTENTE → avant publication |

---

# ADR-001 — Périmètre MVP

**Décision :** Le MVP couvre Windows complet + Android + sync. iOS est conditionnel. Widgets et apps `.exe` sont hors MVP.

**Contexte :** Accélérer le time-to-market tout en livrant le différenciateur principal (pastille Windows).

**Options :**
1. MVP complet multi-plateforme avec widgets
2. Windows seul puis mobile
3. Windows + Android + sync, reste reporté

**Choix :** Option 3

**Raison :** La pastille Windows est le cœur du produit. Android est plus accessible à développer que iOS. Widgets et association `.exe` ajoutent de la complexité native sans être indispensables à la validation du concept.

**Conséquences :**
- (+) Livraison plus rapide
- (+) Risque technique réduit au MVP
- (−) iOS et widgets arrivent plus tard

**Date :** 2026-08-23

---

# ADR-002 — Priorité des plateformes

**Décision :** Ordre de développement : **Windows → Android → iOS (si faisable)**.

**Contexte :** Ressources limitées (développeur solo). iOS nécessite macOS + compte Apple Developer.

**Options :**
1. Développement parallèle des 3 plateformes
2. Windows d'abord, puis mobile
3. Mobile d'abord

**Choix :** Option 2 — Windows en priorité absolue

**Raison :** La pastille flottante n'existe que sur Windows. C'est la fonctionnalité la plus distinctive et la plus risquée — elle doit être validée en prototype (P5) avant d'investir ailleurs.

**Conséquences :**
- (+) Validation du risque principal en premier
- (−) Pas de version mobile avant plusieurs livrables Windows

**Date :** 2026-08-23

---

# ADR-003 — Framework Flutter

**Décision :** **Flutter / Dart** comme framework unique.

**Contexte :** Besoin multi-plateforme (Windows, Android, iOS) avec UI commune.

**Options :** Flutter, .NET MAUI, React Native, Godot, natif par plateforme

**Choix :** Flutter

**Raison :** Support officiel Windows/Android/iOS, une base de code UI, écosystème mature pour apps utilitaires, plugins desktop disponibles. Godot écarté (outil de jeu, pas adapté aux intégrations système).

**Conséquences :**
- (+) ~70-80 % de code partagé estimé
- (−) Intégrations natives Windows nécessitent des plugins tiers (pas d'API SDK officielle fenêtres)

**Date :** 2026-08-23 (confirmé P3)

---

# ADR-004 — Architecture local-first

**Décision :** Toute action utilisateur s'écrit **d'abord en local** (SQLite), puis en file de sync.

**Contexte :** MYA doit fonctionner sans Internet. L'utilisateur ne doit jamais attendre le serveur.

**Options :**
1. Cloud-first (Supabase comme source de vérité)
2. Local-first avec sync
3. Local uniquement (pas de sync au MVP)

**Choix :** Option 2

**Raison :** Exigence fonctionnelle et technique. La sync est un ajout, pas le fondement.

**Conséquences :**
- (+) UX instantanée, offline natif
- (−) Complexité sync à gérer (file locale, conflits, fusion)

**Date :** 2026-08-23

---

# ADR-005 — Backend Supabase

**Décision :** **Supabase** comme backend MVP (Auth + PostgreSQL + Realtime + RLS).

**Contexte :** Besoin d'auth multi-fournisseur, base relationnelle, sync quasi temps réel, coût faible au démarrage, projet destiné à une mise en vente ultérieure.

**Options :**

| Solution | Pour | Contre |
|---|---|---|
| **Supabase** | PostgreSQL, RLS, SDK Flutter, tier gratuit, self-hostable | Dépendance SaaS (mitigée par self-host) |
| Firebase | Mature, bon SDK | NoSQL, vendor lock-in Google, moins adapté aux tâches relationnelles |
| Appwrite | Open source | Écosystème Flutter moins mature |
| Backend custom (Node/Go) | Contrôle total | Coût et temps de dev élevés pour un solo dev |

**Choix :** Supabase

**Raison :**
- PostgreSQL standard → migration self-hosted possible si le SaaS devient trop cher
- Row Level Security native → sécurité par utilisateur sans backend custom
- SDK Flutter officiel couvre Auth, DB et Realtime
- Tier gratuit suffisant pour développement et premiers utilisateurs
- Compatible avec une commercialisation (données utilisateur isolées, suppression de compte)

**Conséquences :**
- (+) Backend opérationnel rapidement, pas de serveur à maintenir au MVP
- (+) Réévaluation possible vers self-hosted avant montée en charge
- (−) Configuration OAuth (Google/Apple/Microsoft) par plateforme
- (−) Les widgets n'appellent jamais Supabase directement (règle architecturale)

**Réévaluation :** Avant mise en vente commerciale, recalculer les coûts Supabase selon le nombre d'utilisateurs prévu.

**Date :** 2026-08-23

---

# ADR-006 — Gestion d'état : Riverpod

**Décision :** **flutter_riverpod** (+ **riverpod_annotation** / **riverpod_generator** optionnels pour la génération de code).

**Contexte :** Besoin d'une gestion d'état testable, compatible avec le pattern Repository, compréhensible pour un développeur non spécialiste Flutter.

**Options :**

| Solution | Pour | Contre |
|---|---|---|
| **Riverpod** | Testable, compile-safe, granulaire, doc excellente | Courbe d'apprentissage modérée |
| Bloc | Très structuré, patterns clairs | Plus verbeux, boilerplate |
| Provider | Simple | Moins puissant, pas de compile-time safety |
| GetX | Rapide à démarrer | Architecture moins rigoureuse, déconseillé pour projets maintenables |

**Choix :** Riverpod

**Raison :**
- S'intègre naturellement avec Repository pattern et injection de dépendances
- Rebuilds UI granulaires (performance)
- Providers facilement mockables pour les tests
- Large communauté et documentation en 2026
- `ConsumerWidget` / `ConsumerStatefulWidget` rendent le lien UI ↔ état explicite et lisible

**Packages :**
```yaml
dependencies:
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x   # optionnel

dev_dependencies:
  riverpod_generator: ^2.x    # optionnel
  build_runner: ^2.x           # si génération activée
```

**Conséquences :**
- (+) Code testable et structuré
- (−) Nécessite de comprendre le concept de `Provider` (documenté dans le code avec commentaires `///`)

**Date :** 2026-08-23

---

# ADR-007 — Base locale : Drift

**Décision :** **Drift** (SQLite) pour le stockage local principal.

**Contexte :** Besoin d'une base locale transactionnelle, typée, avec migrations, fonctionnant sur Windows/Android/iOS.

**Options :**

| Solution | Pour | Contre |
|---|---|---|
| **Drift** | Type-safe, migrations, requêtes SQL + Dart, tests en mémoire | Génération de code (`build_runner`) |
| sqflite | Simple, léger | Pas type-safe, pas de migrations élégantes |
| Hive/Isar | Rapide, NoSQL | Moins adapté aux relations et requêtes structurées |
| shared_preferences | Très simple | Limité aux clé-valeur, pas pour les tâches |

**Choix :** Drift pour les tâches et paramètres utilisateur synchronisables. **shared_preferences** pour les paramètres appareil uniquement (position pastille, Always-on-Top, etc.).

**Packages :**
```yaml
dependencies:
  drift: ^2.x
  sqlite3_flutter_libs: ^0.5.x
  path_provider: ^2.x
  path: ^1.x
  shared_preferences: ^2.x

dev_dependencies:
  drift_dev: ^2.x
  build_runner: ^2.x
```

**Raison :**
- SQLite est mature et adapté aux données structurées (tâches, file de sync)
- Drift génère du code Dart type-safe → moins d'erreurs runtime
- Migrations versionnées pour les évolutions du schéma
- Base en mémoire disponible pour les tests unitaires

**Conséquences :**
- (+) Requêtes complexes (tri, filtre par catégorie) faciles
- (−) `build_runner` à lancer après modification du schéma (`dart run build_runner build`)

**Date :** 2026-08-23

---

# ADR-008 — Fenêtres Windows : window_manager

**Décision :** **window_manager** pour la gestion de la fenêtre pastille (taille, position, Always-on-Top, frameless, masquage).

**Contexte :** La pastille MYA est une fenêtre Flutter frameless, petite, déplaçable, toujours au-dessus optionnel. C'est le risque technique n°1.

**Options :**

| Solution | Pour | Contre |
|---|---|---|
| **window_manager** | Actif, API complète, Always-on-Top, frameless, position, événements | Bugs startup sur certaines versions Flutter (workarounds connus) |
| bitsdojo_window | Custom frame, hide on startup | Moins maintenu (~9 mois sans release), modifie `main.cpp` |
| desktop_multi_window | Multi-fenêtres | Complexité inutile si une seule fenêtre redimensionnable |
| Plugin natif custom | Contrôle total | Temps de dev élevé, maintenance lourde |

**Choix :** `window_manager` — **une seule fenêtre** qui change de taille (pastille ↔ panneau).

**Raison :**
- Écosystème leanflutter cohérent avec `hotkey_manager` et `tray_manager`
- API documentée : `setAlwaysOnTop`, `setPosition`, `setSize`, `TitleBarStyle.hidden`, `skipTaskbar`
- Pas de modification invasive du `main.cpp` (contrairement à bitsdojo)
- Le prototype P5 validera la stabilité ; si insuffisant → plugin natif C++ isolé derrière `WindowService`

**Workaround connu :** Distorsion au démarrage sur certaines versions Flutter Windows → appliquer le workaround documenté (léger ajustement de taille post-frame) si nécessaire en P5.

**Package :**
```yaml
dependencies:
  window_manager: ^0.5.x
```

**Conséquences :**
- (+) Développement rapide de la pastille
- (−) Dépendance à un plugin tiers non officiel Flutter SDK
- (−) Validation obligatoire en prototype P5 avant de continuer

**Date :** 2026-08-23

---

# ADR-009 — Raccourcis globaux : hotkey_manager

**Décision :** **hotkey_manager** pour le raccourci global `Ctrl + Alt + Space`.

**Contexte :** Le raccourci doit fonctionner même quand MYA n'est pas la fenêtre active.

**Options :** hotkey_manager, intégration Win32 custom, raccourci in-app seulement

**Choix :** hotkey_manager (scope système)

**Raison :** Support Windows confirmé, même écosystème leanflutter, API simple (`register` / `unregister`).

**Package :**
```yaml
dependencies:
  hotkey_manager: ^0.2.x
```

**Raccourci par défaut :** `Ctrl + Alt + Space` → ouvre la création rapide.

**Conséquences :**
- (+) Fonctionne en arrière-plan
- (−) Le raccourci peut entrer en conflit avec d'autres apps (configurable ultérieurement)

**Date :** 2026-08-23

---

# ADR-010 — Barre système Windows : tray_manager

**Décision :** **tray_manager** pour l'icône dans la zone de notification Windows.

**Contexte :** MYA doit rester accessible quand la pastille est masquée (ouvrir, masquer, Always-on-Top, quitter).

**Options :** tray_manager, intégration Win32 custom, pas de tray (seulement pastille)

**Choix :** tray_manager

**Menu contextuel minimum :**
- Ouvrir MYA
- Afficher / masquer la pastille
- Always-on-Top on/off
- Quitter

**Package :**
```yaml
dependencies:
  tray_manager: ^0.5.x
```

**Conséquences :**
- (+) Accès permanent même pastille masquée
- (−) Nécessite une icône `.ico` dans les assets

**Date :** 2026-08-23

---

# ADR-011 — Démarrage automatique : launch_at_startup

**Décision :** **launch_at_startup** pour le démarrage avec Windows.

**Contexte :** Option activable/désactivable dans les paramètres. Démarrage silencieux (pastille seulement, pas de grande fenêtre).

**Options :** launch_at_startup, clé registre Windows custom, pas de démarrage auto au MVP

**Choix :** launch_at_startup

**Package :**
```yaml
dependencies:
  launch_at_startup: ^0.5.x
  package_info_plus: ^8.x   # requis pour setup
```

**Conséquences :**
- (+) API simple, compatible MSIX
- (−) Option désactivée par défaut (respect de l'utilisateur)

**Date :** 2026-08-23

---

# ADR-012 — Instance unique : flutter_alone

**Décision :** **flutter_alone** pour empêcher plusieurs instances de MYA.

**Contexte :** Critère de validation du prototype : aucune seconde instance ne doit être créée.

**Options :** flutter_alone, windows_single_instance, mutex Win32 custom

**Choix :** flutter_alone

**Raison :** Compatible explicitement avec `window_manager` sur Windows. Focus automatique sur la fenêtre existante si relancement.

**Package :**
```yaml
dependencies:
  flutter_alone: ^3.x
```

**Conséquences :**
- (+) Une seule pastille à l'écran
- (−) Configuration spécifique Windows à valider en P5

**Date :** 2026-08-23

---

# ADR-013 — Notifications : flutter_local_notifications

**Décision :** **flutter_local_notifications** pour les rappels sur toutes les plateformes.

**Contexte :** Les rappels sont des événements locaux. Le serveur synchronise la config, l'appareil déclenche la notification.

**Options :** flutter_local_notifications, awesome_notifications, APIs natives par plateforme

**Choix :** flutter_local_notifications

**Raison :** Package le plus utilisé, support Windows/Android/iOS, planification de notifications, bien documenté.

**Package :**
```yaml
dependencies:
  flutter_local_notifications: ^18.x
  timezone: ^0.9.x   # pour planification avec fuseau horaire
```

**Conséquences :**
- (+) Une abstraction pour les 3 plateformes
- (−) Configuration initiale par plateforme (canaux Android, permissions iOS)

**Date :** 2026-08-23

---

# ADR-014 — Navigation : go_router

**Décision :** **go_router** pour la navigation.

**Contexte :** Navigation déclarative, support deep links (utile pour auth OAuth callback).

**Options :**

| Solution | Pour | Contre |
|---|---|---|
| **go_router** | Officiel Flutter team, déclaratif, deep links | — |
| auto_route | Génération de code, typé | Plus complexe, `build_runner` supplémentaire |
| Navigator 1.0/2.0 manuel | Pas de dépendance | Verbeux, difficile à maintenir |

**Choix :** go_router

**Package :**
```yaml
dependencies:
  go_router: ^14.x
```

**Date :** 2026-08-23

---

# ADR-015 — Conflits de synchronisation : Last Write Wins

**Décision :** **Last Write Wins (LWW)** basé sur `updatedAt` pour le MVP.

**Contexte :** Deux appareils peuvent modifier la même tâche hors ligne.

**Options :**
1. Last Write Wins (`updatedAt` le plus récent gagne)
2. Merge champ par champ
3. Résolution manuelle par l'utilisateur

**Choix :** LWW avec règles spéciales pour les suppressions

**Règles déterministes :**

```
1. Si deletedAt est défini sur une version → la suppression gagne
   (sauf si la suppression locale est plus ancienne qu'une modification distante non vue)

2. Sinon → la version avec updatedAt le plus récent gagne intégralement

3. Les opérations locales non synchronisées (sync queue pending) ne sont jamais écrasées
   par une version distante plus ancienne

4. En cas d'égalité de updatedAt → l'appareil local conserve sa version
   (tie-breaker déterministe)
```

**Raison :** Simple, prévisible, suffisant pour un pense-bête solo. Pas de merge intelligent nécessaire au MVP.

**Conséquences :**
- (+) Logique centralisée dans `SyncConflictResolver`, testable
- (−) Perte possible d'une modification si deux appareils éditent simultanément hors ligne (acceptable au MVP)

**Évolution future :** Merge champ par champ si les retours utilisateurs le demandent.

**Date :** 2026-08-23

---

# ADR-016 — Fusion première connexion

**Décision :** Fusion par UUID sans suppression silencieuse.

**Contexte :** Un utilisateur peut avoir des tâches locales avant de se connecter.

**Algorithme :**

```
Pour chaque tâche locale (UUID local) :
  Si UUID absent du cloud → upload
  Si UUID présent dans le cloud → appliquer LWW (ADR-015)

Pour chaque tâche cloud (UUID non présent en local) :
  → import en local

Jamais :
  - supprimer des tâches locales sans action utilisateur explicite
  - écraser une tâche locale non synchronisée
```

**Raison :** Les UUID sont générés localement dès la création → pas de collision si l'utilisateur n'a jamais été connecté.

**Conséquences :**
- (+) Aucune perte de données à la première connexion
- (−) Possible duplication si l'utilisateur avait le même compte sur un autre appareil avec des tâches différentes (cas rare, géré par UUID)

**Date :** 2026-08-23

---

# ADR-017 — Priorité d'affichage des catégories

**Décision :** Règles de priorité figées pour le calcul de la section d'affichage.

**Contexte :** Une tâche peut avoir une catégorie persistée différente de sa section d'affichage (ex: `next` + date = aujourd'hui → affichée dans AUJOURD'HUI).

**Règles (dans l'ordre, première correspondance gagne) :**

```
1. status == completed        → section TERMINÉES
2. plannedDate < today        → section EN RETARD (visuel distinct)
3. category == must_do        → section BOUGE TON GROS CUL
4. plannedDate == today       → section AUJOURD'HUI
5. category == next           → section ENSUITE
6. category == someday        → section À FAIRE SI J'AI LE TEMPS
7. défaut                     → section ENSUITE
```

**Implémentation :** Un seul service `TaskDisplayService` dans `domain/services/`. Jamais de duplication dans les widgets.

**Date :** 2026-08-23

---

# ADR-018 — Comportement survol pastille

**Décision :** Comportement MVP de la pastille Windows.

**Contexte :** Le cahier fonctionnel exige consultation rapide sans ouvrir une grande fenêtre.

**Comportement figé pour le MVP :**

| Interaction | Résultat |
|---|---|
| **Survol 400 ms** | Expansion partielle : 3 tâches actives visibles au maximum, liste complète accessible à la molette |
| **Clic** | Panneau complet avec toutes les catégories et défilement |
| **Clic en dehors** | Réduction au mode pastille (si panneau ouvert) |
| **Double-clic** | Bascule Always-on-Top on/off |

**Raison :** Équilibre entre consultation rapide (survol) et usage complet (clic). La hauteur compacte évite de masquer l'écran, tandis que le défilement permet de consulter toutes les tâches sans ouvrir le panneau complet. Le délai de 400 ms évite les expansions accidentelles.

**Conséquences :**
- (+) Respecte l'esprit « ne pas obliger à ouvrir une fenêtre complète »
- (+) Répond au réflexe naturel d'utiliser la molette sur une liste
- (−) La création et l'édition restent réservées au panneau complet

**Date :** 2026-08-23 — révisé le 2026-09-01 après validation ergonomique

---

# ADR-019 — Design UI minimal

**Décision :** Thème **Material 3** minimal, sans identité graphique custom au MVP.

**Contexte :** Pas de logo, couleurs ou typo définis. L'objectif est simple et efficace.

**Choix :**
- **Material 3** (`useMaterial3: true`)
- **Thème** : suit le mode système (clair/sombre) par défaut
- **Typographie** : police système (pas de font custom)
- **Couleurs catégories** : teintes sobres distinctes

| Catégorie | Couleur indicative |
|---|---|
| BOUGE TON GROS CUL | Rouge `#E53935` |
| AUJOURD'HUI | Orange `#FB8C00` |
| ENSUITE | Jaune `#FDD835` |
| À FAIRE SI J'AI LE TEMPS | Gris `#9E9E9E` |
| EN RETARD | Rouge foncé `#B71C1C` |

- **Pas d'animations complexes** au MVP
- **Centralisation** : tout dans `lib/app/theme.dart`

**Date :** 2026-08-23

---

# ADR-020 — Widgets mobile (reporté)

**Décision :** Widgets Android/iOS **hors MVP**, développement après D16/D17.

**Contexte :** Widgets = composants natifs par plateforme, complexité élevée.

**Choix reporté :** `home_widget` sera évalué en phase post-MVP.

**Date :** 2026-08-23

---

# ADR-021 — Applications Windows associées (reporté)

**Décision :** Association tâche ↔ `.exe` **hors MVP**.

**Contexte :** Fonctionnalité locale complexe (chemins, icônes, lancement). Accélérer le time-to-market.

**Choix reporté :** Modèle `ApplicationReference` prévu dans l'architecture mais non implémenté au MVP.

**Date :** 2026-08-23

---

# ADR-022 — Packages utilitaires

**Décision :** Packages transverses retenus.

| Package | Rôle |
|---|---|
| `supabase_flutter` | Auth, DB distante, Realtime |
| `uuid` | Génération d'UUID locaux |
| `intl` | Formatage dates (affichage « 25 août ») |
| `connectivity_plus` | Détection réseau (online/offline/reconnexion) |
| `logger` | Logs structurés (désactivés en production) |
| `equatable` | Comparaison d'entités domaine dans les tests |
| `freezed` + `json_annotation` | *(optionnel)* Immutabilité des modèles data |

**Secrets :** Variables d'environnement via fichier `.env` local (non commité). Package `envied` ou lecture manuelle au choix lors de l'implémentation D13.

**Date :** 2026-08-23

---

# ADR-023 — Schéma PostgreSQL

**Décision :** Schéma défini dans `docs/database.md` et `supabase/migrations/001_initial_schema.sql`.

**Tables cloud :**
- `tasks` — tâches synchronisées (RLS par `user_id`)
- `user_settings` — préférences utilisateur (une ligne par compte)

**Tables locales uniquement (Drift) :**
- `tasks` — miroir local + colonne `sync_status`
- `user_settings` — miroir local
- `sync_operations` — file de sync (n'existe pas sur Supabase)

**Paramètres appareil :** `shared_preferences` (pas en SQL).

**SQL :** [`supabase/migrations/001_initial_schema.sql`](../supabase/migrations/001_initial_schema.sql)

**Date :** 2026-08-23

---

# ADR-024 — Modèle économique (EN ATTENTE)

**Décision :** À définir avant publication commerciale.

**Pistes envisagées (non figées) :**
- Gratuit avec sync (tier gratuit Supabase)
- Freemium (fonctionnalités premium : personnalités, thèmes)
- Achat unique

**Date prévue :** Avant bêta publique

---

# ADR-025 — Politique de confidentialité (EN ATTENTE)

**Décision :** À rédiger avant publication sur les stores.

**Exigences RGPD identifiées :**
- Minimisation des données (compte, tâches, préférences)
- Droit de suppression du compte et des données
- Pas de collecte du contenu d'autres applications
- Pas d'analytics intrusive au MVP

**Date prévue :** Avant soumission Google Play / Microsoft Store

---

# Récapitulatif des packages MVP

Liste consolidée pour `pubspec.yaml` (versions à pinned lors de l'initialisation Flutter) :

```yaml
dependencies:
  # Core
  flutter_riverpod: ^2.x
  go_router: ^14.x

  # Data
  drift: ^2.x
  sqlite3_flutter_libs: ^0.5.x
  path_provider: ^2.x
  path: ^1.x
  shared_preferences: ^2.x
  supabase_flutter: ^2.x

  # Windows desktop
  window_manager: ^0.5.x
  hotkey_manager: ^0.2.x
  tray_manager: ^0.5.x
  launch_at_startup: ^0.5.x
  flutter_alone: ^3.x
  package_info_plus: ^8.x

  # Notifications
  flutter_local_notifications: ^18.x
  timezone: ^0.9.x

  # Utilitaires
  uuid: ^4.x
  intl: ^0.19.x
  connectivity_plus: ^6.x
  logger: ^2.x
  equatable: ^2.x

dev_dependencies:
  drift_dev: ^2.x
  build_runner: ^2.x
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.x
```

**Packages post-MVP :** `home_widget` (widgets mobile)

---

# Processus de modification

Pour changer une décision **FIGÉE** :

1. Créer une nouvelle entrée ADR (ex: ADR-026) qui référence l'ADR remplacé
2. Documenter la raison du changement
3. Mettre à jour `docs/architecture.md` si nécessaire
4. Ne jamais modifier silencieusement une décision existante

---

# Prochaine étape

**P4 — `docs/database.md`** : ✅ Terminé — schéma Drift + Supabase + SQL prêt.

**Prochaine étape : P5** — Prototype Windows (pastille + Always-on-Top + raccourci).
