import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/data/models/daily_intention_entity.dart';
import 'package:sreerajp_todo/domain/entities/ritual_card.dart';
import 'package:sreerajp_todo/domain/entities/ritual_review_state.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/ritual_card_text.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/widgets/ritual_theme_style.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';

/// Step 2: one card from the Ritual Deck.
///
/// The card is chosen by the deck's own spaced repetition, so it changes as
/// the cards are rated rather than cycling in a fixed order. Rating a card is
/// what moves the step on: it is the one thing the step is for.
///
/// "Make this today's intention" writes the card title through the same
/// repository the Morning Intention Card reads, so the day list then shows the
/// same words. Nothing new is stored for it.
class RitualCardStep extends ConsumerStatefulWidget {
  const RitualCardStep({super.key, required this.date, required this.onDone});

  /// Today, as `yyyy-MM-dd`. The intention is written against this day.
  final String date;

  /// Called once the card has been rated, to move to the next step.
  final VoidCallback onDone;

  @override
  ConsumerState<RitualCardStep> createState() => _RitualCardStepState();
}

class _RitualCardStepState extends ConsumerState<RitualCardStep> {
  RitualCard? _card;
  bool _busy = false;
  bool _intentionSaved = false;

  @override
  void initState() {
    super.initState();
    _card = ref.read(ritualServiceProvider).cardForToday();
  }

  void _showAnother() {
    final current = _card;
    if (current == null) return;
    setState(() {
      _card = ref.read(ritualServiceProvider).cardAfter(current.id);
      _intentionSaved = false;
    });
  }

  Future<void> _saveAsIntention(String title) async {
    if (_busy) return;
    setState(() => _busy = true);

    // Straight through the repository the intention card already uses, so NFC
    // normalisation and the day lock are applied exactly once, in one place.
    await ref
        .read(dailyReflectionRepositoryProvider)
        .saveIntention(
          DailyIntentionEntity(
            date: widget.date,
            intentionText: title,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
    ref.invalidate(dailyIntentionProvider(widget.date));

    if (!mounted) return;
    setState(() {
      _busy = false;
      _intentionSaved = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.ritualIntentionSaved)));
  }

  Future<void> _rate(RepetitionRating rating) async {
    final card = _card;
    if (card == null || _busy) return;
    setState(() => _busy = true);
    await ref.read(ritualServiceProvider).rateCard(card.id, rating);
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;
    if (card == null) return const SizedBox.shrink();

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = ritualCardText(l10n, card.id);
    final deckSize = ref.read(ritualServiceProvider).deck.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: card.theme.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(card.theme.icon, size: 18, color: card.theme.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                card.theme.label(context),
                style: theme.textTheme.labelLarge,
              ),
            ),
            Text(
              l10n.ritualCardProgress(card.number, deckSize),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AdaptiveDirectionality(
          text: text.title,
          child: Text(text.title, style: theme.textTheme.headlineSmall),
        ),
        const SizedBox(height: 14),
        AdaptiveDirectionality(
          text: text.prompt,
          child: Text(text.prompt, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: card.theme.accent, width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdaptiveDirectionality(
                text: text.quote,
                child: Text(text.quote, style: theme.textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              AdaptiveDirectionality(
                text: text.author,
                child: Text(
                  text.author,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton.icon(
              onPressed: _busy ? null : _showAnother,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.ritualCardAnother),
            ),
            TextButton.icon(
              onPressed: _busy || _intentionSaved
                  ? null
                  : () => _saveAsIntention(text.title),
              icon: Icon(
                _intentionSaved
                    ? Icons.check_rounded
                    : Icons.wb_twilight_rounded,
              ),
              label: Text(l10n.ritualMakeIntention),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(l10n.ritualRateQuestion, style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                label: l10n.ritualRateHard,
                badge: l10n.ritualRateTomorrow,
                color: colors.error,
                onPressed: _busy ? null : () => _rate(RepetitionRating.hard),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RatingButton(
                label: l10n.ritualRateRevision,
                badge: l10n.ritualRateInDays(
                  RepetitionRating.revision.intervalDaysFrom(0),
                ),
                color: colors.tertiary,
                onPressed: _busy
                    ? null
                    : () => _rate(RepetitionRating.revision),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RatingButton(
                label: l10n.ritualRateEasy,
                badge: l10n.ritualRateInDays(
                  RepetitionRating.easy.intervalDaysFrom(
                    ref.read(ritualServiceProvider).reviewState(card.id).level,
                  ),
                ),
                color: colors.primary,
                onPressed: _busy ? null : () => _rate(RepetitionRating.easy),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One of the three recall buttons, with the wait it leads to printed under it.
///
/// The wait is shown because the choice is otherwise guesswork: "Easy" means
/// nothing until you know it hides the card for weeks.
class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.badge,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String badge;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            badge,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
