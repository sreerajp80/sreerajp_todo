/// Word lists for the Malayalam (`ml-IN`) side of the voice parser.
///
/// Malayalam glues its case endings onto the word, so `ഏഴര` ("half past
/// seven") turns up as `ഏഴരയ്ക്ക്` in a real sentence. Matching whole words
/// would therefore miss almost everything. Every entry below is a **stem**: the
/// part of the word that does not change. The parser matches a stem against the
/// start of a token and then swallows the whole token, ending and all.
///
/// Stems are written without the final chandrakkala where one exists, so
/// `പത്ത്`, `പത്തു` and `പത്തിന്` are all caught by the stem `പത്ത`.
///
/// Where one stem is the start of another (`പത്ത` = 10 begins `പത്തൊൻപത` =
/// 19), the parser always tries the longest stem first, so the longer word
/// wins. That is why these are ordered lists and not maps.
library;

import 'package:sreerajp_todo/core/voice/voice_parse_result.dart';

/// One stem and the number it stands for.
class MlStemValue {
  const MlStemValue(this.stem, this.value);

  /// The unchanging front part of the word.
  final String stem;

  /// What the word means as a number.
  final int value;
}

/// The Malayalam Unicode block, used to spot Malayalam tokens in a sentence
/// that mixes both languages.
const int kMalayalamBlockStart = 0x0D00;

/// The last code point of the Malayalam Unicode block.
const int kMalayalamBlockEnd = 0x0D7F;

/// Day names, as stems, mapped to `DateTime.monday` style numbers.
///
/// Each stem covers both the short name and the `-ആഴ്ച` form: `തിങ്ക` catches
/// both `തിങ്കൾ` and `തിങ്കളാഴ്ച`.
const List<MlStemValue> mlWeekdayStems = <MlStemValue>[
  MlStemValue('തിങ്ക', DateTime.monday),
  MlStemValue('ചൊവ്വ', DateTime.tuesday),
  MlStemValue('ബുധ', DateTime.wednesday),
  MlStemValue('വ്യാഴ', DateTime.thursday),
  MlStemValue('വെള്ളി', DateTime.friday),
  MlStemValue('ശനി', DateTime.saturday),
  MlStemValue('ഞായ', DateTime.sunday),
];

/// Words that name a day relative to today, as stems and day offsets.
const List<MlStemValue> mlRelativeDayStems = <MlStemValue>[
  MlStemValue('മറ്റന്ന', 2), // മറ്റന്നാൾ — the day after tomorrow
  MlStemValue('നാളെ', 1), // നാളെ — tomorrow
  MlStemValue('ഇന്ന', 0), // ഇന്ന് — today
];

/// "Next", as in `അടുത്ത തിങ്കളാഴ്ച` (next Monday).
const String mlNextStem = 'അടുത്ത';

/// "Week", so `അടുത്ത ആഴ്ച` reads as seven days from today.
const String mlWeekStem = 'ആഴ്ച';

/// "Day", so `മൂന്ന് ദിവസം` reads as three days.
const String mlDayStem = 'ദിവസ';

/// Spelled-out numbers, as stems.
///
/// Sixty is the highest that matters here: nothing above it is useful for an
/// hour, a minute count, or a day offset.
const List<MlStemValue> mlNumberStems = <MlStemValue>[
  MlStemValue('ഒരു', 1), // "a" / "one"
  MlStemValue('ഒന്ന', 1),
  MlStemValue('രണ്ട', 2),
  MlStemValue('മൂന്ന', 3),
  MlStemValue('നാല', 4),
  MlStemValue('അഞ്ച', 5),
  MlStemValue('ആറ', 6),
  MlStemValue('ഏഴ', 7),
  MlStemValue('എട്ട', 8),
  MlStemValue('ഒൻപത', 9),
  MlStemValue('ഒമ്പത', 9),
  MlStemValue('പത്ത', 10),
  MlStemValue('പതിനൊന്ന', 11),
  MlStemValue('പന്ത്രണ്ട', 12),
  MlStemValue('പതിമൂന്ന', 13),
  MlStemValue('പതിനാല', 14),
  MlStemValue('പതിനഞ്ച', 15),
  MlStemValue('പതിനാറ', 16),
  MlStemValue('പതിനേഴ', 17),
  MlStemValue('പതിനെട്ട', 18),
  MlStemValue('പത്തൊൻപത', 19),
  MlStemValue('പത്തൊമ്പത', 19),
  MlStemValue('ഇരുപത', 20),
  MlStemValue('ഇരുപത്തിയഞ്ച', 25),
  MlStemValue('ഇരുപത്തഞ്ച', 25),
  MlStemValue('മുപ്പത', 30),
  MlStemValue('നാൽപത', 40),
  MlStemValue('നാല്പത', 40),
  MlStemValue('നാൽപത്തിയഞ്ച', 45),
  MlStemValue('നാല്പത്തിയഞ്ച', 45),
  MlStemValue('അൻപത', 50),
  MlStemValue('അമ്പത', 50),
  MlStemValue('അറുപത', 60),
];

/// The half-past forms, as stems, with the hour they mean.
///
/// `ഏഴര` is half past seven. These are checked before [mlNumberStems] because
/// `ഒന്നര` (half past one) begins with `ഒന്ന` (one).
const List<MlStemValue> mlHalfHourStems = <MlStemValue>[
  MlStemValue('ഒന്നര', 1),
  MlStemValue('രണ്ടര', 2),
  MlStemValue('മൂന്നര', 3),
  MlStemValue('നാലര', 4),
  MlStemValue('അഞ്ചര', 5),
  MlStemValue('ആറര', 6),
  MlStemValue('ഏഴര', 7),
  MlStemValue('എട്ടര', 8),
  MlStemValue('ഒൻപതര', 9),
  MlStemValue('ഒമ്പതര', 9),
  MlStemValue('പത്തര', 10),
  MlStemValue('പതിനൊന്നര', 11),
  MlStemValue('പന്ത്രണ്ടര', 12),
];

/// "Hour" as a length of time: `രണ്ട് മണിക്കൂർ` is two hours long.
///
/// Checked before [mlClockStem], because `മണിക്കൂർ` starts with `മണി`.
const String mlHourUnitStem = 'മണിക്കൂ';

/// "Minute" as a length of time: `45 മിനിറ്റ്`.
const List<String> mlMinuteUnitStems = <String>['മിനിറ്റ', 'മിനുട്ട', 'നിമിഷ'];

/// The o'clock marker: `പത്തു മണിക്ക്` is at ten o'clock.
const String mlClockStem = 'മണി';

/// Parts of the day, deciding morning against evening when the sentence gave
/// an hour on its own. True means before noon.
const Map<String, bool> mlDayPartIsAm = <String, bool>{
  'രാവിലെ': true,
  'പുലർച്ചെ': true,
  'ഉച്ച': false,
  'വൈകുന്നേരം': false,
  'വൈകിട്ട': false,
  'രാത്രി': false,
};

/// Words that set a priority, as stems.
const Map<String, VoicePriority> mlPriorityStems = <String, VoicePriority>{
  'അടിയന്തിര': VoicePriority.urgent,
  'അത്യാവശ്യ': VoicePriority.urgent,
  'പ്രധാന': VoicePriority.high,
  'മുഖ്യ': VoicePriority.high,
};

/// Small words trimmed from the two ends of the finished title only.
const Set<String> mlTitleEdgeFillers = <String>{'ഒരു', 'എന്ന', 'ഈ'};
