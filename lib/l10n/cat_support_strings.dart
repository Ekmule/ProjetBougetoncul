import 'package:flutter/material.dart';
import 'package:mya/l10n/app_locale_code.dart';
import 'package:mya/l10n/mya_localizations.dart';

class CatSupportStrings {
  const CatSupportStrings._(this.isFrench);

  final bool isFrench;

  String get title => isFrench ? 'Soutenir MYA' : 'Support MYA';
  String get message => isFrench
      ? 'Remercie mon chat de vous avoir jugé'
      : 'Thank my cat for judging you';
  String donationAmount(int euros) =>
      isFrench ? 'Don de $euros €' : 'Donate €$euros';
  String get suggestion =>
      isFrench ? 'Envoyer une suggestion' : 'Send a suggestion';
  String get suggestionTitle => isFrench ? 'Ta suggestion' : 'Your suggestion';
  String get suggestionHint => isFrench
      ? 'Écris ton idée pour améliorer MYA…'
      : 'Write your idea to improve MYA…';
  String get suggestionHelp => isFrench
      ? 'Ton application e-mail s’ouvrira. 255 caractères maximum.'
      : 'Your email app will open. 255 characters maximum.';
  String get cancel => isFrench ? 'Annuler' : 'Cancel';
  String get send => isFrench ? 'Envoyer' : 'Send';
  String get emailSubject =>
      isFrench ? 'Suggestion pour MYA' : 'Suggestion for MYA';
  String get openLinkError =>
      isFrench ? 'Impossible d’ouvrir le lien.' : 'Unable to open the link.';
  String get openEmailError => isFrench
      ? 'Aucune application e-mail disponible.'
      : 'No email app is available.';
}

extension CatSupportStringsContext on BuildContext {
  CatSupportStrings get catSupportStrings =>
      CatSupportStrings._(l10n.localeCode == AppLocaleCode.fr);
}
