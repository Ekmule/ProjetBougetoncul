import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mya/core/cat_image_catalog.dart';
import 'package:mya/l10n/cat_support_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class CatSupportSection extends StatelessWidget {
  const CatSupportSection({super.key});

  static const _donationUrls = {
    1: 'https://www.paypal.com/paypalme/ekmule/1',
    2: 'https://www.paypal.com/paypalme/ekmule/2',
    5: 'https://www.paypal.com/paypalme/ekmule/5',
  };

  Future<void> _openDonation(BuildContext context, int amount) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(_donationUrls[amount]!),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Le message ci-dessous guide l'utilisateur si aucun navigateur ne répond.
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.catSupportStrings.openLinkError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.catSupportStrings;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(Icons.favorite_outline),
        title: Text(strings.title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: Image.asset(
                    CatImageCatalog.today,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Colors.black12,
                      child: Center(child: Icon(Icons.pets_outlined, size: 56)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                strings.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final amount in _donationUrls.keys)
                    OutlinedButton.icon(
                      onPressed: () => _openDonation(context, amount),
                      icon: const Icon(Icons.favorite_outline),
                      label: Text(strings.donationAmount(amount)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const _SuggestionDialog(),
                ),
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(strings.suggestion),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionDialog extends StatefulWidget {
  const _SuggestionDialog();

  @override
  State<_SuggestionDialog> createState() => _SuggestionDialogState();
}

class _SuggestionDialogState extends State<_SuggestionDialog> {
  static const _recipient = 'zonakron.edition@gmail.com';
  final _controller = TextEditingController();
  var _sending = false;
  var _emailError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final suggestion = _controller.text.trim();
    if (suggestion.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _emailError = false;
    });

    final strings = context.catSupportStrings;
    final uri = Uri(
      scheme: 'mailto',
      path: _recipient,
      queryParameters: {'subject': strings.emailSubject, 'body': suggestion},
    );
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Le dialogue reste ouvert et affiche une explication.
    }
    if (!mounted) return;
    if (opened) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _sending = false;
        _emailError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.catSupportStrings;

    return AlertDialog(
      title: Text(strings.suggestionTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 5,
            maxLength: 255,
            inputFormatters: [LengthLimitingTextInputFormatter(255)],
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: strings.suggestionHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() => _emailError = false),
          ),
          Text(strings.suggestionHelp),
          if (_emailError) ...[
            const SizedBox(height: 8),
            Text(
              strings.openEmailError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => FilledButton.icon(
            onPressed: value.text.trim().isEmpty || _sending ? null : _send,
            icon: const Icon(Icons.email_outlined),
            label: Text(strings.send),
          ),
        ),
      ],
    );
  }
}
