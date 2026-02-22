import 'package:flutter/material.dart';

class MonthlySummary extends StatelessWidget {
  const MonthlySummary({
    super.key,
    required this.userTotal,
    required this.fairShare,
    required this.diff,
    required this.userName,
  });

  /// All values are in minor currency units (cents).
  final int userTotal;
  final int fairShare;
  final int diff;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOver = diff > 0;
    final isEven = diff == 0;
    final diffColor = isEven
        ? scheme.tertiary
        : isOver
            ? scheme.error
            : scheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User total
          _SummaryCard(
            label: '$userName this month',
            value: _fmt(userTotal),
            valueColor: scheme.onSurface,
            icon: Icons.account_balance_wallet_outlined,
            iconColor: scheme.primary,
          ),
          const SizedBox(height: 10),
          // Balance diff
          _SummaryCard(
            label: _diffLabel(isOver, isEven),
            sublabel:
                'Fair share: ${_fmt(fairShare)}',
            value: '${isOver ? '+' : isEven ? '' : '−'} ${_fmt(diff.abs())}',
            valueColor: diffColor,
            icon: isEven
                ? Icons.balance
                : isOver
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
            iconColor: diffColor,
          ),
        ],
      ),
    );
  }

  String _fmt(int minor) => '€ ${(minor / 100).toStringAsFixed(2)}';

  String _diffLabel(bool isOver, bool isEven) {
    if (isEven) return 'Perfectly balanced';
    return isOver ? 'You spent more than your share' : 'You spent less — you\'re owed';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    this.sublabel,
    required this.value,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String? sublabel;
  final String value;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant.withAlpha(160),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
