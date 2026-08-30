import 'dart:convert';

/// How well a Ritual Deck card landed, and so how soon it should come back.
///
/// This is the same three-way rating the Mastery Deck uses for tasks, but it
/// is a separate engine on a separate store. Cards are not tasks: a card never
/// becomes a todo, never touches the database, and its schedule lives in
/// `SharedPreferences`. Keeping the two apart means neither has to explain the
/// other.
enum RepetitionRating {
  /// Did not land. Bring it back tomorrow and start its count again.
  hard,

  /// Worth another look soon. Three days, and the level stays put.
  revision,

  /// It has sunk in. Leave it seven days times its new level.
  easy;

  /// Days until the card returns, given the level it is at now.
  int intervalDaysFrom(int level) => switch (this) {
    RepetitionRating.hard => 1,
    RepetitionRating.revision => 3,
    RepetitionRating.easy => 7 * (level + 1),
  };
}

/// When one card was last seen and when it is due back.
class CardReviewState {
  const CardReviewState({
    required this.cardId,
    required this.nextReviewDate,
    this.level = 0,
    this.reviewCount = 0,
    this.lastReviewedAt,
  });

  /// A card nobody has rated yet: due straight away, so new cards come first.
  factory CardReviewState.unseen(String cardId, DateTime now) {
    return CardReviewState(cardId: cardId, nextReviewDate: _dayOf(now));
  }

  /// Reads a saved state. Anything unreadable is treated as unseen by the
  /// caller rather than throwing, because a bad value can only come from a
  /// downgrade or a hand-edited preferences file.
  factory CardReviewState.fromMap(Map<String, dynamic> map, DateTime now) {
    final next = DateTime.tryParse(map['nextReviewDate'] as String? ?? '');
    return CardReviewState(
      cardId: map['cardId'] as String,
      level: (map['level'] as num?)?.toInt() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      lastReviewedAt: DateTime.tryParse(map['lastReviewedAt'] as String? ?? ''),
      nextReviewDate: next ?? _dayOf(now),
    );
  }

  /// Reads a saved state from its stored JSON, or null if it cannot be read.
  static CardReviewState? tryDecode(String raw, DateTime now) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['cardId'] is! String) return null;
      return CardReviewState.fromMap(decoded, now);
    } on FormatException {
      return null;
    }
  }

  /// Which card this belongs to.
  final String cardId;

  /// How many times in a row the card has been rated easy. Drops back to zero
  /// on a hard rating.
  final int level;

  /// How many times the card has been rated at all.
  final int reviewCount;

  /// When the card was last rated, or null if it never has been.
  final DateTime? lastReviewedAt;

  /// The day the card is ready to be shown again.
  final DateTime nextReviewDate;

  /// True when the card is ready today, or was ready on an earlier day.
  bool isDue(DateTime now) => !nextReviewDate.isAfter(_dayOf(now));

  /// Applies a rating and works out when the card comes back.
  CardReviewState applyRating(RepetitionRating rating, DateTime now) {
    final newLevel = switch (rating) {
      RepetitionRating.hard => 0,
      RepetitionRating.revision => level,
      RepetitionRating.easy => level + 1,
    };
    // `intervalDaysFrom` is given the level the card was at, so "easy" scales
    // from the old level and lands on 7 x the new one.
    final days = rating.intervalDaysFrom(level);

    return CardReviewState(
      cardId: cardId,
      level: newLevel,
      reviewCount: reviewCount + 1,
      lastReviewedAt: now,
      nextReviewDate: _dayOf(now).add(Duration(days: days)),
    );
  }

  Map<String, dynamic> toMap() => {
    'cardId': cardId,
    'level': level,
    'reviewCount': reviewCount,
    'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    'nextReviewDate': nextReviewDate.toIso8601String(),
  };

  /// The stored form, ready to be written to preferences.
  String encode() => jsonEncode(toMap());

  /// Midnight on the day [moment] falls in, so comparisons ignore the clock.
  static DateTime _dayOf(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);
}
