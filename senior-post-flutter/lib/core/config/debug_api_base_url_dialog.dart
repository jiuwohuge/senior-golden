import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_base_url.dart';
import 'api_base_url_provider.dart';
import '../../widgets/postal/postal_snack.dart';

/// Debug：配置 API Base URL（登录页长按「查看功能引导」唤起）。
Future<void> showDebugApiBaseUrlDialog(BuildContext context, WidgetRef ref) async {
  if (!kDebugMode) {
    return;
  }

  final initialUrl = ref.read(apiBaseUrlProvider);
  final result = await showDialog<({String url, bool restored})>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => _DebugApiBaseUrlDialog(initialUrl: initialUrl),
  );

  if (!context.mounted || result == null) {
    return;
  }

  // 弹窗路由完全退出后再改 Provider / SnackBar，避免与 Form 卸载同帧冲突。
  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) {
    return;
  }

  if (!result.restored) {
    await ref.read(apiBaseUrlProvider.notifier).applyOverride(result.url);
  }

  if (!context.mounted) {
    return;
  }

  final message = result.restored
      ? '已恢复默认：${result.url}'
      : '已保存：${result.url}';
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) {
      return;
    }
    PostalSnack.show(context, message);
  });
}

class _DebugApiBaseUrlDialog extends StatefulWidget {
  const _DebugApiBaseUrlDialog({required this.initialUrl});

  final String initialUrl;

  @override
  State<_DebugApiBaseUrlDialog> createState() => _DebugApiBaseUrlDialogState();
}

class _DebugApiBaseUrlDialogState extends State<_DebugApiBaseUrlDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('调试：API Base URL'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '默认（模拟器本机）：$kDefaultApiBaseUrl\n'
              '编译期：$kApiBaseUrl',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://api.example.com/backend',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) {
                  return '请输入 Base URL';
                }
                final uri = Uri.tryParse(s);
                if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
                  return '请输入有效的 http(s) 地址';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final container = ProviderScope.containerOf(context);
            await container.read(apiBaseUrlProvider.notifier).clearOverride();
            if (!context.mounted) {
              return;
            }
            final resetUrl = container.read(apiBaseUrlProvider);
            Navigator.of(context).pop((url: resetUrl, restored: true));
          },
          child: const Text('恢复默认'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            Navigator.of(context).pop((
              url: normalizeApiBaseUrl(_controller.text),
              restored: false,
            ));
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
