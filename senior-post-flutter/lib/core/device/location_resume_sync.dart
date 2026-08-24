import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../device/location_access.dart';

/// 从系统设置返回前台时，若定位已打开则补报经纬度。
class LocationResumeSync extends ConsumerStatefulWidget {
  const LocationResumeSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LocationResumeSync> createState() => _LocationResumeSyncState();
}

class _LocationResumeSyncState extends ConsumerState<LocationResumeSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    ref.read(locationAccessProvider).syncToServerIfPossible();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
