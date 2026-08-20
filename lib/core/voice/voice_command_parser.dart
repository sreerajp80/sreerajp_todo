import 'package:sreerajp_todo/core/utils/unicode_utils.dart' as unicode_utils;
import 'package:sreerajp_todo/core/voice/voice_lexicon_en.dart';
import 'package:sreerajp_todo/core/voice/voice_lexicon_ml.dart';
import 'package:sreerajp_todo/core/voice/voice_parse_result.dart';

/// Turns one plain sentence into a ready-to-save task.
///
/// Everything runs on the device with plain Dart: no grammar file, no model,
/// no network. The engine walks the sentence four times, once for each thing it
/// can understand, and takes the matched words out as it goes. Whatever is left
/// over becomes the task title.
///
/// The four passes run in this order, and the order matters:
///
/// 1. **Duration** — `for 30 minutes`, `45 മിനിറ്റ്`. First, because a
///    duration always names its unit, so it can never be mistaken for anything
///    else. Running it first also stops `രണ്ട് മണിക്കൂർ` (two hours long) from
///    being read as `രണ്ട് മണിക്ക്` (at two o'clock).
/// 2. **Time of day** — `at 10 am`, `ഏഴരയ്ക്ക്`, `പത്തു മണിക്ക്`.
/// 3. **Date** — `tomorrow`, `next Monday`, `അടുത്ത തിങ്കളാഴ്ച`.
/// 4. **Priority** — `urgent`, `low priority`, `അടിയന്തിരം`.
///
/// Both language lexicons are always tried against every token, so a sentence
/// that mixes English and Malayalam works without the user telling the app
/// which language they are about to use.
///
/// Two promises the engine keeps:
///
/// * **It never invents.** A sentence with no date words gets today, not a
///   guess. An hour with no `am`, `pm`, or part-of-day word is kept exactly as
///   it was said, so `ഏഴര` is 07:30 and `at 5` is 05:00.
/// * **It never returns a blank title.** If every single word was understood as
///   a date or a time, the whole sentence is kept as the title instead.
class VoiceCommandParser {
  const VoiceCommandParser();

  /// Reads [input] as a task, with [today] as the day "today" means.
  ///
  /// [today] is passed in rather than read from the clock so the caller can use
  /// the app's own day-start rule, and so tests are not tied to the wall clock.
  VoiceParseResult parse(String input, {required DateTime today}) {
    final rawText = unicode_utils.nfcNormalize(input.trim());
    if (rawText.isEmpty) {
      return VoiceParseResult(rawText: '', title: '', date: _isoDate(today));
    }

    final body = _stripCommandPrefix(rawText);
    final tokens = _tokenize(body);
    final matched = <VoiceField>{};

    final targetSeconds = _readDuration(tokens);
    if (targetSeconds != null) matched.add(VoiceField.target);

    final timeOfDay = _readTimeOfDay(tokens);
    if (timeOfDay != null) matched.add(VoiceField.timeOfDay);

    final dayOffset = _readDate(tokens, today);
    if (dayOffset != null) matched.add(VoiceField.date);

    final priority = _readPriority(tokens);
    if (priority != null) matched.add(VoiceField.priority);

    // Day-Lock makes past days read-only, so a date can only ever be today or
    // later. Every rule above moves forward, so this guard should never fire;
    // it stays as a safety net rather than a promise about the rules.
    final dayStart = DateTime(today.year, today.month, today.day);
    var resolved = dayStart.add(Duration(days: dayOffset ?? 0));
    var clamped = false;
    if (resolved.isBefore(dayStart)) {
      resolved = dayStart;
      clamped = true;
    }

    var title = _buildTitle(tokens);
    if (title.isEmpty) title = rawText;

    return VoiceParseResult(
      rawText: rawText,
      title: title,
      date: _isoDate(resolved),
      hour: timeOfDay?.hour,
      minute: timeOfDay?.minute ?? 0,
      targetSeconds: targetSeconds,
      priority: priority,
      dateWasClamped: clamped,
      matched: matched,
    );
  }

  // ---------------------------------------------------------------------
  // Setting up
  // ---------------------------------------------------------------------

  /// Drops an opening phrase like `remind me to` that carries no task meaning.
  String _stripCommandPrefix(String text) {
    final lower = text.toLowerCase();
    for (final prefix in enCommandPrefixes) {
      if (lower.startsWith('$prefix ')) {
        return text.substring(prefix.length + 1).trimLeft();
      }
    }
    return text;
  }

  List<_Token> _tokenize(String text) => text
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map(_Token.new)
      .toList();

  // ---------------------------------------------------------------------
  // Pass 1 — how long the task should take
  // ---------------------------------------------------------------------

  /// Reads every duration in the sentence and adds them up.
  ///
  /// Handles `for 30 minutes`, `1 hour 30 minutes`, `half an hour`,
  /// `45 മിനിറ്റ്`, `45മിനിറ്റ്` written as one word, and `ഒരു മണിക്കൂർ`.
  int? _readDuration(List<_Token> tokens) {
    var seconds = 0;
    var found = false;

    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i].used) continue;

      // `half an hour` / `half hour`.
      if (tokens[i].norm == 'half') {
        var j = i + 1;
        if (j < tokens.length &&
            (tokens[j].norm == 'an' || tokens[j].norm == 'a')) {
          j++;
        }
        if (j < tokens.length && enHourUnits.contains(tokens[j].norm)) {
          seconds += 30 * 60;
          found = true;
          _use(tokens, i, j);
          _useLeadIn(tokens, i, enDurationLeadIns);
          i = j;
          continue;
        }
      }

      // A number and its unit written as one Malayalam word, like `45മിനിറ്റ്`.
      final glued = _gluedMalayalamDuration(tokens[i].norm);
      if (glued != null) {
        seconds += glued;
        found = true;
        tokens[i].used = true;
        _useLeadIn(tokens, i, enDurationLeadIns);
        continue;
      }

      final number = _readNumber(tokens, i);
      if (number == null) continue;
      final unitIndex = i + number.length;
      if (unitIndex >= tokens.length) continue;
      final unit = tokens[unitIndex].norm;

      final int? unitSeconds;
      if (enHourUnits.contains(unit) || _hasStem(unit, mlHourUnitStem)) {
        unitSeconds = 3600;
      } else if (enMinuteUnits.contains(unit) ||
          mlMinuteUnitStems.any((stem) => _hasStem(unit, stem))) {
        unitSeconds = 60;
      } else {
        unitSeconds = null;
      }
      if (unitSeconds == null) continue;

      seconds += number.value * unitSeconds;
      found = true;
      _use(tokens, i, unitIndex);
      _useLeadIn(tokens, i, enDurationLeadIns);
      i = unitIndex;
    }

    if (!found || seconds <= 0) return null;
    return seconds;
  }

  /// Reads `45മിനിറ്റ്` and `2മണിക്കൂർ`, where the digits and the unit are one
  /// token. Returns the seconds, or null when the token is not that shape.
  int? _gluedMalayalamDuration(String token) {
    final match = RegExp(r'^(\d{1,4})(.+)$').firstMatch(token);
    if (match == null) return null;
    final value = int.parse(match.group(1)!);
    final rest = match.group(2)!;
    if (_hasStem(rest, mlHourUnitStem)) return value * 3600;
    if (mlMinuteUnitStems.any((stem) => _hasStem(rest, stem))) {
      return value * 60;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Pass 2 — what time of day
  // ---------------------------------------------------------------------

  /// Reads the time of day, if the sentence names one.
  _TimeOfDay? _readTimeOfDay(List<_Token> tokens) {
    // Parts of the day are noted but not taken out yet. `രാവിലെ നടക്കണം`
    // ("walk in the morning") has no hour, and there the word belongs to the
    // title. It is only removed once an hour has actually been found.
    final dayPartIndexes = <int>[];
    bool? dayPartIsAm;
    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i].used) continue;
      final isAm = _dayPartOf(tokens[i].norm);
      if (isAm != null) {
        dayPartIndexes.add(i);
        dayPartIsAm ??= isAm;
      }
    }

    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i].used) continue;
      final found = _timeAt(tokens, i);
      if (found == null) continue;

      var hour = found.hour;
      var explicit = found.meridiemIsAm;
      if (explicit == null && dayPartIsAm != null && hour >= 1 && hour <= 12) {
        explicit = dayPartIsAm;
        for (final index in dayPartIndexes) {
          tokens[index].used = true;
        }
      }
      if (explicit != null && hour >= 1 && hour <= 12) {
        hour = explicit ? hour % 12 : (hour % 12) + 12;
      }
      if (hour > 23 || hour < 0) return null;

      _useLeadIn(tokens, found.startIndex, enTimeLeadIns);
      return _TimeOfDay(hour, found.minute);
    }
    return null;
  }

  /// Tries to read a time starting at token [i]. Marks what it reads as used.
  _TimeMatch? _timeAt(List<_Token> tokens, int i) {
    final token = tokens[i].norm;

    // `ഏഴര`, `പത്തര` — half past an hour, ending and all.
    final half = _longestStem(mlHalfHourStems, token);
    if (half != null) {
      tokens[i].used = true;
      _useIfClockMarker(tokens, i + 1);
      return _TimeMatch(i, half.value, 30, null);
    }

    // `10:30`, `10.30`, optionally followed by am or pm.
    final clockText = RegExp(r'^(\d{1,2})[:.](\d{2})$').firstMatch(token);
    if (clockText != null) {
      final hour = int.parse(clockText.group(1)!);
      final minute = int.parse(clockText.group(2)!);
      if (hour <= 23 && minute <= 59) {
        tokens[i].used = true;
        final meridiem = _useMeridiemAfter(tokens, i + 1);
        return _TimeMatch(i, hour, minute, meridiem);
      }
    }

    // `പത്തുമണിക്ക്` — the number and the o'clock marker glued into one word.
    final gluedHour = _gluedMalayalamHour(token);
    if (gluedHour != null) {
      tokens[i].used = true;
      return _TimeMatch(i, gluedHour, 0, null);
    }

    // `half past seven`, `quarter past 7`, `quarter to 8`.
    if ((token == 'half' || token == 'quarter') &&
        i + 2 < tokens.length &&
        (tokens[i + 1].norm == 'past' || tokens[i + 1].norm == 'to')) {
      final number = _readNumber(tokens, i + 2);
      if (number != null && number.value >= 1 && number.value <= 12) {
        final isPast = tokens[i + 1].norm == 'past';
        final minutes = token == 'half' ? 30 : 15;
        var hour = number.value;
        var minute = minutes;
        if (!isPast) {
          minute = 60 - minutes;
          hour = hour == 1 ? 12 : hour - 1;
        }
        final last = i + 2 + number.length - 1;
        _use(tokens, i, last);
        final meridiem = _useMeridiemAfter(tokens, last + 1);
        return _TimeMatch(i, hour, minute, meridiem);
      }
    }

    final number = _readNumber(tokens, i);
    if (number == null) return null;
    if (number.value < 0 || number.value > 23) return null;
    final next = i + number.length;

    // `10 am`, `10 pm`.
    final meridiem = _meridiemAt(tokens, next);
    if (meridiem != null) {
      _use(tokens, i, next);
      return _TimeMatch(i, number.value, 0, meridiem);
    }

    // `പത്തു മണിക്ക്` — the number, then the o'clock marker as its own word.
    if (next < tokens.length &&
        !tokens[next].used &&
        _hasStem(tokens[next].norm, mlClockStem) &&
        !_hasStem(tokens[next].norm, mlHourUnitStem)) {
      _use(tokens, i, next);
      return _TimeMatch(i, number.value, 0, null);
    }

    // `10 o'clock`, `10 oclock`, `10 o clock`.
    if (next < tokens.length && !tokens[next].used) {
      if (enOClock.contains(tokens[next].norm)) {
        _use(tokens, i, next);
        return _TimeMatch(i, number.value, 0, null);
      }
      if (tokens[next].norm == 'o' &&
          next + 1 < tokens.length &&
          tokens[next + 1].norm == 'clock') {
        _use(tokens, i, next + 1);
        return _TimeMatch(i, number.value, 0, null);
      }
    }

    // `at 10`, `by 5` — a bare number only counts as a time when a word like
    // `at` introduced it, or a plain number in a title would be eaten.
    if (i > 0 &&
        !tokens[i - 1].used &&
        enTimeLeadIns.contains(tokens[i - 1].norm)) {
      _use(tokens, i, next - 1);
      return _TimeMatch(i, number.value, 0, null);
    }

    return null;
  }

  /// Reads `പത്തുമണിക്ക്`, where the hour word and `മണി` are one token.
  int? _gluedMalayalamHour(String token) {
    for (final entry in _byLongestStem(mlNumberStems)) {
      if (!token.startsWith(entry.stem)) continue;
      final rest = token.substring(entry.stem.length);
      if (rest.isEmpty) continue;
      if (_hasStem(rest, mlHourUnitStem)) return null;
      // A case ending such as `ു` can sit between the number and `മണി`.
      final trimmed = _dropLeadingSigns(rest);
      if (trimmed.startsWith(mlClockStem)) return entry.value;
    }
    return null;
  }

  /// Marks token [index] as used when it is `മണി` in its o'clock sense.
  void _useIfClockMarker(List<_Token> tokens, int index) {
    if (index >= tokens.length || tokens[index].used) return;
    if (_hasStem(tokens[index].norm, mlClockStem) &&
        !_hasStem(tokens[index].norm, mlHourUnitStem)) {
      tokens[index].used = true;
    }
  }

  /// Returns true for am, false for pm, null when token [index] is neither.
  bool? _meridiemAt(List<_Token> tokens, int index) {
    if (index >= tokens.length || tokens[index].used) return null;
    final token = tokens[index].norm;
    if (enMeridiemAm.contains(token)) return true;
    if (enMeridiemPm.contains(token)) return false;
    return null;
  }

  /// Like [_meridiemAt], but also takes the word out of the sentence.
  bool? _useMeridiemAfter(List<_Token> tokens, int index) {
    final meridiem = _meridiemAt(tokens, index);
    if (meridiem != null) tokens[index].used = true;
    return meridiem;
  }

  /// Returns true for a morning word, false for an evening one, null for
  /// anything else.
  bool? _dayPartOf(String token) {
    final english = enDayPartIsAm[token];
    if (english != null) return english;
    for (final entry in mlDayPartIsAm.entries) {
      if (_hasStem(token, entry.key)) return entry.value;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Pass 3 — which day
  // ---------------------------------------------------------------------

  /// Reads the day the task is for, as an offset in days from today.
  int? _readDate(List<_Token> tokens, DateTime today) {
    // Phrases first: `the day after tomorrow` must beat `tomorrow`.
    final phrase = _matchPhrase(tokens, enRelativeDayPhrases);
    if (phrase != null) {
      _use(tokens, phrase.start, phrase.end);
      _useLeadIn(tokens, phrase.start, enDateLeadIns);
      return phrase.value;
    }

    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i].used) continue;
      final token = tokens[i].norm;

      final relative = enRelativeDays[token];
      if (relative != null) {
        tokens[i].used = true;
        return relative;
      }

      final mlRelative = _longestStem(mlRelativeDayStems, token);
      if (mlRelative != null) {
        tokens[i].used = true;
        return mlRelative.value;
      }

      // `അടുത്ത ആഴ്ച` (next week) and `അടുത്ത തിങ്കളാഴ്ച` (next Monday).
      if (_hasStem(token, mlNextStem) && i + 1 < tokens.length) {
        final following = tokens[i + 1].norm;
        if (_hasStem(following, mlWeekStem)) {
          _use(tokens, i, i + 1);
          return 7;
        }
        final weekday = _longestStem(mlWeekdayStems, following);
        if (weekday != null) {
          _use(tokens, i, i + 1);
          return _daysUntilWeekday(today, weekday.value);
        }
      }

      // `in 3 days`, `in 2 weeks`, `മൂന്ന് ദിവസം`.
      final number = _readNumber(tokens, i);
      if (number != null) {
        final unitIndex = i + number.length;
        if (unitIndex < tokens.length && !tokens[unitIndex].used) {
          final unit = tokens[unitIndex].norm;
          if (enDayUnits.contains(unit) || _hasStem(unit, mlDayStem)) {
            _use(tokens, i, unitIndex);
            _useLeadIn(tokens, i, enDateLeadIns);
            return number.value;
          }
          if (enWeekUnits.contains(unit)) {
            _use(tokens, i, unitIndex);
            _useLeadIn(tokens, i, enDateLeadIns);
            return number.value * 7;
          }
        }
      }

      // `next Monday`, `on Friday`, `തിങ്കളാഴ്ച`.
      final english = enWeekdays[token];
      if (english != null) {
        tokens[i].used = true;
        _useLeadIn(tokens, i, enDateLeadIns);
        return _daysUntilWeekday(today, english);
      }
      final malayalam = _longestStem(mlWeekdayStems, token);
      if (malayalam != null) {
        tokens[i].used = true;
        return _daysUntilWeekday(today, malayalam.value);
      }
    }
    return null;
  }

  /// How many days ahead the next [weekday] falls.
  ///
  /// Always looks forward, never at today itself: said on a Monday, "Monday"
  /// means the Monday a week away. `next Monday` and a bare `Monday` follow the
  /// same rule, which keeps the answer easy to predict.
  int _daysUntilWeekday(DateTime today, int weekday) {
    final diff = (weekday - today.weekday) % 7;
    return diff == 0 ? 7 : diff;
  }

  // ---------------------------------------------------------------------
  // Pass 4 — how important
  // ---------------------------------------------------------------------

  VoicePriority? _readPriority(List<_Token> tokens) {
    for (final entry in enPriorityPhrases.entries) {
      final parts = entry.key.split(' ');
      for (var i = 0; i + parts.length <= tokens.length; i++) {
        var hit = true;
        for (var j = 0; j < parts.length; j++) {
          if (tokens[i + j].used || tokens[i + j].norm != parts[j]) {
            hit = false;
            break;
          }
        }
        if (hit) {
          _use(tokens, i, i + parts.length - 1);
          return entry.value;
        }
      }
    }

    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i].used) continue;
      final english = enPriorityWords[tokens[i].norm];
      if (english != null) {
        tokens[i].used = true;
        return english;
      }
      for (final entry in mlPriorityStems.entries) {
        if (_hasStem(tokens[i].norm, entry.key)) {
          tokens[i].used = true;
          return entry.value;
        }
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Building the title
  // ---------------------------------------------------------------------

  /// Joins whatever words were not understood back into a title.
  ///
  /// Small joining words are trimmed from the two ends only. Trimming them
  /// everywhere would turn `Call the bank` into `Call bank`.
  String _buildTitle(List<_Token> tokens) {
    final words = tokens.where((t) => !t.used).map((t) => t.raw).toList();

    while (words.isNotEmpty && _isEdgeFiller(words.first)) {
      words.removeAt(0);
    }
    while (words.isNotEmpty && _isEdgeFiller(words.last)) {
      words.removeLast();
    }
    if (words.isEmpty) return '';

    final joined = words.join(' ').trim();
    final cleaned = joined.replaceAll(RegExp(r'^[\s,.;:!?-]+|[\s,;:-]+$'), '');
    return unicode_utils.nfcNormalize(cleaned.trim());
  }

  bool _isEdgeFiller(String word) {
    final norm = _Token(word).norm;
    if (norm.isEmpty) return true;
    if (enTitleEdgeFillers.contains(norm)) return true;
    return mlTitleEdgeFillers.any((filler) => norm == filler);
  }

  // ---------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------

  /// Reads a number starting at token [i], in digits or in words.
  ///
  /// Handles `45`, `forty five`, `forty-five`, and the Malayalam stems.
  _NumberMatch? _readNumber(List<_Token> tokens, int i) {
    if (i >= tokens.length || tokens[i].used) return null;
    final token = tokens[i].norm;

    if (RegExp(r'^\d{1,4}$').hasMatch(token)) {
      return _NumberMatch(int.parse(token), 1);
    }

    // `forty-five` arrives as one token from a keyboard, two from a recogniser.
    if (token.contains('-')) {
      final parts = token.split('-');
      if (parts.length == 2) {
        final tens = enNumberWords[parts[0]];
        final units = enNumberWords[parts[1]];
        if (tens != null &&
            units != null &&
            enTensWords.contains(parts[0]) &&
            units < 10) {
          return _NumberMatch(tens + units, 1);
        }
      }
    }

    final english = enNumberWords[token];
    if (english != null) {
      if (enTensWords.contains(token) && i + 1 < tokens.length) {
        final units = enNumberWords[tokens[i + 1].norm];
        if (units != null && units > 0 && units < 10) {
          return _NumberMatch(english + units, 2);
        }
      }
      return _NumberMatch(english, 1);
    }

    final malayalam = _longestStem(mlNumberStems, token);
    if (malayalam != null) return _NumberMatch(malayalam.value, 1);

    return null;
  }

  /// Finds the longest stem in [entries] that starts [token].
  MlStemValue? _longestStem(List<MlStemValue> entries, String token) {
    MlStemValue? best;
    for (final entry in entries) {
      if (!token.startsWith(entry.stem)) continue;
      if (best == null || entry.stem.length > best.stem.length) best = entry;
    }
    return best;
  }

  List<MlStemValue> _byLongestStem(List<MlStemValue> entries) {
    final sorted = List<MlStemValue>.from(entries)
      ..sort((a, b) => b.stem.length.compareTo(a.stem.length));
    return sorted;
  }

  bool _hasStem(String token, String stem) => token.startsWith(stem);

  /// Drops the vowel signs and viramas that a Malayalam case ending leaves in
  /// front of the next word part, so `ുമണി` becomes `മണി`.
  String _dropLeadingSigns(String text) {
    var index = 0;
    while (index < text.length && index < 3) {
      final code = text.codeUnitAt(index);
      final isSign = (code >= 0x0D3E && code <= 0x0D4D) || code == 0x0D57;
      if (!isSign) break;
      index++;
    }
    return text.substring(index);
  }

  /// Marks tokens [from] to [to] inclusive as understood.
  void _use(List<_Token> tokens, int from, int to) {
    for (var i = from; i <= to && i < tokens.length; i++) {
      if (i >= 0) tokens[i].used = true;
    }
  }

  /// Takes out the little word in front of a match, like the `for` in
  /// `for 30 minutes`, so it never lands in the title.
  void _useLeadIn(List<_Token> tokens, int matchStart, Set<String> leadIns) {
    final index = matchStart - 1;
    if (index < 0 || tokens[index].used) return;
    if (leadIns.contains(tokens[index].norm)) tokens[index].used = true;
  }

  /// Finds the longest phrase from [phrases] sitting in the sentence.
  _PhraseMatch? _matchPhrase(List<_Token> tokens, Map<String, int> phrases) {
    final keys = phrases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final key in keys) {
      final parts = key.split(' ');
      for (var i = 0; i + parts.length <= tokens.length; i++) {
        var hit = true;
        for (var j = 0; j < parts.length; j++) {
          if (tokens[i + j].used || tokens[i + j].norm != parts[j]) {
            hit = false;
            break;
          }
        }
        if (hit) {
          return _PhraseMatch(i, i + parts.length - 1, phrases[key]!);
        }
      }
    }
    return null;
  }

  String _isoDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }
}

/// One word of the sentence, with a tidied copy for looking things up.
class _Token {
  _Token(this.raw) : norm = _normalize(raw);

  /// The word exactly as the user said or typed it, kept for the title.
  final String raw;

  /// Lower case, with the punctuation trimmed off both ends.
  final String norm;

  /// True once a pass has claimed this word, so it stays out of the title.
  bool used = false;

  static String _normalize(String raw) {
    final lower = raw.toLowerCase();
    // The dot is trimmed from both ends, so `tomorrow.` still matches. A dot
    // inside a word is left alone, which keeps `10.30` readable as a time; a
    // trailing dot is not needed by `a.m.` either, since `a.m` is listed too.
    return lower.replaceAll(
      RegExp(r'''^[\s,.;:!?()"'’“”]+|[\s,.;:!?()"'’“”]+$'''),
      '',
    );
  }
}

class _NumberMatch {
  const _NumberMatch(this.value, this.length);

  final int value;

  /// How many tokens the number took up.
  final int length;
}

class _TimeOfDay {
  const _TimeOfDay(this.hour, this.minute);

  final int hour;
  final int minute;
}

class _TimeMatch {
  const _TimeMatch(this.startIndex, this.hour, this.minute, this.meridiemIsAm);

  final int startIndex;
  final int hour;
  final int minute;

  /// True for am, false for pm, null when the sentence did not say.
  final bool? meridiemIsAm;
}

class _PhraseMatch {
  const _PhraseMatch(this.start, this.end, this.value);

  final int start;
  final int end;
  final int value;
}
