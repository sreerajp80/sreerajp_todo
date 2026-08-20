import 'package:flutter/material.dart';
import 'package:sreerajp_todo/presentation/screens/help/widgets/help_widgets.dart';

class MasteryDeckHelpScreen extends StatelessWidget {
  const MasteryDeckHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mastery Deck & Flashcards')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          HelpIntro(
            'Mastery Deck turns your daily learnings, key concepts, and study notes into an active spaced repetition flashcard system. '
            'Retain what you learn long-term with scientifically scheduled review intervals.',
          ),
          SizedBox(height: 24),
          HelpSection(
            icon: Icons.psychology_outlined,
            title: 'Spaced Repetition Review',
            children: [
              HelpBullet(
                'Cards are scheduled for review based on how well you remember them (Easy, Good, Hard, Again).',
              ),
              HelpBullet(
                'Cards rated "Easy" increase their review intervals exponentially (e.g. 1 day → 3 days → 7 days → 16 days).',
              ),
              HelpBullet(
                'Cards rated "Hard" or "Again" reset or shorten their intervals for frequent reinforcement.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.style_outlined,
            title: 'Decks & Organization',
            children: [
              HelpBullet(
                'Group flashcards by subject, project, or language into custom Decks.',
              ),
              HelpBullet(
                'Each card has a Question (Front) and Answer/Explanation (Back), with optional tags.',
              ),
              HelpBullet(
                'Decks show live metrics including Due Today count, Total Cards, and Overall Mastery Percentage.',
              ),
            ],
          ),
          HelpSection(
            icon: Icons.military_tech_outlined,
            title: 'Mastery Levels',
            children: [
              HelpBullet(
                'Cards progress through 5 mastery levels: Learning, Novice, Competent, Proficient, and Mastered.',
              ),
              HelpBullet(
                'Streaks and review consistency reward daily engagement and habit formation.',
              ),
            ],
          ),
          SizedBox(height: 8),
          HelpFooter(
            'Tip: You can export and share your custom decks with other devices using Air QR beams or Local Wi-Fi Sync.',
          ),
        ],
      ),
    );
  }
}
