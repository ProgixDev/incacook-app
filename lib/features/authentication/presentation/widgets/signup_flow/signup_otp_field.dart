import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 6-box one-time-password input. Auto-advances on digit entry, supports
/// paste, and emits the full code via [onCompleted] once all 6 are filled.
class SignupOtpField extends StatefulWidget {
  const SignupOtpField({
    super.key,
    required this.onCompleted,
    this.length = 6,
    this.onChanged,
    this.errorText,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  State<SignupOtpField> createState() => _SignupOtpFieldState();
}

class _SignupOtpFieldState extends State<SignupOtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentCode => _controllers.map((c) => c.text).join();

  void _emit() {
    widget.onChanged?.call(_currentCode);
    if (_currentCode.length == widget.length) {
      widget.onCompleted(_currentCode);
    }
  }

  void _onChanged(int index, String v) {
    if (v.length > 1) {
      // Paste path — distribute digits across the boxes.
      final digits =
          v.replaceAll(RegExp(r'\D'), '').split('').take(widget.length).toList();
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final fillCount = digits.length.clamp(0, widget.length);
      FocusScope.of(context).requestFocus(
        _focusNodes[fillCount >= widget.length
            ? widget.length - 1
            : fillCount],
      );
      _emit();
      return;
    }
    if (v.isNotEmpty && index < widget.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    _emit();
  }

  void _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (i) {
            return KeyboardListener(
              focusNode: FocusNode(skipTraversal: true),
              onKeyEvent: (event) => _onKey(i, event),
              child: SizedBox(
                width: 48,
                height: 56,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (v) => _onChanged(i, v),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: scheme.surfaceContainerLow,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: hasError
                            ? scheme.error
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: hasError ? scheme.error : scheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
  }
}
