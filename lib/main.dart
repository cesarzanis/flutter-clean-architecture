import 'package:flutter/material.dart';

import 'data/repositories/sync_queue_repository.dart';
import 'data/services/remote_sync_service.dart';
import 'ui/features/sync_dashboard/view_models/sync_dashboard_view_model.dart';
import 'ui/features/sync_dashboard/views/sync_dashboard_screen.dart';

void main() {
  final repository = SyncQueueRepository(InMemoryRemoteSyncService());
  final viewModel = SyncDashboardViewModel(repository);
  runApp(CleanArchitectureApp(viewModel: viewModel));
}

class CleanArchitectureApp extends StatelessWidget {
  const CleanArchitectureApp({super.key, required this.viewModel});

  final SyncDashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Offline-First Reference',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: SyncDashboardScreen(viewModel: viewModel),
    );
  }
}
