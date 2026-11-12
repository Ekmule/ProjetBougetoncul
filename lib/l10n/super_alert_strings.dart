import 'package:flutter/material.dart';
import 'package:mya/l10n/app_locale_code.dart';
import 'package:mya/l10n/mya_localizations.dart';

class SuperAlertStrings {
  const SuperAlertStrings._(this.isFrench);

  final bool isFrench;

  String get title => isFrench ? 'SUPER ALERTE' : 'SUPER ALERT';
  String get option => isFrench ? 'Super alerte' : 'Super alert';
  String get enableOption =>
      isFrench ? 'Activer la super alerte' : 'Enable super alert';
  String get disableOption =>
      isFrench ? 'Désactiver la super alerte' : 'Disable super alert';
  String get optionHelp => isFrench
      ? 'Affiche l’image et joue le son à l’ouverture de MYA.'
      : 'Shows the image and plays the sound when MYA opens.';
  String get normalReminder => isFrench ? 'Rappel normal' : 'Normal reminder';
  String get alertType => isFrench ? 'Type de rappel' : 'Reminder type';
  String get stop => isFrench ? 'Arrêter l’alerte' : 'Stop alert';
  String get complete => isFrench ? 'Terminer la tâche' : 'Complete task';
  String get dueMessage => isFrench
      ? 'Cette tâche réclame votre attention :'
      : 'This task needs your attention:';
  String get judgmentCaption =>
      isFrench ? 'Mon chat vous juge' : 'My cat judges you';
  String get displaySizeTitle =>
      isFrench ? 'Taille de la super alerte' : 'Super alert size';
  String get displaySizeHelp => isFrench
      ? 'Pourcentage de l’écran utilisé sur Windows.'
      : 'Percentage of the screen used on Windows.';
}

extension SuperAlertStringsContext on BuildContext {
  SuperAlertStrings get superAlertStrings =>
      SuperAlertStrings._(l10n.localeCode == AppLocaleCode.fr);
}
