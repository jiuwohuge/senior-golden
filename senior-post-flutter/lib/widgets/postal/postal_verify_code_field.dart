import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/postal_tokens.dart';
import 'postal_text_field.dart';

/// 验证码：输入框 + 右侧固定宽度发送按钮（避免 suffix 在无界约束下撑出无限宽）。
class PostalVerifyCodeField extends StatelessWidget {
  const PostalVerifyCodeField({
    super.key,
    required this.controller,
    required this.label,
    required this.sendLabel,
    required this.onSend,
    this.hint,
    this.sending = false,
    this.cooldownSeconds = 0,
    this.enabled = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String sendLabel;
  final VoidCallback? onSend;
  final bool sending;
  final int cooldownSeconds;
  final bool enabled;
  final FormFieldValidator<String>? validator;

  bool get _canSend =>
      enabled && !sending && cooldownSeconds <= 0 && onSend != null;

  @override
  Widget build(BuildContext context) {
    final waiting = cooldownSeconds > 0;
    final actionText = waiting ? '${cooldownSeconds}s' : sendLabel;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: PostalTextField(
            controller: controller,
            label: label,
            hint: hint,
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            showClearButton: false,
            enabled: enabled,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: validator,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 88,
          height: 52,
          child: TextButton(
            onPressed: _canSend ? onSend : null,
            style: TextButton.styleFrom(
              foregroundColor: PostalTokens.postboxGreen,
              disabledForegroundColor: PostalTokens.inkSecondary,
              backgroundColor: PostalTokens.paperEnvelope,
              side: BorderSide(
                color: _canSend
                    ? PostalTokens.postboxGreen
                    : PostalTokens.kraftBrownMuted,
              ),
              minimumSize: const Size(88, 52),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: const RoundedRectangleBorder(
                borderRadius: PostalTokens.shapeMd,
              ),
            ),
            child: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    actionText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _canSend
                          ? PostalTokens.postboxGreen
                          : PostalTokens.inkSecondary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
