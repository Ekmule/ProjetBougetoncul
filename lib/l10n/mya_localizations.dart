import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mya/application/bubble/bubble_position.dart';
import 'package:mya/application/sync/sync_ui_state.dart';
import 'package:mya/domain/entities/mya_auth_provider.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/l10n/app_locale_code.dart';

/// Chaînes UI MYA (anglais / français).
class MyaLocalizations {
  const MyaLocalizations._({
    required this.localeCode,
    required this.languageLabel,
    required this.languageEnglish,
    required this.languageFrench,
    required this.plannedDateHelp,
    required this.plannedDateToday,
    required this.plannedDateTomorrow,
    required this.plannedDatePick,
    required this.plannedDateClear,
    required this.reminderDateHelp,
    required this.reminderTimeHelp,
    required this.cloudSignInOfferTitle,
    required this.cloudSignInOfferBody,
    required this.cloudSignInOfferConnect,
    required this.cloudSignInOfferLater,
    required this.settingsTitle,
    required this.accountAndSyncTitle,
    required this.updatesTitle,
    required this.close,
    required this.cancel,
    required this.save,
    required this.add,
    required this.continueButton,
    required this.later,
    required this.delete,
    required this.editTaskTitle,
    required this.taskTitleLabel,
    required this.nothingHere,
    required this.noActiveTasksPreview,
    required this.noActiveTasksFull,
    required this.quickAddPrompt,
    required this.quickAddHintDense,
    required this.quickAddHintFull,
    required this.quickAddTooltipEnter,
    required this.quickAddShowOptions,
    required this.quickAddHideOptions,
    required this.quickAddKeyboardHint,
    required this.quickAddSuccess,
    required this.settingsTooltip,
    required this.quickAddTooltip,
    required this.versionLoading,
    required this.versionUnknown,
    required this.versionInstalled,
    required this.versionLine,
    required this.supabaseNotConfigured,
    required this.homeWidgetTitle,
    required this.homeWidgetSubtitle,
    required this.homeWidgetPinUnsupported,
    required this.homeWidgetPinDialogTitle,
    required this.homeWidgetPinDialogBody,
    required this.homeWidgetPinAdd,
    required this.authDialogTitle,
    required this.authDialogBody,
    required this.authNoSupabaseBuild,
    required this.authSignOut,
    required this.authSignOutFailed,
    required this.authSignInAndroid,
    required this.authSignInDesktop,
    required this.authFinishInBrowser,
    required this.authCloudNotConfigured,
    required this.authLocalNotSignedIn,
    required this.authSignedIn,
    required this.authSignedInWith,
    required this.authTrayNotConfigured,
    required this.authTraySignIn,
    required this.authTrayAccount,
    required this.authConnectedAccount,
    required this.syncNotConfigured,
    required this.syncLocal,
    required this.syncSyncing,
    required this.syncPending,
    required this.syncSynced,
    required this.updateAvailableTitle,
    required this.updateDownloading,
    required this.updateInstall,
    required this.updateDownloadInstall,
    required this.updateChecking,
    required this.updateRecheck,
    required this.updateCheckFailed,
    required this.updateInstallFailed,
    required this.updateAlreadyLatest,
    required this.bubbleSectionTitle,
    required this.startupWithWindowsTitle,
    required this.startupWithWindowsSubtitle,
    required this.alwaysOnTopTitle,
    required this.alwaysOnTopSubtitle,
    required this.hotkeySettingsTitle,
    required this.hotkeyRecordPrompt,
    required this.hotkeyCurrent,
    required this.hotkeyModifierRequired,
    required this.hotkeyDefault,
    required this.bubbleIconPickerTitle,
    required this.bubbleIconPickerBody,
    required this.bubblePositionTitle,
    required this.displayLabel,
    required this.displayPrimarySuffix,
    required this.bubbleFreePositionHint,
    required this.bubbleFreeDragTitle,
    required this.bubbleFreeDragSubtitle,
    required this.trayHelpTitle,
    required this.trayHelpBody,
    required this.trayHelpButton,
    required this.trayNotificationTitle,
    required this.trayNotificationBody,
    required this.trayTooltip,
    required this.trayOpenMya,
    required this.trayHideBubble,
    required this.trayShowBubble,
    required this.trayAotOn,
    required this.trayAotOff,
    required this.trayStartupOn,
    required this.trayStartupOff,
    required this.trayHotkeyPrefix,
    required this.trayQuit,
    required this.panelSettings,
    required this.panelExpand,
    required this.panelDisableAot,
    required this.panelEnableAot,
    required this.panelHide,
    required this.panelCollapse,
    required this.moveCategoryTooltip,
    required this.reopenTaskTooltip,
    required this.completeTaskTooltip,
    required this.tapToEditTooltip,
    required this.completedOnPrefix,
    required this.addPlannedDate,
    required this.addReminder,
    required this.reminderMustBeFuture,
    required this.reminderInOneHour,
    required this.reminderTomorrow9,
    required this.reminderPickDateTime,
    required this.clearReminder,
    required this.aboutPublisher,
    required this.aboutBlurb,
    required this.copyrightLine,
    required this.categoryMustDo,
    required this.categoryToday,
    required this.categoryNext,
    required this.categorySomeday,
    required this.oauthGoogle,
    required this.oauthApple,
    required this.oauthMicrosoft,
    required this.updatesGitHubSubtitle,
    required String anchorTopLeft,
    required String anchorTopCenter,
    required String anchorTopRight,
    required String anchorCenterLeft,
    required String anchorCenterRight,
    required String anchorBottomLeft,
    required String anchorBottomCenter,
    required String anchorBottomRight,
  })  : _anchorTopLeft = anchorTopLeft,
        _anchorTopCenter = anchorTopCenter,
        _anchorTopRight = anchorTopRight,
        _anchorCenterLeft = anchorCenterLeft,
        _anchorCenterRight = anchorCenterRight,
        _anchorBottomLeft = anchorBottomLeft,
        _anchorBottomCenter = anchorBottomCenter,
        _anchorBottomRight = anchorBottomRight;

  final AppLocaleCode localeCode;
  final String languageLabel;
  final String languageEnglish;
  final String languageFrench;
  final String plannedDateHelp;
  final String plannedDateToday;
  final String plannedDateTomorrow;
  final String plannedDatePick;
  final String plannedDateClear;
  final String reminderDateHelp;
  final String reminderTimeHelp;
  final String cloudSignInOfferTitle;
  final String cloudSignInOfferBody;
  final String cloudSignInOfferConnect;
  final String cloudSignInOfferLater;
  final String settingsTitle;
  final String accountAndSyncTitle;
  final String updatesTitle;
  final String close;
  final String cancel;
  final String save;
  final String add;
  final String continueButton;
  final String later;
  final String delete;
  final String editTaskTitle;
  final String taskTitleLabel;
  final String nothingHere;
  final String noActiveTasksPreview;
  final String noActiveTasksFull;
  final String quickAddPrompt;
  final String quickAddHintDense;
  final String quickAddHintFull;
  final String quickAddTooltipEnter;
  final String quickAddShowOptions;
  final String quickAddHideOptions;
  final String quickAddKeyboardHint;
  final String quickAddSuccess;
  final String settingsTooltip;
  final String quickAddTooltip;
  final String versionLoading;
  final String versionUnknown;
  final String versionInstalled;
  final String versionLine;
  final String supabaseNotConfigured;
  final String homeWidgetTitle;
  final String homeWidgetSubtitle;
  final String homeWidgetPinUnsupported;
  final String homeWidgetPinDialogTitle;
  final String homeWidgetPinDialogBody;
  final String homeWidgetPinAdd;
  final String authDialogTitle;
  final String authDialogBody;
  final String authNoSupabaseBuild;
  final String authSignOut;
  final String authSignOutFailed;
  final String authSignInAndroid;
  final String authSignInDesktop;
  final String authFinishInBrowser;
  final String authCloudNotConfigured;
  final String authLocalNotSignedIn;
  final String authSignedIn;
  final String authSignedInWith;
  final String authTrayNotConfigured;
  final String authTraySignIn;
  final String authTrayAccount;
  final String authConnectedAccount;
  final String syncNotConfigured;
  final String syncLocal;
  final String syncSyncing;
  final String syncPending;
  final String syncSynced;
  final String updateAvailableTitle;
  final String updateDownloading;
  final String updateInstall;
  final String updateDownloadInstall;
  final String updateChecking;
  final String updateRecheck;
  final String updateCheckFailed;
  final String updateInstallFailed;
  final String updateAlreadyLatest;
  final String bubbleSectionTitle;
  final String startupWithWindowsTitle;
  final String startupWithWindowsSubtitle;
  final String alwaysOnTopTitle;
  final String alwaysOnTopSubtitle;
  final String hotkeySettingsTitle;
  final String hotkeyRecordPrompt;
  final String hotkeyCurrent;
  final String hotkeyModifierRequired;
  final String hotkeyDefault;
  final String bubbleIconPickerTitle;
  final String bubbleIconPickerBody;
  final String bubblePositionTitle;
  final String displayLabel;
  final String displayPrimarySuffix;
  final String bubbleFreePositionHint;
  final String bubbleFreeDragTitle;
  final String bubbleFreeDragSubtitle;
  final String trayHelpTitle;
  final String trayHelpBody;
  final String trayHelpButton;
  final String trayNotificationTitle;
  final String trayNotificationBody;
  final String trayTooltip;
  final String trayOpenMya;
  final String trayHideBubble;
  final String trayShowBubble;
  final String trayAotOn;
  final String trayAotOff;
  final String trayStartupOn;
  final String trayStartupOff;
  final String trayHotkeyPrefix;
  final String trayQuit;
  final String panelSettings;
  final String panelExpand;
  final String panelDisableAot;
  final String panelEnableAot;
  final String panelHide;
  final String panelCollapse;
  final String moveCategoryTooltip;
  final String reopenTaskTooltip;
  final String completeTaskTooltip;
  final String tapToEditTooltip;
  final String completedOnPrefix;
  final String addPlannedDate;
  final String addReminder;
  final String reminderMustBeFuture;
  final String reminderInOneHour;
  final String reminderTomorrow9;
  final String reminderPickDateTime;
  final String clearReminder;
  final String aboutPublisher;
  final String aboutBlurb;
  final String copyrightLine;
  final String categoryMustDo;
  final String categoryToday;
  final String categoryNext;
  final String categorySomeday;
  final String oauthGoogle;
  final String oauthApple;
  final String oauthMicrosoft;
  final String updatesGitHubSubtitle;

  static MyaLocalizations of(BuildContext context) {
    return Localizations.of<MyaLocalizations>(context, MyaLocalizations)!;
  }

  static MyaLocalizations lookup(AppLocaleCode code) {
    return code == AppLocaleCode.fr ? _french : _english;
  }

  static MyaLocalizations lookupFromLocale(Locale locale) {
    return lookup(AppLocaleCode.parse(locale.languageCode));
  }

  String categoryLabel(TaskCategoryId id) {
    return switch (id) {
      TaskCategoryId.mustDo => categoryMustDo,
      TaskCategoryId.today => categoryToday,
      TaskCategoryId.next => categoryNext,
      TaskCategoryId.someday => categorySomeday,
    };
  }

  String completedSectionTitle(int count) {
    if (localeCode == AppLocaleCode.fr) {
      return 'TERMINÉES ($count)';
    }
    return 'DONE ($count)';
  }

  String bubbleSizeLabel(int pixels) {
    if (localeCode == AppLocaleCode.fr) {
      return 'Taille de la pastille : $pixels px';
    }
    return 'Bubble size: $pixels px';
  }

  String quickAddHotkeyFooter(String hotkey) {
    if (localeCode == AppLocaleCode.fr) {
      return '$hotkey = création rapide';
    }
    return '$hotkey = quick add';
  }

  String plannedDateButtonLabel(String formatted) {
    if (localeCode == AppLocaleCode.fr) {
      return 'Date : $formatted';
    }
    return 'Date: $formatted';
  }

  String reminderButtonLabel(String formatted) {
    if (localeCode == AppLocaleCode.fr) {
      return 'Rappel : $formatted';
    }
    return 'Reminder: $formatted';
  }

  String completedOnLine(String formatted) {
    return '$completedOnPrefix $formatted';
  }

  String updateAvailableBody(String versionDisplay) {
    if (localeCode == AppLocaleCode.fr) {
      return 'MYA $versionDisplay est disponible.';
    }
    return 'MYA $versionDisplay is available.';
  }

  String updateAlreadyLatestBody(String versionDisplay) {
    return updateAlreadyLatest.replaceFirst('{version}', versionDisplay);
  }

  String versionInstalledLine(String versionDisplay) {
    return '$versionInstalled $versionDisplay';
  }

  String updatesSubtitle(String installedVersion) {
    return updatesGitHubSubtitle.replaceFirst('{version}', installedVersion);
  }

  String trayHotkeyMenu(String hotkeyLabel) => '$trayHotkeyPrefix $hotkeyLabel…';

  String authAccountSummary(String? emailOrName, {required bool isConfigured}) {
    if (!isConfigured) return authCloudNotConfigured;
    if (emailOrName == null || emailOrName.isEmpty) {
      return authLocalNotSignedIn;
    }
    return '$authSignedInWith $emailOrName';
  }

  String authTrayLabel(String? emailOrName, {required bool isConfigured}) {
    if (!isConfigured) return authTrayNotConfigured;
    if (emailOrName == null || emailOrName.isEmpty) return authTraySignIn;
    final label = emailOrName;
    if (label.length <= 28) {
      return '$authTrayAccount $label…';
    }
    return '$authTrayAccount ${label.substring(0, 25)}…';
  }

  String oauthProviderLabel(MyaAuthProvider provider) {
    return switch (provider) {
      MyaAuthProvider.google => oauthGoogle,
      MyaAuthProvider.apple => oauthApple,
      MyaAuthProvider.microsoft => oauthMicrosoft,
    };
  }

  String syncStatusLabel(CloudSyncUiState state) {
    return switch (state) {
      CloudSyncUiState.notConfigured => syncNotConfigured,
      CloudSyncUiState.local => syncLocal,
      CloudSyncUiState.syncing => syncSyncing,
      CloudSyncUiState.pending => syncPending,
      CloudSyncUiState.synced => syncSynced,
    };
  }

  String anchorLabel(BubbleAnchor anchor) {
    return switch (anchor) {
      BubbleAnchor.topLeft => _anchorTopLeft,
      BubbleAnchor.topCenter => _anchorTopCenter,
      BubbleAnchor.topRight => _anchorTopRight,
      BubbleAnchor.centerLeft => _anchorCenterLeft,
      BubbleAnchor.centerRight => _anchorCenterRight,
      BubbleAnchor.bottomLeft => _anchorBottomLeft,
      BubbleAnchor.bottomCenter => _anchorBottomCenter,
      BubbleAnchor.bottomRight => _anchorBottomRight,
    };
  }

  final String _anchorTopLeft;
  final String _anchorTopCenter;
  final String _anchorTopRight;
  final String _anchorCenterLeft;
  final String _anchorCenterRight;
  final String _anchorBottomLeft;
  final String _anchorBottomCenter;
  final String _anchorBottomRight;

  static const MyaLocalizations _english = MyaLocalizations._(
    localeCode: AppLocaleCode.en,
    languageLabel: 'Language',
    languageEnglish: 'English',
    languageFrench: 'French',
    plannedDateHelp: 'Planned date',
    plannedDateToday: 'Today',
    plannedDateTomorrow: 'Tomorrow',
    plannedDatePick: 'Pick a date…',
    plannedDateClear: 'Clear date',
    reminderDateHelp: 'Reminder date',
    reminderTimeHelp: 'Reminder time',
    cloudSignInOfferTitle: 'Connect your account',
    cloudSignInOfferBody:
        'You chose cloud sync during setup. Sign in to sync tasks across devices. '
        'You can skip this and connect later in Settings.',
    cloudSignInOfferConnect: 'Sign in',
    cloudSignInOfferLater: 'Not now',
    settingsTitle: 'Settings',
    accountAndSyncTitle: 'Account and sync',
    updatesTitle: 'Updates',
    close: 'Close',
    cancel: 'Cancel',
    save: 'Save',
    add: 'Add',
    continueButton: 'Continue',
    later: 'Not now',
    delete: 'Delete',
    editTaskTitle: 'Edit task',
    taskTitleLabel: 'Title',
    nothingHere: 'Nothing here',
    noActiveTasksPreview:
        'No active tasks.\nClick to open the full panel.',
    noActiveTasksFull:
        'No active tasks.\nAdd one above or reopen a completed task.',
    quickAddPrompt: 'What should I remember?',
    quickAddHintDense: '+ Add a reminder',
    quickAddHintFull: 'Buy USB-C cable…',
    quickAddTooltipEnter: 'Add (Enter)',
    quickAddShowOptions: 'More options',
    quickAddHideOptions: 'Hide options',
    quickAddKeyboardHint: 'Enter = add · Esc = cancel',
    quickAddSuccess: 'Reminder added',
    settingsTooltip: 'Settings',
    quickAddTooltip: 'Quick add',
    versionLoading: 'Version…',
    versionUnknown: 'Unknown version',
    versionInstalled: 'Installed version:',
    versionLine: 'Version {version}',
    supabaseNotConfigured: 'Supabase is not configured in this build.',
    homeWidgetTitle: 'Home screen widget',
    homeWidgetSubtitle: 'Pin MYA on your launcher',
    homeWidgetPinUnsupported:
        'Your launcher cannot add widgets automatically. '
        'Add the widget manually (long press → Widgets).',
    homeWidgetPinDialogTitle: 'Add MYA to your home screen',
    homeWidgetPinDialogBody:
        'MYA works best with its 1×1 widget: one tap opens your tasks.\n\n'
        'Android will ask you to place it on your home screen.',
    homeWidgetPinAdd: 'Add widget',
    authDialogTitle: 'Account and sync',
    authDialogBody:
        'MYA works without an account. Sign in only to sync tasks across devices.',
    authNoSupabaseBuild:
        'This build has no Supabase keys. See docs/database.md for setup.',
    authSignOut: 'Sign out',
    authSignOutFailed: 'Could not sign out.',
    authSignInAndroid: 'A sign-in window will open.',
    authSignInDesktop:
        'A browser will open. Return here after signing in.',
    authFinishInBrowser: 'Finish signing in in the browser, then return to MYA.',
    authCloudNotConfigured: 'Cloud sync not configured',
    authLocalNotSignedIn: 'Local mode — not signed in',
    authSignedIn: 'Signed in',
    authSignedInWith: 'Signed in:',
    authTrayNotConfigured: 'Account: sync not configured…',
    authTraySignIn: 'Sign in…',
    authTrayAccount: 'Account:',
    authConnectedAccount: 'Connected account',
    syncNotConfigured: 'Cloud sync not configured',
    syncLocal: 'Local mode',
    syncSyncing: 'Syncing…',
    syncPending: 'Waiting for cloud',
    syncSynced: 'Synced',
    updateAvailableTitle: 'Update available',
    updateDownloading: 'Downloading…',
    updateInstall: 'Install',
    updateDownloadInstall: 'Download and install',
    updateChecking: 'Checking GitHub Releases…',
    updateRecheck: 'Check again',
    updateCheckFailed: 'Could not check for updates.',
    updateInstallFailed: 'Installation failed.',
    updateAlreadyLatest: 'MYA is already up to date ({version}).',
    bubbleSectionTitle: 'Bubble',
    startupWithWindowsTitle: 'Start with Windows',
    startupWithWindowsSubtitle: 'Launch MYA automatically when your PC starts.',
    alwaysOnTopTitle: 'Always on top',
    alwaysOnTopSubtitle: 'Keep MYA above other windows.',
    hotkeySettingsTitle: 'Quick add shortcut',
    hotkeyRecordPrompt: 'Press the key combination you want:',
    hotkeyCurrent: 'Current:',
    hotkeyModifierRequired: 'Add at least one modifier (Ctrl, Alt, Shift…).',
    hotkeyDefault: 'Default',
    bubbleIconPickerTitle: 'Choose your bubble',
    bubbleIconPickerBody:
        'MYA stays discreet on your desktop. Pick an icon — you can change it later in Settings.',
    bubblePositionTitle: 'Bubble position',
    displayLabel: 'Display',
    displayPrimarySuffix: ' (primary)',
    bubbleFreePositionHint: 'Free position — pick a fixed spot',
    bubbleFreeDragTitle: 'Allow free dragging',
    bubbleFreeDragSubtitle:
        'Drag the bubble anywhere. It stays on the current screen.',
    trayHelpTitle: 'Taskbar icon',
    trayHelpBody:
        'MYA stays available from an icon near the clock (notification area). '
        'On Windows 11, click ^ if the icon is hidden.\n\n'
        '• Left click: open MYA\n'
        '• Right click: menu (hide, startup, quit…)',
    trayHelpButton: 'Reminder: where to find MYA',
    trayNotificationTitle: 'MYA is in the taskbar',
    trayNotificationBody:
        'Look for the MYA icon near the clock (click ^ on Windows 11). '
        'Right-click for the full menu.',
    trayTooltip: 'MYA — left click: open · right click: menu',
    trayOpenMya: 'Open MYA',
    trayHideBubble: 'Hide bubble',
    trayShowBubble: 'Show bubble',
    trayAotOn: 'Always on top: on',
    trayAotOff: 'Always on top: off',
    trayStartupOn: 'Start with Windows: on',
    trayStartupOff: 'Start with Windows: off',
    trayHotkeyPrefix: 'Shortcut:',
    trayQuit: 'Quit',
    panelSettings: 'Settings',
    panelExpand: 'Open full panel',
    panelDisableAot: 'Disable always on top',
    panelEnableAot: 'Enable always on top',
    panelHide: 'Hide',
    panelCollapse: 'Collapse',
    moveCategoryTooltip: 'Move to…',
    reopenTaskTooltip: 'Reopen task',
    completeTaskTooltip: 'Mark complete',
    tapToEditTooltip: 'Click to edit',
    completedOnPrefix: 'Completed on',
    addPlannedDate: 'Add date',
    addReminder: 'Add reminder',
    reminderMustBeFuture: 'The reminder must be in the future.',
    reminderInOneHour: 'In 1 hour',
    reminderTomorrow9: 'Tomorrow 9:00',
    reminderPickDateTime: 'Pick date and time…',
    clearReminder: 'Clear reminder',
    aboutPublisher: 'Publisher: Zonakron édition',
    aboutBlurb:
        'MYA is published by Zonakron édition. The software and graphics are '
        'protected by copyright. Use is subject to your acceptance of the cloud '
        'service terms you configure (e.g. Supabase, Google).',
    copyrightLine: '© 2026 Zonakron édition. All rights reserved.',
    categoryMustDo: 'GET MOVING',
    categoryToday: 'TODAY',
    categoryNext: 'NEXT UP',
    categorySomeday: 'IF I HAVE TIME',
    oauthGoogle: 'Continue with Google',
    oauthApple: 'Continue with Apple',
    oauthMicrosoft: 'Continue with Microsoft',
    updatesGitHubSubtitle: 'Version {version} — GitHub Releases',
    anchorTopLeft: 'Top left',
    anchorTopCenter: 'Top center',
    anchorTopRight: 'Top right',
    anchorCenterLeft: 'Middle left',
    anchorCenterRight: 'Middle right',
    anchorBottomLeft: 'Bottom left',
    anchorBottomCenter: 'Bottom center',
    anchorBottomRight: 'Bottom right',
  );

  static const MyaLocalizations _french = MyaLocalizations._(
    localeCode: AppLocaleCode.fr,
    languageLabel: 'Langue',
    languageEnglish: 'Anglais',
    languageFrench: 'Français',
    plannedDateHelp: 'Date prévue',
    plannedDateToday: 'Aujourd\'hui',
    plannedDateTomorrow: 'Demain',
    plannedDatePick: 'Choisir une date…',
    plannedDateClear: 'Effacer la date',
    reminderDateHelp: 'Date du rappel',
    reminderTimeHelp: 'Heure du rappel',
    cloudSignInOfferTitle: 'Connecter votre compte',
    cloudSignInOfferBody:
        'Vous avez activé la synchronisation cloud à l\'installation. '
        'Connectez-vous pour synchroniser vos tâches entre appareils. '
        'Vous pouvez ignorer cette étape et vous connecter plus tard dans les paramètres.',
    cloudSignInOfferConnect: 'Se connecter',
    cloudSignInOfferLater: 'Plus tard',
    settingsTitle: 'Paramètres',
    accountAndSyncTitle: 'Compte et synchronisation',
    updatesTitle: 'Mises à jour',
    close: 'Fermer',
    cancel: 'Annuler',
    save: 'Enregistrer',
    add: 'Ajouter',
    continueButton: 'Continuer',
    later: 'Plus tard',
    delete: 'Supprimer',
    editTaskTitle: 'Modifier la tâche',
    taskTitleLabel: 'Titre',
    nothingHere: 'Rien ici',
    noActiveTasksPreview:
        'Aucune tâche active.\nCliquez pour ouvrir le panneau complet.',
    noActiveTasksFull:
        'Aucune tâche active.\nAjoutez-en une ci-dessus ou rouvrez une tâche terminée.',
    quickAddPrompt: 'Que dois-je retenir ?',
    quickAddHintDense: '+ Ajouter un pense-bête',
    quickAddHintFull: 'Acheter câble USB-C…',
    quickAddTooltipEnter: 'Ajouter (Entrée)',
    quickAddShowOptions: 'Plus d\'options',
    quickAddHideOptions: 'Masquer les options',
    quickAddKeyboardHint: 'Entrée = ajouter · Échap = annuler',
    quickAddSuccess: 'Pense-bête ajouté',
    settingsTooltip: 'Paramètres',
    quickAddTooltip: 'Création rapide',
    versionLoading: 'Version…',
    versionUnknown: 'Version inconnue',
    versionInstalled: 'Version installée :',
    versionLine: 'Version {version}',
    supabaseNotConfigured: 'Supabase non configuré dans cette build.',
    homeWidgetTitle: 'Widget écran d\'accueil',
    homeWidgetSubtitle: 'Épingler MYA sur le launcher',
    homeWidgetPinUnsupported:
        'Votre launcher ne permet pas l\'ajout automatique. '
        'Ajoutez le widget manuellement (appui long → Widgets).',
    homeWidgetPinDialogTitle: 'Ajouter MYA à l\'écran d\'accueil',
    homeWidgetPinDialogBody:
        'MYA fonctionne mieux avec son widget 1×1 : un tap ouvre '
        'directement vos tâches.\n\n'
        'Android va vous proposer de le placer sur l\'écran d\'accueil.',
    homeWidgetPinAdd: 'Ajouter le widget',
    authDialogTitle: 'Compte et synchronisation',
    authDialogBody:
        'MYA fonctionne sans compte. Connectez-vous uniquement '
        'pour synchroniser vos tâches entre appareils.',
    authNoSupabaseBuild:
        'Cette build n\'a pas de clés Supabase. '
        'Voir docs/database.md pour la configuration.',
    authSignOut: 'Se déconnecter',
    authSignOutFailed: 'Déconnexion impossible.',
    authSignInAndroid: 'Une fenêtre de connexion va s\'ouvrir.',
    authSignInDesktop:
        'Un navigateur va s\'ouvrir. Revenez ici après la connexion.',
    authFinishInBrowser:
        'Terminez la connexion dans le navigateur, puis revenez à MYA.',
    authCloudNotConfigured: 'Sync cloud non configurée',
    authLocalNotSignedIn: 'Mode local — non connecté',
    authSignedIn: 'Connecté',
    authSignedInWith: 'Connecté :',
    authTrayNotConfigured: 'Compte : sync non configurée…',
    authTraySignIn: 'Se connecter…',
    authTrayAccount: 'Compte :',
    authConnectedAccount: 'Compte connecté',
    syncNotConfigured: 'Sync cloud non configurée',
    syncLocal: 'Mode local',
    syncSyncing: 'Synchronisation…',
    syncPending: 'En attente cloud',
    syncSynced: 'Synchronisé',
    updateAvailableTitle: 'Mise à jour disponible',
    updateDownloading: 'Téléchargement en cours…',
    updateInstall: 'Installer',
    updateDownloadInstall: 'Télécharger et installer',
    updateChecking: 'Recherche sur GitHub Releases…',
    updateRecheck: 'Revérifier',
    updateCheckFailed: 'Impossible de vérifier les mises à jour.',
    updateInstallFailed: 'Installation impossible.',
    updateAlreadyLatest: 'MYA est déjà à jour ({version}).',
    bubbleSectionTitle: 'Pastille',
    startupWithWindowsTitle: 'Démarrage avec Windows',
    startupWithWindowsSubtitle:
        'Lance MYA automatiquement au démarrage du PC.',
    alwaysOnTopTitle: 'Toujours au-dessus',
    alwaysOnTopSubtitle:
        'Garde MYA visible au-dessus des autres fenêtres.',
    hotkeySettingsTitle: 'Raccourci de création rapide',
    hotkeyRecordPrompt: 'Appuyez sur la combinaison souhaitée :',
    hotkeyCurrent: 'Actuel :',
    hotkeyModifierRequired:
        'Ajoutez au moins un modificateur (Ctrl, Alt, Maj…).',
    hotkeyDefault: 'Par défaut',
    bubbleIconPickerTitle: 'Choisissez votre pastille',
    bubbleIconPickerBody:
        'MYA reste discrète sur votre bureau. '
        'Sélectionnez l\'icône qui vous convient — vous pourrez '
        'la changer plus tard dans Paramètres.',
    bubblePositionTitle: 'Position de la pastille',
    displayLabel: 'Écran',
    displayPrimarySuffix: ' (principal)',
    bubbleFreePositionHint:
        'Position libre — choisissez un emplacement fixe',
    bubbleFreeDragTitle: 'Autoriser le déplacement libre',
    bubbleFreeDragSubtitle:
        'Active le glisser-déposer de la pastille. Elle reste toujours '
        'dans l’écran courant.',
    trayHelpTitle: 'Icône dans la barre des tâches',
    trayHelpBody:
        'MYA reste accessible via une icône près de l\'horloge '
        '(zone de notification). Sur Windows 11, cliquez sur ^ si '
        'l\'icône est masquée.\n\n'
        '• Clic gauche : ouvrir MYA\n'
        '• Clic droit : menu (masquer, démarrage auto, quitter…)',
    trayHelpButton: 'Rappel : où trouver l\'icône MYA',
    trayNotificationTitle: 'MYA est dans la barre des tâches',
    trayNotificationBody:
        'Cherchez l\'icône MYA près de l\'horloge (cliquez ^ sur Windows 11). '
        'Clic droit pour le menu complet.',
    trayTooltip:
        'MYA — clic gauche : ouvrir · clic droit : menu',
    trayOpenMya: 'Ouvrir MYA',
    trayHideBubble: 'Masquer la pastille',
    trayShowBubble: 'Afficher la pastille',
    trayAotOn: 'Toujours au-dessus : activé',
    trayAotOff: 'Toujours au-dessus : désactivé',
    trayStartupOn: 'Démarrage avec Windows : activé',
    trayStartupOff: 'Démarrage avec Windows : désactivé',
    trayHotkeyPrefix: 'Raccourci :',
    trayQuit: 'Quitter',
    panelSettings: 'Paramètres',
    panelExpand: 'Ouvrir le panneau complet',
    panelDisableAot: 'Désactiver toujours au-dessus',
    panelEnableAot: 'Activer toujours au-dessus',
    panelHide: 'Masquer',
    panelCollapse: 'Réduire',
    moveCategoryTooltip: 'Déplacer vers…',
    reopenTaskTooltip: 'Réouvrir la tâche',
    completeTaskTooltip: 'Marquer comme terminée',
    tapToEditTooltip: 'Cliquer pour modifier',
    completedOnPrefix: 'Terminée le',
    addPlannedDate: 'Ajouter une date',
    addReminder: 'Ajouter un rappel',
    reminderMustBeFuture: 'Le rappel doit être dans le futur.',
    reminderInOneHour: 'Dans 1 heure',
    reminderTomorrow9: 'Demain 9h',
    reminderPickDateTime: 'Choisir date et heure…',
    clearReminder: 'Effacer le rappel',
    aboutPublisher: 'Éditeur : Zonakron édition',
    aboutBlurb:
        'MYA est édité par Zonakron édition. '
        'Le logiciel et ses éléments graphiques sont protégés par le droit '
        "d'auteur. L'utilisation est soumise à votre acceptation des conditions "
        'd\'utilisation du service cloud que vous configurez (ex. Supabase, Google).',
    copyrightLine: '© 2026 Zonakron édition. Tous droits réservés.',
    categoryMustDo: 'BOUGE TON GROS CUL',
    categoryToday: 'AUJOURD\'HUI',
    categoryNext: 'ENSUITE',
    categorySomeday: 'À FAIRE SI J\'AI LE TEMPS',
    oauthGoogle: 'Continuer avec Google',
    oauthApple: 'Continuer avec Apple',
    oauthMicrosoft: 'Continuer avec Microsoft',
    updatesGitHubSubtitle: 'Version {version} — GitHub Releases',
    anchorTopLeft: 'En haut à gauche',
    anchorTopCenter: 'En haut au centre',
    anchorTopRight: 'En haut à droite',
    anchorCenterLeft: 'Au milieu à gauche',
    anchorCenterRight: 'Au milieu à droite',
    anchorBottomLeft: 'En bas à gauche',
    anchorBottomCenter: 'En bas au centre',
    anchorBottomRight: 'En bas à droite',
  );
}

class MyaLocalizationsDelegate extends LocalizationsDelegate<MyaLocalizations> {
  const MyaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'en' || locale.languageCode == 'fr';
  }

  @override
  Future<MyaLocalizations> load(Locale locale) {
    return SynchronousFuture(MyaLocalizations.lookupFromLocale(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MyaLocalizations> old) =>
      false;
}

extension MyaLocalizationsContext on BuildContext {
  MyaLocalizations get l10n => MyaLocalizations.of(this);
}
