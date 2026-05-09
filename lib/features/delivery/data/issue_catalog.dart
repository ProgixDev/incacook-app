import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/order_stage.dart';

/// How an issue resolves once confirmed.
/// - [abort]  → cancels the active job (advances to [OrderStage.failed]).
/// - [report] → notes the issue but the driver can keep going.
enum IssueSeverity { abort, report }

class IssueOption {
  const IssueOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.severity,
    required this.applicableStages,
    this.isOther = false,
  });

  final String id;
  final String label;
  final IconData icon;
  final IssueSeverity severity;
  final Set<OrderStage> applicableStages;

  /// "Other" → opens a free-text step before confirmation.
  final bool isOther;
}

class IssueCatalog {
  IssueCatalog._();

  static const Set<OrderStage> _pickup = {
    OrderStage.prepared,
    OrderStage.arrivedPickup,
  };

  static const Set<OrderStage> _dropoff = {
    OrderStage.onTheWay,
    OrderStage.arrivedDropoff,
  };

  static const Set<OrderStage> _active = {
    OrderStage.prepared,
    OrderStage.arrivedPickup,
    OrderStage.onTheWay,
    OrderStage.arrivedDropoff,
  };

  static const List<IssueOption> _all = [
    //* abort — pickup side
    IssueOption(
      id: 'restaurant_closed',
      label: AppTexts.issueRestaurantClosed,
      icon: Iconsax.shop_remove,
      severity: IssueSeverity.abort,
      applicableStages: _pickup,
    ),
    IssueOption(
      id: 'order_unavailable',
      label: AppTexts.issueOrderUnavailable,
      icon: Iconsax.box_remove,
      severity: IssueSeverity.abort,
      applicableStages: _pickup,
    ),
    //* abort — dropoff side
    IssueOption(
      id: 'customer_unreachable',
      label: AppTexts.issueCustomerUnreachable,
      icon: Iconsax.user_remove,
      severity: IssueSeverity.abort,
      applicableStages: _dropoff,
    ),
    IssueOption(
      id: 'wrong_address',
      label: AppTexts.issueWrongAddress,
      icon: Iconsax.location_slash,
      severity: IssueSeverity.abort,
      applicableStages: _dropoff,
    ),
    IssueOption(
      id: 'customer_refused',
      label: AppTexts.issueCustomerRefused,
      icon: Iconsax.close_circle,
      severity: IssueSeverity.abort,
      applicableStages: _dropoff,
    ),
    //* abort — anywhere
    IssueOption(
      id: 'vehicle_problem',
      label: AppTexts.issueVehicleProblem,
      icon: Iconsax.car,
      severity: IssueSeverity.abort,
      applicableStages: _active,
    ),
    //* report — pickup side
    IssueOption(
      id: 'order_not_ready',
      label: AppTexts.issueOrderNotReady,
      icon: Iconsax.clock,
      severity: IssueSeverity.report,
      applicableStages: _pickup,
    ),
    IssueOption(
      id: 'missing_item',
      label: AppTexts.issueMissingItem,
      icon: Iconsax.box,
      severity: IssueSeverity.report,
      applicableStages: _pickup,
    ),
    //* report — anywhere; free-text variant
    IssueOption(
      id: 'other',
      label: AppTexts.issueOther,
      icon: Iconsax.message_question,
      severity: IssueSeverity.report,
      applicableStages: _active,
      isOther: true,
    ),
  ];

  static List<IssueOption> forStage(OrderStage stage, IssueSeverity severity) {
    return _all
        .where(
          (i) =>
              i.severity == severity && i.applicableStages.contains(stage),
        )
        .toList(growable: false);
  }
}
