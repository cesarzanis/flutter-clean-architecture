import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/data/repositories/sync_queue_repository.dart';
import 'package:flutter_clean_architecture/data/services/remote_sync_service.dart';
import 'package:flutter_clean_architecture/domain/models/sync_item.dart';
import 'package:flutter_clean_architecture/ui/features/sync_dashboard/view_models/sync_dashboard_view_model.dart';
import 'package:flutter_clean_architecture/ui/features/sync_dashboard/views/sync_dashboard_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dual-lane sync skips unfinalized drafts and recovers orphaned processing items', () async {
    final remote = InMemoryRemoteSyncService();
    final repo = SyncQueueRepository(remote);

    repo.saveDraft(id: 'draft-1', title: 'Local Inspection Draft');
    repo.seedStuckProcessingForRecovery(id: 'orphan-1', title: 'Interrupted Order');

    final recovered = repo.recoverOrphanedProcessing();
    expect(recovered, 1);

    final synced = await repo.processPendingDualLane();
    expect(synced, 1);

    final all = repo.listOrdered();
    expect(all.firstWhere((e) => e.id == 'draft-1').status, SyncStatus.draft);
    expect(all.firstWhere((e) => e.id == 'orphan-1').status, SyncStatus.synced);
  });

  testWidgets('SyncDashboardScreen renders queued item and transitions to synced', (tester) async {
    final repo = SyncQueueRepository(InMemoryRemoteSyncService());
    final vm = SyncDashboardViewModel(repo);
    vm.createAndQueueOrder(id: 'ord-10', title: 'Storefront Order #10');

    await tester.pumpWidget(MaterialApp(home: SyncDashboardScreen(viewModel: vm)));
    expect(find.text('Storefront Order #10'), findsOneWidget);
    expect(find.text('fastJson · pending'), findsOneWidget);

    await tester.tap(find.byTooltip('Run Dual-Lane Sync'));
    await tester.pumpAndSettle();

    expect(find.text('fastJson · synced'), findsOneWidget);
    expect(find.text('Synced 1 item(s)'), findsOneWidget);
  });
}
