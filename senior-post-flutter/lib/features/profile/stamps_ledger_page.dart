import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/mock/mock_models.dart';
import '../../core/mock/mock_repository.dart';
import '../../widgets/postal/postal.dart';

final stampsLedgerProvider = FutureProvider<List<MockStampLedgerEntry>>((ref) async {
  return ref.read(mockStampsRepositoryProvider).list();
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
                    PostalStatusChip(
                      label: delta,
                      icon: e.delta >= 0 ? Icons.add : Icons.remove,
                      color: e.delta >= 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title),
                          const SizedBox(height: 2),
                          Text(DateFormat('MM-dd HH:mm').format(e.at)),
                        ],
                      ),
                    ),
                    Text('Bal ${e.balanceAfter}'),
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
