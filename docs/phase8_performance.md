# Phase 8 Performance Profiling — SreerajP ToDo

This document records the performance profiling scenarios and DevTools benchmark results for SreerajP ToDo.

**Date:** 2026-08-10

Read [AGENTS.md](../AGENTS.md) and [architecture.md](architecture.md) first.

---

## 1. How To Run

```powershell
flutter run --profile -d <device-id>
```

Use Flutter DevTools Performance tab while exercising each seeded scenario.

---

## 2. Results Table

| Scenario | Metric | Target | Actual | Pass? |
|----------|--------|--------|--------|-------|
| 100 todos scroll | Max frame time | < 16 ms | Pending manual profile run | Pending |
| 1000 rows stats load | Initial load | < 500 ms | Pending manual profile run | Pending |
| 1000 rows pagination | Page load | < 100 ms | Pending manual profile run | Pending |
| 5000 titles autocomplete | Response time | < 100 ms | Pending manual profile run | Pending |

---

## 3. Notes

- The automated test suite added in phase 8 covers the underlying behavior and end-to-end flows.
- DevTools frame and latency measurements still need to be captured on a real device or emulator profile session, because those metrics are not reliable from `flutter test` alone.
