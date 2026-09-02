import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mya/application/hotkeys/global_hotkey_display.dart';
import 'package:mya/application/hotkeys/global_hotkey_notifier.dart';
import 'package:mya/application/hotkeys/global_hotkey_service.dart';
import 'package:mya/core/constants/global_hotkey_defaults.dart';

/// Dialogue de configuration du raccourci global (D12).
class HotkeySettingsDialog extends ConsumerStatefulWidget {
  const HotkeySettingsDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const HotkeySettingsDialog(),
    );
  }

  @override
  ConsumerState<HotkeySettingsDialog> createState() =>
      _HotkeySettingsDialogState();
}

class _HotkeySettingsDialogState extends ConsumerState<HotkeySettingsDialog> {
  HotKey? _recordedHotkey;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recordedHotkey = ref.read(globalHotkeyProvider);
  }

  Future<void> _save() async {
    final hotkey = _recordedHotkey;
    if (hotkey == null) return;

    final service = ref.read(globalHotkeyServiceProvider);
    if (!service.isValid(hotkey)) {
      setState(() {
        _error = 'Ajoutez au moins un modificateur (Ctrl, Alt, Maj…).';
      });
      return;
    }

    await ref.read(globalHotkeyProvider.notifier).setHotkey(hotkey);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _recordedHotkey = GlobalHotkeyDefaults.quickAdd;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotkey = _recordedHotkey;

    return AlertDialog(
      title: const Text('Raccourci de création rapide'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appuyez sur la combinaison souhaitée :'),
          const SizedBox(height: 12),
          if (hotkey != null)
            HotKeyRecorder(
              initalHotKey: hotkey,
              onHotKeyRecorded: (recorded) {
                setState(() {
                  _recordedHotkey = recorded;
                  _error = null;
                });
              },
            ),
          if (hotkey != null) ...[
            const SizedBox(height: 8),
            Text(
              'Actuel : ${GlobalHotkeyDisplay.format(hotkey)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _resetToDefault,
          child: const Text('Par défaut'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
