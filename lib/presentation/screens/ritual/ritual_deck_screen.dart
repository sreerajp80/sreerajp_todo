import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/domain/entities/ritual_card.dart';
import 'package:sreerajp_todo/domain/entities/ritual_review_state.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/ritual_card_text.dart';
import 'package:sreerajp_todo/presentation/screens/ritual/widgets/ritual_theme_style.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';

/// The Ritual Deck browser: every card, and when each one comes back.
///
/// Read-only. Cards are bundled with the app, so there is nothing to add,
/// edit or delete here. It is deliberately not the Mastery Deck: that one
/// holds real tasks and writes to the database, this one holds reflection
/// cards and only reads a preference.
class RitualDeckScreen extends ConsumerStatefulWidget {
  const RitualDeckScreen({super.key});

  @override
  ConsumerState<RitualDeckScreen> createState() => _RitualDeckScreenState();
}

class _RitualDeckScreenState extends ConsumerState<RitualDeckScreen> {
  RitualTheme? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = ref.watch(ritualServiceProvider);
    final now = DateTime.now();
    final cards = _filter == null
        ? service.deck
        : service.deck.where((card) => card.theme == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ritualDeckTitle)),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: FilterChip(
                      selected: _filter == null,
                      label: Text(l10n.ritualDeckAll),
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                  ),
                  for (final theme in RitualTheme.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: FilterChip(
                        selected: _filter == theme,
                        avatar: Icon(theme.icon, size: 16),
                        label: Text(theme.label(context)),
                        onSelected: (_) => setState(() => _filter = theme),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: cards.isEmpty
                  ? Center(child: Text(l10n.ritualDeckEmpty))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: cards.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return _DeckTile(
                          card: card,
                          state: service.reviewState(card.id, now: now),
                          now: now,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One card in the browser: its title, its theme, and where it sits in the
/// spaced repetition cycle.
class _DeckTile extends StatelessWidget {
  const _DeckTile({required this.card, required this.state, required this.now});

  final RitualCard card;
  final CardReviewState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = ritualCardText(l10n, card.id);

    final unseen = state.reviewCount == 0;
    final due = state.isDue(now);
    final daysAway = state.nextReviewDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    final badge = unseen
        ? l10n.ritualDeckUnseen
        : due
        ? l10n.ritualDeckDue
        : l10n.ritualRateInDays(daysAway);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: card.theme.accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(card.theme.icon, size: 16, color: card.theme.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  card.theme.label(context),
                  style: theme.textTheme.labelMedium,
                ),
              ),
              Text(
                badge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: due || unseen ? colors.primary : colors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AdaptiveDirectionality(
            text: text.title,
            child: Text(text.title, style: theme.textTheme.titleSmall),
          ),
          const SizedBox(height: 6),
          AdaptiveDirectionality(
            text: text.prompt,
            child: Text(
              text.prompt,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          if (!unseen) ...[
            const SizedBox(height: 6),
            Text(
              l10n.ritualDeckSeenCount(state.reviewCount),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
