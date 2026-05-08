import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';
import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/delivery/data/issue_catalog.dart';
import 'package:incacook/features/orders/domain/order_stage.dart';

/// Resolved selection from [showIssueReportModal]: which issue, plus the
/// driver's free-text note when the option is the "Other" variant.
class IssueReportResult {
  const IssueReportResult({required this.option, this.note});

  final IssueOption option;
  final String? note;
}

/// Presents the stage-aware issue picker. Returns the driver's selection,
/// or `null` if they dismissed without confirming.
Future<IssueReportResult?> showIssueReportModal(
  BuildContext context, {
  required OrderStage stage,
}) {
  return showBlurredModalBottomSheet<IssueReportResult>(
    context: context,
    builder: (_) => IssueReportSheet(stage: stage),
  );
}

class IssueReportSheet extends StatefulWidget {
  const IssueReportSheet({super.key, required this.stage});

  final OrderStage stage;

  @override
  State<IssueReportSheet> createState() => _IssueReportSheetState();
}

sealed class _Step {
  const _Step();
}

class _PickerStep extends _Step {
  const _PickerStep();
}

class _OtherStep extends _Step {
  const _OtherStep(this.option);
  final IssueOption option;
}

class _ConfirmStep extends _Step {
  const _ConfirmStep({required this.option, this.note});
  final IssueOption option;
  final String? note;
}

class _IssueReportSheetState extends State<IssueReportSheet> {
  _Step _step = const _PickerStep();

  void _select(IssueOption option) {
    setState(() {
      _step = option.isOther
          ? _OtherStep(option)
          : _ConfirmStep(option: option);
    });
  }

  void _submitOther(IssueOption option, String note) {
    setState(() => _step = _ConfirmStep(option: option, note: note));
  }

  void _back() {
    setState(() {
      _step = switch (_step) {
        _PickerStep() => _step,
        _OtherStep() => const _PickerStep(),
        _ConfirmStep s when s.note != null =>
          _OtherStep(s.option), //? came from Other → step back to text input
        _ConfirmStep() => const _PickerStep(), //? came from picker
      };
    });
  }

  void _confirm(_ConfirmStep step) {
    Navigator.of(context).pop(
      IssueReportResult(option: step.option, note: step.note),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: FrostedSurface(
          borderRadius: BorderRadius.circular(28),
          tint: scheme.surface.withValues(alpha: 0.94),
          child: SafeArea(
            top: false,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.bottomCenter,
              child: switch (_step) {
                _PickerStep() => _PickerView(
                  stage: widget.stage,
                  onSelect: _select,
                  onClose: () => Navigator.of(context).pop(),
                ),
                _OtherStep(option: final option) => _OtherInputView(
                  option: option,
                  onBack: _back,
                  onSubmit: (note) => _submitOther(option, note),
                ),
                final _ConfirmStep step => _ConfirmView(
                  step: step,
                  onBack: _back,
                  onConfirm: () => _confirm(step),
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerView extends StatelessWidget {
  const _PickerView({
    required this.stage,
    required this.onSelect,
    required this.onClose,
  });

  final OrderStage stage;
  final ValueChanged<IssueOption> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final aborts = IssueCatalog.forStage(stage, IssueSeverity.abort);
    final reports = IssueCatalog.forStage(stage, IssueSeverity.report);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        AppSizes.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: AppTexts.issueSheetTitle,
            leading: const SizedBox.shrink(),
            trailing: IconButton(
              icon: const Icon(Iconsax.close_circle),
              onPressed: onClose,
            ),
          ),
          if (aborts.isNotEmpty) ...[
            const Gap(AppSizes.md),
            _SectionLabel(text: AppTexts.issueSheetSectionAbort),
            const Gap(AppSizes.xs),
            _OptionGroup(
              options: aborts,
              onSelect: onSelect,
              accent: BrandColors.error,
            ),
          ],
          if (reports.isNotEmpty) ...[
            const Gap(AppSizes.md),
            _SectionLabel(text: AppTexts.issueSheetSectionReport),
            const Gap(AppSizes.xs),
            _OptionGroup(
              options: reports,
              onSelect: onSelect,
              accent: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.options,
    required this.onSelect,
    required this.accent,
  });

  final List<IssueOption> options;
  final ValueChanged<IssueOption> onSelect;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            _OptionTile(
              option: options[i],
              accent: accent,
              onTap: () => onSelect(options[i]),
            ),
            if (i != options.length - 1)
              Divider(
                height: 1,
                indent: 56,
                color: scheme.outline.withValues(alpha: 0.15),
              ),
          ],
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.accent,
    required this.onTap,
  });

  final IssueOption option;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(option.icon, color: accent, size: 18),
            ),
            const Gap(AppSizes.sm + 2),
            Expanded(
              child: Text(
                option.label,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherInputView extends StatefulWidget {
  const _OtherInputView({
    required this.option,
    required this.onBack,
    required this.onSubmit,
  });

  final IssueOption option;
  final VoidCallback onBack;
  final ValueChanged<String> onSubmit;

  @override
  State<_OtherInputView> createState() => _OtherInputViewState();
}

class _OtherInputViewState extends State<_OtherInputView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        AppSizes.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: AppTexts.issueSheetOtherInputTitle,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left_2),
              onPressed: widget.onBack,
            ),
            trailing: const SizedBox.shrink(),
          ),
          const Gap(AppSizes.md),
          TextField(
            controller: _controller,
            maxLines: 5,
            minLines: 4,
            autofocus: true,
            textInputAction: TextInputAction.newline,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: AppTexts.issueSheetOtherInputHint,
              filled: true,
              fillColor: scheme.surfaceContainerLow.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
            ),
          ),
          const Gap(AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _controller.text.trim().isEmpty
                  ? null
                  : () => widget.onSubmit(_controller.text.trim()),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(AppTexts.issueSheetContinueCta),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmView extends StatelessWidget {
  const _ConfirmView({
    required this.step,
    required this.onBack,
    required this.onConfirm,
  });

  final _ConfirmStep step;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isAbort = step.option.severity == IssueSeverity.abort;
    final accent = isAbort ? BrandColors.error : scheme.primary;
    final subtitle = isAbort
        ? AppTexts.issueSheetConfirmAbortSubtitle
        : AppTexts.issueSheetConfirmReportSubtitle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        AppSizes.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: AppTexts.issueSheetConfirmTitle,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left_2),
              onPressed: onBack,
            ),
            trailing: const SizedBox.shrink(),
          ),
          const Gap(AppSizes.lg),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(step.option.icon, color: accent, size: 28),
          ),
          const Gap(AppSizes.md),
          Text(
            step.option.label,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          if ((step.note ?? '').isNotEmpty) ...[
            const Gap(AppSizes.xs + 2),
            Text(
              step.note!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const Gap(AppSizes.sm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Gap(AppSizes.lg + 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSizes.md - 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(AppTexts.issueSheetCancelCta),
                ),
              ),
              const Gap(AppSizes.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSizes.md - 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(AppTexts.issueSheetConfirmCta),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.leading,
    required this.trailing,
  });

  final String title;
  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(width: 40, height: 40, child: Center(child: leading)),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: 40, height: 40, child: Center(child: trailing)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
