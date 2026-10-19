# Publication des versions MYA

Les clients **ne se mettent pas a jour** quand vous faites un `git push`.  
Ils lisent **GitHub Releases** (`releases/latest`) et comparent la version installee (`pubspec.yaml` -> `version: x.y.z+build`).

## PowerShell (politique d'execution)

Sur Windows, si `.\scripts\...` est refuse ou si un script plante sur des guillemets, lancez avec :

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\<script>.ps1
```

Ou, pour la session ouverte uniquement :

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Les scripts du depot evitent les caracteres Unicode problematiques (tiret long, etc.) pour PowerShell 5.1.

## Etapes editeur

1. Monter `version:` dans `pubspec.yaml` (ex. `1.0.2+5`).
2. Builder les binaires.
3. Creer une **release GitHub** avec les assets nommes exactement ainsi :

| Plateforme | Fichier attendu |
|------------|-----------------|
| Windows | `MYA-Setup-1.0.2-build5.exe` (ou sans `-build` si build = 1) |
| Android | `MYA-Android-1.0.2-build5.apk` |

4. Les apps verifient au demarrage (apres ~20 s, max 1x/24 h) et via **Parametres -> Mises a jour**.

### Script Windows (installateur seul)

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\publish-github-release.ps1 -BumpBuild -Notes "Correctifs sync"
```

### Windows + Android

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\publish-github-release.ps1 -IncludeAndroid -BumpBuild -Notes "Correctifs sync"
```

### Prerequis GitHub CLI

1. Installer (Windows) :

```powershell
winget install --id GitHub.cli -e
```

2. **Fermer puis rouvrir** le terminal (le PATH est mis a jour).
3. Se connecter :

```powershell
gh auth login
```

4. `.env.json` a la racine pour la build Android si sync cloud.

## Juridique / editeur

MYA est presente dans l'app comme edite par **Zonakron edition** (copyright dans les parametres).  
Sur le **Play Store**, le nom affiche est celui du **compte developpeur** Google ; une mention (c) dans l'app reste recommandee mais n'est pas substitut aux CGU / fiche store.
