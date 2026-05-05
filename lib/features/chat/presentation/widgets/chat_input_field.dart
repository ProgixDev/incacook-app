import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/buttons/circular_icon_button.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    this.onSend,
    this.onAttach,
    this.onMic,
    this.hintText = 'Type A Message...',
  });

  final ValueChanged<String>? onSend;
  final VoidCallback? onAttach;
  final VoidCallback? onMic;
  final String hintText;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        AppSizes.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FrostedSurface(
              borderRadius: BorderRadius.circular(40),
              padding: const EdgeInsets.fromLTRB(
                AppSizes.xs + 2,
                AppSizes.xs,
                AppSizes.xs + 2,
                AppSizes.xs,
              ),
              child: Row(
                children: [
                  CircularIconButton(
                    icon: Iconsax.add,
                    onPressed: widget.onAttach ?? () {},
                    backgroundColor: Colors.transparent,
                    iconColor: scheme.onSurfaceVariant,
                  ),
                  const Gap(AppSizes.sm),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      minLines: 1,
                      maxLines: 5,
                      style: Theme.of(context).textTheme.bodyMedium,
                      cursorColor: scheme.onSurface,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                        isCollapsed: true,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSizes.sm + 2,
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSizes.sm),
                  CircularIconButton(
                    icon: Iconsax.microphone,
                    onPressed: widget.onMic ?? () {},
                    backgroundColor: Colors.transparent,
                    iconColor: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const Gap(AppSizes.sm),
          // SendButton(onTap: _handleSend),
          CircularIconButton(
            size: 42,
            icon: Iconsax.send_1,
            onPressed: _handleSend,
            backgroundColor: colors.selectedSurface,
            iconColor: colors.selectedOnSurface,
          ),
        ],
      ),
    );
  }
}
