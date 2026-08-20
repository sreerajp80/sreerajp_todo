/// How the day list is ordered.
///
/// This lives in `core/` rather than next to the day list screen because the
/// saved default is owned by `TaskDefaultsNotifier` in the application layer,
/// and the application layer must never import from `presentation/`.
///
/// [manual] is the drag-and-drop order stored in `todos.sort_order`. Every
/// other value is worked out in memory when the list is built.
enum TodoSortOption {
  manual,
  nameAsc,
  nameDesc,
  createdOldest,
  createdNewest,
  timeMost,
  timeLeast,
  status,
  priorityHigh,
}
