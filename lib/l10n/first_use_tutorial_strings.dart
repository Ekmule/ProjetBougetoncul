import 'package:flutter/material.dart';
import 'package:mya/l10n/app_locale_code.dart';
import 'package:mya/l10n/mya_localizations.dart';

class FirstUseTutorialStrings {
  const FirstUseTutorialStrings._(this.isFrench);

  final bool isFrench;

  String get title =>
      isFrench ? 'Bienvenue sur Move Your Ass' : 'Welcome to Move Your Ass';
  String get createTask => isFrench
      ? 'Créez une tâche en saisissant un texte, puis validez avec la flèche.'
      : 'Create a task by typing some text, then confirm with the arrow.';
  String get addDate => isFrench
      ? 'Votre tâche est créée. Le calendrier permet de lui ajouter une date.'
      : 'Your task is created. Use the calendar to add a date.';
  String get enableSuperAlert => isFrench
      ? 'La cloche active ou désactive directement la super alerte.'
      : 'The bell directly turns the super alert on or off.';
  String get alertBehavior => isFrench
      ? 'Pour une tâche prévue aujourd’hui, la super alerte se lance lorsque vous revenez dans MYA. L’icône MYA bouge doucement pour vous prévenir.'
      : 'For a task due today, the super alert appears when you return to MYA. The MYA icon gently moves to warn you.';
  String get understood => isFrench ? 'J’ai compris' : 'Got it';
}

extension FirstUseTutorialStringsContext on BuildContext {
  FirstUseTutorialStrings get firstUseTutorialStrings =>
      FirstUseTutorialStrings._(l10n.localeCode == AppLocaleCode.fr);
}
