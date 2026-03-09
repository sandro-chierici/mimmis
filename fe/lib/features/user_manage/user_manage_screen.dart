import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user.dart';
import 'user_manage_notifier.dart';

class UserManageScreen extends StatefulWidget {
  const UserManageScreen({super.key, required this.notifier});

  final UserManageNotifier notifier;

  @override
  State<UserManageScreen> createState() => _UserManageScreenState();
}

class _UserManageScreenState extends State<UserManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.notifier.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        final n = widget.notifier;
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'User Manager',
              style: textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (n.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: n.isLoading && n.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (n.error != null)
                          _ErrorBanner(
                            message: n.error!,
                            onDismiss: n.clearError,
                          ),
                        if (n.users.isEmpty && !n.isLoading)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No users yet. Add one below.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        else
                          _UserTable(
                            users: n.users,
                            deletingId: n.deletingId,
                            onEdit: (user) => _openForm(context, user: user),
                            onDelete: (user) =>
                                _confirmDelete(context, n, user),
                          ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _openForm(context),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add User'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context, {User? user}) async {
    final refreshed =
        await context.push<bool>('/user-form', extra: user);
    if (refreshed == true) {
      widget.notifier.refresh();
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, UserManageNotifier n, User user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove user'),
        content: Text(
            'Remove ${user.name} ${user.surname}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await n.delete(user.userId);
    }
  }
}

// ── User table ─────────────────────────────────────────────────────────────────

class _UserTable extends StatelessWidget {
  const _UserTable({
    required this.users,
    required this.deletingId,
    required this.onEdit,
    required this.onDelete,
  });

  final List<User> users;
  final String? deletingId;
  final ValueChanged<User> onEdit;
  final ValueChanged<User> onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(maxHeight: 264), // ~3 rows
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withAlpha(128)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Name',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Surname',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Email',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 72), // actions column space
              ],
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant.withAlpha(128)),
          // Scrollable body (capped at 3 rows)
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: users.length,
              separatorBuilder: (context2, index2) =>
                  Divider(height: 1, color: scheme.outlineVariant.withAlpha(80)),
              itemBuilder: (_, index) {
                final user = users[index];
                final isDeleting = deletingId == user.userId;
                return _UserRow(
                  user: user,
                  isDeleting: isDeleting,
                  onEdit: () => onEdit(user),
                  onDelete: () => onDelete(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  final User user;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              user.name,
              style: textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              user.surname,
              style: textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.mail,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isDeleting)
            const SizedBox(
              width: 72,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  iconSize: 20,
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_rounded,
                      color: scheme.primary),
                ),
                IconButton(
                  tooltip: 'Remove',
                  iconSize: 20,
                  onPressed: onDelete,
                  icon:
                      Icon(Icons.delete_rounded, color: scheme.error),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Error banner ───────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: scheme.onErrorContainer),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
