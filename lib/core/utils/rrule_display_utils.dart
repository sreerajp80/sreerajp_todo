/// Converts an RRULE string (without `RRULE:` prefix) to a human-readable
/// description. Handles common patterns; falls back to the raw string for
/// unsupported combinations.
String describeRrule(String rruleString) {
  final parts = _parseParts(rruleString);
  final freq = parts['FREQ'];
  if (freq == null) return rruleString;

  final interval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;
  final byDay = parts['BYDAY'];
  final byMonthDay = parts['BYMONTHDAY'];
  final byMonth = parts['BYMONTH'];

  return switch (freq) {
    'DAILY' => _describeDaily(interval),
    'WEEKLY' => _describeWeekly(interval, byDay),
    'MONTHLY' => _describeMonthly(interval, byDay, byMonthDay),
    'YEARLY' => _describeYearly(interval, byMonth, byMonthDay),
    _ => rruleString,
  };
}

Map<String, String> _parseParts(String rrule) {
  final result = <String, String>{};
  for (final part in rrule.split(';')) {
    final idx = part.indexOf('=');
    if (idx > 0) {
      result[part.substring(0, idx)] = part.substring(idx + 1);
    }
  }
  return result;
}

String _describeDaily(int interval) {
  if (interval == 1) return 'Daily';
  return 'Every $interval days';
}

String _describeWeekly(int interval, String? byDay) {
  if (byDay == null) {
    if (interval == 1) return 'Weekly';
    return 'Every $interval weeks';
  }

  final days = byDay.split(',');
  final weekdaySet = {'MO', 'TU', 'WE', 'TH', 'FR'};
  if (days.toSet().containsAll(weekdaySet) && days.length == 5) {
    return 'Every weekday';
  }

  final weekendSet = {'SA', 'SU'};
  if (days.toSet().containsAll(weekendSet) && days.length == 2) {
    return 'Every weekend';
  }

  final dayNames = days.map(_dayAbbrevToFull).toList();
  final joined = _joinWithAnd(dayNames);

  if (interval == 1) return 'Every $joined';
  return 'Every $interval weeks on $joined';
}

String _describeMonthly(int interval, String? byDay, String? byMonthDay) {
  final prefix = interval == 1 ? 'Monthly' : 'Every $interval months';

  if (byDay != null) {
    final match = RegExp(r'^([+-]?\d+)(\w{2})$').firstMatch(byDay);
    if (match != null) {
      final ordinal = int.tryParse(match.group(1)!) ?? 1;
      final day = match.group(2)!;
      return '$prefix on the ${_ordinal(ordinal)} ${_dayAbbrevToFull(day)}';
    }
  }

  if (byMonthDay != null) {
    return '$prefix on day $byMonthDay';
  }

  return prefix;
}

String _describeYearly(
  int interval,
  String? byMonth,
  String? byMonthDay,
) {
  final prefix = interval == 1 ? 'Annually' : 'Every $interval years';

  if (byMonth != null && byMonthDay != null) {
    final monthNum = int.tryParse(byMonth);
    if (monthNum != null) {
      return '$prefix on ${_monthName(monthNum)} $byMonthDay';
    }
  }

  if (byMonth != null) {
    final monthNum = int.tryParse(byMonth);
    if (monthNum != null) {
      return '$prefix in ${_monthName(monthNum)}';
    }
  }

  return prefix;
}

String _ordinal(int n) {
  if (n == -1) return 'last';
  if (n == -2) return '2nd-to-last';
  return switch (n) {
    1 => '1st',
    2 => '2nd',
    3 => '3rd',
    4 => '4th',
    5 => '5th',
    _ => '${n}th',
  };
}

String _dayAbbrevToFull(String abbrev) {
  return switch (abbrev.toUpperCase()) {
    'MO' => 'Monday',
    'TU' => 'Tuesday',
    'WE' => 'Wednesday',
    'TH' => 'Thursday',
    'FR' => 'Friday',
    'SA' => 'Saturday',
    'SU' => 'Sunday',
    _ => abbrev,
  };
}

String _monthName(int month) {
  const names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  if (month >= 1 && month <= 12) return names[month - 1];
  return 'Month $month';
}

String _joinWithAnd(List<String> items) {
  if (items.isEmpty) return '';
  if (items.length == 1) return items.first;
  if (items.length == 2) return '${items[0]} and ${items[1]}';
  return '${items.sublist(0, items.length - 1).join(', ')} and ${items.last}';
}
