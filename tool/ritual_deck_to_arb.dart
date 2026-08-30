// Converts the Ritual Deck card text into ARB entries.
//
// Run once, when the deck is first brought into the project, and again only if
// the deck source ever changes. It exists so that no card text — Malayalam
// especially — is ever retyped by hand into `app_en.arb` and `app_ml.arb`.
//
// The source it reads is a Dart file holding `RitualCard(...)` literals with
// both languages inline, which is how the deck arrives from SreerajP Journal
// Vault. In this project the deck file keeps only `id`, `number` and `theme`;
// every piece of text lives in the ARB files, like every other user-visible
// string in the app.
//
// Usage:
//   dart run tool/ritual_deck_to_arb.dart <path-to-source-deck.dart> <out-dir>
//
// It writes four files into the output directory, and edits nothing in the
// project itself, so a bad run can never damage the ARB files:
//
//   ritual_deck_en.arb.part   entries to paste into `lib/l10n/app_en.arb`
//   ritual_deck_ml.arb.part   entries to paste into `lib/l10n/app_ml.arb`
//   ritual_card_deck.part     the const card list for the deck file
//   ritual_card_text.dart     the id-to-strings resolver, ready to copy in
//
// The resolver is generated rather than written by hand because the ARB
// getters are generated methods: there is no way to look one up by name at
// run time, so the 50 cards need an explicit switch. Generating it keeps that
// switch and the ARB keys from ever drifting apart.
//
// Any card missing text for a field is listed by name at the end, so a gap is
// seen and filled rather than silently falling back to English.

import 'dart:convert';
import 'dart:io';

/// The four text fields on a card, and the ARB key suffix each one gets.
const Map<String, String> _fields = {
  'title': 'Title',
  'prompt': 'Prompt',
  'quote': 'Quote',
  'quoteAuthor': 'QuoteAuthor',
};

/// A short description written into `app_en.arb` beside each English entry.
const Map<String, String> _descriptions = {
  'title': 'Ritual deck card {id}: card title.',
  'prompt': 'Ritual deck card {id}: the reflection question.',
  'quote': 'Ritual deck card {id}: the grounding quote.',
  'quoteAuthor': 'Ritual deck card {id}: who the quote is from.',
};

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
      'Usage: dart run tool/ritual_deck_to_arb.dart '
      '<path-to-source-deck.dart> <out-dir>',
    );
    exitCode = 64;
    return;
  }

  final source = File(args[0]);
  if (!source.existsSync()) {
    stderr.writeln('Source deck not found: ${args[0]}');
    exitCode = 66;
    return;
  }

  final cards = _parseCards(source.readAsStringSync());
  if (cards.isEmpty) {
    stderr.writeln('No RitualCard(...) literals found in ${args[0]}.');
    exitCode = 65;
    return;
  }

  final english = StringBuffer();
  final malayalam = StringBuffer();
  final deck = StringBuffer();
  final resolver = StringBuffer();
  final gaps = <String>[];
  var cardsWritten = 0;
  var keysWritten = 0;

  for (final card in cards) {
    final id = card['id'];
    // The class's own constructor declaration matches the same marker but
    // carries no `id:`, so it is skipped here rather than counted as a card.
    if (id == null || id.isEmpty) continue;
    final keyStem = _keyStem(id);
    cardsWritten++;

    final number = card['number'] ?? '$cardsWritten';
    final theme = card['theme'] ?? 'RitualTheme.dharma';
    deck.writeln("    RitualCard(id: '$id', number: $number, theme: $theme),");

    resolver.writeln("      case '$id':");
    resolver.writeln('        return RitualCardText(');
    resolver.writeln('          title: l10n.${keyStem}Title,');
    resolver.writeln('          prompt: l10n.${keyStem}Prompt,');
    resolver.writeln('          quote: l10n.${keyStem}Quote,');
    resolver.writeln('          author: l10n.${keyStem}QuoteAuthor,');
    resolver.writeln('        );');

    for (final entry in _fields.entries) {
      final field = entry.key;
      final key = '$keyStem${entry.value}';

      final en = card[field];
      final ml = card['${field}Ml'];

      if (en == null || en.isEmpty) {
        gaps.add('$id: English "$field" is missing');
        continue;
      }
      if (ml == null || ml.isEmpty) {
        gaps.add('$id: Malayalam "${field}Ml" is missing');
      }

      english.writeln('  ${_json(key)}: ${_json(en)},');
      english.writeln('  ${_json('@$key')}: {');
      english.writeln(
        '    "description": '
        '${_json(_descriptions[field]!.replaceAll('{id}', id))}',
      );
      english.writeln('  },');

      // A missing Malayalam string is written as the English one on purpose:
      // the fragment stays valid and complete, and the gap is reported above
      // so it can be translated properly rather than left to a silent
      // fallback nobody notices.
      malayalam.writeln('  ${_json(key)}: ${_json(ml ?? en)},');
      keysWritten++;
    }
  }

  final outDir = Directory(args[1]);
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  File(
    '${outDir.path}/ritual_deck_en.arb.part',
  ).writeAsStringSync(english.toString());
  File(
    '${outDir.path}/ritual_deck_ml.arb.part',
  ).writeAsStringSync(malayalam.toString());
  File(
    '${outDir.path}/ritual_card_deck.part',
  ).writeAsStringSync(deck.toString());
  File(
    '${outDir.path}/ritual_card_text.dart',
  ).writeAsStringSync(_resolverFile(resolver.toString()));

  stdout.writeln('Cards written: $cardsWritten');
  stdout.writeln('Keys written per language: $keysWritten');
  stdout.writeln('Wrote ${outDir.path}/ritual_deck_en.arb.part');
  stdout.writeln('Wrote ${outDir.path}/ritual_deck_ml.arb.part');
  stdout.writeln('Wrote ${outDir.path}/ritual_card_deck.part');
  stdout.writeln('Wrote ${outDir.path}/ritual_card_text.dart');

  if (gaps.isEmpty) {
    stdout.writeln(
      'No missing text. Every card is complete in both '
      'languages.',
    );
  } else {
    stdout.writeln('\nMissing text (${gaps.length}):');
    for (final gap in gaps) {
      stdout.writeln('  $gap');
    }
  }
}

/// Wraps the generated `switch` arms in a complete, ready-to-copy Dart file.
String _resolverFile(String arms) {
  return """
// GENERATED by tool/ritual_deck_to_arb.dart. Do not edit by hand.
//
// Maps a Ritual Deck card id to its text in the app's current language.
//
// The ARB getters are generated methods, so a card's text cannot be looked up
// by key at run time. This switch is the bridge. It is generated from the same
// source as the ARB entries, so the two can never disagree.

import 'package:sreerajp_todo/l10n/app_localizations.dart';

/// The four pieces of text on one Ritual Deck card.
class RitualCardText {
  const RitualCardText({
    required this.title,
    required this.prompt,
    required this.quote,
    required this.author,
  });

  /// Short name of the card, shown as its heading.
  final String title;

  /// The reflection question the card asks.
  final String prompt;

  /// The grounding quote below the question.
  final String quote;

  /// Who the quote is from.
  final String author;
}

/// Returns the text for [cardId] in the language [l10n] is set to.
///
/// An unknown id falls back to the first card rather than throwing: a stale id
/// can only come from a downgrade or a hand-edited preferences file, and must
/// never stop the ritual from opening.
RitualCardText ritualCardText(AppLocalizations l10n, String cardId) {
  switch (cardId) {
$arms    default:
      return RitualCardText(
        title: l10n.ritualCardSd01Title,
        prompt: l10n.ritualCardSd01Prompt,
        quote: l10n.ritualCardSd01Quote,
        author: l10n.ritualCardSd01QuoteAuthor,
      );
  }
}
""";
}

/// Turns a card id such as `sd_01` into the ARB key stem `ritualCardSd01`.
String _keyStem(String id) {
  final parts = id.split('_').where((part) => part.isNotEmpty);
  final camel = parts
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join();
  return 'ritualCard$camel';
}

/// Encodes a Dart string as a JSON string, escaping exactly as ARB needs.
String _json(String value) => jsonEncode(value);

/// Pulls every `RitualCard(...)` literal out of [source] as a field map.
///
/// The deck is a plain `const` list of constructor calls with no nesting
/// beyond the odd bracket inside a quote, so it is read by walking the text
/// rather than by running the analyser. Quotes and escapes are handled, which
/// matters because several cards contain an apostrophe.
List<Map<String, String>> _parseCards(String source) {
  const marker = 'RitualCard(';
  final cards = <Map<String, String>>[];

  var index = source.indexOf(marker);
  while (index != -1) {
    final bodyStart = index + marker.length;
    final bodyEnd = _findClosingParen(source, bodyStart);
    if (bodyEnd == -1) break;
    cards.add(_parseFields(source.substring(bodyStart, bodyEnd)));
    index = source.indexOf(marker, bodyEnd);
  }
  return cards;
}

/// Returns the index of the `)` that closes the call opened before [start],
/// skipping anything inside a quoted string. Returns -1 if it never closes.
int _findClosingParen(String source, int start) {
  var depth = 1;
  var i = start;
  while (i < source.length) {
    final char = source[i];
    if (char == r'\') {
      i += 2;
      continue;
    }
    if (char == "'" || char == '"') {
      i = _skipString(source, i);
      continue;
    }
    if (char == '(') depth++;
    if (char == ')') {
      depth--;
      if (depth == 0) return i;
    }
    i++;
  }
  return -1;
}

/// Returns the index just past the string literal that starts at [start].
int _skipString(String source, int start) {
  final quote = source[start];
  var i = start + 1;
  while (i < source.length) {
    final char = source[i];
    if (char == r'\') {
      i += 2;
      continue;
    }
    if (char == quote) return i + 1;
    i++;
  }
  return source.length;
}

/// Reads `name: value` pairs out of one constructor body.
///
/// Only string and simple values are kept; anything else (an enum such as
/// `RitualTheme.dharma`, or a number) is stored as written, which is all the
/// caller needs for `id`.
Map<String, String> _parseFields(String body) {
  final fields = <String, String>{};
  var i = 0;

  while (i < body.length) {
    final colon = body.indexOf(':', i);
    if (colon == -1) break;

    // Walk back over the field name.
    final nameEnd = colon;
    var nameStart = nameEnd;
    while (nameStart > 0 && _isNameChar(body[nameStart - 1])) {
      nameStart--;
    }
    final name = body.substring(nameStart, nameEnd).trim();
    if (name.isEmpty) {
      i = colon + 1;
      continue;
    }

    // Read the value, joining adjacent string pieces the way Dart does, so a
    // prompt split across several source lines comes back as one string.
    var j = colon + 1;
    final value = StringBuffer();
    var sawString = false;

    while (j < body.length) {
      final char = body[j];
      if (char == ' ' || char == '\n' || char == '\r' || char == '\t') {
        j++;
        continue;
      }
      if (char == "'" || char == '"') {
        final end = _skipString(body, j);
        value.write(_unescape(body.substring(j + 1, end - 1)));
        sawString = true;
        j = end;
        continue;
      }
      break;
    }

    if (sawString) {
      fields[name] = value.toString();
    } else {
      // A non-string value: take it up to the next comma at depth zero.
      final comma = body.indexOf(',', j);
      final end = comma == -1 ? body.length : comma;
      fields[name] = body.substring(j, end).trim();
      j = end;
    }

    i = j + 1;
  }

  return fields;
}

bool _isNameChar(String char) {
  return RegExp(r'[A-Za-z0-9_]').hasMatch(char);
}

/// Turns Dart source escapes back into the characters they stand for.
String _unescape(String raw) {
  final out = StringBuffer();
  var i = 0;
  while (i < raw.length) {
    final char = raw[i];
    if (char != r'\') {
      out.write(char);
      i++;
      continue;
    }
    if (i + 1 >= raw.length) break;
    final next = raw[i + 1];
    switch (next) {
      case 'n':
        out.write('\n');
      case 't':
        out.write('\t');
      case 'r':
        out.write('\r');
      default:
        out.write(next);
    }
    i += 2;
  }
  return out.toString();
}
