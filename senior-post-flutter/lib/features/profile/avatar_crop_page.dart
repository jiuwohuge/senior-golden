import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../widgets/postal/postal.dart';

/// 头像裁剪（圆形预览，输出圆内接正方形位图供上传）。
class AvatarCropPage extends StatefulWidget {
  const AvatarCropPage({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<AvatarCropPage> createState() => _AvatarCropPageState();
}

class _AvatarCropPageState extends State<AvatarCropPage> {
  final _controller = CropController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: PostalTokens.paperCream,
      appBar: AppBar(
        backgroundColor: PostalTokens.postboxGreen,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: PostalTokens.inkNavy.withValues(alpha: 0.2),
        iconTheme: const IconThemeData(color: Colors.white, size: 26),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: l10n.profileAvatarCropCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.profileAvatarCropTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _controller,
              withCircleUi: true,
              aspectRatio: 1,
              interactive: true,
              baseColor: PostalTokens.paperCard,
              onCropped: (CropResult result) {
                switch (result) {
                  case CropSuccess(:final croppedImage):
                    Navigator.of(context).pop<Uint8List>(croppedImage);
                  case CropFailure(:final cause):
                    PostalSnack.show(
                      context,
                      '$cause',
                      tone: PostalSnackTone.error,
                    );
                }
              },
            ),
          ),
          Material(
            elevation: 8,
            shadowColor: PostalTokens.inkNavy.withValues(alpha: 0.12),
            color: PostalTokens.paperEnvelope,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.profileAvatarCropHelp,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PostalTokens.inkSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PostalTokens.postboxGreen,
                                side: const BorderSide(
                                  color: PostalTokens.postboxGreen,
                                  width: 1.4,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: PostalTokens.shapeMd,
                                ),
                              ),
                              child: Text(
                                l10n.profileAvatarCropCancel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: () => _controller.cropCircle(),
                              style: FilledButton.styleFrom(
                                backgroundColor: PostalTokens.postboxGreen,
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: PostalTokens.shapeMd,
                                ),
                              ),
                              child: Text(
                                l10n.profileAvatarCropConfirm,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
