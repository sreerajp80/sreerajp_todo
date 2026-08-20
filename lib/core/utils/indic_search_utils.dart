import 'package:characters/characters.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

/// Search text folding for Indic (Malayalam-first) scripts.
///
/// The same fold is applied to text before it goes into the FTS index and to
/// whatever the user types, so both sides always meet in one normal form.
///
/// The fold does four things:
///  1. Unifies Malayalam Chillu letters. `ണ` + virama + ZWJ and the single
///     letter `ൺ` are the same sound, so both become the single letter.
///  2. Removes the zero-width joiner and non-joiner, which are invisible but
///     otherwise break a word into two tokens.
///  3. Strips Latin accent marks (`café` becomes `cafe`). Malayalam vowel
///     signs and the virama are never removed — they change the word.
///  4. Lower-cases and squeezes runs of whitespace into one space.

/// Zero-width joiner.
const String kZwj = '‍';

/// Zero-width non-joiner.
const String kZwnj = '‌';

/// Malayalam virama (chandrakkala).
const String kMalayalamVirama = '്';

/// Base consonant -> atomic Chillu letter.
///
/// The sequence written in the database may be `<consonant><virama><ZWJ>`;
/// the value is the single code point that means the same thing.
const Map<String, String> kChilluByConsonant = <String, String>{
  'ണ': 'ൺ', // ണ -> ൺ
  'ന': 'ൻ', // ന -> ൻ
  'ര': 'ർ', // ര -> ർ
  'ല': 'ൽ', // ല -> ൽ
  'ള': 'ൾ', // ള -> ൾ
  'ക': 'ൿ', // ക -> ൿ
};

/// Combining mark ranges that carry Latin (and general punctuation) accents.
///
/// Malayalam marks live in U+0D00–U+0D7F and are deliberately absent here.
const List<List<int>> _accentMarkRanges = <List<int>>[
  <int>[0x0300, 0x036F], // Combining Diacritical Marks
  <int>[0x1AB0, 0x1AFF], // Combining Diacritical Marks Extended
  <int>[0x1DC0, 0x1DFF], // Combining Diacritical Marks Supplement
  <int>[0x20D0, 0x20F0], // Combining Diacritical Marks for Symbols
  <int>[0xFE20, 0xFE2F], // Combining Half Marks
];

final RegExp _whitespaceRun = RegExp(r'\s+');

/// Characters that FTS5 reads as query syntax rather than as text.
final RegExp _ftsSyntaxChars = RegExp(r'''["*^:()\-+{}\[\]]''');

/// Folds [input] into the single normal form used for search.
///
/// Returns an empty string for empty or whitespace-only input.
String foldForSearch(String input) {
  if (input.isEmpty) return '';

  final String normalized = nfcNormalize(input);
  final String unified = _unifyChilluAndStripJoiners(normalized);
  final String unaccented = _stripAccentMarks(unified);

  return unaccented.toLowerCase().replaceAll(_whitespaceRun, ' ').trim();
}

/// True when [a] and [b] mean the same thing for search purposes.
bool foldedEquals(String a, String b) => foldForSearch(a) == foldForSearch(b);

/// Builds an FTS5 `MATCH` expression from raw user [input].
///
/// Each folded word becomes a quoted prefix term, and the terms are joined
/// with `AND` so every word must appear. A whole input wrapped in double
/// quotes is treated as one exact phrase instead.
///
/// Returns an empty string when there is nothing to search for; callers must
/// treat that as "no results" rather than passing it to SQLite.
String buildFtsMatchQuery(String input) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) return '';

  final bool isPhrase =
      trimmed.length > 2 && trimmed.startsWith('"') && trimmed.endsWith('"');

  final String folded = foldForSearch(
    isPhrase ? trimmed.substring(1, trimmed.length - 1) : trimmed,
  );
  if (folded.isEmpty) return '';

  final String cleaned = folded.replaceAll(_ftsSyntaxChars, ' ');

  if (isPhrase) {
    final String phrase = cleaned.replaceAll(_whitespaceRun, ' ').trim();
    return phrase.isEmpty ? '' : '"$phrase"';
  }

  final Iterable<String> words = cleaned
      .split(_whitespaceRun)
      .where((String w) => w.isNotEmpty);
  if (words.isEmpty) return '';

  return words.map((String w) => '"$w"*').join(' AND ');
}

/// Rewrites Chillu sequences and drops joiners, walking whole grapheme
/// clusters so a multi-code-point letter is never split in half.
String _unifyChilluAndStripJoiners(String input) {
  if (!input.contains(kZwj) && !input.contains(kZwnj)) return input;

  final StringBuffer buffer = StringBuffer();

  for (final String cluster in input.characters) {
    if (!cluster.contains(kZwj) && !cluster.contains(kZwnj)) {
      buffer.write(cluster);
      continue;
    }

    String folded = cluster;
    for (final MapEntry<String, String> entry in kChilluByConsonant.entries) {
      folded = folded.replaceAll(
        '${entry.key}$kMalayalamVirama$kZwj',
        entry.value,
      );
    }
    buffer.write(folded.replaceAll(kZwj, '').replaceAll(kZwnj, ''));
  }

  return buffer.toString();
}

/// Removes Latin accent marks while leaving Indic marks untouched.
String _stripAccentMarks(String input) {
  final String decomposed = unorm.nfd(input);
  final StringBuffer buffer = StringBuffer();

  for (final int rune in decomposed.runes) {
    if (_isAccentMark(rune)) continue;
    buffer.writeCharCode(rune);
  }

  return nfcNormalize(buffer.toString());
}

bool _isAccentMark(int rune) {
  for (final List<int> range in _accentMarkRanges) {
    if (rune >= range[0] && rune <= range[1]) return true;
  }
  return false;
}
