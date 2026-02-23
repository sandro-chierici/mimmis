import 'package:flutter/material.dart';

import '../../../data/models/cost.dart';

class CostPreviewList extends StatelessWidget {
  const CostPreviewList({
    super.key,
    required this.costs,
    required this.onAddTap,
    required this.onItemTap,
  });

  final List<Cost> costs;
  final VoidCallback onAddTap;
  final ValueChanged<Cost> onItemTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Row(
            children: [
              Text(
                'Recent',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onAddTap,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (costs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withAlpha(128),
                ),
              ),
              child: Center(
                child: Text(
                  'No costs this month',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withAlpha(128),
                ),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < costs.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: scheme.outlineVariant.withAlpha(80),
                      ),
                    _CostRow(
                      cost: costs[i],
                      onTap: () => onItemTap(costs[i]),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({required this.cost, required this.onTap});

  final Cost cost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Total is stored in minor units (cents). Display as €.
    final amount = '€ ${(cost.total / 100).toStringAsFixed(2)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cost.name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                if (cost.note.isNotEmpty)
                  Text(
                    cost.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
        ],
        ),
      ),
    );
  }
}
