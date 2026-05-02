import 'package:flutter/material.dart';

import '../../app/theme/postal_tokens.dart';

/// 复古头像：占位采用首字母 + 邮票框 + 牛皮纸边。
class PostalAvatar extends StatelessWidget {
  const PostalAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.framed = true,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final initial = (name == null || name!.trim().isEmpty)
        ? '?'
        : name!.trim().characters.first.toUpperCase();

    final inner = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PostalTokens.paperCard,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PostalTokens.kraftBrownMuted.withValues(alpha: 0.6),
            PostalTokens.paperEnvelope,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (_, _, _) => _initialText(initial),
              ),
            )
          : _initialText(initial),
    );

    if (!framed) return inner;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PostalTokens.kraftBrown, width: 1.4),
      ),
      child: inner,
    );
  }

  Widget _initialText(String initial) {
    return Text(
      initial,
      style: TextStyle(
        color: PostalTokens.postboxGreen,
        fontSize: size * 0.42,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}
