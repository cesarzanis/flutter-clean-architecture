# ADR 001: Layered MVVM and Offline-First Dual-Lane Sync Queue

- **Status:** Accepted
- **Author:** Cesar Zanis

## Context

Field operations, retail POS, and logistics mobile apps frequently operate on congested cellular links or Wi-Fi dead zones. Mixing HTTP calls inside Widgets or running single-lane media uploads blocks critical JSON state updates and causes stuck jobs when the OS terminates background isolates.

## Decision

1. Enforce strict layer boundaries (`ui` -> `domain` <- `data`) with `ChangeNotifier` ViewModels exposing immutable snapshots to `ListenableBuilder` views.
2. Express service outcomes with a Dart 3 `sealed class Result<T>` (`Ok` / `Failure`) for exhaustive switch handling.
3. Isolate local `draft` records from background workers until explicit user finalization (`finalizeForSync`).
4. Run `recoverOrphanedProcessing()` at bootstrap to reset interrupted `processing` items back to `pending`, and drain `fastJson` payloads ahead of `heavyMedia` attachments.
