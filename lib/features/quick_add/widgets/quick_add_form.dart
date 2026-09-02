import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mya/core/constants/task_categories.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/features/quick_add/models/quick_add_input.dart';

/// Formulaire de création rapide — 1 saisie + validation (spec §12).
///
/// Les options (catégorie) sont repliables pour ne pas bloquer le flux rapide.
class QuickAddForm extends StatefulWidget {
  const QuickAddForm({
    super.key,
    required this.onSubmit,
    this.onCancel,
    this.autofocus = true,
    this.showCategoryOptions = true,
    this.dense = false,
  });

  final ValueChanged<QuickAddInput> onSubmit;
  final VoidCallback? onCancel;
  final bool autofocus;
  final bool showCategoryOptions;
  final bool dense;

  @override
  State<QuickAddForm> createState() => _QuickAddFormState();
}

class _QuickAddFormState extends State<QuickAddForm> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  var _showOptions = false;
  var _category = TaskCategoryId.next;

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final input = QuickAddInput(
      title: _controller.text,
      category: _category,
    );
    if (!input.isValid) return;

    widget.onSubmit(input);
    _controller.clear();
    setState(() {
      _showOptions = false;
      _category = TaskCategoryId.next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shortcuts(
      shortcuts: {
        if (widget.onCancel != null)
          const SingleActivator(LogicalKeyboardKey.escape): _CancelIntent(),
      },
      child: Actions(
        actions: {
          if (widget.onCancel != null)
            _CancelIntent: CallbackAction<_CancelIntent>(
              onInvoke: (_) {
                widget.onCancel!();
                return null;
              },
            ),
        },
        child: Focus(
          autofocus: widget.autofocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.dense)
                Text(
                  'Que dois-je retenir ?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (!widget.dense) const SizedBox(height: 12),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.dense
                      ? '+ Ajouter un pense-bête'
                      : 'Acheter câble USB-C…',
                  prefixIcon: widget.dense
                      ? const Icon(Icons.add, size: 22)
                      : null,
                  suffixIcon: widget.dense
                      ? IconButton(
                          icon: const Icon(Icons.send_rounded),
                          tooltip: 'Ajouter (Entrée)',
                          onPressed: _submit,
                        )
                      : null,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (widget.showCategoryOptions) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _showOptions = !_showOptions),
                  icon: Icon(
                    _showOptions
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18,
                  ),
                  label: Text(
                    _showOptions ? 'Masquer les options' : 'Plus d\'options',
                  ),
                ),
                if (_showOptions) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final category in TaskCategoryDisplay.displayOrder)
                        ChoiceChip(
                          label: Text(
                            category.defaultLabel,
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: _category == category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                    ],
                  ),
                ],
              ],
              if (!widget.dense) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.onCancel != null)
                      TextButton(
                        onPressed: widget.onCancel,
                        child: const Text('Annuler'),
                      ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Entrée = ajouter · Échap = annuler',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelIntent extends Intent {
  const _CancelIntent();
}
