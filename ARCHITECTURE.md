Oui. Je te conseille de faire de `ARCHITECTURE.md` le **document central que Cursor devra lire avant toute modification du code**. Il doit être plus prescriptif que le cahier des charges : il fixe *comment* MYA doit être construit et évite que Cursor change d'architecture en cours de route.

Je peux aussi ensuite te produire les autres fichiers (`database.md`, `synchronization.md`, `windows.md`, etc.) afin de constituer un véritable dossier technique cohérent.

Voici le contenu prêt à enregistrer sous **`docs/ARCHITECTURE.md`** :

````markdown
# MYA — Architecture technique

**Projet :** MYA — Move Your Ass  
**Document :** Architecture technique  
**Version :** 1.0  
**Statut :** Référence technique du projet  
**Dernière mise à jour :** 2026-08-23

---

# 1. Objectif du document

Ce document définit l'architecture technique de MYA.

Il constitue une référence obligatoire pour toute modification importante du projet.

Tout développeur humain ou agent IA travaillant sur MYA doit :

1. lire ce document avant toute modification architecturale ;
2. respecter les responsabilités définies ici ;
3. ne pas déplacer une responsabilité d'une couche à une autre sans justification ;
4. ne pas ajouter une dépendance importante sans la documenter ;
5. ne pas modifier le backend ou le modèle de données sans mettre à jour la documentation correspondante ;
6. ne pas contourner les abstractions définies par cette architecture.

Une décision contraire à ce document doit être explicitement documentée dans :

`docs/decisions.md`

---

# 2. Philosophie générale

MYA est une application de pense-bête multiplateforme.

Elle doit rester :

- simple ;
- rapide ;
- disponible hors connexion ;
- peu consommatrice de ressources ;
- immédiatement utilisable ;
- synchronisée entre appareils ;
- adaptée à Windows, Android et iOS.

La complexité technique doit rester invisible pour l'utilisateur.

Principe fondamental :

> L'utilisateur doit pouvoir créer ou consulter une tâche immédiatement, même sans connexion Internet.

---

# 3. Architecture générale

MYA utilise une architecture :

**Local-first + synchronisation cloud + intégrations natives par plateforme.**

Architecture générale :

```text
                        ┌───────────────────────────┐
                        │         SUPABASE          │
                        │                           │
                        │ Authentication            │
                        │ PostgreSQL                │
                        │ Row Level Security        │
                        │ Realtime                  │
                        └─────────────┬─────────────┘
                                      │
                              Synchronisation
                                      │
             ┌────────────────────────┴────────────────────────┐
             │                                                 │
       ┌─────▼─────┐                                     ┌─────▼─────┐
       │  WINDOWS  │                                     │  MOBILE   │
       │           │                                     │           │
       │ Flutter   │                                     │ Flutter   │
       │           │                                     │           │
       │ Services  │                                     │ Services  │
       └─────┬─────┘                                     └─────┬─────┘
             │                                                 │
       ┌─────┼─────────────┐                         ┌──────────┼──────────┐
       │     │             │                         │          │          │
    Local  Windows      Hotkeys                   Local    Notifications Widgets
    DB     Window       Native                    DB       Native        Native
       │     │             │                         │          │          │
       └─────┴─────────────┘                         └──────────┴──────────┘
````

---

# 4. Plateformes

MYA cible :

1. Windows
2. Android
3. iOS

Flutter est le framework principal.

Le code commun doit être maximisé.

Cependant, les fonctionnalités spécifiques aux plateformes doivent utiliser les APIs natives lorsque nécessaire.

---

# 5. Règle fondamentale : Flutter n'est pas la plateforme

Flutter constitue la couche applicative commune.

Il ne doit pas être utilisé pour simuler artificiellement des fonctionnalités natives lorsque celles-ci nécessitent une intégration système.

Exemples :

### Flutter

* interface ;
* navigation ;
* logique métier ;
* gestion des tâches ;
* affichage des catégories ;
* synchronisation ;
* paramètres.

### Windows natif

* fenêtre flottante ;
* Always-On-Top ;
* raccourci global ;
* démarrage Windows ;
* lancement d'applications `.exe` ;
* intégration avec la zone de notification.

### Android natif

* widget ;
* notifications ;
* services spécifiques Android.

### iOS natif

* widget ;
* notifications ;
* intégration Apple ;
* fonctionnalités spécifiques iOS.

---

# 6. Architecture en couches

L'application est organisée selon les couches suivantes :

```text
Presentation
     ↓
Application
     ↓
Domain
     ↓
Data
     ↓
Infrastructure
```

Une dépendance doit normalement aller de haut en bas.

Une couche inférieure ne doit jamais dépendre directement d'un widget Flutter.

---

# 7. Couche Presentation

Responsabilité :

Afficher l'état de l'application et recueillir les interactions utilisateur.

Contient notamment :

* pages ;
* widgets ;
* composants visuels ;
* animations ;
* formulaires ;
* navigation.

Exemple :

```text
TaskListPage
TaskCard
FloatingBubble
TaskCreationDialog
SettingsPage
```

La couche Presentation ne doit pas :

* appeler directement Supabase ;
* écrire directement dans SQLite ;
* manipuler les APIs Windows ;
* contenir les règles métier principales.

---

# 8. Couche Application

Cette couche orchestre les actions utilisateur.

Exemples :

```text
CreateTask
CompleteTask
DeleteTask
UpdateTask
MoveTask
SetReminder
SyncTasks
```

Elle fait le lien entre l'interface et le domaine.

Exemple :

```text
User clicks "Terminer"
        ↓
CompleteTask
        ↓
TaskRepository.complete()
        ↓
Local database
        ↓
Sync queue
```

---

# 9. Couche Domain

La couche Domain contient les règles métier de MYA.

Elle doit être indépendante de :

* Flutter ;
* Supabase ;
* SQLite ;
* Windows ;
* Android ;
* iOS.

Le domaine doit pouvoir être testé sans lancer l'interface.

---

# 10. Entités principales

Les principales entités sont :

```text
Task
Category
Reminder
ApplicationReference
UserSettings
DeviceSettings
```

Les entités ne doivent pas contenir de dépendances vers des frameworks externes lorsque cela peut être évité.

---

# 11. Task

Structure conceptuelle :

```text
Task
├── id
├── userId
├── title
├── category
├── status
├── plannedDate
├── reminderAt
├── createdAt
├── updatedAt
├── completedAt
├── applicationReference
├── sortOrder
├── syncVersion
└── deletedAt
```

---

# 12. Statut d'une tâche

Le statut est indépendant de la catégorie.

Valeurs :

```text
active
completed
deleted
```

Une tâche terminée n'est pas immédiatement supprimée.

---

# 13. Catégorie

Les catégories internes sont identifiées par des valeurs stables.

Exemple :

```text
must_do
today
next
someday
```

Les noms visibles sont personnalisables.

Par défaut :

```text
must_do → BOUGE TON GROS CUL
today   → AUJOURD'HUI
next    → ENSUITE
someday → À FAIRE SI J'AI LE TEMPS
```

Les chaînes affichées ne doivent jamais être utilisées comme identifiants métier.

---

# 14. Date et catégorie

La date d'une tâche ne doit pas automatiquement modifier sa catégorie persistée.

Exemple :

```text
category = next
plannedDate = 2026-08-25
```

Lorsque nous sommes le 25 août :

```text
Affichage = AUJOURD'HUI
```

mais :

```text
category = next
```

reste inchangé.

Cette séparation est importante.

---

# 15. Règle d'affichage

L'état affiché d'une tâche est calculé par le domaine.

Exemple conceptuel :

```text
TaskPresentationState
```

Peut produire :

```text
overdue
today
must_do
next
someday
completed
```

Cette logique ne doit pas être réimplémentée dans plusieurs widgets.

---

# 16. Application Reference

Une tâche peut être associée à une application.

Exemple :

```text
Faire les portraits
    ↓
Photoshop
```

L'association doit être abstraite :

```text
ApplicationReference
├── id
├── name
├── type
└── platformData
```

---

# 17. Important : chemins locaux

Un chemin Windows comme :

```text
C:\Program Files\Godot\Godot.exe
```

ne doit jamais être considéré comme une donnée universelle de la tâche.

Il est spécifique à l'appareil.

Le modèle doit donc séparer :

```text
ApplicationReference
```

de :

```text
DeviceApplicationMapping
```

Exemple :

```text
Task
 └── applicationId = "godot"

Windows device
 └── godot → C:\...\Godot.exe
```

Sur Android/iOS :

```text
godot
```

peut simplement ne produire aucune action.

---

# 18. Repository Pattern

Le domaine ne doit pas connaître directement la base de données.

Il utilise des interfaces.

Exemple :

```dart
abstract class TaskRepository {
  Future<Task> create(Task task);

  Future<List<Task>> getTasks();

  Future<Task> update(Task task);

  Future<void> delete(String id);

  Future<void> complete(String id);
}
```

Les implémentations sont situées dans Data.

---

# 19. Architecture Data

La couche Data est responsable de la persistance.

Elle contient notamment :

```text
LocalTaskRepository
RemoteTaskRepository
TaskLocalDataSource
TaskRemoteDataSource
SyncDataSource
```

---

# 20. Base locale

La base locale est la source principale utilisée par l'interface.

Architecture :

```text
UI
 ↓
Application
 ↓
Repository
 ↓
Local DB
```

Le réseau n'est jamais requis pour afficher les données locales.

---

# 21. Technologie locale

La solution privilégiée est :

**SQLite avec une abstraction Dart telle que Drift**, sous réserve de validation lors de l'implémentation.

La technologie définitive doit être documentée dans :

```text
docs/decisions.md
```

---

# 22. Pourquoi SQLite

SQLite est adapté car :

* mature ;
* local ;
* transactionnel ;
* rapide ;
* disponible sur les plateformes ciblées ;
* adapté aux données structurées ;
* permet une file de synchronisation fiable.

---

# 23. Supabase

Supabase constitue le backend principal.

Il fournit :

* PostgreSQL ;
* Auth ;
* Realtime ;
* API ;
* sécurité RLS.

Supabase ne doit cependant pas être considéré comme la base directement utilisée par les widgets Flutter.

---

# 24. Flux de données normal

Lorsqu'une tâche est créée :

```text
Utilisateur
    ↓
UI
    ↓
CreateTask
    ↓
TaskRepository
    ↓
SQLite
    ↓
UI mise à jour immédiatement
    ↓
SyncQueue
    ↓
Supabase
```

Le serveur intervient après la modification locale.

---

# 25. Principe Local-first

Toute action utilisateur doit d'abord être appliquée localement lorsque cela est possible.

Exemple :

```text
Utilisateur coche une tâche
        ↓
SQLite modifiée
        ↓
Interface mise à jour
        ↓
Synchronisation serveur
```

L'utilisateur ne doit pas attendre la réponse du serveur.

---

# 26. File de synchronisation

Les modifications doivent pouvoir être placées dans une file :

```text
SyncOperation
├── id
├── entityId
├── entityType
├── operation
├── payload
├── createdAt
├── retryCount
└── status
```

Opérations :

```text
create
update
complete
delete
```

---

# 27. Synchronisation

Le SyncService est responsable de :

* détecter les opérations en attente ;
* les envoyer ;
* gérer les erreurs ;
* réessayer ;
* recevoir les modifications distantes ;
* appliquer les modifications locales ;
* résoudre les conflits.

---

# 28. Realtime

Supabase Realtime peut notifier MYA lorsqu'une modification distante apparaît.

Flux :

```text
Téléphone
    ↓
Supabase
    ↓
Realtime
    ↓
PC
    ↓
Local DB
    ↓
UI
```

La base locale reste toutefois la source de lecture de l'interface.

---

# 29. Authentification

L'authentification est gérée par Supabase Auth.

Fournisseurs prévus :

```text
Google
Apple
Microsoft
```

La possibilité d'utiliser MYA sans compte doit être conservée.

---

# 30. Mode local sans compte

Un utilisateur doit pouvoir :

```text
Installer MYA
    ↓
Créer des tâches
    ↓
Utiliser MYA localement
```

sans inscription obligatoire.

Lorsqu'il se connecte :

```text
Local tasks
    +
Cloud tasks
    ↓
Fusion
```

---

# 31. Fusion initiale

Les tâches utilisent des UUID générés localement.

Lors de la première synchronisation :

```text
si UUID absent du cloud
    → upload
```

```text
si UUID déjà présent
    → comparaison
```

Les données locales ne doivent jamais être supprimées silencieusement.

---

# 32. Conflits

Pour le MVP :

**Last Write Wins**, basé sur `updatedAt`, peut être utilisé.

Toutefois :

* la modification doit être déterministe ;
* les suppressions doivent être traitées séparément ;
* les timestamps doivent être fiables ;
* les opérations locales non synchronisées doivent être protégées.

Une stratégie plus avancée pourra être ajoutée ultérieurement.

---

# 33. Suppression

Les suppressions doivent être représentées temporairement par :

```text
deletedAt
```

plutôt que par une suppression physique immédiate.

Cela permet aux autres appareils de recevoir l'information de suppression.

---

# 34. Nettoyage

Après une période définie, les entrées supprimées peuvent être définitivement supprimées du serveur et des appareils.

La durée exacte sera définie dans la configuration de synchronisation.

---

# 35. Gestion des rappels

Les rappels sont des événements locaux.

Exemple :

```text
Task
plannedDate = 2026-08-25
reminderAt = 14:00
```

L'appareil programme une notification locale.

Le serveur synchronise la configuration du rappel, mais n'est pas responsable du déclenchement normal d'une notification locale.

---

# 36. Notifications

Les notifications sont abstraites derrière :

```text
NotificationService
```

Exemple :

```text
NotificationService.scheduleReminder()
NotificationService.cancelReminder()
```

La couche Domain ne connaît pas Android, iOS ou Windows.

---

# 37. Personnalité des notifications

Le système doit permettre :

```text
normal
humorous
brutal
```

Exemples :

```text
normal:
N'oublie pas : Faire les portraits.

humorous:
BOUGE TON GROS CUL. Faire les portraits.

brutal:
TU AVAIS DIT QUE TU LE FERAIS AUJOURD'HUI.
```

Les textes doivent être générés par un service de présentation/notification.

---

# 38. Pastille Windows

La pastille est une fonctionnalité spécifique Windows.

Elle ne doit pas être implémentée comme une simple page Flutter classique.

Architecture :

```text
FloatingBubbleController
        ↓
WindowService
        ↓
Windows native API
```

---

# 39. Responsabilités de WindowService

WindowService gère :

* position ;
* taille ;
* visibilité ;
* Always-On-Top ;
* déplacement ;
* ancrage ;
* minimisation ;
* ouverture ;
* fermeture ;
* état de fenêtre.

Les widgets ne doivent pas appeler directement l'API Windows.

---

# 40. Position de la pastille

Position par défaut :

```text
côté gauche ou droit
environ 80 % de la hauteur
```

La position est ensuite librement modifiable.

Modes :

```text
free
snapLeft
snapRight
```

---

# 41. Ancrage

Lorsque l'utilisateur déplace la pastille près d'un bord :

```text
Distance < threshold
```

la pastille peut s'accrocher.

L'utilisateur doit pouvoir la détacher.

---

# 42. Panneau de tâches

La pastille peut être développée en panneau.

```text
        ●
        ↓
┌─────────────────────────┐
│ BOUGE TON GROS CUL      │
│                         │
│ Faire les portraits     │
│                         │
│ AUJOURD'HUI             │
│ Corriger dialogue       │
│                         │
│ ENSUITE                 │
│ Créer animations        │
│                         │
│        ↓ scroll ↓       │
└─────────────────────────┘
```

Toutes les tâches peuvent être affichées via une zone défilante.

---

# 43. Compteur

MYA ne doit pas afficher de compteur global de tâches par défaut.

Raison :

Le compteur peut créer une sensation de surcharge ou de stress.

MYA est un pense-bête, pas un outil de productivité agressif.

---

# 44. Raccourci global

Le raccourci par défaut prévu est :

```text
Ctrl + Alt + Space
```

Il doit ouvrir une interface de création rapide.

Exemple :

```text
┌─────────────────────────────┐
│ Que dois-je retenir ?       │
│                             │
│ Acheter câble USB-C         │
│                             │
│ Entrée = ajouter            │
└─────────────────────────────┘
```

---

# 45. Création rapide

La création rapide doit :

1. être immédiatement accessible ;
2. demander uniquement le titre ;
3. créer la tâche ;
4. fermer l'interface.

Les options avancées sont secondaires.

---

# 46. Options avancées

Après création ou depuis le détail d'une tâche :

```text
Date
Rappel
Catégorie
Application
```

peuvent être configurés.

Il ne faut pas afficher ces champs lors de la création simple.

---

# 47. Interface mobile

L'écran principal mobile doit privilégier :

```text
+ Ajouter un pense-bête
```

L'utilisateur doit pouvoir :

```text
ouvrir
écrire
valider
```

en quelques secondes.

---

# 48. Widget mobile

Le widget est une vue secondaire.

Il peut afficher :

```text
BOUGE TON GROS CUL
Faire les portraits

ENSUITE
Corriger dialogue
```

Le widget ne doit pas tenter de reproduire toute l'application.

---

# 49. Application mobile et widget

Le widget doit rester fonctionnel lorsque l'application principale n'est pas ouverte.

Il doit donc utiliser un mécanisme de stockage partagé avec l'application native.

---

# 50. Application mobile et exécutable Windows

Une association d'application est :

**Windows-only.**

Sur mobile :

* l'information peut éventuellement être visible ;
* l'action « lancer » ne doit pas être proposée ;
* aucune tentative de lancer l'application Windows ne doit être effectuée.

---

# 51. Gestion d'état

La solution privilégiée est **Riverpod**, sous réserve de validation.

Les providers doivent être organisés par fonctionnalité.

Exemple :

```text
tasksProvider
taskRepositoryProvider
syncServiceProvider
settingsProvider
```

Éviter un provider global contenant toute l'application.

---

# 52. Navigation

La navigation doit utiliser une solution Flutter adaptée aux routes déclaratives.

Le choix exact du routeur doit être documenté.

Les pages doivent être indépendantes.

---

# 53. Organisation du code

Structure cible :

```text
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── utils/
│   └── configuration/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── services/
│
├── application/
│   ├── tasks/
│   ├── sync/
│   ├── reminders/
│   └── authentication/
│
├── data/
│   ├── local/
│   ├── remote/
│   ├── models/
│   └── repositories/
│
├── features/
│   ├── home/
│   ├── tasks/
│   ├── quick_add/
│   ├── settings/
│   └── authentication/
│
└── platform/
    ├── windows/
    ├── android/
    └── ios/
```

---

# 54. Règle de dépendance

Une dépendance normale :

```text
features
   ↓
application
   ↓
domain
   ↓
interfaces
```

La data implémente les interfaces du domaine.

La plateforme implémente les interfaces nécessaires.

---

# 55. Interdictions architecturales

Le code suivant est interdit :

```dart
Widget
  ↓
Supabase.from(...)
```

Préférer :

```text
Widget
 ↓
Controller / Application Service
 ↓
Repository
 ↓
DataSource
 ↓
Supabase
```

---

# 56. Même principe pour Windows

Interdit :

```text
Widget
 ↓
Windows API
```

Préférer :

```text
Widget
 ↓
WindowService
 ↓
Platform adapter
 ↓
Windows API
```

---

# 57. Interfaces plateforme

Les services spécifiques doivent avoir des abstractions.

Exemple :

```dart
abstract class WindowService {
  Future<void> setAlwaysOnTop(bool value);

  Future<void> setPosition(double x, double y);

  Future<void> show();

  Future<void> hide();
}
```

Puis :

```text
WindowsWindowService
```

implémente cette interface.

---

# 58. Tests

Les règles métier doivent être testables sans Flutter UI.

Exemple :

```text
TaskDateServiceTest
TaskCategoryServiceTest
TaskHistoryServiceTest
SyncConflictTest
```

---

# 59. Tests d'intégration

Les scénarios critiques :

```text
Créer tâche hors ligne
    ↓
Connexion
    ↓
Synchronisation
```

et :

```text
Créer sur PC
    ↓
Supabase
    ↓
Téléphone
```

doivent être testés.

---

# 60. Gestion des erreurs

Les erreurs doivent être catégorisées.

Exemple :

```text
NetworkError
AuthenticationError
DatabaseError
SyncError
PlatformError
ValidationError
```

Ne jamais afficher directement une exception technique à l'utilisateur.

---

# 61. Logging

Le logging doit être utilisé pour :

* synchronisation ;
* erreurs ;
* intégrations natives ;
* authentification ;
* notifications.

Les logs ne doivent jamais contenir :

* mot de passe ;
* token ;
* données privées inutiles ;
* contenu complet des tâches en production.

---

# 62. Mode développement

En développement :

```text
debug logging = enabled
```

En production :

```text
debug logging = disabled
```

Les erreurs importantes peuvent rester journalisées de façon contrôlée.

---

# 63. Performance

Objectifs :

* lancement rapide ;
* création instantanée ;
* interface fluide ;
* consommation CPU faible ;
* consommation mémoire raisonnable ;
* aucune boucle de polling permanente.

---

# 64. Realtime et batterie

Sur mobile, la synchronisation ne doit pas maintenir inutilement une connexion réseau permanente lorsque le système ne le permet pas ou lorsque l'application est inactive.

Les mécanismes natifs de chaque plateforme doivent être respectés.

---

# 65. Sécurité

Les données cloud sont protégées par :

```text
Supabase Auth
+
Row Level Security
```

Chaque requête concernant les tâches doit être associée à l'utilisateur authentifié.

---

# 66. Secrets

Aucun secret serveur ne doit être stocké dans :

```text
Git
Flutter assets
code Dart
repository public
```

Les fichiers `.env` locaux contenant des secrets ne doivent pas être commités.

---

# 67. RGPD

MYA doit respecter le principe de minimisation.

Les données nécessaires sont principalement :

```text
compte
tâches
préférences
appareils
```

MYA ne doit pas collecter le contenu d'autres applications présentes sur l'ordinateur.

---

# 68. Analytics

Pas d'analytics intrusive dans le MVP.

Si des analytics sont ajoutées ultérieurement :

* elles doivent être documentées ;
* anonymisées autant que possible ;
* compatibles RGPD ;
* séparées du contenu utilisateur.

---

# 69. Architecture de publication

Windows :

```text
Flutter
 ↓
Build Windows
 ↓
MSIX
 ↓
Microsoft Store / distribution directe
```

Android :

```text
Flutter
 ↓
AAB
 ↓
Google Play
```

iOS :

```text
Flutter
 ↓
IPA/archive
 ↓
App Store Connect
```

---

# 70. CI/CD

Le projet pourra utiliser GitHub Actions.

Pipeline cible :

```text
git push
    ↓
format
    ↓
analyze
    ↓
unit tests
    ↓
integration tests
    ↓
build
```

Les builds de production ne doivent être générés qu'après validation.

---

# 71. Git

Branches minimales :

```text
main
feature/*
fix/*
```

Chaque fonctionnalité doit être développée dans une branche dédiée lorsque cela est pertinent.

---

# 72. Documentation

Le répertoire :

```text
docs/
```

doit contenir :

```text
ARCHITECTURE.md
DATABASE.md
SYNCHRONIZATION.md
WINDOWS.md
ANDROID.md
IOS.md
DEPLOYMENT.md
DECISIONS.md
```

Les noms peuvent être adaptés mais les responsabilités doivent rester séparées.

---

# 73. Rôle de Cursor

Cursor est considéré comme un agent de développement.

Il ne doit pas être considéré comme l'autorité architecturale.

L'architecture définie dans les fichiers `/docs` prime sur les suggestions automatiques de Cursor.

---

# 74. Règles pour Cursor

Avant toute modification importante, Cursor doit :

1. lire `ARCHITECTURE.md` ;
2. lire le document fonctionnel pertinent ;
3. vérifier les décisions existantes ;
4. identifier les couches concernées ;
5. modifier uniquement les fichiers nécessaires ;
6. lancer les tests ;
7. signaler les erreurs ;
8. mettre à jour la documentation si nécessaire.

---

# 75. Interdiction de réarchitecture spontanée

Cursor ne doit jamais décider seul de :

* remplacer Flutter ;
* remplacer Supabase ;
* changer la base locale ;
* changer le système de gestion d'état ;
* modifier le modèle de synchronisation ;
* supprimer une couche ;
* ajouter une architecture complètement différente.

Une telle modification nécessite une décision explicite.

---

# 76. Ajout d'une dépendance

Avant d'ajouter un package important, Cursor doit fournir :

```text
Nom
Version
Plateformes
Fonction
Pourquoi nécessaire
Alternatives
Risques
Licence
```

Une dépendance ne doit pas être ajoutée uniquement parce qu'elle semble pratique.

---

# 77. Principe de simplicité

MYA ne doit pas devenir un Jira miniature.

Il n'y aura pas dans le MVP :

* projets complexes ;
* sous-tâches ;
* tâches récurrentes ;
* Kanban ;
* statistiques ;
* système de points ;
* gamification obligatoire ;
* commentaires ;
* collaboration ;
* dépendances entre tâches.

---

# 78. Principe UX fondamental

Une fonctionnalité supplémentaire doit être évaluée selon :

> Est-ce qu'elle rend MYA plus simple ou plus compliqué ?

Si elle rend l'application plus compliquée sans apporter une valeur claire au concept de pense-bête, elle doit être repoussée.

---

# 79. Architecture cible résumée

```text
                    ┌─────────────────┐
                    │    Supabase     │
                    │                 │
                    │ Auth            │
                    │ PostgreSQL      │
                    │ Realtime        │
                    │ RLS             │
                    └────────┬────────┘
                             │
                        SyncService
                             │
        ┌────────────────────┴────────────────────┐
        │                                         │
    Windows                                   Mobile
        │                                         │
    Flutter                                   Flutter
        │                                         │
 Application Layer                         Application Layer
        │                                         │
      Domain                                    Domain
        │                                         │
    Repository                                Repository
        │                                         │
    SQLite                                    SQLite
        │                                         │
 ┌──────┴───────────┐                  ┌──────────┴─────────┐
 │                  │                  │                    │
WindowService   HotkeyService    NotificationService    WidgetService
 │                  │                  │                    │
Windows API      Windows API      Native APIs          Native APIs
```

---

# 80. Règle finale

L'architecture de MYA doit rester fidèle à quatre principes :

### 1. Local-first

MYA doit fonctionner immédiatement sans Internet.

### 2. Multiplateforme

Le maximum de logique doit être partagé entre Windows, Android et iOS.

### 3. Native lorsque nécessaire

Les fonctionnalités propres aux plateformes doivent utiliser les APIs natives plutôt que des contournements fragiles.

### 4. Simplicité

La complexité technique doit rester derrière l'application.

L'utilisateur doit uniquement voir :

> une petite pastille, quelques tâches et un moyen extrêmement rapide de se rappeler ce qu'il doit faire.

---

# 81. Statut des décisions

Les décisions suivantes sont considérées comme **validées** :

* Flutter comme framework principal ;
* Windows + Android + iOS ;
* architecture Local-first ;
* Supabase comme backend envisagé ;
* PostgreSQL ;
* synchronisation cloud ;
* authentification Google/Apple/Microsoft ;
* notifications natives ;
* pastille Windows ;
* raccourci global ;
* widgets mobiles ;
* application associée Windows ;
* absence de sous-tâches ;
* absence de tâches récurrentes ;
* simplicité comme principe architectural.

Les décisions suivantes restent **à valider** :

* package de base locale ;
* package de gestion d'état ;
* package de gestion des fenêtres Windows ;
* package de raccourcis globaux ;
* package de notifications ;
* solution définitive pour widgets ;
* stratégie exacte de résolution des conflits ;
* schéma SQL définitif ;
* stratégie de sauvegarde Supabase ;
* système CI/CD définitif.

---

# 82. Prochaine étape

Avant le développement complet, les documents suivants doivent être finalisés :

1. `DATABASE.md`
2. `SYNCHRONIZATION.md`
3. `WINDOWS.md`
4. `ANDROID.md`
5. `IOS.md`
6. `DEPLOYMENT.md`
7. `DECISIONS.md`

Ensuite seulement, créer le prompt maître destiné à Cursor.

```

### Un point important

Je ferais **une modification par rapport à mon cahier des charges précédent** : je ne figerais pas encore Supabase, Drift ou Riverpod comme des choix irrévocables. Dans `ARCHITECTURE.md`, je les ai donc distingués entre **architecture validée** et **choix techniques restant à valider**.

C'est important pour Cursor : sinon il risque de considérer une proposition technique comme une contrainte absolue et de construire tout le projet autour d'un package qui, après vérification, pourrait ne pas être le meilleur choix.

Et surtout, **je ne commencerais pas encore à coder MYA**. La prochaine étape logique est `DATABASE.md` + `SYNCHRONIZATION.md`, car la synchronisation PC ↔ téléphone est probablement la partie qui peut provoquer le plus de problèmes si on la conçoit mal dès le départ.
```
