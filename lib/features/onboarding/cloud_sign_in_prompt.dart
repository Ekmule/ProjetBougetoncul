import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/features/onboarding/cloud_sign_in_offer_dialog.dart';

/// Propose la connexion compte si demandée à l'installation Windows.
Future<void> maybeShowCloudSignInPrompt(
  BuildContext context,
  WidgetRef ref,
) async {
  final store = ref.read(deviceSettingsStoreProvider);
  if (!store.isCloudSignInPromptPending()) return;
  if (!ref.read(authConfiguredProvider)) {
    await store.clearCloudSignInPromptPending();
    return;
  }

  final user = ref.read(authUserProvider).value;
  if (user != null) {
    await store.clearCloudSignInPromptPending();
    return;
  }

  if (!context.mounted) return;

  final connect = await CloudSignInOfferDialog.show(context);
  await store.clearCloudSignInPromptPending();

  if (!connect || !context.mounted) return;

  await CloudSignInOfferDialog.openAuthSettings(context);
}
