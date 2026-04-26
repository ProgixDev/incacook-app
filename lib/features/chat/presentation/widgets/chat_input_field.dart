import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/buttons/circular_icon_button.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';

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
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.xs + 2,
                AppSizes.xs,
                AppSizes.xs + 2,
                AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Color(0xFFEAEAEA)),
              ),
              child: Row(
                children: [
                  CircularIconButton(
                    icon: Iconsax.add,
                    onPressed: widget.onAttach ?? () {},
                    backgroundColor: AppColors.white,
                    iconColor: AppColors.grey,
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
                      cursorColor: AppColors.secondary,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
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
                    backgroundColor: Color(0xFFF6F6F6),
                    iconColor: AppColors.grey,
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
            backgroundColor: AppColors.secondary,
            iconColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
