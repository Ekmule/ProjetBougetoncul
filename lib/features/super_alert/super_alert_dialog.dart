import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/tasks/tasks_notifier.dart';
import 'package:mya/core/cat_image_catalog.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/l10n/super_alert_strings.dart';

/// Alerte renforcée affichée à l'ouverture de MYA.
class SuperAlertDialog extends ConsumerStatefulWidget {
  const SuperAlertDialog({super.key, required this.task});

  final Task task;

  static Future<void> show(BuildContext context, Task task) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => SuperAlertDialog(task: task),
    );
  }

  @override
  ConsumerState<SuperAlertDialog> createState() => _SuperAlertDialogState();
}

class _SuperAlertDialogState extends ConsumerState<SuperAlertDialog>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _colorController;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    unawaited(_startSound());
  }

  Future<void> _startSound() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('super_alert/Bouge ton gros cul.mp3'));
    } catch (_) {
      // L'écran reste utilisable si le moteur audio ou l'asset est indisponible.
    }
  }

  Future<void> _stop({required bool complete}) async {
    if (_busy) return;
    setState(() => _busy = true);
    await _player.stop();
    if (complete) {
      await ref.read(tasksProvider.notifier).completeTask(widget.task.id);
    } else {
      await ref
          .read(tasksProvider.notifier)
          .acknowledgeSuperAlert(widget.task.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _colorController.dispose();
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.superAlertStrings;
    final size = MediaQuery.sizeOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                strings.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _colorController,
                builder: (context, _) {
                  final progress = reduceMotion ? 0.5 : _colorController.value;
                  final color = Color.lerp(
                    Colors.redAccent,
                    Colors.amberAccent,
                    progress,
                  );
                  return Text(
                    strings.judgmentCaption,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: color, fontWeight: FontWeight.w800),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(strings.dueMessage),
              const SizedBox(height: 8),
              Text(
                widget.task.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _colorController,
                    builder: (context, child) {
                      final progress = reduceMotion
                          ? 0.5
                          : _colorController.value;
                      final color = Color.lerp(
                        Colors.redAccent,
                        Colors.amberAccent,
                        progress,
                      )!;
                      return Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 28,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        CatImageCatalog.today,
                        width: size.width,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.notification_important_rounded,
                          color: Colors.redAccent,
                          size: 140,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _stop(complete: false),
                    icon: const Icon(Icons.volume_off_outlined),
                    label: Text(strings.stop),
                  ),
                  FilledButton.icon(
                    onPressed: _busy ? null : () => _stop(complete: true),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(strings.complete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
