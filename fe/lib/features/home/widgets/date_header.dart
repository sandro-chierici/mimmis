import 'package:flutter/material.dart';

const _monthNamesShort = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

class DateHeader extends StatelessWidget {
  const DateHeader({
    super.key,
    required this.selectedDate,
    required this.onDayTap,
    required this.onMonthTap,
    required this.onYearTap,
  });

  final DateTime selectedDate;
  final VoidCallback onDayTap;
  final VoidCallback onMonthTap;
  final VoidCallback onYearTap;

  @override
  Widget build(BuildContext context) {
    final day = selectedDate.day.toString().padLeft(2, '0');
    final monthNum = selectedDate.month.toString().padLeft(2, '0');
    final monthName = _monthNamesShort[selectedDate.month - 1];
    final year = selectedDate.year.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 110,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Day — small box
            _TappableDateBox(
              flex: 1,
              onTap: onDayTap,
              child: Text(
                day,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Month — large box
            _TappableDateBox(
              flex: 3,
              onTap: onMonthTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    monthNum,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    monthName,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 3,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Year — large box
            _TappableDateBox(
              flex: 3,
              onTap: onYearTap,
              child: Text(
                year,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TappableDateBox extends StatelessWidget {
  const _TappableDateBox({
    required this.flex,
    required this.child,
    required this.onTap,
  });

  final int flex;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      flex: flex,
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withAlpha(128),
              ),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                child,
                Positioned(
                  top: 0,
                  right: 6,
                  child: Icon(
                    Icons.edit,
                    size: 11,
                    color: scheme.onSurfaceVariant.withAlpha(100),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
