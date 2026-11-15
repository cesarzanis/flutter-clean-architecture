import 'package:flutter/material.dart';

import '../../../../domain/models/sync_item.dart';
import '../view_models/sync_dashboard_view_model.dart';

class SyncDashboardScreen extends StatelessWidget {
  const SyncDashboardScreen({super.key, required this.viewModel});

  final SyncDashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final snapshot = viewModel.state;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Offline-First Sync Queue'),
            actions: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: IconButton(
                  tooltip: 'Run Dual-Lane Sync',
                  onPressed: snapshot.isSyncing ? null : viewModel.syncNow,
                  icon: const Icon(Icons.sync),
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  snapshot.lastBanner,
                  key: const ValueKey<String>('sync-banner'),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.items.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.items[index];
                    return RepaintBoundary(
                      child: Semantics(
                        container: true,
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text('${item.lane.name} · ${item.status.name}'),
                          trailing: Icon(
                            item.status == SyncStatus.synced
                                ? Icons.check_circle
                                : Icons.schedule,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
