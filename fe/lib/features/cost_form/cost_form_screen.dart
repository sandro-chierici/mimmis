import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'cost_form_notifier.dart';

class CostFormScreen extends StatelessWidget {
  const CostFormScreen({super.key, required this.notifier});

  final CostFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final n = notifier;
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            actions: [
              if (n.isEditing)
                IconButton(
                  tooltip: 'Delete cost',
                  onPressed: n.isDeleting
                      ? null
                      : () async {
                          final ok = await n.delete();
                          if (ok && context.mounted) {
                            context.pop(true);
                          }
                        },
                  icon: n.isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : const Icon(Icons.delete_rounded, color: Colors.red),
                ),
            ],
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  n.isEditing ? 'Edit Cost' : 'Add Cost',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (n.selectedUserName != null) ...[  
                  const SizedBox(width: 8),
                  Text(
                    n.selectedUserName!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (n.error != null) ...[
                          _ErrorBanner(
                            message: n.error!,
                            onDismiss: n.clearError,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _LabeledField(
                          label: 'Name',
                          child: TextField(
                            controller: n.nameCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: _inputDecoration(
                              context,
                              hint: 'e.g. Groceries',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: 'Note',
                          child: TextField(
                            controller: n.noteCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 3,
                            decoration: _inputDecoration(
                              context,
                              hint: 'Optional note…',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: 'Amount (€)',
                          child: TextField(
                            controller: n.totalCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration(
                              context,
                              hint: '0.00',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ShadowCostTile(
                          value: n.shadowCost,
                          onChanged: n.setShadowCost,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _BottomActions(
                  isSaving: n.isSaving,
                  onBack: () => context.pop(false),
                  onConfirm: () async {
                    final ok = await n.save();
                    if (ok && context.mounted) {
                      context.pop(true);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {required String hint}) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InputDecoration(
      hintText: hint,
      hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ── Private widgets ────────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _ShadowCostTile extends StatelessWidget {
  const _ShadowCostTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shadow Cost',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Excluded from shared calculations',
                  style: textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isSaving,
    required this.onBack,
    required this.onConfirm,
  });

  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withAlpha(128)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSaving ? null : onBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: isSaving ? null : onConfirm,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall
                  ?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.close_rounded, color: scheme.onErrorContainer, size: 18),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
