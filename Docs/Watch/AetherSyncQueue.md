# AetherSyncQueue

## How It Works

`AetherSyncQueue` provides a durable, disk-backed FIFO queue for small payloads.
It is designed for offline-first scenarios where network connectivity is
intermittent — most notably Apple Watch.

### Storage layout

```
<directoryURL>/
  index.json            ← ordered array of UUIDs (the FIFO order)
  items/
    <uuid-1>.json       ← individual QueueItem
    <uuid-2>.json
    …
```

* **One file per item** — a crash during a write can corrupt at most one item,
  never the whole queue.
* **Atomic writes** — every file mutation goes through a *write-to-temp, then
  rename* pattern so the data on disk is always complete.
* **Lightweight index** — `index.json` is a flat JSON array of UUIDs that
  preserves insertion order. It is small enough to reload on every queue
  instantiation without measurable latency.

### Public API (abridged)

| Method | Description |
|--------|-------------|
| `enqueue(kind:payload:)` | Append a new item to the tail. |
| `peek(limit:)` | Return up to *limit* items from the head (skips items whose `retryAfter` is in the future). |
| `markSucceeded(_:)` | Remove the item after successful delivery. |
| `markFailed(_:retryAfter:)` | Increment `attempts`; optionally hide the item until a future date. |
| `purge(olderThan:)` | Delete stale items whose `createdAt` exceeds the given age. |

## Why It Is Safe on watchOS

| Concern | Mitigation |
|---------|-----------|
| **Low memory** | Items are never bulk-loaded into RAM. `peek(limit:)` reads only the requested number of files. The index is a tiny UUID array. |
| **Background budget** | All operations are synchronous file I/O wrapped in an actor, so they complete within a single run-loop tick — well inside the ~15 s background budget. |
| **Crash safety** | Atomic writes mean the file system is always in a valid state. A missing item file is treated as a no-op by `peek`. |
| **Concurrency** | `DurableQueue` is an actor, so all access is serialised. Swift 6 strict concurrency enforces `Sendable` on every boundary. |
| **Disk space** | `purge(olderThan:)` allows the host app to cap disk usage. Payloads are expected to be < 256 KB. |

## WCSession Integration Sketch

The queue is intentionally transport-agnostic. Below is a sketch of how it
plugs into `WCSession` for Watch ↔ iPhone syncing.

```swift
import WatchConnectivity

final class SyncTransport: NSObject, WCSessionDelegate, @unchecked Sendable {
    // @unchecked Sendable: WCSessionDelegate callbacks arrive on a
    // serial delegate queue managed by WatchConnectivity, so access
    // to `queue` is safe. The actor itself serialises all mutations.

    private let queue: DurableQueue

    init(queue: DurableQueue) {
        self.queue = queue
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Called by the app when it wants to flush pending changes.
    func flush() async {
        guard WCSession.default.isReachable else { return }
        do {
            let batch = try await queue.peek(limit: 10)
            for item in batch {
                let message: [String: Any] = [
                    "id": item.id.uuidString,
                    "kind": item.kind,
                    "payload": item.payload,
                ]
                WCSession.default.sendMessage(message, replyHandler: { _ in
                    Task {
                        try? await self.queue.markSucceeded(item.id)
                    }
                }, errorHandler: { _ in
                    Task {
                        try? await self.queue.markFailed(
                            item.id, retryAfter: 30
                        )
                    }
                })
            }
        } catch {
            // Log but do not crash — items are safe on disk.
        }
    }

    // MARK: - WCSessionDelegate (required stubs)

    func session(
        _ session: WCSession,
        activationDidCompleteWith state: WCSessionActivationState,
        error: Error?
    ) {}
}
```

### Recommended flush triggers

| Trigger | API |
|---------|-----|
| App foreground | `WKApplicationDelegate.applicationDidBecomeActive()` |
| Reachability change | `WCSessionDelegate.sessionReachabilityDidChange(_:)` |
| After enqueue | Call `flush()` opportunistically after every `enqueue`. |
| Background refresh | `WKApplicationRefreshBackgroundTask` |
