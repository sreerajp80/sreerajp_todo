# Implementation Plan — SreerajP ToDo

This document outlines the phase-by-phase implementation roadmap and technical milestones for SreerajP ToDo.

**Date:** 2026-08-10

Read [architecture.md](architecture.md) and [features.md](features.md) first to review technical specifications and app features.

---

## Phase 1: Foundation & Core Utilities

- Set up Flutter project with pure offline package dependencies.
- Implement core utilities: NFC Unicode normalization (`unicodeUtils`), date formatting (`dateUtils`), duration formatting (`durationUtils`), and custom exception classes.
- Implement application strings in `app_strings.dart`.

---

## Phase 2: Database Layer & Data Access

- Implement SQLite database service (`DatabaseService`) with `sqflite_sqlcipher` (mobile) and `sqflite_common_ffi` (desktop).
- Configure PRAGMAs: `PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;`.
- Implement baseline schema v1 migration (`migration_v1.dart`) and DAOs (`TodoDao`, `TimeSegmentDao`, `RecurringPatternDao`).
- Write unit tests for all DAO operations using in-memory SQLite instances.

---

## Phase 3: Domain Entities & Use Cases

- Define immutable domain entities (`TodoEntity`, `TimeSegmentEntity`, `RecurringPatternEntity`) using `@freezed`.
- Implement repository interfaces and concrete data repository implementations (`TodoRepositoryImpl`, `TimeSegmentRepositoryImpl`, `RecurringPatternRepositoryImpl`).
- Implement core use-cases enforcing domain rules: `StartNextSegment`, `StopActiveSegment`, `PortTodo`, `RepairOrphanedSegments`, `DeleteRecurringTodos`.

---

## Phase 4: Application State Management & Routing

- Implement declarative routing via `go_router` in `lib/app.dart` with custom page transitions.
- Configure Riverpod providers and StateNotifiers in `lib/application/providers.dart`.
- Implement live timer stream provider and day lock state providers.

---

## Phase 5: Presentation & User Interface

- Build custom Light and Dark theme definitions (`AppTheme`).
- Implement responsive layout scaffold adapting `NavigationBar` (mobile `<600dp`) and `NavigationRail` (desktop/tablet `>=600dp`).
- Implement screens: `DailyListScreen`, `CreateEditTodoScreen`, `SearchResultsScreen`, `CopyTodosScreen`, `RecurringTodosScreen`, `StatisticsScreen`, `BackupScreen`.
- Ensure bilingual UI rendering (English and Malayalam) with dynamic per-field LTR/RTL directionality.

---

## Phase 6: Backup & Encryption Engine

- Implement AES-256 ZIP encrypted local backup export and import service (`BackupService`).
- Provide user passphrase protection, SHA-256 key derivation, and validation checks (`BackupVersionTooNewException`, `BackupCorruptedException`).

---

## Phase 7: Recurrence Engine & Advanced Features

- Integrate RFC 5545 iCalendar recurrence engine using `rrule` package.
- Implement automated daily recurring todo generation and series deletion.
- Implement interactive statistical reports (`fl_chart`) with paginated data tables.

---

## Phase 8: Hardening & Testing

- Implement comprehensive unit, DAO, use-case, widget, and integration tests (`integration_test/app_test.dart`).
- Validate complete offline compliance (zero network permissions, zero network dependencies).
- Validate full formatting (`dart format`) and clean static analysis (`flutter analyze`).
