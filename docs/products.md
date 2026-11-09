# Produits MYA

Le dépôt produit trois applications installables côte à côte.

| Produit | Plateforme | Cloud | Identité |
|---|---|---|---|
| MYA Complete | Android et Windows | Supabase facultatif | Produit historique |
| MYA Mobile | Android | Aucun compte ni synchronisation | `com.mya.mya.mobile` |
| MYA Desktop | Windows | Aucun compte ni synchronisation | AppId Windows dédié |

Les versions sont indépendantes dans `config/versions/`.

## Développement et builds

```powershell
# Complete Android
powershell -ExecutionPolicy Bypass -File .\scripts\build-apk.ps1 -Product complete

# Mobile local
powershell -ExecutionPolicy Bypass -File .\scripts\build-apk.ps1 -Product mobile

# Complete Windows
powershell -ExecutionPolicy Bypass -File .\scripts\build-installer.ps1 -Product complete

# Desktop local
powershell -ExecutionPolicy Bypass -File .\scripts\build-installer.ps1 -Product desktop
```

MYA Complete utilise `lib/main.dart` et `.env.json`. Les produits locaux
utilisent `lib/main_local.dart`, qui n'injecte ni authentification Supabase ni
source de données distante.

## Travailler sur plusieurs produits

Ne pas maintenir une branche permanente par produit. Une branche de
fonctionnalité modifie le code partagé, puis utilise `ProductConfig` uniquement
pour les capacités réellement différentes.

- Fonction commune : développer et tester une fois.
- Fonction Complete : protéger avec `ProductConfig.supportsCloud`.
- Fonction Mobile : code Android et interface plein écran.
- Fonction Desktop : code Windows, pastille et tray.

## Publications indépendantes

```powershell
.\scripts\publish-product-release.ps1 -Product complete -BumpBuild
.\scripts\publish-product-release.ps1 -Product mobile -BumpBuild
.\scripts\publish-product-release.ps1 -Product desktop -BumpBuild
```

Tags GitHub :

- `complete-v1.2.0-build4`
- `mobile-v1.0.1-build2`
- `desktop-v1.0.3-build7`

Chaque client parcourt les releases et ne considère que son préfixe de tag et
ses assets. Une release d'un autre produit ne peut donc pas être proposée.

Le script Complete publie aussi les anciens noms `MYA-Setup-*` et
`MYA-Android-*` pendant la transition des clients déjà installés.
