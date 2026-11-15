enum SyncLane {
  fastJson,
  heavyMedia,
}

enum SyncStatus {
  draft,
  pending,
  processing,
  synced,
  failed,
}

final class SyncItem {
  const SyncItem({
    required this.id,
    required this.title,
    required this.lane,
    required this.status,
    required this.attempts,
  });

  final String id;
  final String title;
  final SyncLane lane;
  final SyncStatus status;
  final int attempts;

  bool get isEligibleForBackgroundSync => status == SyncStatus.pending;

  SyncItem copyWith({
    String? title,
    SyncLane? lane,
    SyncStatus? status,
    int? attempts,
  }) {
    return SyncItem(
      id: id,
      title: title ?? this.title,
      lane: lane ?? this.lane,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
    );
  }
}
