import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/domain_models.dart';
import '../../widgets/postal/postal.dart';
import 'stamps_remote.dart';

final stampsLedgerProvider = FutureProvider<List<StampLedgerLine>>((ref) async {
  return ref.read(stampsRemoteProvider).ledgerPage();
});

class StampsLedgerPage extends ConsumerWidget {
  const StampsLedgerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stampsLedgerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Stamps ledger')),
      body: SafeArea(
        child: async.when(
          loading: () => const PostalSkeletonList(itemCount: 5, itemHeight: 92),
          error: (e, _) => PostalEmptyState(
            title: 'Unable to load ledger',
            subtitle: '$e',
            tone: PostalEmptyTone.error,
          ),
          data: (items) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final e = items[i];
              final delta = e.delta > 0 ? '+${e.delta}' : '${e.delta}';
              return PostalCardEnvelope(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(e.at),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      delta,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: e.delta >= 0 ? Colors.green[700] : Colors.red[700],
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text('→ ${e.balanceAfter}', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
