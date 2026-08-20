/// Word lists for the English (`en-IN`) side of the voice parser.
///
/// Every English word the parser knows lives here, so the parser file itself
/// holds only rules and no vocabulary. Keys are already lower case; the parser
/// lower-cases each token before looking it up.
library;

import 'package:sreerajp_todo/core/voice/voice_parse_result.dart';

/// Weekday names and their common short forms, mapped to `DateTime.monday`
/// style numbers (Monday = 1 ... Sunday = 7).
const Map<String, int> enWeekdays = <String, int>{
  'monday': DateTime.monday,
  'mon': DateTime.monday,
  'tuesday': DateTime.tuesday,
  'tue': DateTime.tuesday,
  'tues': DateTime.tuesday,
  'wednesday': DateTime.wednesday,
  'wed': DateTime.wednesday,
  'weds': DateTime.wednesday,
  'thursday': DateTime.thursday,
  'thu': DateTime.thursday,
  'thur': DateTime.thursday,
  'thurs': DateTime.thursday,
  'friday': DateTime.friday,
  'fri': DateTime.friday,
  'saturday': DateTime.saturday,
  'sat': DateTime.saturday,
  'sunday': DateTime.sunday,
  'sun': DateTime.sunday,
};

/// Single words that name a day relative to today, as a day offset.
const Map<String, int> enRelativeDays = <String, int>{
  'today': 0,
  'tonight': 0,
  'tomorrow': 1,
  'tmrw': 1,
  'tmr': 1,
  'overmorrow': 2,
};

/// Phrases that name a day relative to today, as a day offset.
///
/// Each key is a run of whitespace-separated tokens. The parser tries the
/// longest phrase first, so `the day after tomorrow` wins over `tomorrow`.
const Map<String, int> enRelativeDayPhrases = <String, int>{
  'the day after tomorrow': 2,
  'day after tomorrow': 2,
  'next week': 7,
  'next fortnight': 14,
};

/// Spelled-out numbers. Tens and units are combined by the parser, so
/// `twenty five` is read as 25 without needing its own entry.
const Map<String, int> enNumberWords = <String, int>{
  'zero': 0,
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'six': 6,
  'seven': 7,
  'eight': 8,
  'nine': 9,
  'ten': 10,
  'eleven': 11,
  'twelve': 12,
  'thirteen': 13,
  'fourteen': 14,
  'fifteen': 15,
  'sixteen': 16,
  'seventeen': 17,
  'eighteen': 18,
  'nineteen': 19,
  'twenty': 20,
  'thirty': 30,
  'forty': 40,
  'fourty': 40,
  'fifty': 50,
  'sixty': 60,
};

/// Numbers that can take a unit word after them, used to build `twenty five`.
const Set<String> enTensWords = <String>{
  'twenty',
  'thirty',
  'forty',
  'fourty',
  'fifty',
};

/// Words that mean "minutes" after a number.
const Set<String> enMinuteUnits = <String>{'minute', 'minutes', 'min', 'mins'};

/// Words that mean "hours" after a number.
const Set<String> enHourUnits = <String>{'hour', 'hours', 'hr', 'hrs'};

/// Words that mean "days" after a number, used by `in 3 days`.
const Set<String> enDayUnits = <String>{'day', 'days'};

/// Words that mean "weeks" after a number, used by `in 2 weeks`.
const Set<String> enWeekUnits = <String>{'week', 'weeks'};

/// Ways of saying "before noon".
const Set<String> enMeridiemAm = <String>{'am', 'a.m', 'a.m.', 'a m'};

/// Ways of saying "after noon".
const Set<String> enMeridiemPm = <String>{'pm', 'p.m', 'p.m.', 'p m'};

/// Words that follow an hour to mean a whole hour.
const Set<String> enOClock = <String>{"o'clock", 'oclock', 'clock'};

/// Parts of the day that decide between morning and evening when the sentence
/// gave an hour without `am` or `pm`.
const Map<String, bool> enDayPartIsAm = <String, bool>{
  'morning': true,
  'afternoon': false,
  'noon': false,
  'evening': false,
  'night': false,
};

/// Single words that set a priority on their own.
const Map<String, VoicePriority> enPriorityWords = <String, VoicePriority>{
  'urgent': VoicePriority.urgent,
  'urgently': VoicePriority.urgent,
  'asap': VoicePriority.urgent,
  'critical': VoicePriority.urgent,
  'important': VoicePriority.high,
};

/// Two-word priority phrases, tried before the single words above.
const Map<String, VoicePriority> enPriorityPhrases = <String, VoicePriority>{
  'top priority': VoicePriority.urgent,
  'high priority': VoicePriority.high,
  'low priority': VoicePriority.low,
  'no rush': VoicePriority.low,
};

/// Prepositions that introduce a time, taken out with the time they lead.
const Set<String> enTimeLeadIns = <String>{'at', 'by', 'around', 'about'};

/// Prepositions that introduce a duration, taken out with it.
const Set<String> enDurationLeadIns = <String>{'for', 'takes', 'take'};

/// Prepositions that introduce a date, taken out with it.
const Set<String> enDateLeadIns = <String>{
  'on',
  'this',
  'coming',
  'in',
  'next',
};

/// Small words trimmed from the two ends of the finished title only.
///
/// They are never removed from the middle, or `Call the bank` would lose its
/// `the`.
const Set<String> enTitleEdgeFillers = <String>{
  'at',
  'on',
  'for',
  'in',
  'the',
  'a',
  'an',
  'to',
  'of',
  'and',
  'by',
  'around',
  'about',
  'this',
  'next',
  'then',
  'please',
};

/// Opening phrases people say to a voice box that carry no meaning for the
/// task, stripped from the start of the sentence before anything else.
const List<String> enCommandPrefixes = <String>[
  'remind me to',
  'remind me',
  'please add a task to',
  'please add a task',
  'add a new task to',
  'add a new task',
  'add a task to',
  'add a task',
  'create a task to',
  'create a task',
  'new task',
  'add todo',
  'add to do',
  'i need to',
  'i have to',
];
