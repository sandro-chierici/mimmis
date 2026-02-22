import 'package:flutter/material.dart';

import '../../../data/models/user.dart';

class UserSelector extends StatelessWidget {
  const UserSelector({
    super.key,
    required this.users,
    required this.selectedUser,
    required this.onSelect,
  });

  final List<User> users;
  final User? selectedUser;

  /// Called when the user taps a card. May return a Future (async selectUser).
  final void Function(User) onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: users.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final user = users[index];
          final selected = user.userId == selectedUser?.userId;

          return GestureDetector(
            onTap: () => onSelect(user),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? scheme.primary
                      : scheme.outlineVariant.withAlpha(128),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurface,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                  ),
                  Text(
                    user.surname,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected
                              ? scheme.onPrimaryContainer.withAlpha(180)
                              : scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
