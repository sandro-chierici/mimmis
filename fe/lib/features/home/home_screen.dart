import 'package:flutter/material.dart';

import 'home_notifier.dart';
import 'widgets/cost_preview_list.dart';
import 'widgets/date_header.dart';
import 'widgets/date_picker_sheet.dart';
import 'widgets/monthly_summary.dart';
import 'widgets/user_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.notifier});

  final HomeNotifier notifier;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Defer until after the first frame so notifyListeners() inside init()
    // doesn't fire during the widget tree's first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.notifier.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        final n = widget.notifier;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: n.isLoading && n.users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
              onRefresh: n.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── App bar ───────────────────────────────────────────────
                  SliverAppBar(
                    pinned: true,
                    backgroundColor:
                        Theme.of(context).colorScheme.surface,
                    surfaceTintColor: Colors.transparent,
                    title: Text(
                      'Mimmis',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
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

                  if (n.error != null)
                    SliverFillRemaining(
                      child: _ErrorView(
                        message: n.error!,
                        onRetry: n.refresh,
                      ),
                    )
                  else ...[
                    // ── User selector ─────────────────────────────────────
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                      child: UserSelector(
                        users: n.users,
                        selectedUser: n.selectedUser,
                        onSelect: n.selectUser,
                      ),
                    ),

                    // ── Date header ───────────────────────────────────────
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: DateHeader(
                        selectedDate: n.selectedDate,
                        onDayTap: () => _pickDatePart(context, n, DatePart.day),
                        onMonthTap: () => _pickDatePart(context, n, DatePart.month),
                        onYearTap: () => _pickDatePart(context, n, DatePart.year),
                      ),
                    ),

                    // ── Cost preview ──────────────────────────────────────
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: CostPreviewList(
                        costs: n.recentCosts(),
                        onAddTap: () {
                          // TODO: navigate to Add Cost screen
                        },
                      ),
                    ),

                    // ── Monthly summary ───────────────────────────────────
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: n.selectedUser != null
                          ? MonthlySummary(
                              userTotal: n.userMonthTotal,
                              fairShare: n.fairShare,
                              diff: n.diff,
                              userName: n.selectedUser!.name,
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDatePart(
      BuildContext context, HomeNotifier n, DatePart part) async {
    final picked = await showDatePartPicker(
      context: context,
      current: n.selectedDate,
      part: part,
    );
    if (picked != null) {
      n.setSelectedDate(picked);
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
