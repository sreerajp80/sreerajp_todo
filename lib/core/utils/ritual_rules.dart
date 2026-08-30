/// The fixed rules behind Ritual Mode: breathing rhythms and the few limits
/// the flow enforces.
///
/// Pure Dart on purpose, like `focus_pulse_rules.dart`, so the timings can be
/// tested without building a widget.
library;

/// A breathing rhythm, given as seconds for each phase of one breath.
///
/// The three come from SreerajP Journal Vault, where they were already in use.
/// Nothing here is medical advice: they are simply slow, even counts that are
/// easy to follow.
enum BreathTechnique {
  /// Four seconds in, hold four, out four, hold four. The steady default.
  box,

  /// Four in, hold seven, out eight. The longest out-breath of the three.
  relaxing,

  /// Four in, four out, no holds. The simplest.
  calm;

  /// Seconds spent breathing in.
  int get inhaleSeconds => 4;

  /// Seconds held after breathing in. Zero means the phase is skipped.
  int get holdInSeconds => switch (this) {
    BreathTechnique.box => 4,
    BreathTechnique.relaxing => 7,
    BreathTechnique.calm => 0,
  };

  /// Seconds spent breathing out.
  int get exhaleSeconds => switch (this) {
    BreathTechnique.box => 4,
    BreathTechnique.relaxing => 8,
    BreathTechnique.calm => 4,
  };

  /// Seconds rested after breathing out. Zero means the phase is skipped.
  int get holdOutSeconds => switch (this) {
    BreathTechnique.box => 4,
    BreathTechnique.relaxing => 0,
    BreathTechnique.calm => 0,
  };

  /// How long one whole breath takes.
  int get cycleSeconds =>
      inhaleSeconds + holdInSeconds + exhaleSeconds + holdOutSeconds;

  /// The phases this rhythm actually runs, in order, with their lengths.
  ///
  /// Phases set to zero seconds are left out rather than flashing past.
  List<(BreathPhase, int)> get phases => [
    (BreathPhase.inhale, inhaleSeconds),
    if (holdInSeconds > 0) (BreathPhase.holdIn, holdInSeconds),
    (BreathPhase.exhale, exhaleSeconds),
    if (holdOutSeconds > 0) (BreathPhase.holdOut, holdOutSeconds),
  ];
}

/// One part of a single breath.
enum BreathPhase {
  inhale,
  holdIn,
  exhale,
  holdOut;

  /// True while the circle should be growing.
  bool get isExpanding => this == BreathPhase.inhale;

  /// True while the circle should be shrinking.
  bool get isContracting => this == BreathPhase.exhale;
}

/// Fewest breaths the first step may be set to.
const int kRitualMinBreaths = 1;

/// Most breaths the first step may be set to.
const int kRitualMaxBreaths = 5;

/// Breaths a fresh install runs.
const int kRitualDefaultBreaths = 2;

/// How many tasks may be marked as today's focus in the settle step.
///
/// Three is the whole point of the step. A longer list is just the day list
/// again, and picking everything is the same as picking nothing.
const int kRitualFocusLimit = 3;

/// The hour the evening close starts being offered on a fresh install.
const int kRitualDefaultEveningHour = 20;

/// Earliest hour the evening close may be set to.
const int kRitualMinEveningHour = 12;

/// Latest hour the evening close may be set to.
const int kRitualMaxEveningHour = 23;
