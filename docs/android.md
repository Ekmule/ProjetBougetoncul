# MYA — Android (D16)

Guide pour installer l’APK de test et connecter la synchronisation Supabase.

---

## 0. Prérequis build Windows (une seule fois)

Pour générer l’APK depuis Windows, installez le SDK Android :

```powershell
.\scripts\setup-android-sdk.ps1
```

Ce script installe sur `E:\` (sans accent, comme Flutter) :

- JDK 17 portable → `E:\jdk\jdk-17`
- Android SDK → `E:\Android\Sdk`
- variables `JAVA_HOME`, `ANDROID_HOME`, `Path`

Android Studio est **optionnel** (proposé via winget, nécessite UAC). Il n’est pas requis pour builder l’APK.

Fermez puis rouvrez le terminal après l’installation.

Vérification :

```powershell
flutter doctor -v
```

La ligne **Android toolchain** doit être verte (ou au minimum détecter `E:\Android\Sdk`).

---

## 1. Build de l’APK

Depuis la racine du projet (Windows) :

```powershell
.\scripts\build-apk.ps1
```

L’APK release se trouve dans :

```
build/app/outputs/flutter-apk/app-release.apk
```

Option APK plus legers par processeur :

```powershell
.\scripts\build-apk.ps1 -SplitPerAbi
```

### Fichier `.env.json`

Comme sur Windows, la build doit inclure les cles Supabase :

```json
{
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_ANON_KEY": "eyJ..."
}
```

Sans ce fichier, l’app fonctionne en **local-only** (pas de sync).

---

## 2. Installation sur le telephone

1. Copiez `app-release.apk` sur le telephone (USB, Drive, etc.).
2. Ouvrez le fichier et autorisez **Sources inconnues** si Android le demande.
3. Installez **MYA** (`com.mya.mya`).

> Cette build de test est signee avec la cle debug Android (Gradle). Elle convient aux tests personnels, pas a une publication Play Store.

---

## 3. OAuth Google (connexion compte)

### Supabase

Dans **Authentication → URL Configuration**, ajoutez :

```
com.mya.app://login-callback/
```

(Google seul est propose dans l’UI MYA.)

### Google Cloud Console

Le flux OAuth mobile utilise une **fenêtre de connexion intégrée** (`flutter_web_auth_2`) qui capture directement le retour `com.mya.app://login-callback/`. Les erreurs s'affichent dans le dialogue Compte.

- Type d’application OAuth : **Externe** (pas Interne).
- Redirect URI autorise cote Google : l’URL callback Supabase (`https://<project>.supabase.co/auth/v1/callback`).

L’intent-filter Android est deja configure dans `AndroidManifest.xml`.

### Test connexion

1. Ouvrez MYA → icone **Parametres** (engrenage).
2. **Compte et synchronisation** → **Continuer avec Google**.
3. Terminez la connexion dans **Chrome** (onglet intégré) ; MYA doit se rouvrir et afficher le badge sync vert.

> Installez **Google Chrome** sur le téléphone si ce n’est pas déjà fait. Sur Honor / Firefox, le navigateur par défaut peut afficher une page HTML « Found » avec un lien `com.mya.app://…` au lieu de revenir dans MYA.

### L’app ne s’ouvre plus ou se ferme après OAuth

1. **Paramètres Android → Applications → MYA → Stockage → Effacer les données** (ou désinstallez puis réinstallez l’APK).
2. Réinstallez la dernière version de `app-release.apk`.
3. Relancez la connexion Google **une seule fois**, sans quitter MYA pendant le flux.

En cas d’echec au retour navigateur, verifiez que la redirect URL Supabase correspond exactement à `com.mya.app://login-callback/`.

---

## 4. Synchronisation

Une fois connecte avec le **meme compte** que sur Windows :

- Les taches se fusionnent au premier sync (LWW).
- Les modifications offline sont mises en file puis poussees a la reconnexion.
- Le badge dans la barre d’outils indique l’etat (local / sync / en cours / en attente).

Test E2E recommande :

1. Creer une tache sur Windows → verifier sur Android apres sync.
2. Creer une tache sur Android → verifier sur Windows.
3. Modifier la meme tache sur les deux appareils (hors ligne si possible) → la version la plus recente gagne.

---

## 5. Developpement

Lancer sur un appareil ou emulateur connecte :

```powershell
$env:FLUTTER_ROOT = "E:\flutter"
$env:Path = "E:\flutter\bin;" + $env:Path
flutter run -d android --dart-define-from-file=.env.json
```

---

## 6. Widget écran d’accueil (D17a)

Widget **redimensionnable** (launcher) entre **1×1** et **2×2** :

| Taille | Contenu |
|--------|---------|
| **1×1** (compact) | Icône MYA + pastille **verte** (sync) + pastille **ambre** (tâche(s) du jour) |
| **2×2** (étendu) | Icône plus grande, anneau ambre animé si tâche du jour, libellé **AUJOURD’HUI** + titre de la première tâche |

Après ajout du widget, **pincez les bords** sur l’écran d’accueil pour passer du format icône au format carte (Honor / Android).

### Ajouter le widget (Honor / Android)

1. Appui long sur l’écran d’accueil → **Widgets**
2. Cherchez **MYA**
3. Glissez le widget MYA où vous voulez (par défaut souvent **2×2** ; réduisez en **1×1** si besoin)
4. **Tap** sur le widget → ouvre la liste des tâches

Les pastilles se mettent à jour à l’ouverture de l’app, au retour au premier plan, après sync et quand vous modifiez une tâche. Si MYA n’est pas ouverte, le widget peut rester figé jusqu’au prochain lancement (pas de mise à jour à minuit en arrière-plan pour l’instant).

> Animation au rappel et création rapide depuis le widget : phases D17b–D17c.

---

## 7. Mises à jour (GitHub Releases)

Comme sur Windows, l’APK **ne se met pas à jour** au `git push` : il faut publier une release avec l’asset  
`MYA-Android-x.y.z-buildN.apk` (voir `docs/releases.md`).

Dans MYA : **Paramètres → Mises à jour** (version installée + vérification manuelle).  
Au démarrage, une vérification automatique peut proposer une mise à jour (max ~1×/24 h).

`.env.json` peut inclure `UPDATE_GITHUB_OWNER` / `UPDATE_GITHUB_REPO` (voir `.env.json.example`).

Éditeur affiché dans l’app : **Zonakron édition** (copyright dans les paramètres).

---

## 8. Hors scope prochaines phases

- Pastille flottante overlay (comme Windows)
- Publication Play Store (mises à jour via Google Play, autre flux)
- Signature release Android dédiée (keystore éditeur — recommandé avant diffusion large)

Voir `docs/architecture.md` pour la feuille de route complete.
