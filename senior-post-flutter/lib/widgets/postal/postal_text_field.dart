import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/postal_tokens.dart';

/// 邮政风格输入框：圆角、纸感底色、focus 邮筒绿，错误就地提示。
/// - 支持密码显隐、清除按钮、前后图标
/// - 高度 52，照顾 45+ 触控热区
class PostalTextField extends StatefulWidget {
  const PostalTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscure = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.showClearButton = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscure;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool showClearButton;
  final bool autofocus;

  @override
  State<PostalTextField> createState() => _PostalTextFieldState();
}

class _PostalTextFieldState extends State<PostalTextField> {
  late bool _obscureText;
  TextEditingController? _ownedController;

  TextEditingController get _ctrl =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _ctrl,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextFormField(
          controller: _ctrl,
          obscureText: _obscureText,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            helperText: widget.helper,
            counterText: widget.maxLength == null ? '' : null,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: PostalTokens.kraftBrown,
                    size: 22,
                  )
                : null,
            suffixIcon: _suffix(hasText),
          ),
        );
      },
    );
  }

  Widget? _suffix(bool hasText) {
    final children = <Widget>[];
    if (widget.obscure) {
      children.add(
        IconButton(
          tooltip: _obscureText ? 'Show' : 'Hide',
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: PostalTokens.kraftBrown,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      );
    } else if (widget.showClearButton && hasText && widget.enabled) {
      children.add(
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(
            Icons.cancel_rounded,
            color: PostalTokens.kraftBrown,
          ),
          onPressed: () {
            _ctrl.clear();
            widget.onChanged?.call('');
          },
        ),
      );
    }
    if (children.isEmpty) return null;
    if (children.length == 1) return children.first;
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
