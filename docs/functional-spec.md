# Cahier des charges fonctionnel — MYA

**Nom du projet :** MYA  
**Signification :** Move Your Ass  
**Type :** Pense-bête personnel multiplateforme  
**Plateformes cibles :** Windows, Android, iOS  
**Version initiale :** MVP  
**Objectif :** Permettre à l'utilisateur de voir immédiatement ce qu'il doit faire, d'ajouter une tâche en quelques secondes et de recevoir un rappel uniquement lorsqu'il le souhaite.

---

# 1. Vision du produit

MYA est une application de pense-bête destinée à aider l'utilisateur à ne pas oublier ses tâches et à passer à l'action.

MYA n'est pas conçu comme :

- un logiciel de gestion de projet ;
- un agenda complet ;
- un outil professionnel de gestion d'équipe ;
- un clone de Jira ;
- un outil complexe de productivité ;
- une base de données de tâches à gérer quotidiennement.

Son objectif est beaucoup plus simple :

> **Permettre à l'utilisateur de savoir rapidement ce qu'il doit faire et de lui rappeler certaines choses au moment approprié.**

L'application doit donc privilégier :

- la simplicité ;
- la rapidité ;
- la visibilité ;
- la faible charge mentale ;
- l'humour ;
- la personnalisation légère ;
- la synchronisation entre appareils.

---

# 2. Philosophie UX

La règle fondamentale de MYA est :

> **Une tâche simple doit pouvoir être créée sans remplir un formulaire.**

L'utilisateur doit pouvoir écrire :

> Acheter du pain

et valider.

La tâche existe immédiatement.

Les informations supplémentaires sont facultatives :

- date ;
- rappel ;
- catégorie ;
- application associée ;
- etc.

L'utilisateur ne doit jamais être obligé de renseigner ces informations pour créer une tâche.

---

# 3. Identité de MYA

## 3.1 Nom

**MYA**

Nom complet :

**Move Your Ass**

L'expression anglaise est volontairement familière et humoristique.

La traduction conceptuelle française est :

> **Bouge ton cul.**

Le nom doit être utilisable comme une marque/appellation courte.

---

## 3.2 Ton

MYA possède une personnalité humoristique.

L'humour doit toutefois rester optionnel et configurable.

L'application peut par défaut utiliser une formulation telle que :

> 🔴 BOUGE TON GROS CUL

pour représenter les tâches auxquelles l'utilisateur doit réellement s'atteler.

L'utilisateur doit pouvoir modifier les intitulés des catégories et désactiver ou réduire le ton humoristique.

---

# 4. Plateformes

MYA est conçu pour :

- Windows ;
- Android ;
- iOS.

La synchronisation doit permettre de retrouver les mêmes tâches sur tous les appareils connectés au même compte.

---

# 5. Concept central : la pastille MYA

Sur Windows, MYA doit posséder une petite pastille flottante servant de point d'accès permanent à l'application.

## 5.1 Position initiale

Par défaut, la pastille doit apparaître :

- sur le côté gauche ou droit de l'écran ;
- approximativement à 80 % de la hauteur de l'écran ;
- pas directement dans le coin.

Exemple :

```text
┌──────────────────────────────────────────────┐
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                              │
│                                      ●       │
│                                              │
└──────────────────────────────────────────────┘
```

La position exacte doit être configurable.

---

# 6. Déplacement de la pastille

L'utilisateur doit pouvoir :

- déplacer librement la pastille ;
- la placer à gauche ;
- la placer à droite ;
- la placer en haut ;
- la placer en bas ;
- éventuellement l'accrocher à un bord de l'écran.

Lorsque la pastille est accrochée à un bord, elle peut adopter un comportement discret de type bouton flottant.

La position doit être mémorisée.

---

# 7. Affichage au survol

La pastille doit pouvoir être survolée par la souris.

Le survol doit permettre d'afficher rapidement le contenu principal de MYA.

Le comportement exact pourra être défini pendant la conception graphique, mais l'objectif est :

> **Ne pas obliger l'utilisateur à ouvrir une fenêtre complète pour consulter ses tâches.**

Le clic doit également permettre d'ouvrir l'interface complète.

---

# 8. Mode toujours au-dessus

MYA doit proposer un bouton permettant d'activer ou désactiver le comportement :

> **Toujours au-dessus**

Lorsque ce mode est activé, la fenêtre MYA doit pouvoir rester visible au-dessus des autres applications.

Cela doit pouvoir fonctionner lorsque l'utilisateur :

- travaille dans Godot ;
- utilise un navigateur ;
- travaille dans un logiciel graphique ;
- utilise Word ;
- joue à un jeu.

Le comportement exact avec les jeux utilisant un véritable plein écran dépendra des possibilités techniques de Windows et sera documenté dans le cahier des charges technique.

---

# 9. Masquage

L'utilisateur doit pouvoir masquer rapidement MYA.

Un bouton doit permettre de cacher l'interface.

La pastille doit pouvoir rester disponible même lorsque le panneau principal est fermé.

L'utilisateur doit également pouvoir désactiver complètement l'affichage flottant.

---

# 10. Démarrage automatique

MYA doit pouvoir proposer :

> Lancer MYA au démarrage de Windows.

Cette option doit être activable ou désactivable.

---

# 11. Raccourci clavier global

MYA doit proposer un raccourci clavier permettant d'ouvrir rapidement l'interface d'ajout d'une tâche.

Exemple envisagé :

**Ctrl + Alt + Space**

Le raccourci définitif sera configurable si cela est techniquement pertinent.

---

# 12. Création rapide d'une tâche

La création d'une tâche doit être extrêmement rapide.

Exemple :

```text
┌────────────────────────────────────┐
│ Que dois-je retenir ?              │
│                                    │
│ Acheter câble USB-C                │
│                                    │
│                             [Entrée]│
└────────────────────────────────────┘
```

L'utilisateur saisit :

> Acheter câble USB-C

puis valide.

La tâche est immédiatement créée.

Aucun champ supplémentaire ne doit être obligatoire.

---

# 13. Création avancée

Après création, l'utilisateur peut éventuellement modifier la tâche.

Les options peuvent inclure :

- date ;
- rappel ;
- catégorie ;
- statut ;
- application associée ;
- paramètres supplémentaires.

Ces options doivent être accessibles sans gêner le processus de création rapide.

---

# 14. Structure d'une tâche

Une tâche MYA peut contenir au minimum :

- identifiant unique ;
- texte/titre ;
- statut ;
- catégorie ;
- date de création ;
- date éventuellement prévue ;
- date/heure de rappel éventuellement définie ;
- date de complétion si terminée ;
- application associée éventuellement ;
- informations de synchronisation.

Les sous-tâches ne font **pas partie du MVP**.

---

# 15. Pas de sous-tâches dans la première version

MYA ne doit pas proposer de hiérarchie complexe :

```text
Tâche
 ├── Sous-tâche
 │    ├── Sous-sous-tâche
 │    └── Sous-sous-tâche
```

Chaque élément est une tâche indépendante.

Cette décision pourra être réévaluée dans une version ultérieure, mais elle est volontairement exclue du MVP.

---

# 16. Organisation globale

MYA utilise une seule liste globale.

Il n'existe pas de système obligatoire de projets.

L'utilisateur ne doit pas avoir à choisir :

> Projet → Catégorie → Liste → Sous-liste → Tâche

pour ajouter un pense-bête.

Une tâche appartient simplement à la liste globale de l'utilisateur.

---

# 17. Catégories principales

MYA possède quatre catégories fonctionnelles principales.

## 17.1 BOUGE TON GROS CUL

Catégorie correspondant aux tâches nécessitant une action importante ou urgente.

Une tâche peut être placée manuellement dans cette catégorie.

Elle peut également y arriver automatiquement lorsqu'une échéance est atteinte ou dépassée.

---

## 17.2 AUJOURD'HUI

Catégorie regroupant les tâches dont la date prévue correspond à la date actuelle.

Exemple :

```text
📅 25 août

→ le 25 août :

🟠 AUJOURD'HUI
Faire les portraits
```

La tâche n'a pas besoin d'être déplacée manuellement.

---

## 17.3 ENSUITE

Tâches que l'utilisateur souhaite réaliser après les tâches actuelles.

Une tâche sans date peut être placée ici.

Exemple :

```text
🟡 ENSUITE

Corriger le dialogue
Créer les animations
```

---

## 17.4 À FAIRE SI J'AI LE TEMPS

Catégorie destinée aux tâches non prioritaires.

Elle permet de conserver des idées ou tâches utiles sans les présenter comme urgentes.

Exemple :

```text
⚪ À FAIRE SI J'AI LE TEMPS

Refaire les icônes
Ajouter des effets sonores
Améliorer l'interface
```

---

# 18. Catégories personnalisables

L'utilisateur doit pouvoir modifier le nom des catégories.

Par exemple :

```text
🔴 BOUGE TON GROS CUL
```

peut devenir :

```text
🔴 URGENT
```

ou :

```text
🔴 À FAIRE ABSOLUMENT
```

Le fonctionnement interne des catégories doit rester cohérent même si leur intitulé change.

L'humour par défaut doit cependant faire partie de l'identité de MYA.

---

# 19. Affectation manuelle

L'utilisateur doit pouvoir déplacer manuellement une tâche entre les catégories.

Exemple :

```text
À FAIRE SI J'AI LE TEMPS
        ↓
      ENSUITE
        ↓
     AUJOURD'HUI
        ↓
BOUGE TON GROS CUL
```

Le déplacement doit être possible avec un minimum d'interactions.

Le glisser-déposer peut être envisagé.

---

# 20. Gestion automatique des dates

Une tâche peut avoir une date sans avoir d'heure.

Exemple :

> Faire les portraits  
> 📅 25 août

Le 25 août, la tâche doit automatiquement apparaître dans la catégorie correspondant aux tâches du jour.

L'utilisateur ne doit pas avoir besoin de la déplacer manuellement.

---

# 21. Date et rappel sont deux informations différentes

Une date signifie :

> Je prévois cette tâche à cette date.

Un rappel signifie :

> Je veux que MYA m'avertisse à ce moment.

Ainsi :

```text
Faire les portraits
📅 25 août
```

n'implique pas obligatoirement une notification.

Mais l'utilisateur peut ajouter :

```text
🔔 25 août à 14h00
```

---

# 22. Rappels

Les rappels sont facultatifs.

Lorsqu'un rappel arrive, MYA doit utiliser une notification classique du système.

Pour le MVP :

- notification système ;
- pas de système sonore complexe ;
- pas de voix ;
- pas de comportement agressif.

La personnalisation avancée des notifications est repoussée à une version ultérieure.

---

# 23. Personnalité des notifications

Une fonctionnalité future doit permettre de choisir le ton des notifications.

Exemples :

### Normal

> N'oublie pas : Faire les portraits.

### Humoristique

> BOUGE TON GROS CUL — Faire les portraits.

### Brutal

> TU AVAIS DIT QUE TU LE FERAIS AUJOURD'HUI.

Le système doit être conçu de façon suffisamment souple pour permettre ultérieurement l'ajout d'autres personnalités.

Cette fonctionnalité n'est pas indispensable au MVP.

---

# 24. Animation de la pastille

Lorsqu'une tâche devient urgente ou lorsqu'un rappel intervient, la pastille MYA peut attirer brièvement l'attention de l'utilisateur.

L'animation doit rester :

- courte ;
- discrète ;
- configurable ;
- non stressante.

Elle ne doit pas provoquer une sensation permanente d'alerte.

---

# 25. Pas de compteur sur la pastille

La pastille ne doit pas afficher :

```text
● 7
```

ou :

```text
● 15
```

Le nombre de tâches doit rester invisible depuis la pastille.

Raison :

> MYA est un pense-bête et non une source de pression ou de stress.

---

# 26. Affichage de toutes les tâches

La fenêtre MYA doit permettre de consulter toutes les tâches actives.

Lorsque le nombre de tâches dépasse la hauteur disponible, une zone défilante doit être utilisée.

Les tâches ne doivent pas être limitées arbitrairement aux cinq prochaines.

L'utilisateur doit pouvoir consulter l'ensemble de ses tâches actives.

---

# 27. Tâches terminées

Lorsqu'une tâche est cochée :

1. elle passe dans l'état terminé ;
2. une animation visuelle peut être jouée ;
3. elle disparaît progressivement de la liste active ;
4. elle est conservée temporairement dans l'historique.

L'animation doit donner une sensation de progression satisfaisante sans être excessive.

---

# 28. Historique

L'historique des tâches terminées est temporaire.

L'utilisateur doit pouvoir choisir la durée de conservation.

Valeurs envisageables :

- aucun historique ;
- 1 jour ;
- 2 jours ;
- 3 jours ;
- 7 jours.

**Maximum : 7 jours.**

L'objectif n'est pas de constituer un historique professionnel permanent.

Les anciennes tâches terminées peuvent être supprimées automatiquement.

---

# 29. Pas de gestion de projet

MYA ne doit pas intégrer au MVP :

- projets complexes ;
- tableaux Kanban ;
- dépendances entre tâches ;
- diagrammes de Gantt ;
- rapports de productivité ;
- statistiques de productivité ;
- objectifs professionnels ;
- gestion d'équipe.

Ces fonctionnalités sont volontairement exclues.

---

# 30. Association avec une application Windows

Une tâche peut éventuellement être associée à une application installée sur le PC.

Exemple :

```text
🎨 Faire les portraits
```

avec Photoshop comme application associée.

Autre exemple :

```text
🎮 Tester le combat
```

avec Godot.

---

# 31. Icône d'application associée

Lorsqu'une tâche possède une application associée, MYA peut afficher l'icône correspondante.

Exemple :

```text
🎨 Faire les portraits
```

L'icône doit permettre de distinguer rapidement la tâche.

---

# 32. Lancement de l'application associée

Sur Windows, lorsque cela est techniquement possible, cliquer sur l'icône associée doit pouvoir lancer l'application.

Exemple :

```text
🎨 Faire les portraits
```

→ clic sur l'icône Photoshop  
→ lancement de Photoshop.

L'association doit pouvoir être configurée manuellement si MYA ne détecte pas automatiquement l'application.

---

# 33. Fonctionnalité locale uniquement

L'association avec les applications Windows est une fonctionnalité locale.

Elle ne doit pas tenter d'exécuter l'application associée sur téléphone.

Sur Android/iOS, la tâche reste simplement une tâche synchronisée.

---

# 34. Synchronisation

MYA doit synchroniser les tâches entre les appareils connectés au même compte.

Exemple :

```text
PC
 │
 ├── Créer une tâche
 │
 ▼
☁️ Synchronisation
 │
 ▼
Téléphone
```

et :

```text
Téléphone
 │
 ├── Cocher une tâche
 │
 ▼
☁️ Synchronisation
 │
 ▼
PC
```

La synchronisation doit être aussi rapide que raisonnablement possible.

---

# 35. Fonctionnement hors connexion

MYA doit idéalement continuer à fonctionner sans connexion Internet.

L'utilisateur doit pouvoir :

- consulter ses tâches ;
- créer des tâches ;
- modifier des tâches ;
- terminer des tâches ;
- ajouter des dates.

Lorsque la connexion revient, les modifications doivent être synchronisées.

---

# 36. Résolution des conflits

L'architecture devra prévoir les situations dans lesquelles une même tâche est modifiée sur deux appareils avant synchronisation.

Le cahier des charges technique devra définir une stratégie de résolution des conflits.

Pour le MVP, une stratégie simple et fiable est préférable à un système complexe.

---

# 37. Compte utilisateur

La synchronisation nécessite un compte.

La création du compte doit être aussi simple que possible.

Les méthodes privilégiées sont les comptes déjà utilisés par les utilisateurs :

- Google ;
- Apple ;
- Microsoft.

L'objectif est d'éviter un système d'inscription classique avec mot de passe lorsque cela n'est pas nécessaire.

---

# 38. Première utilisation

Lors de la première installation, l'utilisateur doit pouvoir commencer rapidement.

Exemple :

```text
Bienvenue dans MYA.

Move Your Ass.

[ Commencer ]
```

L'utilisateur ne doit pas être forcé de configurer immédiatement toutes les options.

Il doit pouvoir découvrir l'application avant de personnaliser son fonctionnement.

---

# 39. Synchronisation lors de la première connexion

Si l'utilisateur commence sans compte, ses données doivent rester locales.

Lorsqu'il décide de synchroniser :

> Se connecter

puis :

> Continuer avec Google  
> Continuer avec Apple  
> Continuer avec Microsoft

L'application doit ensuite envoyer ses tâches locales vers le compte selon une stratégie définie techniquement.

---

# 40. Application mobile

L'application mobile doit conserver la philosophie minimaliste de MYA.

L'écran principal doit afficher rapidement :

```text
🔴 BOUGE TON GROS CUL

Faire les portraits

🟠 AUJOURD'HUI

Corriger le dialogue
Tester le combat

🟡 ENSUITE

Créer les animations

⚪ SI J'AI LE TEMPS

Ajouter les effets sonores
```

---

# 41. Création rapide sur mobile

Un bouton clairement identifiable :

> **+ Ajouter un pense-bête**

doit être accessible rapidement.

L'utilisateur saisit simplement :

> Acheter du pain

puis valide.

Les options avancées restent facultatives.

---

# 42. Widget mobile

MYA doit proposer, lorsque les contraintes de la plateforme le permettent, un widget mobile.

Le widget doit afficher les tâches pertinentes sans obliger à ouvrir l'application.

Exemple :

```text
┌─────────────────────────┐
│ 🔴 BOUGE TON GROS CUL   │
│                         │
│ Faire les portraits     │
│                         │
│ 🟡 Corriger dialogue    │
│ 🟡 Tester le combat     │
└─────────────────────────┘
```

Le widget doit rester simple.

---

# 43. Interactions avec le widget

À étudier techniquement :

- ouvrir MYA ;
- cocher une tâche directement ;
- afficher la tâche suivante ;
- créer rapidement une tâche.

Les fonctions qui ne sont pas fiables sur les widgets mobiles doivent être limitées.

---

# 44. Notifications mobiles

MYA doit pouvoir utiliser les notifications natives du téléphone.

Exemple :

> 🔔 Faire les portraits  
> Rappel MYA

Les notifications sont facultatives.

---

# 45. Pas de tâches récurrentes

Le MVP ne doit pas proposer :

> Tous les jours.

ou :

> Tous les lundis.

Une tâche correspond à une action ponctuelle.

La répétition pourra être étudiée ultérieurement si elle s'avère nécessaire.

---

# 46. Navigation

La navigation doit rester extrêmement simple.

L'application doit privilégier :

- écran principal ;
- ajout ;
- détail/modification d'une tâche ;
- paramètres.

Il ne doit pas exister de dizaines de sections.

---

# 47. Paramètres

Les paramètres doivent regrouper notamment :

## Apparence

- thème clair/sombre ;
- taille de l'interface ;
- comportement de la pastille.

## Pastille

- position ;
- taille ;
- toujours au-dessus ;
- comportement au survol ;
- affichage/masquage.

## Notifications

- activer/désactiver ;
- ton ;
- rappels.

## Catégories

- noms personnalisés.

## Historique

- durée de conservation ;
- maximum 7 jours.

## Compte

- connexion ;
- synchronisation ;
- déconnexion.

---

# 48. Personnalisation visuelle

MYA doit proposer une interface moderne mais sobre.

L'utilisateur doit pouvoir choisir au minimum :

- thème clair ;
- thème sombre.

L'interface doit rester lisible et fonctionner sur des écrans de tailles différentes.

---

# 49. Accessibilité

Le produit doit prévoir :

- taille de texte raisonnable ;
- contraste suffisant ;
- utilisation sans souris lorsque possible ;
- raccourcis clavier sur Windows ;
- zones tactiles suffisamment grandes sur mobile.

---

# 50. Confidentialité

Les tâches personnelles de l'utilisateur doivent être considérées comme privées.

Le produit doit limiter la collecte de données au strict nécessaire.

Il ne doit pas collecter de contenu inutile à des fins statistiques sans consentement.

Le cahier des charges technique devra définir :

- données stockées localement ;
- données synchronisées ;
- données d'authentification ;
- données conservées sur le serveur ;
- suppression des données ;
- suppression du compte.

Le produit devra être conçu en tenant compte du RGPD pour une éventuelle publication en Europe.

---

# 51. Modèle économique envisagé

Le modèle économique définitif reste à déterminer.

Le produit est cependant conçu dès le départ pour pouvoir être publié sur :

- Google Play ;
- Apple App Store ;
- Microsoft Store ;
- éventuellement téléchargement direct.

L'application doit donc éviter les choix techniques empêchant une publication ultérieure.

---

# 52. Architecture fonctionnelle générale

Le fonctionnement global peut être représenté ainsi :

```text
                         ☁️ COMPTE MYA
                              │
                  ┌───────────┴───────────┐
                  │                       │
              🖥️ WINDOWS              📱 MOBILE
                  │                    /       \
                  │                 Android    iOS
                  │
             ┌────┴────┐
             │         │
          Pastille   Fenêtre
             │
             └────┬────┘
                  │
              Tâches
                  │
       ┌──────────┼──────────┐
       │          │          │
    🔴 Urgent  🟠 Aujourd'hui 🟡 Ensuite
                              │
                     ⚪ Si j'ai le temps
```

---

# 53. Flux principal : ajouter une tâche

```text
Utilisateur
    ↓
Raccourci / bouton +
    ↓
Saisie du texte
    ↓
Validation
    ↓
Tâche créée
    ↓
Catégorie déterminée
    ↓
Affichage immédiat
    ↓
Synchronisation
```

Aucune étape supplémentaire ne doit être obligatoire.

---

# 54. Flux principal : terminer une tâche

```text
Utilisateur coche la tâche
          ↓
Animation
          ↓
Tâche terminée
          ↓
Disparition de la liste active
          ↓
Historique temporaire
          ↓
Synchronisation
```

---

# 55. Flux principal : tâche datée

```text
Création
   ↓
Date définie
   ↓
Tâche reste dans sa catégorie appropriée
   ↓
Date atteinte
   ↓
Tâche apparaît dans AUJOURD'HUI
   ↓
Si définie comme urgente :
BOUGE TON GROS CUL
   ↓
Si rappel configuré :
Notification
```

Le détail exact de la priorité entre « urgence manuelle », « date du jour » et « date dépassée » devra être défini dans le cahier des charges technique.

---

# 56. Flux principal : tâche en retard

Une tâche dont la date est dépassée et qui n'est pas terminée doit être clairement identifiable.

MYA peut utiliser :

- une catégorie urgente ;
- un indicateur visuel ;
- un changement de texte ;
- une notification si un rappel a été défini.

Le système ne doit cependant pas devenir anxiogène.

---

# 57. MVP — fonctionnalités obligatoires

La première version fonctionnelle doit comprendre :

### Windows

- application MYA ;
- pastille flottante ;
- déplacement de la pastille ;
- position mémorisée ;
- ouverture du panneau principal ;
- masquage ;
- mode Always-on-Top activable ;
- création rapide ;
- raccourci global ;
- affichage des tâches ;
- défilement ;
- catégories ;
- déplacement entre catégories ;
- dates ;
- rappels ;
- tâches terminées ;
- historique configurable ;
- démarrage automatique ;
- stockage local.

### Mobile

- application Android ;
- application iOS si faisable dans le périmètre initial ;
- création rapide ;
- consultation des tâches ;
- modification ;
- suppression ;
- validation ;
- dates ;
- rappels ;
- synchronisation.

### Synchronisation

- compte ;
- authentification simple ;
- synchronisation PC/mobile ;
- fonctionnement hors connexion ;
- synchronisation après reconnexion.

---

# 58. Fonctionnalités souhaitées mais non obligatoires pour le MVP

Les fonctionnalités suivantes peuvent être intégrées si elles ne compromettent pas la stabilité :

- widget Android ;
- widget iOS ;
- détection des applications Windows ;
- association tâche/application ;
- lancement d'une application depuis MYA ;
- glisser-déposer avancé ;
- animations avancées ;
- personnalisation poussée des notifications.

---

# 59. Fonctionnalités explicitement repoussées

Ne pas développer dans le MVP :

- sous-tâches ;
- tâches récurrentes ;
- gestion de projets ;
- équipes ;
- partage de tâches ;
- Kanban ;
- statistiques ;
- gamification ;
- calendrier complet ;
- système complexe de priorités ;
- rapports de productivité ;
- système de notes ;
- messagerie ;
- IA.

---

# 60. Vision future

Après la V1, MYA pourra éventuellement évoluer vers :

- personnalités humoristiques ;
- packs de notifications ;
- personnalisation graphique ;
- commandes vocales ;
- intégration avec les applications ;
- raccourcis avancés ;
- widgets plus interactifs ;
- statistiques très légères ;
- intégration calendrier optionnelle.

Ces fonctionnalités ne doivent pas modifier la philosophie fondamentale du produit.

---

# 61. Principe anti-usine-à-gaz

Toute nouvelle fonctionnalité doit être évaluée selon la question :

> **Est-ce que cette fonctionnalité aide réellement l'utilisateur à se souvenir de ce qu'il doit faire, ou ajoute-t-elle simplement de la gestion ?**

Si elle ajoute principalement de la gestion, elle ne doit pas être intégrée au cœur de MYA.

---

# 62. Principe de rapidité

Une action courante doit nécessiter le moins d'interactions possible.

Objectifs :

### Ajouter une tâche simple

**1 saisie + validation.**

### Terminer une tâche

**1 interaction.**

### Consulter ses tâches

**1 survol ou 1 clic.**

### Ouvrir la création rapide

**1 raccourci clavier.**

### Consulter MYA sur mobile

**1 ouverture de l'application ou consultation du widget.**

---

# 63. Principe de faible pression

MYA doit rappeler les tâches sans transformer leur nombre en source de stress.

Conséquences :

- pas de compteur sur la pastille ;
- pas de score de productivité ;
- pas de séries quotidiennes ;
- pas de culpabilisation permanente ;
- notifications facultatives ;
- historique court ;
- interface simple.

L'humour « Bouge ton gros cul » doit être perçu comme une incitation amusante, pas comme une pression psychologique permanente.

---

# 64. Critère de réussite

MYA sera considéré comme réussi si l'utilisateur peut :

1. regarder rapidement l'écran ;
2. comprendre immédiatement ce qu'il doit faire ;
3. ajouter une nouvelle tâche en quelques secondes ;
4. cocher une tâche sans navigation complexe ;
5. retrouver les mêmes informations sur son téléphone ;
6. recevoir un rappel uniquement lorsqu'il le demande ;
7. continuer à utiliser l'application plusieurs heures par jour sans qu'elle devienne gênante.

---

# 65. Décision technologique provisoire

La technologie pressentie est **Flutter**, car MYA nécessite une application multiplateforme principalement orientée interface.

Le choix définitif doit toutefois être validé dans le cahier des charges technique en étudiant spécifiquement :

- fenêtre flottante Windows ;
- Always-on-Top ;
- raccourci clavier global ;
- démarrage automatique ;
- accès aux applications Windows ;
- notifications ;
- widgets Android ;
- widgets iOS ;
- stockage local ;
- synchronisation ;
- authentification ;
- publication sur les stores.

Godot n'est pas retenu a priori, malgré la familiarité du développeur avec cet outil, car MYA est une application utilitaire et non un jeu.

---

# 66. Décisions prises

Les décisions fonctionnelles actuellement arrêtées sont :

| Élément | Décision |
|---|---|
| Nom | MYA |
| Signification | Move Your Ass |
| Type | Pense-bête |
| Plateformes | Windows + Android + iOS |
| Liste | Une liste globale |
| Projets | Non |
| Sous-tâches | Non |
| Tâches récurrentes | Non |
| Pastille PC | Oui |
| Position initiale | Côté gauche/droit, environ 80 % de hauteur |
| Déplacement | Oui |
| Accrochage au bord | Oui |
| Always-on-Top | Oui, activable/désactivable |
| Masquage | Oui |
| Compteur sur pastille | Non |
| Création rapide | Oui |
| Raccourci global | Oui |
| Catégories | Oui |
| Catégorie humoristique | BOUGE TON GROS CUL |
| Catégories personnalisables | Oui |
| Date | Oui |
| Heure | Facultative |
| Rappel | Facultatif |
| Notifications | Classiques pour le MVP |
| Historique | Oui |
| Durée historique maximale | 7 jours |
| Application Windows associée | Oui, si techniquement possible |
| Application associée sur mobile | Non |
| Synchronisation | Oui |
| Quasi temps réel | Oui |
| Hors connexion | Oui |
| Compte | Oui pour synchronisation |
| Authentification | Google / Apple / Microsoft envisagés |
| Widget mobile | Oui |
| Notifications mobile | Oui |
| Ton humoristique | Oui |
| Personnalité des notifications | Prévue, pas indispensable au MVP |
| Technologie envisagée | Flutter |

---

