# Phase 8 Performance Profiling

This document records the profiling scenarios defined in `prompts\phase8_testing.md`.

## How To Run

```powershell
flutter run --profile -d <device-id>
```

Use Flutter DevTools Performance tab while exercising each seeded scenario.

## Results Table

| Scenario | Metric | Target | Actual | Pass? |
|----------|--------|--------|--------|-------|
| 100 todos scroll | Max frame time | < 16 ms | Pending manual profile run | Pending |
| 1000 rows stats load | Initial load | < 500 ms | Pending manual profile run | Pending |
| 1000 rows pagination | Page load | < 100 ms | Pending manual profile run | Pending |
| 5000 titles autocomplete | Response time | < 100 ms | Pending manual profile run | Pending |

## Notes

- The automated test suite added in phase 8 covers the underlying behavior and end-to-end flows.
- DevTools frame and latency measurements still need to be captured on a real device or emulator profile session, because those metrics are not reliable from `flutter test` alone.
