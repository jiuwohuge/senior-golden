import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileAvatarCropTitle),
        actions: [
          TextButton(
            onPressed: () => _controller.cropCircle(),
            child: Text(l10n.profileAvatarCropDone),
          ),
        ],
      ),
      body: SafeArea(
        child: Crop(
          image: widget.imageBytes,
          controller: _controller,
          withCircleUi: true,
          aspectRatio: 1,
          interactive: true,
          baseColor: Theme.of(context).colorScheme.surface,
          onCropped: (CropResult result) {
            switch (result) {
              case CropSuccess(:final croppedImage):
                Navigator.of(context).pop<Uint8List>(croppedImage);
              case CropFailure(:final cause):
                PostalSnack.show(context, '$cause', tone: PostalSnackTone.error);
            }
          },
        ),
      ),
    );
  }
}
