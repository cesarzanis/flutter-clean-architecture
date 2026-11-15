# Flutter Offline-First Clean Architecture Reference

Production-grade **Flutter 3 / Dart 3** reference architecture maintained by [Cesar Zanis](https://cesarzanis.com). Built for high-reliability mobile applications operating across unstable networks.

## Architectural Highlights

- **Layered MVVM (`ui` / `domain` / `data`):** Lean `StatelessWidget` views listening via `ListenableBuilder` to `ChangeNotifier` ViewModels that expose immutable state snapshots.
- **Dart 3 Exhaustive `Result<T>`:** `sealed class Result<T>` (`Ok<T>` / `Failure<T>`) eliminates unhandled runtime exceptions across repository boundaries.
- **Offline-First Dual-Lane Sync Engine:** Separates `fastJson` transactional payloads from `heavyMedia` binary uploads, isolates unfinalized `draft` records from background workers, and runs `recoverOrphanedProcessing()` on bootstrap.
- **Rendering & Accessibility Discipline:** `RepaintBoundary` + `Semantics(container: true)` per list item and `48x48dp` minimum touch targets.

## Project Structure

```text
flutter-clean-architecture/
├── pubspec.yaml
├── analysis_options.yaml
├── docs/adr/001-offline-first-sync-queue.md
├── lib/
│   ├── core/result.dart
│   ├── data/
│   │   ├── repositories/sync_queue_repository.dart
│   │   └── services/remote_sync_service.dart
│   ├── domain/models/sync_item.dart
│   └── ui/features/sync_dashboard/
│       ├── view_models/sync_dashboard_view_model.dart
│       └── views/sync_dashboard_screen.dart
└── test/
    └── sync_queue_test.dart
```

## Quick Start

```bash
flutter pub get
flutter analyze
flutter test
```

## License

MIT. Maintained by [Cesar Zanis](https://cesarzanis.com).
