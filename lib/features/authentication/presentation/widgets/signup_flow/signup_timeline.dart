import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';

/// Top-of-screen step indicator for the multi-step signup flow.
///
/// Renders a horizontal row of dots connected by a track. The currently
/// active dot pulses subtly; completed dots are filled with a checkmark.
class SignupTimeline extends StatelessWidget {
  const SignupTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() {
        final total = controller.totalPages;
        // Guard against empty steps list during initialization - show nothing
        // rather than throwing from List.generate(-1, ...) when total is 0.
        if (total == 0) return const SizedBox.shrink();
        final current = controller.currentPage.value.clamp(0, total - 1);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Row(
            children: List.generate(total * 2 - 1, (i) {
              if (i.isOdd) {
                final segIndex = i ~/ 2;
                return _Track(completed: segIndex < current);
              }
              final dotIndex = i ~/ 2;
              return _Dot(
                state: dotIndex < current
                    ? _DotState.completed
                    : dotIndex == current
                        ? _DotState.active
                        : _DotState.upcoming,
              );
            }),
          ),
        );
      }),
    );
  }
}

enum _DotState { completed, active, upcoming }

class _Dot extends StatefulWidget {
  const _Dot({required this.state});

  final _DotState state;

  @override
  State<_Dot> createState() => _DotInternalState();
}

class _DotInternalState extends State<_Dot>
    with SingleTickerProviderStateMixin {
  // Eager (not `late final`) — the controller must always exist by the
  // time [dispose] runs. With `late final` + side-effecting initializer,
  // a dot that's never the active one wouldn't access [_pulse] during
  // build, so [dispose] would lazily create the controller using
  // `vsync: this` while the State is already deactivating, which throws
  // "Looking up a deactivated widget's ancestor".
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCompleted = widget.state == _DotState.completed;
    final isActive = widget.state == _DotState.active;

    final fill = isCompleted || isActive ? scheme.primary : Colors.transparent;
    final border = isCompleted || isActive
        ? scheme.primary
        : scheme.outlineVariant;
    final size = isActive ? 16.0 : 12.0;

    Widget dot = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check, size: 8, color: Colors.white)
          : null,
    );

    if (isActive) {
      dot = AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) {
          final t = Curves.easeInOut.transform(_pulse.value);
          final scale = 1.0 + 0.10 * t;
          final glow = 0.30 - 0.20 * t;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: glow),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: dot,
      );
    }

    return SizedBox(
      width: 22,
      height: 22,
      child: Center(child: dot),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 24,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: completed ? scheme.primary : scheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
