import 'package:flutter/material.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Which date component to pick (public API).
typedef DatePart = _DatePart;

/// Shows a bottom sheet with a drum-roll [ListWheelScrollView].
/// Returns the chosen [DateTime] (only the changed component is replaced).
Future<DateTime?> showDatePartPicker({
  required BuildContext context,
  required DateTime current,
  required DatePart part,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _DatePartSheet(current: current, part: part),
  );
}

/// Which date component to pick.
enum _DatePart { day, month, year }

class _DatePartSheet extends StatefulWidget {
  const _DatePartSheet({required this.current, required this.part});

  final DateTime current;
  final _DatePart part;

  @override
  State<_DatePartSheet> createState() => _DatePartSheetState();
}

class _DatePartSheetState extends State<_DatePartSheet> {
  late List<int> _values;
  late int _selectedIndex;
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _values = _buildValues();
    final seed = _seedValue();
    _selectedIndex = _values.indexOf(seed).clamp(0, _values.length - 1);
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  List<int> _buildValues() {
    switch (widget.part) {
      case _DatePart.day:
        return List.generate(31, (i) => i + 1);
      case _DatePart.month:
        return List.generate(12, (i) => i + 1);
      case _DatePart.year:
        final now = DateTime.now().year;
        return List.generate(11, (i) => now - 5 + i);
    }
  }

  int _seedValue() {
    switch (widget.part) {
      case _DatePart.day:   return widget.current.day;
      case _DatePart.month: return widget.current.month;
      case _DatePart.year:  return widget.current.year;
    }
  }

  String _label(int value) {
    switch (widget.part) {
      case _DatePart.day:   return value.toString().padLeft(2, '0');
      case _DatePart.month: return _monthNames[value - 1];
      case _DatePart.year:  return value.toString();
    }
  }

  String get _title {
    switch (widget.part) {
      case _DatePart.day:   return 'Day';
      case _DatePart.month: return 'Month';
      case _DatePart.year:  return 'Year';
    }
  }

  DateTime _buildResult(int value) {
    switch (widget.part) {
      case _DatePart.day:
        // Clamp to valid day for the current month.
        final maxDay = DateUtils.getDaysInMonth(
            widget.current.year, widget.current.month);
        return DateTime(
          widget.current.year,
          widget.current.month,
          value.clamp(1, maxDay),
        );
      case _DatePart.month:
        final maxDay = DateUtils.getDaysInMonth(widget.current.year, value);
        return DateTime(
          widget.current.year,
          value,
          widget.current.day.clamp(1, maxDay),
        );
      case _DatePart.year:
        final maxDay = DateUtils.getDaysInMonth(value, widget.current.month);
        return DateTime(
          value,
          widget.current.month,
          widget.current.day.clamp(1, maxDay),
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _title,
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          // Drum-roll picker
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Selection highlight band
                Center(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withAlpha(120),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: 48,
                  perspective: 0.003,
                  diameterRatio: 2.5,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (i) =>
                      setState(() => _selectedIndex = i),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: _values.length,
                    builder: (context, index) {
                      final selected = index == _selectedIndex;
                      return Center(
                        child: Text(
                          _label(_values[index]),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: selected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context)
                  .pop(_buildResult(_values[_selectedIndex])),
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}
