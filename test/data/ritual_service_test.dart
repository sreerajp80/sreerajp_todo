import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/data/services/ritual_service.dart';
import 'package:sreerajp_todo/domain/entities/ritual_card.dart';
import 'package:sreerajp_todo/domain/entities/ritual_review_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<RitualService> freshService([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return RitualService(await SharedPreferences.getInstance());
  }

  final monday = DateTime(2026, 8, 24, 7, 30);

  group('the deck itself', () {
    test('holds fifty cards, numbered without a gap', () async {
      final deck = (await freshService()).deck;

      expect(deck, hasLength(50));
      for (var i = 0; i < deck.length; i++) {
        expect(deck[i].number, i + 1);
      }
    });

    test('every card id is unique', () async {
      final deck = (await freshService()).deck;
      expect(deck.map((card) => card.id).toSet(), hasLength(deck.length));
    });

    test(
      'a card key stem matches the one the ARB keys were built from',
      () async {
        expect(RitualCard.byId('sd_01')!.keyStem, 'ritualCardSd01');
        expect(RitualCard.byId('sd_50')!.keyStem, 'ritualCardSd50');
        expect(RitualCard.byId('nope'), isNull);
      },
    );
  });

  group('picking today\'s card', () {
    test('a fresh install starts at the first card', () async {
      final service = await freshService();
      expect(service.cardForToday(now: monday).id, 'sd_01');
    });

    test('a rated card is not offered again until it is due', () async {
      final service = await freshService();
      await service.rateCard('sd_01', RepetitionRating.easy, now: monday);

      // Easy at level zero hides the card for seven days, so the next unseen
      // card comes up instead.
      expect(service.cardForToday(now: monday).id, 'sd_02');
    });

    test('a card that has come due is preferred over an unseen one', () async {
      final service = await freshService();
      // Rate the first two cards hard, so both come back tomorrow.
      await service.rateCard('sd_01', RepetitionRating.hard, now: monday);
      await service.rateCard('sd_02', RepetitionRating.hard, now: monday);

      final tuesday = monday.add(const Duration(days: 1));
      // sd_01 was rated first, so it is the one waiting longest.
      expect(service.cardForToday(now: tuesday).id, 'sd_01');
    });

    test('"show another" walks the deck and wraps round', () async {
      final service = await freshService();

      expect(service.cardAfter('sd_01').id, 'sd_02');
      expect(service.cardAfter('sd_50').id, 'sd_01');
      // An id that is no longer in the deck falls back rather than throwing.
      expect(service.cardAfter('gone').id, 'sd_01');
    });
  });

  group('rating a card', () {
    test('hard brings it back tomorrow and clears its level', () async {
      final service = await freshService();
      await service.rateCard('sd_03', RepetitionRating.easy, now: monday);
      final after = await service.rateCard(
        'sd_03',
        RepetitionRating.hard,
        now: monday,
      );

      expect(after.level, 0);
      expect(after.nextReviewDate, DateTime(2026, 8, 25));
    });

    test('revision holds the level and waits three days', () async {
      final service = await freshService();
      final after = await service.rateCard(
        'sd_04',
        RepetitionRating.revision,
        now: monday,
      );

      expect(after.level, 0);
      expect(after.nextReviewDate, DateTime(2026, 8, 27));
    });

    test('easy stretches the wait each time', () async {
      final service = await freshService();

      final first = await service.rateCard(
        'sd_05',
        RepetitionRating.easy,
        now: monday,
      );
      expect(first.level, 1);
      expect(first.nextReviewDate, DateTime(2026, 8, 31)); // seven days

      final second = await service.rateCard(
        'sd_05',
        RepetitionRating.easy,
        now: monday,
      );
      expect(second.level, 2);
      expect(second.nextReviewDate, DateTime(2026, 9, 7)); // fourteen days
    });

    test('the count of times seen keeps going up', () async {
      final service = await freshService();
      await service.rateCard('sd_06', RepetitionRating.hard, now: monday);
      await service.rateCard('sd_06', RepetitionRating.revision, now: monday);

      expect(service.reviewState('sd_06', now: monday).reviewCount, 2);
    });
  });

  group('stored state', () {
    test('survives being written and read again', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await RitualService(
        prefs,
      ).rateCard('sd_07', RepetitionRating.easy, now: monday);

      final reloaded = RitualService(prefs).reviewState('sd_07', now: monday);
      expect(reloaded.level, 1);
      expect(reloaded.reviewCount, 1);
      expect(reloaded.nextReviewDate, DateTime(2026, 8, 31));
    });

    test('an unreadable entry is treated as an unseen card', () async {
      final service = await freshService({
        '${kRitualCardReviewPrefix}sd_08': 'not json at all',
      });

      final state = service.reviewState('sd_08', now: monday);
      expect(state.reviewCount, 0);
      expect(state.isDue(monday), isTrue);
    });

    test('resetting clears every card', () async {
      final service = await freshService();
      await service.rateCard('sd_09', RepetitionRating.easy, now: monday);
      await service.resetAllReviews();

      expect(service.reviewState('sd_09', now: monday).reviewCount, 0);
      expect(service.cardForToday(now: monday).id, 'sd_01');
    });
  });
}
