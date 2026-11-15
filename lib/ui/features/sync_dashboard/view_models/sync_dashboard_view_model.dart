import 'package:flutter/foundation.dart';

import '../../../../data/repositories/sync_queue_repository.dart';
import '../../../../domain/models/sync_item.dart';

final class SyncDashboardState {
  const SyncDashboardState({
    required this.items,
    required this.isSyncing,
    required this.lastBanner,
  });

  final List<SyncItem> items;
  final bool isSyncing;
  final String lastBanner;
}

final class SyncDashboardViewModel extends ChangeNotifier {
  SyncDashboardViewModel(this._repository) {
    _repository.recoverOrphanedProcessing();
  }

  final SyncQueueRepository _repository;
  bool _isSyncing = false;
  String _lastBanner = 'Ready';

  SyncDashboardState get state => SyncDashboardState(
        items: _repository.listOrdered(),
        isSyncing: _isSyncing,
        lastBanner: _lastBanner,
      );

  void createAndQueueOrder({required String id, required String title}) {
    _repository.saveDraft(id: id, title: title);
    _repository.finalizeForSync(id);
    _lastBanner = 'Queued $title';
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    final count = await _repository.processPendingDualLane();
    _isSyncing = false;
    _lastBanner = 'Synced $count item(s)';
    notifyListeners();
  }
}
