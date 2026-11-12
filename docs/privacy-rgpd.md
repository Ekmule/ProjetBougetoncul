# MYA — Confidentialité, consentement et RGPD

> **Avertissement** : ce document est un **guide produit et technique** pour l’éditeur (Zonakron édition). Il ne constitue **pas** un avis juridique. Pour une mise à disposition publique (UE ou international), faites valider une **politique de confidentialité** et des **CGU** par un professionnel du droit.

---

## 1. Rôle de MYA

| Mode | Données | Hébergement |
|------|---------|-------------|
| **Local** (par défaut) | Tâches, paramètres pastille, préférences | Appareil uniquement (`%LOCALAPPDATA%\mya`, `%APPDATA%\com.mya` sur Windows ; stockage app sur Android) |
| **Cloud** (optionnel) | Même contenu synchronisé + compte OAuth (ex. e-mail) | Projet **Supabase** configuré par l’éditeur (PostgreSQL, Auth) |

L’utilisateur **n’est pas obligé** de créer un compte pour utiliser MYA.

---

## 2. Responsable du traitement

- **Éditeur** : Zonakron édition (mentionnée dans l’app, `lib/core/constants/app_legal.dart`).
- **Contact** : à définir (e-mail dédié confidentialité recommandé, ex. `privacy@…`).
- **Finalité principale** : gestion personnelle de rappels / tâches (« pense-bêtes »).

---

## 3. Données personnelles concernées

### 3.1 Toujours (app locale)

- Contenu des tâches (titres, dates, rappels, catégories).
- Préférences (langue, icône pastille, raccourcis, etc.).
- Identifiants techniques locaux (base SQLite / fichiers).

### 3.2 Si sync cloud activée

- Identité de compte : identifiant Supabase Auth, e-mail ou nom affiché fourni par **Google** (OAuth).
- Réplication des tâches et réglages synchronisés vers Supabase.
- Métadonnées techniques : horodatages, identifiants de sync, journaux côté hébergeur selon configuration Supabase.

### 3.3 Ce que MYA ne doit pas viser à collecter

- Données de santé, bancaires, mots de passe, secrets professionnels critiques — **à déconseiller explicitement** dans l’UI et la politique.
- Une suggestion (255 caractères maximum) n’est transmise qu’à l’initiative de l’utilisateur, par son application e-mail, à `zonakron.edition@gmail.com` ; MYA ne l’enregistre pas automatiquement. Les boutons de don ouvrent PayPal et sont soumis à la politique de confidentialité de PayPal.

---

## 4. Bases légales (RGPD — indicatif)

| Traitement | Base possible (à confirmer juridiquement) |
|------------|-------------------------------------------|
| Fonctionnement local | **Intérêt légitime** / exécution du service demandé par l’utilisateur |
| Sync cloud + compte | **Consentement** (case / écran dédié, révocable par déconnexion + suppression) |
| Mises à jour (GitHub Releases) | Téléchargement technique ; pas de profilage utilisateur dans MYA aujourd’hui |

Documenter le choix retenu dans le registre des traitements (obligation pour les structures concernées).

---

## 5. Sous-traitants et transferts

| Prestataire | Rôle | Action éditeur |
|-------------|------|----------------|
| **Supabase** | Auth + base de données sync | Compte éditeur ; activer **RLS** ; lire DPA / conditions Supabase |
| **Google** | Connexion OAuth (si proposée) | Console Google Cloud ; politique Google applicable |
| **GitHub** | Hébergement des binaires (mises à jour) | Pas de données utilisateur MYA dans les releases |
| **Hébergeur OAuth / navigateur** | Flux de connexion mobile | Selon appareil (ex. Chrome Custom Tabs) |

Vérifier si les serveurs Supabase sont dans l’**UE** ou hors UE ; si transfert hors UE, mécanismes type **clauses contractuelles types** (à traiter avec le juriste).

---

## 6. Durée de conservation

- **Local** : tant que l’app est installée ; suppression par désinstallation / effacement données app.
- **Cloud** : tant que le compte existe ; définir une politique d’**inactivité** (ex. suppression après X mois sans connexion) si exigé par votre modèle.
- **Sauvegardes Supabase** : selon rétention du plan Supabase.

La doc technique prévoit une suppression en cascade côté serveur lors de la suppression du compte Auth (`docs/synchronization.md`) — le **parcours utilisateur** (« Supprimer mon compte et mes données cloud ») reste à exposer clairement dans l’app et la politique.

---

## 7. Droits des personnes (RGPD)

Informer les utilisateurs qu’ils peuvent demander (selon les cas) :

- **Accès** et **copie** de leurs données ;
- **Rectification** ;
- **Effacement** (« droit à l’oubli ») ;
- **Limitation** / **opposition** (selon base légale) ;
- **Portabilité** (données fournies de manière structurée, si applicable).

**Canal** : e-mail du responsable du traitement ; délai de réponse réglementaire (en principe 1 mois).

**Dans l’app (recommandé)** :

1. Paramètres → lien **Politique de confidentialité** (URL stable).
2. Compte connecté → **Exporter** (option future) / **Supprimer mon compte cloud** avec confirmation explicite.

---

## 8. Consentement cloud — état actuel et cible

### Déjà en place (partiel)

- Installateur Windows : case **sync cloud** (opt-in) + `install_options.json` (`prefer_cloud_sync`, `app_locale`).
- Premier lancement : dialogue **proposition de connexion** si l’option était cochée (« Plus tard » possible).
- Texte « À propos » : renvoi aux conditions des services cloud tiers.

### À renforcer pour une conformité sérieuse

1. **Écran ou section « Confidentialité »** avant la première connexion OAuth :
   - résumé en langage clair (données synchronisées, hébergeur, sous-traitants) ;
   - lien vers la politique complète ;
   - boutons **Accepter et continuer** / **Rester en mode local**.
2. **Ne pas pré-cocher** la sync cloud sans lecture (installateur : case décochée par défaut — vérifier `mya.iss`).
3. **Rappel** : ne pas stocker d’informations sensibles dans les pense-bêtes.
4. **Journal du consentement** (horodatage + version de la politique) — utile en cas de contrôle ; stockage local ou serveur à définir avec le juriste.

---

## 9. Sécurité (communication utilisateur)

Formulations prudentes :

- Données cloud : **chiffrées en transit** (HTTPS/TLS).
- **Ne pas** promettre un chiffrement de bout en bout du contenu des tâches sur le serveur sauf si implémenté (ce n’est pas le cas par défaut sur Postgres hébergé).

Côté technique éditeur : RLS Supabase, secrets hors dépôt (`.env.json`), clés OAuth restreintes, mises à jour de sécurité des dépendances.

---

## 10. Mineurs

Si MYA est grand public sans ciblage enfants : le mentionner ; en cas d’usage par des moins de 15 ans (France), règles spécifiques de consentement — à valider juridiquement.

---

## 11. Échelle Supabase (ex. 500 utilisateurs)

- Le **tier gratuit** a des limites (stockage, bande passante, requêtes, etc.) — surveiller le dashboard Supabase.
- 500 comptes avec peu de tâches peut tenir un temps ; la charge réelle dépend de l’**activité** sync.
- Prévoir passage à un **plan payant** ou révision de l’architecture avant diffusion large (voir ADR-005 dans `docs/decisions.md`).

---

## 12. Checklist éditeur avant diffusion publique

- [ ] Politique de confidentialité publiée (web) + lien dans l’app
- [ ] CGU / conditions d’utilisation MYA (éditeur)
- [ ] Consentement explicite sync cloud (UI + trace si conseillé)
- [ ] Contact confidentialité et procédure demandes RGPD
- [ ] Registre des traitements (si applicable)
- [ ] DPA / contrats sous-traitants (Supabase, etc.)
- [ ] Parcours **suppression de compte** documenté et testé
- [ ] Android : signature **release** (keystore) ; Play Store si audience large
- [ ] Windows : installateur distribué via GitHub Releases (pas de check `build\` au runtime — voir `installer/mya.iss`)

---

## 13. Références internes

- `lib/core/constants/app_legal.dart` — mentions courtes in-app
- `lib/core/install/install_options.dart` — options première installation
- `docs/synchronization.md` — modèle de données sync
- `docs/android.md` — OAuth, APK, mises à jour
- `docs/releases.md` — publication des versions

---

*Dernière mise à jour document : à compléter à chaque évolution majeure du traitement des données.*
