/// The Ritual Deck: the reflection cards shown in step 2 of Ritual Mode.
///
/// The deck holds no text. Every card's title, prompt, quote and attribution
/// live in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`, keyed from the
/// card id, exactly like every other user-visible string in the app. A card
/// here is only an identity: which card it is, where it sits in the deck, and
/// which theme it belongs to.
///
/// The deck came from SreerajP Journal Vault, where the text sits inline in
/// Dart. `tool/ritual_deck_to_arb.dart` did the conversion, so no line of it
/// was retyped.
library;

/// The ten themes the deck is grouped by, drawn from Sanathana Dharma.
///
/// The order is the order the cards run in, so the deck reads as a sequence
/// rather than a shuffled pile.
enum RitualTheme {
  dharma,
  karma,
  bhakti,
  jnana,
  yoga,
  ahimsa,
  sathya,
  vairagya,
  seva,
  shanti;

  /// The ARB key stem for this theme's display name, e.g. `ritualThemeDharma`.
  String get labelKey =>
      'ritualTheme${name[0].toUpperCase()}${name.substring(1)}';
}

/// One card in the Ritual Deck.
class RitualCard {
  const RitualCard({
    required this.id,
    required this.number,
    required this.theme,
  });

  /// Stable id, e.g. `sd_01`. Used as the spaced-repetition key and as the
  /// stem of the card's ARB keys, so it must never be changed once shipped.
  final String id;

  /// Position in the deck, from 1. Shown to the user as "Card 7 of 50" and
  /// used to break ties when two cards are equally due.
  final int number;

  /// Which group of the deck the card belongs to.
  final RitualTheme theme;

  /// The ARB key stem for this card, e.g. `ritualCardSd01`.
  ///
  /// Built the same way `tool/ritual_deck_to_arb.dart` built the keys, so the
  /// two can never drift apart.
  String get keyStem {
    final camel = id
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join();
    return 'ritualCard$camel';
  }

  /// Every card, in deck order.
  static const List<RitualCard> curatedDeck = [
    RitualCard(id: 'sd_01', number: 1, theme: RitualTheme.dharma),
    RitualCard(id: 'sd_02', number: 2, theme: RitualTheme.dharma),
    RitualCard(id: 'sd_03', number: 3, theme: RitualTheme.dharma),
    RitualCard(id: 'sd_04', number: 4, theme: RitualTheme.dharma),
    RitualCard(id: 'sd_05', number: 5, theme: RitualTheme.dharma),
    RitualCard(id: 'sd_06', number: 6, theme: RitualTheme.karma),
    RitualCard(id: 'sd_07', number: 7, theme: RitualTheme.karma),
    RitualCard(id: 'sd_08', number: 8, theme: RitualTheme.karma),
    RitualCard(id: 'sd_09', number: 9, theme: RitualTheme.karma),
    RitualCard(id: 'sd_10', number: 10, theme: RitualTheme.karma),
    RitualCard(id: 'sd_11', number: 11, theme: RitualTheme.bhakti),
    RitualCard(id: 'sd_12', number: 12, theme: RitualTheme.bhakti),
    RitualCard(id: 'sd_13', number: 13, theme: RitualTheme.bhakti),
    RitualCard(id: 'sd_14', number: 14, theme: RitualTheme.bhakti),
    RitualCard(id: 'sd_15', number: 15, theme: RitualTheme.bhakti),
    RitualCard(id: 'sd_16', number: 16, theme: RitualTheme.jnana),
    RitualCard(id: 'sd_17', number: 17, theme: RitualTheme.jnana),
    RitualCard(id: 'sd_18', number: 18, theme: RitualTheme.jnana),
    RitualCard(id: 'sd_19', number: 19, theme: RitualTheme.jnana),
    RitualCard(id: 'sd_20', number: 20, theme: RitualTheme.jnana),
    RitualCard(id: 'sd_21', number: 21, theme: RitualTheme.jnana),
    RitualCard(id: 'sd_22', number: 22, theme: RitualTheme.jnana),
    RitualCard(id: 'sd_23', number: 23, theme: RitualTheme.yoga),
    RitualCard(id: 'sd_24', number: 24, theme: RitualTheme.yoga),
    RitualCard(id: 'sd_25', number: 25, theme: RitualTheme.yoga),
    RitualCard(id: 'sd_26', number: 26, theme: RitualTheme.yoga),
    RitualCard(id: 'sd_27', number: 27, theme: RitualTheme.yoga),
    RitualCard(id: 'sd_28', number: 28, theme: RitualTheme.ahimsa),
    RitualCard(id: 'sd_29', number: 29, theme: RitualTheme.ahimsa),
    RitualCard(id: 'sd_30', number: 30, theme: RitualTheme.ahimsa),
    RitualCard(id: 'sd_31', number: 31, theme: RitualTheme.ahimsa),
    RitualCard(id: 'sd_32', number: 32, theme: RitualTheme.sathya),
    RitualCard(id: 'sd_33', number: 33, theme: RitualTheme.sathya),
    RitualCard(id: 'sd_34', number: 34, theme: RitualTheme.sathya),
    RitualCard(id: 'sd_35', number: 35, theme: RitualTheme.sathya),
    RitualCard(id: 'sd_36', number: 36, theme: RitualTheme.vairagya),
    RitualCard(id: 'sd_37', number: 37, theme: RitualTheme.vairagya),
    RitualCard(id: 'sd_38', number: 38, theme: RitualTheme.vairagya),
    RitualCard(id: 'sd_39', number: 39, theme: RitualTheme.vairagya),
    RitualCard(id: 'sd_40', number: 40, theme: RitualTheme.seva),
    RitualCard(id: 'sd_41', number: 41, theme: RitualTheme.seva),
    RitualCard(id: 'sd_42', number: 42, theme: RitualTheme.seva),
    RitualCard(id: 'sd_43', number: 43, theme: RitualTheme.seva),
    RitualCard(id: 'sd_44', number: 44, theme: RitualTheme.seva),
    RitualCard(id: 'sd_45', number: 45, theme: RitualTheme.shanti),
    RitualCard(id: 'sd_46', number: 46, theme: RitualTheme.shanti),
    RitualCard(id: 'sd_47', number: 47, theme: RitualTheme.shanti),
    RitualCard(id: 'sd_48', number: 48, theme: RitualTheme.shanti),
    RitualCard(id: 'sd_49', number: 49, theme: RitualTheme.shanti),
    RitualCard(id: 'sd_50', number: 50, theme: RitualTheme.shanti),
  ];

  /// Looks a card up by [id], or returns null when nothing matches.
  ///
  /// Used when a saved review points at a card that is no longer in the deck,
  /// which can only happen after a downgrade or a hand-edited preferences
  /// file. Returning null lets the caller drop the stale entry instead of
  /// crashing.
  static RitualCard? byId(String id) {
    for (final card in curatedDeck) {
      if (card.id == id) return card;
    }
    return null;
  }
}
