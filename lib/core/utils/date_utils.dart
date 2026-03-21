import 'package:intl/intl.dart';

final _isoFormat = DateFormat('yyyy-MM-dd');
final _displayFormat = DateFormat.yMMMEd();

String todayAsIso() => _isoFormat.format(DateTime.now());

bool isToday(String date) => date == todayAsIso();

bool isPastDate(String date) => date.compareTo(todayAsIso()) < 0;

bool isFutureDate(String date) => date.compareTo(todayAsIso()) > 0;

String formatDate(DateTime d) => _displayFormat.format(d);

String dateTimeToIso(DateTime d) => _isoFormat.format(d);

DateTime parseIsoDate(String date) => _isoFormat.parseStrict(date);

String formatDateFromIso(String isoDate) =>
    _displayFormat.format(parseIsoDate(isoDate));
