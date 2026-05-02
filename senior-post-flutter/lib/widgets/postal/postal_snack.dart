import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

enum PostalSnackTone { info, success, warning, error }

/// 邮政风格 Snackbar：纸条 + 邮戳红/绿点 + 圆角。
class PostalSnack {
  PostalSnack._();

  static void show(
    BuildContext context,
    String message, {
    PostalSnackTone tone = PostalSnackTone.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final color = switch (tone) {
      PostalSnackTone.info => PostalTokens.info,
      PostalSnackTone.success => PostalTokens.success,
      PostalSnackTone.warning => PostalTokens.warning,
      PostalSnackTone.error => PostalTokens.stampVermilion,
    };
    final icon = switch (tone) {
      PostalSnackTone.info => Icons.info_outline,
      PostalSnackTone.success => Icons.check_circle_outline,
      PostalSnackTone.warning => Icons.error_outline,
      PostalSnackTone.error => Icons.cancel_outlined,
    };

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: PostalTokens.inkNavy,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: const RoundedRectangleBorder(
            borderRadius: PostalTokens.shapeMd,
          ),
          content: Row(
            children: [
              Container(
                width: 8,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: PostalTokens.stampGold,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }
}
