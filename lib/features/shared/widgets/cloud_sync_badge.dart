import 'package:flutter/material.dart';
import 'package:mya/application/sync/sync_ui_state.dart';

/// Pastille colorée indiquant l'état cloud sur l'icône MYA.
class CloudSyncBadge extends StatelessWidget {
  const CloudSyncBadge({
    super.key,
    required this.snapshot,
    this.size = 12,
    this.pulse = false,
  });

  final CloudSyncSnapshot snapshot;
  final double size;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.showsConnectedBadge) return const SizedBox.shrink();

    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: snapshot.badgeColor(Theme.of(context).colorScheme),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
    );

    if (!pulse || snapshot.state != CloudSyncUiState.syncing) return dot;

    return _PulsingBadge(child: dot);
  }
}

class CloudSyncStatusChip extends StatelessWidget {
  const CloudSyncStatusChip({
    super.key,
    required this.snapshot,
    this.compact = false,
  });

  final CloudSyncSnapshot snapshot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (snapshot.state == CloudSyncUiState.notConfigured ||
        snapshot.state == CloudSyncUiState.local) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = snapshot.badgeColor(theme.colorScheme);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CloudSyncBadge(
            snapshot: snapshot,
            size: compact ? 8 : 10,
            pulse: snapshot.state == CloudSyncUiState.syncing,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            snapshot.statusLabel(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: compact ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingBadge extends StatefulWidget {
  const _PulsingBadge({required this.child});

  final Widget child;

  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 0.55,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
