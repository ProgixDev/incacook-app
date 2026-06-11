import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/delivery/presentation/widgets/delivery_nav_bar.dart';
import 'package:incacook/features/delivery/presentation/widgets/delivery_settings_section.dart';
import 'package:incacook/features/delivery/presentation/widgets/job_lifecycle_card.dart';
import 'package:incacook/features/delivery/presentation/widgets/today_stats_card.dart';

class DeliveryBottomSheet extends StatefulWidget {
  const DeliveryBottomSheet({super.key});

  @override
  State<DeliveryBottomSheet> createState() => _DeliveryBottomSheetState();
}

class _DeliveryBottomSheetState extends State<DeliveryBottomSheet> {
  static const double _expandedFraction = 0.9;
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  /// 1 = nav bar fully frosted (sheet collapsed); 0 = solid surface (expanded).
  /// Driven from [_controller] in [_updateFrostedness].
  final ValueNotifier<double> _frostedness = ValueNotifier<double>(1.0);

  /// Currently selected nav-bar tab — drives which body content is shown.
  final ValueNotifier<DeliveryNavTab> _selectedTab =
      ValueNotifier<DeliveryNavTab>(DeliveryNavTab.drive);

  /// Recomputed in [build] from MediaQuery; the listener reads it.
  double _collapsedFraction = 0.15;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFrostedness);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateFrostedness);
    _controller.dispose();
    _frostedness.dispose();
    _selectedTab.dispose();
    super.dispose();
  }

  void _updateFrostedness() {
    final range = _expandedFraction - _collapsedFraction;
    if (range <= 0) return;
    final t = ((_controller.size - _collapsedFraction) / range).clamp(0.0, 1.0);
    _frostedness.value = 1 - t;
  }

  void _toggle() {
    final size = _controller.size;
    final midpoint = (_collapsedFraction + _expandedFraction) / 2;
    final target = size < midpoint ? _expandedFraction : _collapsedFraction;
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectTab(DeliveryNavTab tab) {
    _selectedTab.value = tab;
    //* Tapping a tab while collapsed expands the sheet so the user can
    //* see the content they just switched to.
    final midpoint = (_collapsedFraction + _expandedFraction) / 2;
    if (_controller.size < midpoint) {
      _controller.animateTo(
        _expandedFraction,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //* The collapsed sheet is just tall enough to show the full nav bar
    //* (including its overhang) plus the bottom safe area.
    _collapsedFraction =
        (DeliveryNavBar.totalHeight + MediaQuery.of(context).padding.bottom) /
        MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _collapsedFraction,
      minChildSize: _collapsedFraction,
      maxChildSize: _expandedFraction,
      snap: true,
      snapSizes: [_collapsedFraction, _expandedFraction],
      builder: (context, scrollController) {
        final scheme = Theme.of(context).colorScheme;
        return Column(
          children: [
            GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: DeliveryNavBar(
                frostedness: _frostedness,
                selectedTab: _selectedTab,
                onTabSelected: _selectTab,
              ),
            ),
            Expanded(
              //* Body shares the bar's surface tint so they read as one
              //* continuous panel — alpha tracks `_frostedness` in lockstep
              //* with the bar (1 = collapsed/over-map, 0 = expanded/solid).
              child: ValueListenableBuilder<double>(
                valueListenable: _frostedness,
                builder: (context, t, child) => ColoredBox(
                  color: DeliveryNavBar.surfaceTintFor(scheme, t),
                  child: child,
                ),
                //* Body content swaps based on the active tab. Keyed on the
                //* tab so the ListView is rebuilt with a clean scroll
                //* position when the user switches.
                child: ValueListenableBuilder<DeliveryNavTab>(
                  valueListenable: _selectedTab,
                  builder: (context, tab, _) {
                    if (tab == DeliveryNavTab.settings) {
                      return ListView(
                        key: const ValueKey(DeliveryNavTab.settings),
                        controller: scrollController,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        children: const [
                          Gap(AppSizes.xl),
                          DeliverySettingsSection(),
                          Gap(AppSizes.lg),
                        ],
                      );
                    }
                    //* Drive tab: when a job is active, show the lifecycle
                    //* card; otherwise the idle dashboard.
                    return Obx(() {
                      final hasJob = DeliveryRouteController
                          .instance.currentJob.value != null;
                      return ListView(
                        key: ValueKey(hasJob),
                        controller: scrollController,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        children: hasJob
                            ? const [
                                Gap(AppSizes.xl),
                                JobLifecycleCard(),
                                Gap(AppSizes.lg),
                              ]
                            // Scheduled-pickups ("Prochain retrait") section
                            // removed: it had no backend and rendered mock
                            // ScheduledPickup data with a mock-accept button.
                            // The real flow is the live incoming-order modal.
                            : const [
                                Gap(AppSizes.xl),
                                TodayStatsCard(),
                                Gap(AppSizes.lg),
                              ],
                      );
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
