import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/orders/domain/order_stage.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.currentStage, this.onStageTap});

  final OrderStage currentStage;
  final ValueChanged<OrderStage>? onStageTap;

  static const _stages = [
    _StageSpec(
      stage: OrderStage.prepared,
      icon: Icons.room_service_rounded,
      label: AppTexts.trackingStagePrepared,
    ),
    _StageSpec(
      stage: OrderStage.onTheWay,
      icon: Icons.delivery_dining_rounded,
      label: AppTexts.trackingStageOnTheWay,
    ),
    _StageSpec(
      stage: OrderStage.delivered,
      icon: Icons.home_rounded,
      label: AppTexts.trackingStageDelivered,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stages.indexWhere((s) => s.stage == currentStage);

    return Row(
      children: [
        for (var i = 0; i < _stages.length; i++) ...[
          Expanded(
            child: _StageColumn(
              spec: _stages[i],
              state: i < currentIndex
                  ? _StageState.done
                  : i == currentIndex
                  ? _StageState.active
                  : _StageState.upcoming,
              onTap: onStageTap == null
                  ? null
                  : () => onStageTap!(_stages[i].stage),
            ),
          ),
          if (i != _stages.length - 1) _Connector(done: i < currentIndex),
        ],
      ],
    );
  }
}

enum _StageState { done, active, upcoming }

class _StageSpec {
  const _StageSpec({
    required this.stage,
    required this.icon,
    required this.label,
  });

  final OrderStage stage;
  final IconData icon;
  final String label;
}

class _StageColumn extends StatelessWidget {
  const _StageColumn({required this.spec, required this.state, this.onTap});

  final _StageSpec spec;
  final _StageState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = state == _StageState.active;
    final isDone = state == _StageState.done;

    final bgColor = (isActive || isDone) ? scheme.onSurface : scheme.surface;
    final iconColor = (isActive || isDone) ? scheme.surface : scheme.onSurfaceVariant;
    final labelColor = isActive ? scheme.onSurface : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //? halo ring only around the active dot
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? scheme.onSurface.withValues(alpha: 0.06)
                  : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: state == _StageState.upcoming
                    ? Border.all(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.2),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(spec.icon, color: iconColor, size: 20),
            ),
          ),
          const Gap(6),
          Text(
            spec.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: labelColor,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      //? align with the dot row (ignore the label height below)
      padding: const EdgeInsets.only(bottom: 26),
      child: SizedBox(
        width: 48,
        height: 2,
        child: CustomPaint(
          painter: _DashedLinePainter(
            done: done,
            doneColor: scheme.onSurface,
            upcomingColor: scheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.done, required this.doneColor, required this.upcomingColor});

  final bool done;
  final Color doneColor;
  final Color upcomingColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = done ? doneColor : upcomingColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dashWidth = 4.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashWidth, size.height / 2),
        paint,
      );
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.done != done ||
      oldDelegate.doneColor != doneColor ||
      oldDelegate.upcomingColor != upcomingColor;
}
