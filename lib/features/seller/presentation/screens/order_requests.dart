import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

import 'package:homemade/core/constants/animations.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/widgets/decor/decor_blob.dart';
import 'package:homemade/features/seller/data/accepted_order_mock_data.dart';
import 'package:homemade/features/seller/domain/accepted_order.dart';
import 'package:homemade/features/seller/presentation/widgets/accepted_order_card.dart';
import 'package:homemade/features/seller/presentation/widgets/orders_filter_panel.dart';
import 'package:homemade/features/seller/presentation/widgets/orders_tab_toggle.dart';

class OrderRequestsScreen extends StatefulWidget {
  const OrderRequestsScreen({super.key});

  @override
  State<OrderRequestsScreen> createState() => _OrderRequestsScreenState();
}

class _OrderRequestsScreenState extends State<OrderRequestsScreen> {
  OrdersTab _tab = OrdersTab.accepted;
  OrdersStatusFilter _statusFilter;
  OrdersSortBy _sortBy = OrdersSortBy.acceptedTime;

  _OrderRequestsScreenState() : _statusFilter = null;

  List<AcceptedOrder> get _orders {
    final source = _tab == OrdersTab.accepted
        ? AcceptedOrderMockData.demoAccepted()
        : AcceptedOrderMockData.demoHistory();
    final filtered = _statusFilter == null
        ? source
        : source.where((o) => o.status == _statusFilter).toList();
    final sorted = [...filtered]
      ..sort((a, b) {
        return switch (_sortBy) {
          OrdersSortBy.acceptedTime => b.acceptedAt.compareTo(a.acceptedAt),
          OrdersSortBy.totalPrice => b.totalPrice.compareTo(a.totalPrice),
        };
      });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orders;
    return Scaffold(
      body: Stack(
        children: [
          //* decorative top-right blob (purely cosmetic, no input).
          const Positioned(
            top: -8,
            right: -16,
            child: IgnorePointer(child: DecorBlob()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                children: [
                  const Gap(AppSizes.md),
                  OrdersTabToggle(
                    selected: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                  const Gap(AppSizes.md),
                  OrdersFilterPanel(
                    statusFilter: _statusFilter,
                    sortBy: _sortBy,
                    onStatusChanged: (s) =>
                        setState(() => _statusFilter = s),
                    onSortChanged: (s) => setState(() => _sortBy = s),
                  ),
                  const Gap(AppSizes.spaceBtwSections),
                  Expanded(
                    child: orders.isEmpty
                        ? const _EmptyOrders()
                        : ListView.separated(
                            padding: const EdgeInsets.only(
                              bottom: AppSizes.spaceBtwSections,
                            ),
                            itemCount: orders.length,
                            separatorBuilder: (_, _) =>
                                const Gap(AppSizes.md),
                            itemBuilder: (context, i) =>
                                AcceptedOrderCard(order: orders[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            AppAnimations.noResults,
            width: MediaQuery.of(context).size.width * 0.6,
            fit: BoxFit.contain,
          ),
          const Gap(AppSizes.md),
          Text(
            AppTexts.sellerOrdersEmptyMessage,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
