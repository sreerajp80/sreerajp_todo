import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/domain/entities/ritual_card.dart';
import 'package:sreerajp_todo/domain/entities/ritual_review_state.dart';

/// Prefix for the saved review state of one Ritual Deck card.
///
/// One key per card rather than one big blob, so a single unreadable entry
/// costs one card's history and not the whole deck's.
const String kRitualCardReviewPrefix = 'ritual_card_review_';

/// Owns the Ritual Deck's spaced repetition: which card to show next, and
/// when a rated card comes back.
///
/// Everything lives in [SharedPreferences]. Nothing here touches the database,
/// so the deck is never part of a backup, an export, or a sync payload: it is
/// device state about a fixed, bundled deck, not user content.
class RitualService {
  const RitualService(this._prefs);

  final SharedPreferences _prefs;

  /// The whole deck, in order.
  List<RitualCard> get deck => RitualCard.curatedDeck;

  /// Reads the saved state for [cardId], or an unseen one if there is none.
  CardReviewState reviewState(String cardId, {DateTime? now}) {
    final moment = now ?? DateTime.now();
    final raw = _prefs.getString('$kRitualCardReviewPrefix$cardId');
    if (raw == null) return CardReviewState.unseen(cardId, moment);
    return CardReviewState.tryDecode(raw, moment) ??
        CardReviewState.unseen(cardId, moment);
  }

  /// Saves [state] for its card.
  Future<void> saveReviewState(CardReviewState state) {
    return _prefs.setString(
      '$kRitualCardReviewPrefix${state.cardId}',
      state.encode(),
    );
  }

  /// Records how a card landed and returns its new schedule.
  Future<CardReviewState> rateCard(
    String cardId,
    RepetitionRating rating, {
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final updated = reviewState(
      cardId,
      now: moment,
    ).applyRating(rating, moment);
    await saveReviewState(updated);
    return updated;
  }

  /// Picks the card to open today with.
  ///
  /// A card that was scheduled to return today wins over one that has never
  /// been shown. This is the opposite of the order SreerajP Journal Vault
  /// uses, and the change is deliberate: rating a card "Hard" promises it
  /// comes back tomorrow, and with unseen cards going first that promise
  /// could not be kept until all fifty had been seen.
  ///
  /// So, in order:
  ///   1. a card that is due back, the one waiting longest first,
  ///   2. a card that has never been shown, lowest number first.
  ///
  /// An unseen card counts as due from the moment it exists, so on a fresh
  /// install this simply walks the deck from card one.
  RitualCard cardForToday({DateTime? now}) {
    final moment = now ?? DateTime.now();
    final states = [
      for (final card in deck)
        (card: card, state: reviewState(card.id, now: moment)),
    ];

    final due = states.where((item) => item.state.isDue(moment)).toList();
    if (due.isNotEmpty) {
      due.sort(_dueOrder);
      return due.first.card;
    }

    // Nothing is due, which can only happen once every card has been seen.
    // Show whichever one comes back soonest.
    states.sort(_dueOrder);
    return states.first.card;
  }

  /// The card after [cardId] in deck order, wrapping round at the end.
  ///
  /// Used by "show another card", which walks the deck rather than picking at
  /// random: a random jump can land on the same card twice and looks broken.
  RitualCard cardAfter(String cardId) {
    final index = deck.indexWhere((card) => card.id == cardId);
    if (index == -1) return deck.first;
    return deck[(index + 1) % deck.length];
  }

  /// Clears the review history for every card in the deck.
  Future<void> resetAllReviews() async {
    for (final card in deck) {
      await _prefs.remove('$kRitualCardReviewPrefix${card.id}');
    }
  }

  /// Sorts cards already in the cycle ahead of ones never shown, then by the
  /// day each is due, then by when it was last seen, then by deck order.
  ///
  /// The last step matters more than it looks: without it the answer would
  /// depend on the order the cards happened to be read in, and the same day
  /// could open with a different card each time the app started.
  static int _dueOrder(
    ({RitualCard card, CardReviewState state}) a,
    ({RitualCard card, CardReviewState state}) b,
  ) {
    final aSeen = a.state.reviewCount > 0;
    final bSeen = b.state.reviewCount > 0;
    if (aSeen != bSeen) return aSeen ? -1 : 1;

    final byDue = a.state.nextReviewDate.compareTo(b.state.nextReviewDate);
    if (byDue != 0) return byDue;

    final aLast = a.state.lastReviewedAt;
    final bLast = b.state.lastReviewedAt;
    if (aLast != null && bLast != null) {
      final byLast = aLast.compareTo(bLast);
      if (byLast != 0) return byLast;
    }
    return a.card.number.compareTo(b.card.number);
  }
}
