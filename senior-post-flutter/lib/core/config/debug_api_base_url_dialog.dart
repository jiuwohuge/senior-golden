import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_base_url.dart';
import 'api_base_url_provider.dart';
import '../../widgets/postal/postal_snack.dart';

/// Debug：配置 API Base URL（登录页长按「查看功能引导」唤起）。
Future<void> showDebugApiBaseUrlDialog(BuildContext context, WidgetRef ref) async {
  if (!kDebugMode) {
    return;
  }
  final controller = TextEditingController(text: ref.read(apiBaseUrlProvider));
  final formKey = GlobalKey<FormState>();

  if (!context.mounted) {
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('调试：API Base URL'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '默认（模拟器本机）：$kDefaultApiBaseUrl\n'
                '编译期：$kApiBaseUrl',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
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
              await ref.read(apiBaseUrlProvider.notifier).clearOverride();
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                if (context.mounted) {
                  PostalSnack.show(
                    context,
                    '已恢复默认：${ref.read(apiBaseUrlProvider)}',
                  );
                }
              }
            },
            child: const Text('恢复默认'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }
              final url = normalizeApiBaseUrl(controller.text);
              await ref.read(apiBaseUrlProvider.notifier).applyOverride(url);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                if (context.mounted) {
                  PostalSnack.show(context, '已保存：$url');
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      );
    },
  );

  controller.dispose();
}
