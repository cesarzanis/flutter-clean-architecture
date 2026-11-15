import '../../core/result.dart';
import '../../domain/models/sync_item.dart';
import '../services/remote_sync_service.dart';

final class SyncQueueRepository {
  SyncQueueRepository(this._remoteService);

  final RemoteSyncService _remoteService;
  final List<SyncItem> _items = <SyncItem>[];

  List<SyncItem> listOrdered() => List<SyncItem>.unmodifiable(_items);

  void saveDraft({required String id, required String title, SyncLane lane = SyncLane.fastJson}) {
    _upsert(
      SyncItem(
        id: id,
        title: title,
        lane: lane,
        status: SyncStatus.draft,
        attempts: 0,
      ),
    );
  }

  Result<SyncItem> finalizeForSync(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) {
      return const Result.failure('Sync.NotFound', 'Item was not found in local store.');
    }
    final updated = _items[index].copyWith(status: SyncStatus.pending);
    _items[index] = updated;
    return Result.ok(updated);
  }

  /// Resets stale `processing` records back to `pending` after OS process death.
  int recoverOrphanedProcessing() {
    var recovered = 0;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].status == SyncStatus.processing) {
        _items[i] = _items[i].copyWith(status: SyncStatus.pending);
        recovered++;
      }
    }
    return recovered;
  }

  /// Processes fast transactional JSON records before heavy media attachments,
  /// strictly skipping unfinalized user drafts.
  Future<int> processPendingDualLane() async {
    var syncedCount = 0;
    for (final lane in <SyncLane>[SyncLane.fastJson, SyncLane.heavyMedia]) {
      for (var i = 0; i < _items.length; i++) {
        final current = _items[i];
        if (current.lane != lane || !current.isEligibleForBackgroundSync) {
          continue;
        }
        _items[i] = current.copyWith(status: SyncStatus.processing);
        final res = await _remoteService.pushItem(_items[i]);
        switch (res) {
          case Ok<void>():
            _items[i] = _items[i].copyWith(
              status: SyncStatus.synced,
              attempts: current.attempts + 1,
            );
            syncedCount++;
          case Failure<void>():
            _items[i] = _items[i].copyWith(
              status: SyncStatus.pending,
              attempts: current.attempts + 1,
            );
        }
      }
    }
    return syncedCount;
  }

  void seedStuckProcessingForRecovery({required String id, required String title}) {
    _upsert(
      SyncItem(
        id: id,
        title: title,
        lane: SyncLane.fastJson,
        status: SyncStatus.processing,
        attempts: 1,
      ),
    );
  }

  void _upsert(SyncItem item) {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx == -1) {
      _items.add(item);
    } else {
      _items[idx] = item;
    }
  }
}
