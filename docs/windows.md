# MYA — Spécificités Windows (prototype P5)

**Version :** 1.0  
**Dernière mise à jour :** 2026-08-23  
**Statut :** Prototype validable — pastille flottante

---

# 1. Objectif du prototype P5

Valider la fonctionnalité la plus distinctive de MYA :

> **Une pastille discrète et permanente sur le bureau Windows.**

## Critères de validation (cahier technique §86)

| Critère | Implémentation |
|---|---|
| Pastille stable | `BubbleButton` + `window_manager` frameless |
| Déplacement libre | `GestureDetector.onPanUpdate` → `WindowsWindowController.moveBy` |
| Accrochage aux bords | `snapToEdgeIfNeeded()` au relâchement |
| Panneau rapide | Clic = panneau complet, survol 400 ms = aperçu |
| Always-on-Top | Double-clic pastille ou bouton épingle |
| Raccourci global | `Ctrl+Alt+Space` via `hotkey_manager` |
| Une seule instance | `flutter_alone` mutex `com.mya.app` |
| Création de tâche | Champ dans panneau + dialogue rapide |
| Catégories | `TaskDisplayService` + sections colorées |

---

# 2. Prérequis machine

## 2.1 Flutter SDK

**Important :** si ton profil Windows contient un accent ou caractère spécial dans le nom
(ex. `C:\Users\ékmule\`), Flutter **doit** être installé sur un chemin **ASCII uniquement**.

Le SDK du projet est configuré pour :

```
E:\flutter
```

Variables d'environnement recommandées :

| Variable | Valeur |
|---|---|
| PATH (ajouter) | `E:\flutter\bin` |
| `FLUTTER_ROOT` | `E:\flutter` |
| `PUB_CACHE` | `E:\pub-cache` |

Si Flutter est encore dans `%LOCALAPPDATA%\flutter`, la compilation des shaders échoue avec :

```
Included file not found: flutter/runtime_effect.glsl
```

Le chemin affiché sera corrompu : `C:\Users\├®kmule\...`

## 2.2 Visual Studio Build Tools

Requis pour compiler l'application Windows (C++ workload).  
Installé via : `Microsoft.VisualStudio.2022.BuildTools` + workload VCTools.

**Composant supplémentaire obligatoire (D9 — notifications Windows) :**

| Composant | ID | Pourquoi |
|---|---|---|
| C++ ATL for latest v143 build tools | `Microsoft.VisualStudio.Component.VC.ATL` | `flutter_local_notifications_windows` inclut `atlbase.h` |

Sans ATL, la build échoue avec :

```
error C1083: Impossible d'ouvrir le fichier include : 'atlbase.h'
```

Installation en ligne de commande (**PowerShell lancé en Administrateur**, obligatoire avec `--passive`) :

```powershell
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" modify `
  --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" `
  --add Microsoft.VisualStudio.Component.VC.ATL `
  --passive --norestart
```

> Si l'installateur s'arrête immédiatement avec le code **5007**, la fenêtre n'était **pas** ouverte en administrateur.  
> Clic droit sur PowerShell → **Exécuter en tant qu'administrateur**, puis relancer la commande.

Ou via **Visual Studio Installer → Modifier → Composants individuels → rechercher « ATL »** (plus simple, pas besoin de ligne de commande).

## 2.3 Mode Développeur Windows (obligatoire)

Flutter a besoin des **symlinks** pour les plugins natifs.

1. Ouvrir **Paramètres → Confidentialité et sécurité → Pour les développeurs**
2. Activer **Mode développeur**

Ou exécuter : `start ms-settings:developers`

Sans cela, `flutter build windows` et `flutter run` échouent avec :

```
Building with plugins requires symlink support.
```

---

# 3. Lancer le prototype

### Utilisation rapide (pastille Windows)

| Action | Comment |
|---|---|
| **Pastille rouge** | Clic = panneau complet · survol = aperçu · glisser = déplacer |
| **Paramètres** | Icône engrenage dans le panneau · ou clic droit sur l'icône tray |
| **Icône tray** | Près de l'horloge (^ sur Windows 11) · clic droit = menu complet |
| **Créer une tâche** | Clic pastille (ou clic sur l’aperçu), puis champ « + Ajouter un pense-bête » ; ou **Ctrl+Alt+Espace** |
| **Valider une tâche** | Clic sur le cercle ☐ à gauche de la tâche |
| **Modifier / supprimer** | Clic sur le titre d’une tâche dans le panneau complet |
| **Catégories** | Menu « Déplacer vers… » sur chaque tâche |
| **Tray** | Clic droit sur l'icône MYA → Ouvrir, masquer, compte, raccourci… |

> Si le panneau n'affiche que « MYA » sans contenu : **cliquez la pastille rouge** (pas seulement le survol) pour ouvrir le panneau complet 520 px.

### Logs de debug pastille

En mode `flutter run`, les actions pastille sont loguées sur une ligne avec le
préfixe `[MYA][bubble]` :

```
[MYA][bubble] hover enter | mode=bubble applying=false
[MYA][bubble] hover delay elapsed → open preview
[MYA][bubble] applyViewMode | bubble=false preview=true panel=false size=280x260
[MYA][bubble] open preview done
[MYA][bubble] hover exit | mode=preview inGrace=true
[MYA][bubble] hover exit ignored (grace period)
```

Utile pour diagnostiquer un aperçu qui s'ouvre puis se referme.

En debug, le contrôle d'instance unique est désactivé afin que `R` (hot
restart) ne termine pas MYA. Il reste actif dans les builds release.

### Méthode recommandée (script)

```powershell
cd E:\Project-Repo\ProjetBougetoncul
.\scripts\run-windows.ps1
```

Le script configure automatiquement `E:\flutter` et `E:\pub-cache`.

### Méthode manuelle

```powershell
$env:FLUTTER_ROOT = "E:\flutter"
$env:PUB_CACHE = "E:\pub-cache"
$env:Path = "E:\flutter\bin;" + $env:Path

cd E:\Project-Repo\ProjetBougetoncul
flutter pub get
flutter run -d windows
```

Build release (optionnel) :

```powershell
flutter build windows --release
```

L'exécutable se trouve dans :

```
build\windows\x64\runner\Release\mya.exe
```

### Installateur Windows (recommandé pour votre PC cobaye)

Prérequis : [Inno Setup 6](https://jrsoftware.org/isdl.php) (gratuit).

```powershell
cd E:\Project-Repo\ProjetBougetoncul
powershell -ExecutionPolicy Bypass -File .\scripts\build-installer.ps1 -BumpBuild
```

Le switch **`-BumpBuild`** incrémente le numéro de build dans `pubspec.yaml` (ex. `1.0.0+1` → `1.0.0+2`) et produit un installateur distinct à chaque compilation, par ex. `dist\MYA-Setup-1.0.0-build2.exe`.

| Étape | Contenu |
|---|---|
| **Dossier d'installation** | Par défaut `C:\Program Files\MYA` (modifiable à la première install) |
| **Mise à jour** | Même `AppId` → l'assistant détecte une mise à jour, conserve le dossier d'install |
| **Données utilisateur** | **Non effacées** : base SQLite `%LOCALAPPDATA%\mya\`, préférences `%APPDATA%\com.mya\` |
| **Raccourci bureau** | Optionnel (première install uniquement) |
| **Démarrage avec Windows** | Coché par défaut — appliqué au premier lancement uniquement |
| **Synchronisation cloud** | Option « bientôt disponible » — enregistre la préférence pour D14–D15 |

### Tester une mise à jour

1. Installez `MYA-Setup-1.0.0-build1.exe`, créez des tâches, changez l'icône de pastille.
2. Recompilez avec `-BumpBuild` → `MYA-Setup-1.0.0-build2.exe`.
3. Fermez MYA (clic droit tray → Quitter), lancez le nouvel installateur.
4. L'assistant doit afficher **« Mise à jour ou réparation de MYA »** (pas une install from scratch).
5. Vérifiez que vos tâches et paramètres sont toujours là.

> **Note :** l'installateur `MYA-Setup-1.0.0.exe` (sans numéro de build) enregistre la version `1.0.0`. Les builds suivants (`build2`, `build3`…) la détectent comme mise à jour vers `1.0.0.2`, etc.

L'installateur généré se trouve dans `dist\MYA-Setup-<version>-build<N>.exe`.

> Après installation, lancez MYA depuis le menu Démarrer (pas `flutter run`). Le chemin fixe permet au démarrage automatique et à l'icône tray de fonctionner correctement.

Build release manuel (sans installateur) :

---

# 4. Architecture du code prototype

```
lib/
├── main.dart                          # Bootstrap : instance unique + fenêtre
├── app/
│   ├── app.dart                       # MaterialApp.router + go_router
│   ├── bootstrap.dart                 # Init Windows (pastille, instance unique)
│   ├── router.dart                    # Routes go_router
│   └── theme.dart                     # Thème sombre minimal
├── core/constants/
│   └── window_constants.dart          # Tailles pastille / panneau
├── domain/
│   ├── entities/task.dart             # Modèle tâche (mémoire)
│   └── services/task_display_service.dart  # Règles d'affichage catégories
├── application/
│   ├── tasks/tasks_notifier.dart      # Liste tâches (Riverpod)
│   └── bubble/bubble_ui_notifier.dart # État pastille / panneau
├── platform/windows/
│   ├── windows_window_controller.dart # window_manager (NE PAS appeler depuis widgets)
│   └── windows_hotkey_controller.dart # hotkey_manager
└── features/floating_bubble/
    ├── bubble_screen.dart             # Écran principal
    └── widgets/
        ├── bubble_button.dart         # Cercle rouge "M"
        ├── task_panel.dart            # Liste par catégories
        └── quick_add/                   # Création rapide unifiée (D5)
```

---

# 5. Interactions utilisateur

| Action | Résultat |
|---|---|
| **Survol 400 ms** | Aperçu partiel des tâches |
| **Clic** | Panneau complet |
| **Double-clic** | Bascule Always-on-Top |
| **Glisser** | Déplace la pastille |
| **Relâcher près d'un bord** | Accrochage |
| **Ctrl+Alt+Space** | Dialogue création rapide |
| **Bouton épingle** | Always-on-Top |
| **Bouton masquer** | Cache la fenêtre |
| **Croix** | Réduit en pastille |
| **Coche** | Termine une tâche |

---

# 6. Packages Windows utilisés

| Package | Rôle | ADR |
|---|---|---|
| `window_manager` | Fenêtre frameless, taille, position, Always-on-Top | ADR-008 |
| `hotkey_manager` | Raccourci global système | ADR-009 |
| `flutter_alone` | Instance unique | ADR-012 |
| `screen_retriever` | Taille écran pour position initiale | — |

**Production Windows (D10) :**
- `tray_manager` — zone de notification (ADR-010)
- `launch_at_startup` — démarrage Windows (ADR-011)
- `shared_preferences` — position pastille, visibilité, Always-on-Top

---

# 7. Limitations connues du prototype

| Limitation | Statut |
|---|---|
| Tâches en mémoire uniquement (pas Drift) | ✅ Résolu en D3 |
| Pas de persistance position pastille | ✅ D10 — shared_preferences |
| Pas d'icône barre système | ✅ D10 — tray_manager |
| Distorsion fenêtre au démarrage (certaines versions Flutter) | Workaround ADR-008 si nécessaire |
| Chemin utilisateur avec accents (`ékmule`) | **Flutter doit être dans `E:\flutter`** — voir section 10 |

---

# 8. Prochaines étapes après validation P5

1. **D14** — Backend Supabase (tables déjà prêtes, sync D15)

---

# 9. Dépannage

## `flutter` non reconnu

Ajouter `%LOCALAPPDATA%\flutter\bin` au PATH.

## Erreur symlink

Activer le mode développeur Windows (section 2.3).

## Visual Studio not found

Installer Visual Studio Build Tools 2022 avec « Développement Desktop en C++ » **et** le composant **C++ ATL** (voir section 2.2).

## `atlbase.h` introuvable

Le plugin `flutter_local_notifications_windows` (rappels D9) compile du C++ ATL.  
Installer `Microsoft.VisualStudio.Component.VC.ATL` via Visual Studio Installer, puis relancer :

```powershell
flutter clean
flutter pub get
flutter run -d windows
```

## `LNK1168` — impossible d'écrire `mya.exe`

MYA est encore en cours d'exécution (souvent invisible dans la barre des tâches, icône tray uniquement).

1. Clic droit sur l'icône MYA dans la zone de notification → **Quitter**
2. Ou : Gestionnaire des tâches → terminer `mya.exe`
3. Relancer `flutter run -d windows`

## Le raccourci Ctrl+Alt+Space ne fonctionne pas

Vérifier qu'aucune autre application n'utilise ce raccourci.  
Relancer MYA en administrateur si nécessaire (rare).

## Deuxième instance lancée

`flutter_alone` doit bloquer — si ça échoue, fermer l'ancienne instance dans le Gestionnaire des tâches.

> **Exception OAuth (D13) :** lors du retour navigateur après connexion, Windows relance brièvement MYA avec le deep link ; `SendAppLinkToInstance` transmet l'URL à l'instance déjà ouverte et quitte — comportement normal.

---

# 11. Authentification Supabase (D13)

## Sans clés Supabase

MYA fonctionne **100 % en local**. Sans `.env.json`, le menu tray affiche « sync non configurée ».

## Activer l'auth

1. Créer le projet Supabase et exécuter `supabase/migrations/001_initial_schema.sql` (voir `docs/database.md`)
2. Copier `.env.json.example` → `.env.json` à la racine du projet
3. Renseigner `SUPABASE_URL` et `SUPABASE_ANON_KEY`
4. Dans Supabase → **Authentication → URL Configuration**, ajouter :
   ```
   com.mya.app://login-callback/
   ```
5. Activer les providers Google / Apple / Microsoft dans le dashboard
6. Lancer avec `.\scripts\run-windows.ps1` (détecte `.env.json` automatiquement)

## Connexion dans MYA

Clic droit tray → **Se connecter…** → choisir le provider → navigateur → retour automatique à MYA.

La synchronisation des tâches arrive en **D14–D15** ; D13 ne fait que l'auth.

---

# 10. Erreur shader `runtime_effect.glsl not found`

## Symptôme

```
ink_sparkle.frag: error: '#include' : Included file not found.
flutter/runtime_effect.glsl
C:\Users\├®kmule\AppData\Local\flutter\...
```

## Cause

Le SDK Flutter est dans un chemin avec **caractères non-ASCII** (accent dans le nom d'utilisateur Windows).
Le compilateur de shaders (Impeller) ne résout pas correctement les chemins.

## Solution

1. Copier Flutter vers `E:\flutter` (déjà fait sur cette machine)
2. Ajouter **`E:\flutter\bin`** au PATH utilisateur (pas `%LOCALAPPDATA%\flutter\bin`)
3. Définir `PUB_CACHE=E:\pub-cache` (optionnel mais recommandé)
4. Nettoyer le projet :

```powershell
$env:Path = "E:\flutter\bin;" + $env:Path
cd E:\Project-Repo\ProjetBougetoncul
flutter clean
flutter pub get
flutter run -d windows
```

Ou utiliser : `.\scripts\run-windows.ps1`
