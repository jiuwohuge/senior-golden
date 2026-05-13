import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_provider.dart';

class AppReleaseNote {
  const AppReleaseNote({
    required this.id,
    required this.title,
    required this.versionLabel,
    required this.releaseNotes,
  });

  final int id;
  final String title;
  final String versionLabel;
  final String releaseNotes;

  factory AppReleaseNote.fromJson(Map<String, dynamic> m) {
    return AppReleaseNote(
      id: (m['id'] as num).toInt(),
      title: (m['title'] as String?)?.trim() ?? '',
      versionLabel: (m['versionLabel'] as String?)?.trim() ?? '',
      releaseNotes: (m['releaseNotes'] as String?)?.trim() ?? '',
    );
  }
}

final releaseNoteFetchProvider = FutureProvider<AppReleaseNote?>((ref) async {
  final dio = ref.watch(dioProvider);
  final vcStr = const String.fromEnvironment('API_VERSION_CODE', defaultValue: '1');
  final vc = int.tryParse(vcStr) ?? 1;
  try {
    final res = await dio.get<Map<String, dynamic>>(
      '/api/bootstrap/release-note',
      queryParameters: <String, dynamic>{'versionCode': vc},
    );
    final raw = res.data;
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    if (raw['success'] is bool && raw['success'] == false) {
      return null;
    }
    final inner = raw['data'];
    if (inner is! Map<String, dynamic>) {
      return null;
    }
    return AppReleaseNote.fromJson(inner);
  } on DioException {
    return null;
  }
});

/// 非强更版本公告：可关闭，关闭后写入 SharedPreferences。
class ReleaseNoteLayer extends ConsumerStatefulWidget {
  const ReleaseNoteLayer({super.key});

  @override
  ConsumerState<ReleaseNoteLayer> createState() => _ReleaseNoteLayerState();
}

class _ReleaseNoteLayerState extends ConsumerState<ReleaseNoteLayer> {
  bool _presented = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AppReleaseNote?>>(releaseNoteFetchProvider, (prev, next) {
      next.whenData((note) {
        if (note != null && !_presented && mounted) {
          _maybeShow(note);
        }
      });
    });
    return const SizedBox.shrink();
  }

  Future<void> _maybeShow(AppReleaseNote note) async {
    if (_presented || !mounted) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = 'release_note_dismissed_${note.id}';
    if (prefs.getBool(key) == true) {
      return;
    }
    _presented = true;
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(note.title.isEmpty ? 'Update' : note.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (note.versionLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      note.versionLabel,
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                  ),
                SelectableText(
                  note.releaseNotes,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.setBool(key, true);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
