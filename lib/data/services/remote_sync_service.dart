import '../../core/result.dart';
import '../../domain/models/sync_item.dart';

abstract interface class RemoteSyncService {
  Future<Result<void>> pushItem(SyncItem item);
}

final class InMemoryRemoteSyncService implements RemoteSyncService {
  bool simulateOffline = false;

  @override
  Future<Result<void>> pushItem(SyncItem item) async {
    if (simulateOffline) {
      return const Result.failure(
        'Network.Offline',
        'Device is offline; item kept safely in local outbox.',
      );
    }
    return const Result.ok(null);
  }
}
