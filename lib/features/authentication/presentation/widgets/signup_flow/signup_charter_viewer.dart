import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';

/// Scrollable viewer for legal text. Surfaces a "tu dois lire jusqu'à la
/// fin" hint that disappears once the user has scrolled to the bottom.
/// Reports the scroll-to-bottom transition via [onReachedBottom] so the
/// caller can enable an acceptance checkbox.
class SignupCharterViewer extends StatefulWidget {
  const SignupCharterViewer({
    super.key,
    required this.text,
    this.onReachedBottom,
    this.maxHeightFraction = 0.4,
  });

  final String text;
  final VoidCallback? onReachedBottom;
  final double maxHeightFraction;

  @override
  State<SignupCharterViewer> createState() => _SignupCharterViewerState();
}

class _SignupCharterViewerState extends State<SignupCharterViewer> {
  final _controller = ScrollController();
  bool _atBottom = false;
  bool _emittedBottom = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_controller.hasClients) return;
      if (_controller.position.maxScrollExtent <= 0) {
        setState(() => _atBottom = true);
        _emitOnce();
      }
    });
  }

  void _onScroll() {
    final pos = _controller.position;
    final reached = pos.pixels >= pos.maxScrollExtent - 8;
    if (reached != _atBottom) {
      setState(() => _atBottom = reached);
      if (reached) _emitOnce();
    }
  }

  void _emitOnce() {
    if (_emittedBottom) return;
    _emittedBottom = true;
    widget.onReachedBottom?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Honor a bounded parent (e.g. wrapped in [Expanded]) — otherwise
    // fall back to a fraction of the screen so callers nested inside an
    // unbounded scroll view still get a sensible cap.
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final maxH = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * widget.maxHeightFraction;
        return _buildBody(scheme, maxH);
      },
    );
  }

  Widget _buildBody(ColorScheme scheme, double maxH) {
    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          ),
          padding: const EdgeInsets.all(AppSizes.md),
          child: Scrollbar(
            controller: _controller,
            child: SingleChildScrollView(
              controller: _controller,
              child: Text(
                widget.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ),
          ),
        ),
        if (!_atBottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSizes.sm,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _atBottom ? 0 : 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm + 4,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const Gap(AppSizes.xs),
                      Text(
                        AppTexts.signupCharterScrollHint,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
