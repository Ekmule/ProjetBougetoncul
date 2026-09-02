# Cahier des charges technique — MYA

**Projet :** MYA — Move Your Ass  
**Version du document :** 1.0  
**Type :** Application de pense-bête multiplateforme  
**Plateformes prioritaires :** Windows / Android / iOS  
**Framework principal retenu :** Flutter  
**Backend envisagé :** Supabase  
**Base de données envisagée :** PostgreSQL via Supabase  
**Architecture :** Client local-first + synchronisation cloud  
**Statut :** Préparation du développement

---

# 1. Objectif technique

MYA doit être une application multiplateforme partageant une base de code Flutter commune autant que possible.

L'architecture doit toutefois respecter les particularités de chaque plateforme.

Le principe architectural est :

```text
                     ┌─────────────────┐
                     │   SUPABASE      │
                     │                 │
                     │ Auth            │
                     │ PostgreSQL      │
                     │ Realtime        │
                     │ API             │
                     └────────┬────────┘
                              │
                     Synchronisation
                              │
             ┌────────────────┴────────────────┐
             │                                 │
       ┌─────▼─────┐                     ┌─────▼─────┐
       │  WINDOWS  │                     │  MOBILE   │
       │  Flutter  │                     │  Flutter  │
       └─────┬─────┘                     └─────┬─────┘
             │                                 │
      ┌──────┴──────┐                    ┌─────┴─────┐
      │             │                    │           │
   stockage      services             Android       iOS
   local        Windows               natif         natif
```

L'application doit fonctionner correctement même lorsque le serveur n'est pas accessible.

---

# 2. Décision technologique

## 2.1 Flutter

Flutter est retenu comme framework principal.

Flutter supporte actuellement le déploiement vers Windows, Android et iOS dans les versions officiellement prises en charge.

Flutter permet également d'utiliser des plugins et du code natif spécifique à chaque plateforme.

Cette architecture convient particulièrement à MYA car :

- l'interface est majoritairement commune ;
- la logique métier peut être partagée ;
- le modèle de données est commun ;
- la synchronisation est commune ;
- Android/iOS/Windows peuvent recevoir chacun leurs intégrations natives.

---

# 3. Godot

Godot n'est pas retenu pour MYA.

Raison :

MYA est une application utilitaire et non un jeu.

Les fonctionnalités importantes sont :

- gestion de fenêtres ;
- notifications ;
- widgets ;
- authentification ;
- synchronisation ;
- stockage ;
- intégration système ;
- publication sur les stores.

Flutter est plus adapté à ce type d'application.

La connaissance préalable de Godot par le développeur ne doit pas influencer ce choix.

---

# 4. Architecture générale

Le projet doit utiliser une architecture en couches.

```text
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── configuration/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── services/
│
├── data/
│   ├── local/
│   ├── remote/
│   ├── models/
│   └── synchronization/
│
├── features/
│   ├── tasks/
│   ├── quick_add/
│   ├── floating_bubble/
│   ├── reminders/
│   ├── settings/
│   ├── authentication/
│   └── history/
│
├── platform/
│   ├── windows/
│   ├── android/
│   └── ios/
│
└── main.dart
```

Le code doit être organisé par responsabilité.

Aucune fonctionnalité ne doit être placée directement dans `main.dart` ou dans un énorme widget central.

---

# 5. Architecture logique

L'application doit séparer :

## Présentation

Flutter UI.

## Domaine

Règles métier de MYA.

## Données

Stockage local et distant.

## Synchronisation

Gestion des changements entre appareils.

## Plateforme

Fonctions spécifiques à Windows, Android et iOS.

---

# 6. Modèle de données

## 6.1 Task

Une tâche doit posséder au minimum :

```text
Task
├── id
├── userId
├── title
├── status
├── category
├── createdAt
├── updatedAt
├── plannedDate
├── reminderAt
├── completedAt
├── applicationLink
├── sortOrder
├── syncVersion
└── deletedAt
```

Toutes les propriétés optionnelles doivent être réellement optionnelles.

---

# 7. Identifiant

Chaque tâche doit utiliser un identifiant global unique.

Un UUID est recommandé.

L'identifiant est créé localement dès la création de la tâche.

Cela permet de créer une tâche hors connexion puis de la synchroniser plus tard.

---

# 8. Statut

Le statut doit être indépendant de la catégorie.

Exemple :

```text
TaskStatus

active
completed
deleted
```

Une tâche terminée ne doit pas être supprimée immédiatement de la base locale.

Elle passe temporairement en `completed`.

---

# 9. Catégorie

La catégorie doit être représentée par un identifiant stable plutôt que par son texte affiché.

Exemple :

```text
CategoryType

must_do
today
next
someday
```

Les intitulés visibles sont personnalisables.

Ainsi :

```text
must_do
```

peut afficher :

> BOUGE TON GROS CUL

ou :

> URGENT

sans modifier la logique interne.

---

# 10. Gestion des dates

Une tâche peut posséder :

```text
plannedDate = 2026-08-25
```

sans heure.

La date prévue est distincte du rappel.

---

# 11. Rappel

Un rappel est facultatif.

Exemple :

```text
plannedDate = 2026-08-25
reminderAt = 2026-08-25T14:00
```

Une tâche peut donc avoir :

- une date ;
- une date + heure de rappel ;
- aucune date.

---

# 12. Calcul de la catégorie affichée

Le système doit distinguer :

### catégorie choisie manuellement

et

### état calculé à partir de la date.

Exemple :

```text
Catégorie manuelle :
next

Date :
2026-08-25

Date actuelle :
2026-08-25
```

L'interface peut présenter la tâche dans :

> AUJOURD'HUI

sans modifier nécessairement la catégorie persistée.

Cette distinction doit être clairement définie dans le code.

---

# 13. Priorité des règles

Le système doit définir explicitement une priorité.

Proposition :

```text
1. Tâche terminée
2. Tâche en retard
3. Tâche urgente manuelle
4. Tâche prévue aujourd'hui
5. Catégorie manuelle ENSUITE
6. Catégorie SI J'AI LE TEMPS
```

La règle définitive doit être centralisée dans un service métier.

Elle ne doit jamais être dupliquée dans plusieurs widgets.

---

# 14. Dates dépassées

Une tâche dont `plannedDate` est antérieure à aujourd'hui et qui n'est pas terminée est considérée comme en retard.

Elle doit être visuellement identifiable.

Le comportement exact :

```text
plannedDate < today
AND status == active
```

doit produire un état `overdue`.

---

# 15. Tâches urgentes

L'utilisateur peut explicitement placer une tâche dans :

> BOUGE TON GROS CUL

Cette information doit être stockée.

Elle ne doit pas dépendre uniquement de la date.

---

# 16. Tâches terminées

Lorsqu'une tâche est terminée :

```text
status = completed
completedAt = now
```

L'application doit ensuite :

1. mettre à jour l'interface ;
2. afficher éventuellement l'animation ;
3. synchroniser ;
4. conserver la tâche pendant la durée d'historique définie.

---

# 17. Nettoyage de l'historique

La durée maximale est de 7 jours.

Le nettoyage doit être automatique.

Exemple :

```text
completedAt < now - retentionPeriod
```

→ suppression logique ou physique selon l'architecture de synchronisation.

La durée choisie doit être stockée dans les préférences utilisateur.

---

# 18. Stockage local

MYA doit être **local-first**.

Une base locale doit contenir les tâches.

Le choix précis de la technologie locale sera arrêté lors de l'implémentation, avec préférence pour une solution :

- SQLite/Drift ou équivalent ;
- transactionnelle ;
- compatible Windows/Android/iOS ;
- capable de gérer efficacement les changements locaux.

La base locale est la source utilisée par l'interface.

Le serveur ne doit pas être nécessaire pour afficher les tâches déjà présentes localement.

---

# 19. Pourquoi local-first ?

Cela permet :

- lancement rapide ;
- utilisation hors connexion ;
- création instantanée ;
- consultation instantanée ;
- meilleure résilience ;
- synchronisation différée.

L'utilisateur ne doit jamais attendre un aller-retour serveur pour cocher une tâche.

---

# 20. Architecture de synchronisation

La synchronisation doit être basée sur les changements.

Exemple :

```text
PC
 │
 │ Task A modified
 ▼
Local database
 │
 │ sync queue
 ▼
Supabase
 │
 │ realtime event
 ▼
Téléphone
 │
 ▼
Local database
```

---

# 21. File de synchronisation locale

Chaque modification importante doit pouvoir être enregistrée dans une file locale :

```text
SyncOperation
├── id
├── entityId
├── operationType
├── timestamp
├── payload
└── retryCount
```

Types :

```text
create
update
complete
delete
```

La synchronisation tente d'envoyer les opérations lorsque le réseau est disponible.

---

# 22. Realtime

Supabase Realtime est envisagé pour recevoir les changements distants.

Le SDK Flutter officiel de Supabase fournit l'accès à l'authentification, à PostgreSQL et aux fonctions Realtime.

L'application doit écouter les changements concernant uniquement l'utilisateur connecté.

---

# 23. Backend

**Supabase est le backend privilégié.**

Il fournit notamment :

- PostgreSQL ;
- authentification ;
- API ;
- Realtime ;
- stockage ;
- fonctions serveur.

Le SDK Flutter officiel est prévu pour l'intégration Flutter.

---

# 24. Base de données serveur

Table principale :

```text
tasks
```

Colonnes conceptuelles :

```text
id
user_id
title
category
status
planned_date
reminder_at
created_at
updated_at
completed_at
application_path
application_name
application_icon
sort_order
deleted_at
```

Les types exacts seront définis dans les migrations SQL.

---

# 25. Sécurité Supabase

Toutes les données utilisateur doivent être protégées par des politiques Row Level Security.

Principe :

```text
user_id == authenticated_user_id
```

Un utilisateur ne doit jamais pouvoir lire ou modifier les tâches d'un autre utilisateur.

La documentation Supabase recommande explicitement de vérifier les politiques RLS avant un déploiement en production.

---

# 26. Authentification

Les fournisseurs prioritaires sont :

- Google ;
- Apple ;
- Microsoft.

L'authentification email/mot de passe n'est pas nécessaire au MVP sauf nécessité technique ou décision ultérieure.

Supabase Flutter prend en charge les flux d'authentification OAuth et les intégrations natives Google/Apple.

Le flux PKCE doit être privilégié pour les flux nécessitant des deep links. Supabase Flutter utilise désormais PKCE comme flux par défaut pour ce type d'authentification.

---

# 27. Google

Google Sign-In doit être prévu pour :

- Android ;
- iOS ;
- éventuellement Windows via OAuth.

La configuration nécessitera les identifiants client propres aux plateformes.

---

# 28. Apple

Sign in with Apple doit être prévu pour iOS.

Une intégration native Apple est disponible avec Supabase Flutter via la dépendance Apple appropriée.

---

# 29. Microsoft

Microsoft OAuth doit être étudié comme fournisseur de connexion pour Windows.

L'objectif est de permettre aux utilisateurs Windows de se connecter sans créer un nouveau mot de passe MYA.

---

# 30. Session

La session utilisateur doit être persistante.

L'utilisateur ne doit pas devoir se reconnecter quotidiennement.

La déconnexion doit être disponible dans les paramètres.

---

# 31. Compte sans synchronisation

L'application doit idéalement pouvoir fonctionner sans compte.

Dans ce cas :

```text
Installation
↓
Créer des tâches
↓
Stockage local
```

La synchronisation est activée uniquement lorsque l'utilisateur se connecte.

---

# 32. Fusion des données lors de la première connexion

Cas :

```text
Utilisateur possède déjà :
3 tâches locales
```

Puis se connecte à un compte contenant :

```text
5 tâches cloud
```

L'application doit éviter de supprimer silencieusement les tâches locales.

Une stratégie de fusion doit être définie.

Pour le MVP :

> fusion des tâches locales et cloud, basée sur les UUID.

---

# 33. Conflits

Deux appareils peuvent modifier simultanément une tâche.

Exemple :

```text
PC :
Faire les portraits → terminé

Téléphone :
Faire les portraits → titre modifié
```

Une stratégie déterministe doit être utilisée.

Pour le MVP :

- conserver une version ;
- utiliser `updatedAt` ;
- appliquer une stratégie Last-Write-Wins contrôlée ;
- journaliser les erreurs de synchronisation.

La logique doit être centralisée.

---

# 34. Suppression

Une suppression synchronisée doit utiliser de préférence une suppression logique temporaire :

```text
deletedAt
```

Cela évite qu'un appareil hors ligne recrée involontairement une tâche supprimée.

Le nettoyage définitif pourra être effectué après une période de sécurité.

---

# 35. Gestion du réseau

L'application doit détecter :

- en ligne ;
- hors ligne ;
- reconnexion.

Une perte de réseau ne doit jamais provoquer de perte de données.

Les opérations non synchronisées restent en attente.

---

# 36. Notifications

Les notifications doivent utiliser les mécanismes natifs de chaque plateforme.

### Windows

Notification Windows.

### Android

Notification Android.

### iOS

Notification iOS.

Le MVP ne nécessite pas de serveur de notifications push pour les rappels strictement locaux.

---

# 37. Rappels locaux

Un rappel configuré par l'utilisateur doit être enregistré localement sur l'appareil.

Exemple :

```text
14:00
↓
notification locale
```

Cela évite de dépendre du serveur pour déclencher un rappel personnel.

La synchronisation doit toutefois transmettre l'information du rappel aux autres appareils si le comportement souhaité est de recevoir le rappel sur plusieurs appareils.

---

# 38. Pastille Windows

La pastille Windows est une fonctionnalité spécifique.

Flutter fournit le rendu de l'interface, mais les fonctions système peuvent nécessiter un plugin ou du code natif Windows. Flutter permet explicitement la création de plugins et l'appel au code Windows natif.

---

# 39. Fenêtre flottante

La fenêtre principale MYA doit pouvoir être :

- sans bordure ;
- redimensionnable selon le mode ;
- déplacée ;
- positionnée librement ;
- placée au-dessus des autres fenêtres ;
- masquée.

La gestion précise de la fenêtre doit être encapsulée dans un service :

```text
WindowService
```

Aucun widget métier ne doit directement manipuler les API Windows.

---

# 40. Always-On-Top

Le mode :

```text
Always On Top = true
```

doit être activable par l'utilisateur.

L'état doit être mémorisé localement.

Le comportement avec les applications utilisant un plein écran exclusif doit être testé séparément.

---

# 41. Pastille et panneau

La pastille et le panneau doivent être conçus comme deux états d'une même expérience.

```text
État A
●

       ↓ survol/clic

État B
┌─────────────────┐
│ Tâches MYA      │
│ ...             │
└─────────────────┘
```

Le système ne doit pas lancer plusieurs instances de MYA.

---

# 42. Barre système Windows

MYA doit idéalement rester accessible depuis la zone de notification Windows.

Fonctions :

- ouvrir MYA ;
- masquer MYA ;
- afficher/masquer la pastille ;
- activer/désactiver Always-On-Top ;
- quitter MYA.

---

# 43. Démarrage Windows

MYA doit pouvoir démarrer automatiquement avec Windows.

Cette option doit être désactivable.

Le démarrage doit être silencieux et ne pas ouvrir inutilement une grande fenêtre.

---

# 44. Raccourci global

Le raccourci global doit fonctionner même lorsque MYA n'est pas la fenêtre active.

Le package `hotkey_manager` est un candidat possible car il supporte les raccourcis système Windows dans les applications Flutter desktop.

Le choix définitif du package doit être validé avant implémentation.

Le raccourci par défaut envisagé est :

```text
Ctrl + Alt + Space
```

Il doit pouvoir être modifié ultérieurement.

---

# 45. Application Windows associée

Une tâche peut contenir une association locale :

```text
ApplicationLink
├── executablePath
├── displayName
└── icon
```

Exemple :

```text
C:\Program Files\Godot\Godot.exe
```

---

# 46. Sécurité des applications associées

MYA ne doit jamais exécuter automatiquement une application sans action explicite de l'utilisateur.

Le lancement doit être déclenché par un clic.

Les chemins doivent être validés.

---

# 47. Synchronisation de l'application associée

Le chemin local Windows ne doit pas être considéré comme une donnée universelle.

Une tâche peut synchroniser :

```text
applicationName = Godot
```

mais le chemin :

```text
C:\...\Godot.exe
```

reste spécifique à l'appareil.

Architecture recommandée :

```text
Task
 └── applicationReference = "godot"

Device
 └── local path = "C:\...\Godot.exe"
```

Cela évite d'envoyer un chemin Windows inutilisable sur Android/iOS.

---

# 48. Détection des applications

La détection automatique des applications installées est une fonctionnalité secondaire.

Elle pourra rechercher les applications pertinentes sur Windows.

La V1 peut également permettre :

> Parcourir → sélectionner un `.exe`

La détection automatique ne doit pas bloquer le développement du cœur de MYA.

---

# 49. Widget Android/iOS

Les widgets sont une fonctionnalité importante mais doivent être développés comme des composants natifs associés à Flutter.

Le package `home_widget` fournit une interface commune Flutter pour les widgets Android/iOS, mais la documentation précise que les widgets restent rendus/configurés avec les mécanismes natifs des plateformes.

Android dispose notamment de widgets pouvant afficher des collections et permettre certaines interactions, dont la validation d'éléments sur les versions modernes.

---

# 50. Widget Android

Le widget Android doit afficher :

- tâche urgente ;
- tâches du jour ;
- tâches suivantes.

Il doit rester compact.

Un widget de taille moyenne est la cible initiale.

---

# 51. Widget iOS

Le widget iOS doit afficher les informations essentielles.

Les interactions disponibles seront limitées par les capacités de WidgetKit.

Le widget doit donc être considéré principalement comme un affichage rapide avec accès à MYA.

---

# 52. Architecture des widgets

Les données nécessaires au widget doivent être synchronisées avec un stockage partagé approprié.

Le widget ne doit pas dépendre d'une instance Flutter active.

---

# 53. Mise à jour des widgets

Après modification d'une tâche :

```text
Flutter
 ↓
stockage partagé
 ↓
widget update
```

Les mécanismes natifs de chaque plateforme doivent être utilisés.

---

# 54. Création rapide mobile

L'écran mobile principal doit avoir une action :

```text
+ Ajouter
```

L'utilisateur saisit le texte.

Validation immédiate.

Les paramètres avancés sont secondaires.

---

# 55. Architecture UI

Les écrans principaux sont :

```text
Home
├── tâches
├── ajouter
└── paramètres

TaskDetail
├── titre
├── date
├── rappel
├── catégorie
└── application Windows

Settings
├── apparence
├── notifications
├── pastille
├── catégories
├── historique
└── compte
```

---

# 56. Responsive design

L'interface Flutter doit s'adapter :

- petit téléphone ;
- grand téléphone ;
- tablette ;
- fenêtre Windows compacte ;
- fenêtre Windows agrandie.

Les tailles ne doivent pas être codées en dur.

Flutter recommande une conception adaptative et responsive lorsqu'une application cible plusieurs plateformes.

---

# 57. État de l'application

Le système de gestion d'état doit être choisi avant le développement.

Recommandation :

- Riverpod ou équivalent moderne ;
- architecture réactive ;
- séparation claire entre état UI et données.

La décision définitive doit être prise avant de générer le code.

---

# 58. Repository pattern

Les fonctionnalités métier doivent dépendre d'interfaces :

```text
TaskRepository
```

et non directement de Supabase.

Exemple conceptuel :

```text
TaskRepository
   │
   ├── LocalTaskRepository
   └── SyncTaskRepository
```

Cela permet de tester l'application sans backend.

---

# 59. Services principaux

Les services prévus sont :

```text
TaskService
SyncService
AuthService
NotificationService
ReminderService
WindowService
HotkeyService
ApplicationLauncherService
SettingsService
HistoryService
WidgetService
```

Chaque service doit avoir une responsabilité claire.

---

# 60. Gestion des paramètres

Les préférences locales comprennent notamment :

```text
theme
floatingBubbleEnabled
floatingBubblePosition
alwaysOnTop
startupWithWindows
historyRetentionDays
notificationStyle
categoryLabels
globalHotkey
```

Les paramètres purement locaux ne doivent pas nécessairement être synchronisés.

---

# 61. Données synchronisées

Doivent être synchronisées :

- tâches ;
- catégories personnalisées ;
- dates ;
- rappels ;
- préférences utilisateur qui doivent être communes entre appareils, si retenues.

Ne doivent pas être synchronisées comme données universelles :

- position de la pastille Windows ;
- chemin d'un `.exe` ;
- état Always-On-Top ;
- raccourci Windows ;
- paramètres spécifiques à l'écran.

---

# 62. Configuration par appareil

Une table ou un stockage local de configuration d'appareil pourra être utilisé :

```text
DeviceSettings
├── deviceId
├── platform
├── floatingPosition
├── alwaysOnTop
├── startupEnabled
└── applicationMappings
```

---

# 63. Gestion du temps

Les dates et heures doivent être stockées de façon cohérente.

Recommandation :

- dates sans heure : représentation de date locale ;
- rappels : timestamp avec timezone ;
- synchronisation serveur : UTC lorsque pertinent.

Le système doit éviter les erreurs liées au changement d'heure.

---

# 64. Tests unitaires

Les règles métier doivent être testées indépendamment de l'interface.

Tests obligatoires :

- tâche sans date ;
- tâche avec date ;
- tâche aujourd'hui ;
- tâche future ;
- tâche en retard ;
- tâche urgente ;
- tâche terminée ;
- expiration de l'historique ;
- rappel ;
- changement de catégorie ;
- synchronisation ;
- suppression ;
- conflits.

---

# 65. Tests d'intégration

Tester :

- création locale → serveur ;
- serveur → appareil ;
- PC → téléphone ;
- téléphone → PC ;
- hors connexion → reconnexion ;
- modification simultanée ;
- suppression hors ligne ;
- première connexion ;
- fusion des données.

---

# 66. Tests Windows

Tests obligatoires :

- Windows 10 ;
- Windows 11 ;
- résolution 1920×1080 ;
- résolution supérieure ;
- plusieurs écrans ;
- changement d'écran ;
- changement de DPI ;
- déplacement de la pastille ;
- Always-On-Top ;
- lancement automatique ;
- raccourci global ;
- fermeture ;
- redémarrage.

Flutter prend actuellement en charge officiellement Windows 10 et 11 pour ses builds Windows.

---

# 67. Tests jeux

Tester MYA avec :

- application fenêtrée ;
- borderless fullscreen ;
- plein écran exclusif si possible.

Le comportement Always-On-Top ne doit pas être garanti lorsqu'un jeu monopolise le mode plein écran exclusif.

---

# 68. Tests mobiles

Android :

- différentes tailles d'écran ;
- widget ;
- notification ;
- mode hors connexion ;
- reconnexion ;
- rotation si pertinente.

iOS :

- différentes tailles d'écran ;
- widget ;
- notification ;
- arrière-plan ;
- reconnexion ;
- gestion de la batterie.

---

# 69. Performance

MYA doit rester extrêmement léger.

La pastille ne doit pas :

- consommer beaucoup de CPU ;
- maintenir inutilement des animations ;
- générer des requêtes réseau permanentes ;
- empêcher Windows de dormir ;
- consommer inutilement la batterie mobile.

Le système Realtime doit être correctement arrêté ou suspendu lorsque l'application n'en a plus besoin.

---

# 70. Synchronisation intelligente

MYA ne doit pas synchroniser continuellement des données inutiles.

Les changements doivent être envoyés uniquement lorsqu'ils sont nécessaires.

Le Realtime sert principalement à recevoir les changements distants.

---

# 71. Sécurité du client

Aucune clé secrète Supabase ne doit être incluse dans le dépôt Git.

Les clés publiques nécessaires au client peuvent être utilisées selon les recommandations Supabase, mais les secrets serveur doivent rester côté backend.

Les variables d'environnement doivent être utilisées pour les configurations de développement/déploiement. Supabase recommande explicitement de ne pas committer les secrets et de gérer les credentials de production correctement.

---

# 72. Git

Le projet doit être versionné avec Git.

Branches recommandées :

```text
main
develop
feature/*
fix/*
release/*
```

Pour un projet individuel, l'organisation peut rester plus simple :

```text
main
feature/*
```

---

# 73. Environnement de développement

Le développement Windows nécessite :

- Flutter SDK ;
- Dart ;
- Visual Studio avec les outils de développement desktop Windows ;
- Android Studio pour Android ;
- Xcode pour iOS.

La compilation iOS nécessite un environnement macOS. Flutter documente explicitement que le développement iOS doit être effectué sur macOS.

Cela signifie que le développement initial peut être effectué sur Windows pour :

- Windows ;
- Android ;

mais qu'une machine/macOS sera nécessaire pour produire et tester correctement la version iOS.

---

# 74. Packages à étudier

Les packages ne doivent pas être ajoutés automatiquement sans justification.

Candidats :

```text
supabase_flutter
```

Backend/auth/synchronisation.

```text
hotkey_manager
```

Raccourcis globaux desktop.

```text
home_widget
```

Widgets Android/iOS.

Un package de gestion de fenêtres Windows devra également être évalué.

Pour le stockage local, une solution SQLite/Drift ou équivalente doit être comparée.

---

# 75. Principe de sélection des packages

Avant d'ajouter un package :

1. vérifier sa maintenance ;
2. vérifier sa compatibilité Flutter actuelle ;
3. vérifier ses plateformes ;
4. vérifier sa licence ;
5. vérifier son activité GitHub/pub.dev ;
6. vérifier ses limitations ;
7. vérifier qu'il n'existe pas une API Flutter/native plus appropriée.

Ne pas multiplier les dépendances inutilement.

---

# 76. Architecture des plugins natifs

Si un package ne permet pas une fonctionnalité suffisamment fiable, MYA pourra utiliser un plugin natif.

Flutter permet explicitement d'écrire des plugins utilisant :

- Kotlin/Java pour Android ;
- Swift/Objective-C pour iOS ;
- C++ pour Windows.

Les intégrations natives doivent rester isolées derrière des interfaces Dart.

---

# 77. Publication Android

MYA doit être préparé pour Google Play.

Le pipeline devra produire une application Android signée.

La publication devra prévoir :

- application ID définitif ;
- icône ;
- captures d'écran ;
- description ;
- politique de confidentialité ;
- classification ;
- signature ;
- versioning.

---

# 78. Publication iOS

La publication nécessitera :

- Apple Developer ;
- bundle identifier ;
- certificats/signature ;
- App Store Connect ;
- captures d'écran ;
- politique de confidentialité ;
- configuration Sign in with Apple ;
- widget extension.

Flutter documente un processus de publication iOS spécifique.

---

# 79. Publication Windows

Le Microsoft Store est une possibilité officielle pour les applications Flutter Windows. Flutter documente la création de packages MSIX et leur publication via Partner Center.

Le projet doit donc être compatible avec :

```text
MSIX
```

La publication Microsoft Store nécessite notamment un compte/adhésion développeur approprié et le respect des politiques du Store.

---

# 80. Distribution Windows alternative

MYA pourra également être distribué directement sous forme d'installateur Windows.

Le Microsoft Store ne doit pas être l'unique voie de distribution.

---

# 81. CI/CD

Une fois le MVP stabilisé, le projet pourra utiliser GitHub Actions ou un service CI/CD approprié.

Pipeline :

```text
Git push
   ↓
Tests
   ↓
Build
   ↓
Artifacts
   ↓
Release
```

Les stores ne doivent pas être intégrés au pipeline avant que les builds manuels soient fiables.

---

# 82. Gestion des versions

Format :

```text
MAJOR.MINOR.PATCH
```

Exemple :

```text
0.1.0
0.2.0
1.0.0
```

Le build number est géré séparément selon les contraintes de chaque plateforme.

---

# 83. MVP technique

Le MVP technique doit être développé dans cet ordre.

## Phase 1

Projet Flutter multiplateforme.

## Phase 2

Modèle Task.

## Phase 3

Stockage local.

## Phase 4

Interface principale.

## Phase 5

Création rapide.

## Phase 6

Catégories.

## Phase 7

Dates.

## Phase 8

Tâches terminées.

## Phase 9

Rappels locaux.

## Phase 10

Pastille Windows.

## Phase 11

Always-On-Top.

## Phase 12

Raccourci global.

## Phase 13

Authentification.

## Phase 14

Supabase.

## Phase 15

Synchronisation.

## Phase 16

Android.

## Phase 17

Widget Android.

## Phase 18

iOS.

## Phase 19

Widget iOS.

## Phase 20

Tests.

## Phase 21

Publication.

---

# 84. Ordre de développement recommandé

Il ne faut surtout pas commencer par Supabase.

La première version doit fonctionner entièrement hors ligne.

Architecture :

```text
Flutter
 ↓
TaskService
 ↓
LocalDatabase
```

Puis :

```text
Flutter
 ↓
TaskService
 ↓
LocalDatabase
 ↓
SyncService
 ↓
Supabase
```

Cela réduit considérablement la complexité du développement initial.

---

# 85. Prototype Windows

Avant de développer toute l'application, réaliser un prototype uniquement Windows capable de :

1. afficher la pastille ;
2. déplacer la pastille ;
3. ouvrir le panneau ;
4. créer une tâche ;
5. afficher les catégories ;
6. masquer le panneau ;
7. activer Always-On-Top ;
8. utiliser le raccourci global.

Ce prototype doit valider la fonctionnalité la plus spécifique de MYA :

> **la présence discrète et permanente sur le bureau.**

---

# 86. Critère de validation du prototype

Le prototype est validé si :

- la pastille reste stable ;
- elle ne gêne pas l'utilisation normale de Windows ;
- elle peut être déplacée ;
- elle peut être accrochée ;
- le panneau s'ouvre rapidement ;
- Always-On-Top fonctionne ;
- le raccourci global fonctionne ;
- aucune seconde instance n'est créée ;
- l'application ne consomme pas excessivement de ressources.

---

# 87. Prototype mobile

Le prototype mobile doit ensuite valider :

- affichage des tâches ;
- création ;
- modification ;
- validation ;
- notification ;
- widget.

La synchronisation peut être simulée dans cette phase.

---

# 88. Prototype synchronisation

Avant d'intégrer toutes les fonctionnalités :

```text
PC
↓
Supabase
↓
Téléphone
```

Tester uniquement :

- création ;
- modification ;
- suppression ;
- terminaison.

Puis ajouter les dates et rappels.

---

# 89. Risque technique principal

Le risque principal du projet n'est **pas Flutter lui-même**.

Les principales difficultés sont :

### 1. Fenêtre flottante Windows

Gestion native de fenêtre.

### 2. Widgets mobiles

Chaque système possède ses propres contraintes.

Les widgets Android ont notamment des limitations propres aux interactions disponibles.

### 3. Synchronisation offline-first

C'est probablement la partie backend la plus délicate.

### 4. Authentification multiplateforme

Google/Apple/Microsoft nécessitent des configurations différentes.

### 5. Publication iOS

Elle nécessite un environnement macOS et les configurations Apple correspondantes.

---

# 90. Risques à éviter absolument

Ne pas :

- mettre toute la logique dans les widgets Flutter ;
- faire dépendre l'interface de Supabase ;
- stocker les tâches uniquement dans le cloud ;
- ajouter 30 packages dès le départ ;
- créer un énorme service `AppManager`;
- mélanger logique métier et code Windows ;
- mettre les chemins `.exe` dans les données synchronisées ;
- rendre les notifications obligatoires ;
- créer un système de tâches complexe.

---

# 91. Principe de développement avec Cursor

Cursor doit recevoir des instructions strictes.

Il doit :

- lire les documents du projet avant de modifier le code ;
- respecter l'architecture ;
- ne pas ajouter de fonctionnalité non demandée ;
- ne pas changer de framework ;
- ne pas remplacer Supabase sans justification ;
- ne pas modifier le modèle de données sans documenter la migration ;
- ne pas ajouter de package sans justification ;
- produire des tests pour les règles métier ;
- signaler les incertitudes techniques ;
- ne pas inventer les APIs des plateformes.

---

# 92. Documentation du projet

Le dépôt doit contenir :

```text
/docs
├── functional-spec.md
├── technical-spec.md
├── architecture.md
├── database.md
├── synchronization.md
├── windows.md
├── android.md
├── ios.md
├── deployment.md
└── decisions.md
```

Chaque décision technique importante doit être documentée.

---

# 93. Architecture des décisions

Créer un fichier :

```text
docs/decisions.md
```

Chaque décision importante doit contenir :

```text
Decision
Context
Options considered
Chosen solution
Reason
Consequences
Date
```

Cela empêchera Cursor de revenir constamment sur des choix déjà validés.

---

# 94. Première structure du repository

Structure cible :

```text
mya/
│
├── lib/
├── test/
├── integration_test/
├── android/
├── ios/
├── windows/
├── docs/
├── assets/
│
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── .gitignore
```

---

# 95. Assets

Les assets doivent être séparés :

```text
assets/
├── icons/
├── images/
├── sounds/
└── fonts/
```

Le MVP doit utiliser très peu d'assets.

---

# 96. Son

Le son n'est pas obligatoire dans le MVP.

Les notifications utilisent les mécanismes natifs.

Les sons humoristiques ou personnalisés seront une fonctionnalité future.

---

# 97. Analytics

Aucune analytics intrusive dans le MVP.

Si des statistiques anonymisées sont ajoutées ultérieurement, elles devront :

- être documentées ;
- respecter le RGPD ;
- ne pas collecter le contenu des tâches ;
- être désactivables si nécessaire.

---

# 98. RGPD

Pour une publication européenne, MYA devra prévoir :

- politique de confidentialité ;
- droit de suppression ;
- suppression du compte ;
- suppression des données ;
- information sur les données collectées ;
- minimisation des données.

Les tâches utilisateur doivent être considérées comme des données privées.

---

# 99. Suppression du compte

L'utilisateur doit pouvoir demander la suppression de son compte et de ses données synchronisées.

La procédure exacte sera définie avant publication.

---

# 100. Sauvegarde

Le backend doit assurer la persistance des données synchronisées.

Une stratégie de sauvegarde PostgreSQL doit être définie avant la mise en production.

Le stockage local ne doit pas être considéré comme la seule sauvegarde.

---

# 101. Évolutivité

L'architecture doit permettre ultérieurement :

- plusieurs appareils ;
- nouveaux systèmes d'exploitation ;
- nouvelles méthodes de connexion ;
- nouvelles personnalités ;
- nouvelles fonctionnalités de notification ;
- partage éventuel.

Mais aucune de ces fonctionnalités ne doit être développée prématurément.

---

# 102. Coût

Le backend doit être choisi pour permettre de commencer avec un coût très faible.

Supabase est intéressant pour le MVP car son SDK Flutter fournit déjà les briques d'authentification, base de données et Realtime nécessaires.

Les coûts réels devront être recalculés au moment du lancement commercial selon les tarifs en vigueur et le nombre d'utilisateurs.

---

# 103. Architecture finale cible

```text
                         ┌───────────────────────┐
                         │       SUPABASE        │
                         │                       │
                         │ Authentication       │
                         │ PostgreSQL            │
                         │ Row Level Security    │
                         │ Realtime               │
                         └───────────┬───────────┘
                                     │
                              Synchronisation
                                     │
                 ┌───────────────────┴───────────────────┐
                 │                                       │
          ┌──────▼──────┐                         ┌──────▼──────┐
          │   WINDOWS   │                         │   MOBILE    │
          │             │                         │             │
          │ Flutter UI  │                         │ Flutter UI  │
          │             │                         │             │
          │ TaskService │                         │ TaskService │
          └──────┬──────┘                         └──────┬──────┘
                 │                                       │
       ┌─────────┼──────────┐                   ┌────────┼────────┐
       │         │          │                   │        │        │
    SQLite   WindowService Hotkey          SQLite  Notification Widget
       │         │          │                   │        │        │
       │      Windows       │                   │      Native    Native
       │       API          │                   │
       └─────────┴──────────┘                   └─────────────────┘
```

---

# 104. Résumé des choix techniques

| Domaine | Choix |
|---|---|
| Framework | Flutter |
| Langage | Dart |
| Windows | Flutter + intégration native Windows |
| Android | Flutter + Kotlin si nécessaire |
| iOS | Flutter + Swift si nécessaire |
| Backend | Supabase |
| Base serveur | PostgreSQL |
| Auth | Google / Apple / Microsoft |
| Realtime | Supabase Realtime |
| Base locale | SQLite/Drift ou équivalent |
| Architecture | Local-first |
| Synchronisation | File locale + Realtime |
| Notifications | Natives |
| Widget | Native Android/iOS via abstraction Flutter |
| Pastille Windows | Fenêtre native/Flutter |
| Always-On-Top | API Windows/plugin |
| Hotkey | Plugin global ou intégration native |
| Application `.exe` | Windows uniquement |
| Historique | Local + synchronisé selon besoin |
| CI/CD | GitHub Actions ou équivalent |
| Windows Store | MSIX |
| Android Store | Google Play |
| iOS Store | App Store |

---

# 105. Décisions encore à prendre avant le développement

Les points suivants doivent être décidés avant de commencer le développement complet :

1. package exact de gestion des fenêtres Windows ;
2. package exact de stockage local ;
3. solution exacte de gestion d'état Flutter ;
4. package exact de notifications ;
5. solution exacte pour les widgets ;
6. comportement précis du panneau au survol ;
7. règles définitives de priorité entre urgence/date/catégorie ;
8. stratégie exacte de conflit de synchronisation ;
9. stratégie de fusion lors de la première connexion ;
10. modèle exact de base PostgreSQL ;
11. design visuel ;
12. identité graphique de MYA ;
13. fournisseur d'authentification Microsoft ;
14. politique de confidentialité ;
15. modèle économique ;
16. comptes développeur et publication.

Ces décisions doivent être documentées dans `docs/decisions.md`.

---

# 106. Ordre recommandé avant Cursor

Le projet ne doit pas encore être confié à Cursor avec la consigne :

> « Développe MYA. »

La procédure recommandée est :

```text
CAHIER DES CHARGES FONCTIONNEL
              ↓
CAHIER DES CHARGES TECHNIQUE
              ↓
VALIDATION DES PACKAGES
              ↓
MAQUETTES UI
              ↓
SCHÉMA BASE DE DONNÉES
              ↓
PROTOTYPE WINDOWS
              ↓
VALIDATION
              ↓
PROTOTYPE MOBILE
              ↓
SYNCHRONISATION
              ↓
MVP
              ↓
BÊTA
              ↓
PUBLICATION
```

---

# 107. Conclusion technique

Flutter est retenu comme technologie principale.

L'architecture recommandée est :

> **Flutter + stockage local + Supabase + intégrations natives ciblées.**

Cette architecture permet de conserver une grande partie du code commune entre Windows, Android et iOS tout en traitant correctement les fonctions spécifiques aux plateformes.

Flutter dispose actuellement d'un support officiel Windows/Android/iOS et d'un mécanisme prévu pour intégrer du code natif lorsque les fonctionnalités multiplateformes ne suffisent pas.

Supabase constitue une solution cohérente pour le backend du MVP : son SDK Flutter couvre actuellement l'authentification, la base de données et Realtime.

Les widgets mobiles sont réalisables, mais doivent être considérés comme des composants spécifiques Android/iOS plutôt que comme de simples widgets Flutter.

La fonctionnalité techniquement la plus distinctive de MYA reste la **pastille Windows flottante**, qui doit donc être prototypée avant d'investir dans le reste du produit.

Enfin, la publication Windows est compatible avec Flutter via notamment MSIX/Microsoft Store, tandis que Flutter documente également les procédures de publication Android et iOS.

**Prochaine étape recommandée :** réaliser le document `ARCHITECTURE.md` et surtout **figer les choix techniques encore ouverts** (base locale, gestion d'état, fenêtres Windows, notifications et widgets) avant de produire le prompt définitif destiné à Cursor.