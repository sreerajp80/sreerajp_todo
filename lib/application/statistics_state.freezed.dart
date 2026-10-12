// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StatisticsState {

 List<DayStats> get dailyStats; int get dailyCurrentPage; int get dailyTotalPages; DateRange get dateRange; DateTime? get customStartDate; DateTime? get customEndDate; SummaryStats get summaryStats; List<TodoTimeStats> get perItemStats; int get perItemCurrentPage; int get perItemTotalPages; String get searchQuery; String? get selectedTitle; List<TitleTimePoint> get selectedTitleHistory; bool get isLoading; String? get error;
/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatisticsStateCopyWith<StatisticsState> get copyWith => _$StatisticsStateCopyWithImpl<StatisticsState>(this as StatisticsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StatisticsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatisticsState&&const DeepCollectionEquality().equals(other.dailyStats, _this.dailyStats)&&(identical(other.dailyCurrentPage, _this.dailyCurrentPage) || other.dailyCurrentPage == _this.dailyCurrentPage)&&(identical(other.dailyTotalPages, _this.dailyTotalPages) || other.dailyTotalPages == _this.dailyTotalPages)&&(identical(other.dateRange, _this.dateRange) || other.dateRange == _this.dateRange)&&(identical(other.customStartDate, _this.customStartDate) || other.customStartDate == _this.customStartDate)&&(identical(other.customEndDate, _this.customEndDate) || other.customEndDate == _this.customEndDate)&&(identical(other.summaryStats, _this.summaryStats) || other.summaryStats == _this.summaryStats)&&const DeepCollectionEquality().equals(other.perItemStats, _this.perItemStats)&&(identical(other.perItemCurrentPage, _this.perItemCurrentPage) || other.perItemCurrentPage == _this.perItemCurrentPage)&&(identical(other.perItemTotalPages, _this.perItemTotalPages) || other.perItemTotalPages == _this.perItemTotalPages)&&(identical(other.searchQuery, _this.searchQuery) || other.searchQuery == _this.searchQuery)&&(identical(other.selectedTitle, _this.selectedTitle) || other.selectedTitle == _this.selectedTitle)&&const DeepCollectionEquality().equals(other.selectedTitleHistory, _this.selectedTitleHistory)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as StatisticsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.dailyStats),_this.dailyCurrentPage,_this.dailyTotalPages,_this.dateRange,_this.customStartDate,_this.customEndDate,_this.summaryStats,const DeepCollectionEquality().hash(_this.perItemStats),_this.perItemCurrentPage,_this.perItemTotalPages,_this.searchQuery,_this.selectedTitle,const DeepCollectionEquality().hash(_this.selectedTitleHistory),_this.isLoading,_this.error);
}

@override
String toString() {
  final _this = this as StatisticsState;
  return 'StatisticsState(dailyStats: ${_this.dailyStats}, dailyCurrentPage: ${_this.dailyCurrentPage}, dailyTotalPages: ${_this.dailyTotalPages}, dateRange: ${_this.dateRange}, customStartDate: ${_this.customStartDate}, customEndDate: ${_this.customEndDate}, summaryStats: ${_this.summaryStats}, perItemStats: ${_this.perItemStats}, perItemCurrentPage: ${_this.perItemCurrentPage}, perItemTotalPages: ${_this.perItemTotalPages}, searchQuery: ${_this.searchQuery}, selectedTitle: ${_this.selectedTitle}, selectedTitleHistory: ${_this.selectedTitleHistory}, isLoading: ${_this.isLoading}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $StatisticsStateCopyWith<$Res>  {
  factory $StatisticsStateCopyWith(StatisticsState value, $Res Function(StatisticsState) _then) = _$StatisticsStateCopyWithImpl;
@useResult
$Res call({
 List<DayStats> dailyStats, int dailyCurrentPage, int dailyTotalPages, DateRange dateRange, DateTime? customStartDate, DateTime? customEndDate, SummaryStats summaryStats, List<TodoTimeStats> perItemStats, int perItemCurrentPage, int perItemTotalPages, String searchQuery, String? selectedTitle, List<TitleTimePoint> selectedTitleHistory, bool isLoading, String? error
});


$SummaryStatsCopyWith<$Res> get summaryStats;

}
/// @nodoc
class _$StatisticsStateCopyWithImpl<$Res>
    implements $StatisticsStateCopyWith<$Res> {
  _$StatisticsStateCopyWithImpl(this._self, this._then);

  final StatisticsState _self;
  final $Res Function(StatisticsState) _then;

/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dailyStats = null,Object? dailyCurrentPage = null,Object? dailyTotalPages = null,Object? dateRange = null,Object? customStartDate = freezed,Object? customEndDate = freezed,Object? summaryStats = null,Object? perItemStats = null,Object? perItemCurrentPage = null,Object? perItemTotalPages = null,Object? searchQuery = null,Object? selectedTitle = freezed,Object? selectedTitleHistory = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(StatisticsState(
dailyStats: null == dailyStats ? _self.dailyStats : dailyStats // ignore: cast_nullable_to_non_nullable
as List<DayStats>,dailyCurrentPage: null == dailyCurrentPage ? _self.dailyCurrentPage : dailyCurrentPage // ignore: cast_nullable_to_non_nullable
as int,dailyTotalPages: null == dailyTotalPages ? _self.dailyTotalPages : dailyTotalPages // ignore: cast_nullable_to_non_nullable
as int,dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateRange,customStartDate: freezed == customStartDate ? _self.customStartDate : customStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,customEndDate: freezed == customEndDate ? _self.customEndDate : customEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,summaryStats: null == summaryStats ? _self.summaryStats : summaryStats // ignore: cast_nullable_to_non_nullable
as SummaryStats,perItemStats: null == perItemStats ? _self.perItemStats : perItemStats // ignore: cast_nullable_to_non_nullable
as List<TodoTimeStats>,perItemCurrentPage: null == perItemCurrentPage ? _self.perItemCurrentPage : perItemCurrentPage // ignore: cast_nullable_to_non_nullable
as int,perItemTotalPages: null == perItemTotalPages ? _self.perItemTotalPages : perItemTotalPages // ignore: cast_nullable_to_non_nullable
as int,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedTitle: freezed == selectedTitle ? _self.selectedTitle : selectedTitle // ignore: cast_nullable_to_non_nullable
as String?,selectedTitleHistory: null == selectedTitleHistory ? _self.selectedTitleHistory : selectedTitleHistory // ignore: cast_nullable_to_non_nullable
as List<TitleTimePoint>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryStatsCopyWith<$Res> get summaryStats {
  
  return $SummaryStatsCopyWith<$Res>(_self.summaryStats, (value) {
    return _then(_self.copyWith(summaryStats: value));
  });
}
}


/// Adds pattern-matching-related methods to [StatisticsState].
extension StatisticsStatePatterns on StatisticsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatisticsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatisticsState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatisticsState value)  $default,){
final _that = this;
switch (_that) {
case _StatisticsState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatisticsState value)?  $default,){
final _that = this;
switch (_that) {
case _StatisticsState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DayStats> dailyStats,  int dailyCurrentPage,  int dailyTotalPages,  DateRange dateRange,  DateTime? customStartDate,  DateTime? customEndDate,  SummaryStats summaryStats,  List<TodoTimeStats> perItemStats,  int perItemCurrentPage,  int perItemTotalPages,  String searchQuery,  String? selectedTitle,  List<TitleTimePoint> selectedTitleHistory,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatisticsState() when $default != null:
return $default(_that.dailyStats,_that.dailyCurrentPage,_that.dailyTotalPages,_that.dateRange,_that.customStartDate,_that.customEndDate,_that.summaryStats,_that.perItemStats,_that.perItemCurrentPage,_that.perItemTotalPages,_that.searchQuery,_that.selectedTitle,_that.selectedTitleHistory,_that.isLoading,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DayStats> dailyStats,  int dailyCurrentPage,  int dailyTotalPages,  DateRange dateRange,  DateTime? customStartDate,  DateTime? customEndDate,  SummaryStats summaryStats,  List<TodoTimeStats> perItemStats,  int perItemCurrentPage,  int perItemTotalPages,  String searchQuery,  String? selectedTitle,  List<TitleTimePoint> selectedTitleHistory,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _StatisticsState():
return $default(_that.dailyStats,_that.dailyCurrentPage,_that.dailyTotalPages,_that.dateRange,_that.customStartDate,_that.customEndDate,_that.summaryStats,_that.perItemStats,_that.perItemCurrentPage,_that.perItemTotalPages,_that.searchQuery,_that.selectedTitle,_that.selectedTitleHistory,_that.isLoading,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DayStats> dailyStats,  int dailyCurrentPage,  int dailyTotalPages,  DateRange dateRange,  DateTime? customStartDate,  DateTime? customEndDate,  SummaryStats summaryStats,  List<TodoTimeStats> perItemStats,  int perItemCurrentPage,  int perItemTotalPages,  String searchQuery,  String? selectedTitle,  List<TitleTimePoint> selectedTitleHistory,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _StatisticsState() when $default != null:
return $default(_that.dailyStats,_that.dailyCurrentPage,_that.dailyTotalPages,_that.dateRange,_that.customStartDate,_that.customEndDate,_that.summaryStats,_that.perItemStats,_that.perItemCurrentPage,_that.perItemTotalPages,_that.searchQuery,_that.selectedTitle,_that.selectedTitleHistory,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _StatisticsState implements StatisticsState {
  const _StatisticsState({ List<DayStats> dailyStats = const [], this.dailyCurrentPage = 0, this.dailyTotalPages = 0, this.dateRange = DateRange.last7Days, this.customStartDate, this.customEndDate, this.summaryStats = const SummaryStats(),  List<TodoTimeStats> perItemStats = const [], this.perItemCurrentPage = 0, this.perItemTotalPages = 0, this.searchQuery = '', this.selectedTitle,  List<TitleTimePoint> selectedTitleHistory = const [], this.isLoading = false, this.error}): _dailyStats = dailyStats,_perItemStats = perItemStats,_selectedTitleHistory = selectedTitleHistory;
  

 final  List<DayStats> _dailyStats;
@override@JsonKey() List<DayStats> get dailyStats {
  if (_dailyStats is EqualUnmodifiableListView) return _dailyStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dailyStats);
}

@override@JsonKey() final  int dailyCurrentPage;
@override@JsonKey() final  int dailyTotalPages;
@override@JsonKey() final  DateRange dateRange;
@override final  DateTime? customStartDate;
@override final  DateTime? customEndDate;
@override@JsonKey() final  SummaryStats summaryStats;
 final  List<TodoTimeStats> _perItemStats;
@override@JsonKey() List<TodoTimeStats> get perItemStats {
  if (_perItemStats is EqualUnmodifiableListView) return _perItemStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_perItemStats);
}

@override@JsonKey() final  int perItemCurrentPage;
@override@JsonKey() final  int perItemTotalPages;
@override@JsonKey() final  String searchQuery;
@override final  String? selectedTitle;
 final  List<TitleTimePoint> _selectedTitleHistory;
@override@JsonKey() List<TitleTimePoint> get selectedTitleHistory {
  if (_selectedTitleHistory is EqualUnmodifiableListView) return _selectedTitleHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedTitleHistory);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatisticsStateCopyWith<_StatisticsState> get copyWith => __$StatisticsStateCopyWithImpl<_StatisticsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatisticsState&&const DeepCollectionEquality().equals(other.dailyStats, _dailyStats)&&(identical(other.dailyCurrentPage, dailyCurrentPage) || other.dailyCurrentPage == dailyCurrentPage)&&(identical(other.dailyTotalPages, dailyTotalPages) || other.dailyTotalPages == dailyTotalPages)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.customStartDate, customStartDate) || other.customStartDate == customStartDate)&&(identical(other.customEndDate, customEndDate) || other.customEndDate == customEndDate)&&(identical(other.summaryStats, summaryStats) || other.summaryStats == summaryStats)&&const DeepCollectionEquality().equals(other.perItemStats, _perItemStats)&&(identical(other.perItemCurrentPage, perItemCurrentPage) || other.perItemCurrentPage == perItemCurrentPage)&&(identical(other.perItemTotalPages, perItemTotalPages) || other.perItemTotalPages == perItemTotalPages)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedTitle, selectedTitle) || other.selectedTitle == selectedTitle)&&const DeepCollectionEquality().equals(other.selectedTitleHistory, _selectedTitleHistory)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_dailyStats),dailyCurrentPage,dailyTotalPages,dateRange,customStartDate,customEndDate,summaryStats,const DeepCollectionEquality().hash(_perItemStats),perItemCurrentPage,perItemTotalPages,searchQuery,selectedTitle,const DeepCollectionEquality().hash(_selectedTitleHistory),isLoading,error);
}

@override
String toString() {
    return 'StatisticsState(dailyStats: $dailyStats, dailyCurrentPage: $dailyCurrentPage, dailyTotalPages: $dailyTotalPages, dateRange: $dateRange, customStartDate: $customStartDate, customEndDate: $customEndDate, summaryStats: $summaryStats, perItemStats: $perItemStats, perItemCurrentPage: $perItemCurrentPage, perItemTotalPages: $perItemTotalPages, searchQuery: $searchQuery, selectedTitle: $selectedTitle, selectedTitleHistory: $selectedTitleHistory, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$StatisticsStateCopyWith<$Res> implements $StatisticsStateCopyWith<$Res> {
  factory _$StatisticsStateCopyWith(_StatisticsState value, $Res Function(_StatisticsState) _then) = __$StatisticsStateCopyWithImpl;
@override @useResult
$Res call({
 List<DayStats> dailyStats, int dailyCurrentPage, int dailyTotalPages, DateRange dateRange, DateTime? customStartDate, DateTime? customEndDate, SummaryStats summaryStats, List<TodoTimeStats> perItemStats, int perItemCurrentPage, int perItemTotalPages, String searchQuery, String? selectedTitle, List<TitleTimePoint> selectedTitleHistory, bool isLoading, String? error
});


@override $SummaryStatsCopyWith<$Res> get summaryStats;

}
/// @nodoc
class __$StatisticsStateCopyWithImpl<$Res>
    implements _$StatisticsStateCopyWith<$Res> {
  __$StatisticsStateCopyWithImpl(this._self, this._then);

  final _StatisticsState _self;
  final $Res Function(_StatisticsState) _then;

/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dailyStats = null,Object? dailyCurrentPage = null,Object? dailyTotalPages = null,Object? dateRange = null,Object? customStartDate = freezed,Object? customEndDate = freezed,Object? summaryStats = null,Object? perItemStats = null,Object? perItemCurrentPage = null,Object? perItemTotalPages = null,Object? searchQuery = null,Object? selectedTitle = freezed,Object? selectedTitleHistory = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_StatisticsState(
dailyStats: null == dailyStats ? _self._dailyStats : dailyStats // ignore: cast_nullable_to_non_nullable
as List<DayStats>,dailyCurrentPage: null == dailyCurrentPage ? _self.dailyCurrentPage : dailyCurrentPage // ignore: cast_nullable_to_non_nullable
as int,dailyTotalPages: null == dailyTotalPages ? _self.dailyTotalPages : dailyTotalPages // ignore: cast_nullable_to_non_nullable
as int,dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateRange,customStartDate: freezed == customStartDate ? _self.customStartDate : customStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,customEndDate: freezed == customEndDate ? _self.customEndDate : customEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,summaryStats: null == summaryStats ? _self.summaryStats : summaryStats // ignore: cast_nullable_to_non_nullable
as SummaryStats,perItemStats: null == perItemStats ? _self._perItemStats : perItemStats // ignore: cast_nullable_to_non_nullable
as List<TodoTimeStats>,perItemCurrentPage: null == perItemCurrentPage ? _self.perItemCurrentPage : perItemCurrentPage // ignore: cast_nullable_to_non_nullable
as int,perItemTotalPages: null == perItemTotalPages ? _self.perItemTotalPages : perItemTotalPages // ignore: cast_nullable_to_non_nullable
as int,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedTitle: freezed == selectedTitle ? _self.selectedTitle : selectedTitle // ignore: cast_nullable_to_non_nullable
as String?,selectedTitleHistory: null == selectedTitleHistory ? _self._selectedTitleHistory : selectedTitleHistory // ignore: cast_nullable_to_non_nullable
as List<TitleTimePoint>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of StatisticsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryStatsCopyWith<$Res> get summaryStats {
  
  return $SummaryStatsCopyWith<$Res>(_self.summaryStats, (value) {
    return _then(_self.copyWith(summaryStats: value));
  });
}
}

// dart format on
