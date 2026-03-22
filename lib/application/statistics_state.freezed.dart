// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StatisticsState {
  List<DayStats> get dailyStats => throw _privateConstructorUsedError;
  int get dailyCurrentPage => throw _privateConstructorUsedError;
  int get dailyTotalPages => throw _privateConstructorUsedError;
  DateRange get dateRange => throw _privateConstructorUsedError;
  DateTime? get customStartDate => throw _privateConstructorUsedError;
  DateTime? get customEndDate => throw _privateConstructorUsedError;
  SummaryStats get summaryStats => throw _privateConstructorUsedError;
  List<TodoTimeStats> get perItemStats => throw _privateConstructorUsedError;
  int get perItemCurrentPage => throw _privateConstructorUsedError;
  int get perItemTotalPages => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  String? get selectedTitle => throw _privateConstructorUsedError;
  List<TitleTimePoint> get selectedTitleHistory =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatisticsStateCopyWith<StatisticsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatisticsStateCopyWith<$Res> {
  factory $StatisticsStateCopyWith(
    StatisticsState value,
    $Res Function(StatisticsState) then,
  ) = _$StatisticsStateCopyWithImpl<$Res, StatisticsState>;
  @useResult
  $Res call({
    List<DayStats> dailyStats,
    int dailyCurrentPage,
    int dailyTotalPages,
    DateRange dateRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    SummaryStats summaryStats,
    List<TodoTimeStats> perItemStats,
    int perItemCurrentPage,
    int perItemTotalPages,
    String searchQuery,
    String? selectedTitle,
    List<TitleTimePoint> selectedTitleHistory,
    bool isLoading,
    String? error,
  });

  $SummaryStatsCopyWith<$Res> get summaryStats;
}

/// @nodoc
class _$StatisticsStateCopyWithImpl<$Res, $Val extends StatisticsState>
    implements $StatisticsStateCopyWith<$Res> {
  _$StatisticsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyStats = null,
    Object? dailyCurrentPage = null,
    Object? dailyTotalPages = null,
    Object? dateRange = null,
    Object? customStartDate = freezed,
    Object? customEndDate = freezed,
    Object? summaryStats = null,
    Object? perItemStats = null,
    Object? perItemCurrentPage = null,
    Object? perItemTotalPages = null,
    Object? searchQuery = null,
    Object? selectedTitle = freezed,
    Object? selectedTitleHistory = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            dailyStats: null == dailyStats
                ? _value.dailyStats
                : dailyStats // ignore: cast_nullable_to_non_nullable
                      as List<DayStats>,
            dailyCurrentPage: null == dailyCurrentPage
                ? _value.dailyCurrentPage
                : dailyCurrentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyTotalPages: null == dailyTotalPages
                ? _value.dailyTotalPages
                : dailyTotalPages // ignore: cast_nullable_to_non_nullable
                      as int,
            dateRange: null == dateRange
                ? _value.dateRange
                : dateRange // ignore: cast_nullable_to_non_nullable
                      as DateRange,
            customStartDate: freezed == customStartDate
                ? _value.customStartDate
                : customStartDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            customEndDate: freezed == customEndDate
                ? _value.customEndDate
                : customEndDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            summaryStats: null == summaryStats
                ? _value.summaryStats
                : summaryStats // ignore: cast_nullable_to_non_nullable
                      as SummaryStats,
            perItemStats: null == perItemStats
                ? _value.perItemStats
                : perItemStats // ignore: cast_nullable_to_non_nullable
                      as List<TodoTimeStats>,
            perItemCurrentPage: null == perItemCurrentPage
                ? _value.perItemCurrentPage
                : perItemCurrentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            perItemTotalPages: null == perItemTotalPages
                ? _value.perItemTotalPages
                : perItemTotalPages // ignore: cast_nullable_to_non_nullable
                      as int,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedTitle: freezed == selectedTitle
                ? _value.selectedTitle
                : selectedTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedTitleHistory: null == selectedTitleHistory
                ? _value.selectedTitleHistory
                : selectedTitleHistory // ignore: cast_nullable_to_non_nullable
                      as List<TitleTimePoint>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SummaryStatsCopyWith<$Res> get summaryStats {
    return $SummaryStatsCopyWith<$Res>(_value.summaryStats, (value) {
      return _then(_value.copyWith(summaryStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StatisticsStateImplCopyWith<$Res>
    implements $StatisticsStateCopyWith<$Res> {
  factory _$$StatisticsStateImplCopyWith(
    _$StatisticsStateImpl value,
    $Res Function(_$StatisticsStateImpl) then,
  ) = __$$StatisticsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DayStats> dailyStats,
    int dailyCurrentPage,
    int dailyTotalPages,
    DateRange dateRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    SummaryStats summaryStats,
    List<TodoTimeStats> perItemStats,
    int perItemCurrentPage,
    int perItemTotalPages,
    String searchQuery,
    String? selectedTitle,
    List<TitleTimePoint> selectedTitleHistory,
    bool isLoading,
    String? error,
  });

  @override
  $SummaryStatsCopyWith<$Res> get summaryStats;
}

/// @nodoc
class __$$StatisticsStateImplCopyWithImpl<$Res>
    extends _$StatisticsStateCopyWithImpl<$Res, _$StatisticsStateImpl>
    implements _$$StatisticsStateImplCopyWith<$Res> {
  __$$StatisticsStateImplCopyWithImpl(
    _$StatisticsStateImpl _value,
    $Res Function(_$StatisticsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyStats = null,
    Object? dailyCurrentPage = null,
    Object? dailyTotalPages = null,
    Object? dateRange = null,
    Object? customStartDate = freezed,
    Object? customEndDate = freezed,
    Object? summaryStats = null,
    Object? perItemStats = null,
    Object? perItemCurrentPage = null,
    Object? perItemTotalPages = null,
    Object? searchQuery = null,
    Object? selectedTitle = freezed,
    Object? selectedTitleHistory = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$StatisticsStateImpl(
        dailyStats: null == dailyStats
            ? _value._dailyStats
            : dailyStats // ignore: cast_nullable_to_non_nullable
                  as List<DayStats>,
        dailyCurrentPage: null == dailyCurrentPage
            ? _value.dailyCurrentPage
            : dailyCurrentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyTotalPages: null == dailyTotalPages
            ? _value.dailyTotalPages
            : dailyTotalPages // ignore: cast_nullable_to_non_nullable
                  as int,
        dateRange: null == dateRange
            ? _value.dateRange
            : dateRange // ignore: cast_nullable_to_non_nullable
                  as DateRange,
        customStartDate: freezed == customStartDate
            ? _value.customStartDate
            : customStartDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        customEndDate: freezed == customEndDate
            ? _value.customEndDate
            : customEndDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        summaryStats: null == summaryStats
            ? _value.summaryStats
            : summaryStats // ignore: cast_nullable_to_non_nullable
                  as SummaryStats,
        perItemStats: null == perItemStats
            ? _value._perItemStats
            : perItemStats // ignore: cast_nullable_to_non_nullable
                  as List<TodoTimeStats>,
        perItemCurrentPage: null == perItemCurrentPage
            ? _value.perItemCurrentPage
            : perItemCurrentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        perItemTotalPages: null == perItemTotalPages
            ? _value.perItemTotalPages
            : perItemTotalPages // ignore: cast_nullable_to_non_nullable
                  as int,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedTitle: freezed == selectedTitle
            ? _value.selectedTitle
            : selectedTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedTitleHistory: null == selectedTitleHistory
            ? _value._selectedTitleHistory
            : selectedTitleHistory // ignore: cast_nullable_to_non_nullable
                  as List<TitleTimePoint>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$StatisticsStateImpl implements _StatisticsState {
  const _$StatisticsStateImpl({
    final List<DayStats> dailyStats = const [],
    this.dailyCurrentPage = 0,
    this.dailyTotalPages = 0,
    this.dateRange = DateRange.last7Days,
    this.customStartDate,
    this.customEndDate,
    this.summaryStats = const SummaryStats(),
    final List<TodoTimeStats> perItemStats = const [],
    this.perItemCurrentPage = 0,
    this.perItemTotalPages = 0,
    this.searchQuery = '',
    this.selectedTitle,
    final List<TitleTimePoint> selectedTitleHistory = const [],
    this.isLoading = false,
    this.error,
  }) : _dailyStats = dailyStats,
       _perItemStats = perItemStats,
       _selectedTitleHistory = selectedTitleHistory;

  final List<DayStats> _dailyStats;
  @override
  @JsonKey()
  List<DayStats> get dailyStats {
    if (_dailyStats is EqualUnmodifiableListView) return _dailyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyStats);
  }

  @override
  @JsonKey()
  final int dailyCurrentPage;
  @override
  @JsonKey()
  final int dailyTotalPages;
  @override
  @JsonKey()
  final DateRange dateRange;
  @override
  final DateTime? customStartDate;
  @override
  final DateTime? customEndDate;
  @override
  @JsonKey()
  final SummaryStats summaryStats;
  final List<TodoTimeStats> _perItemStats;
  @override
  @JsonKey()
  List<TodoTimeStats> get perItemStats {
    if (_perItemStats is EqualUnmodifiableListView) return _perItemStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_perItemStats);
  }

  @override
  @JsonKey()
  final int perItemCurrentPage;
  @override
  @JsonKey()
  final int perItemTotalPages;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  final String? selectedTitle;
  final List<TitleTimePoint> _selectedTitleHistory;
  @override
  @JsonKey()
  List<TitleTimePoint> get selectedTitleHistory {
    if (_selectedTitleHistory is EqualUnmodifiableListView)
      return _selectedTitleHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedTitleHistory);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'StatisticsState(dailyStats: $dailyStats, dailyCurrentPage: $dailyCurrentPage, dailyTotalPages: $dailyTotalPages, dateRange: $dateRange, customStartDate: $customStartDate, customEndDate: $customEndDate, summaryStats: $summaryStats, perItemStats: $perItemStats, perItemCurrentPage: $perItemCurrentPage, perItemTotalPages: $perItemTotalPages, searchQuery: $searchQuery, selectedTitle: $selectedTitle, selectedTitleHistory: $selectedTitleHistory, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatisticsStateImpl &&
            const DeepCollectionEquality().equals(
              other._dailyStats,
              _dailyStats,
            ) &&
            (identical(other.dailyCurrentPage, dailyCurrentPage) ||
                other.dailyCurrentPage == dailyCurrentPage) &&
            (identical(other.dailyTotalPages, dailyTotalPages) ||
                other.dailyTotalPages == dailyTotalPages) &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange) &&
            (identical(other.customStartDate, customStartDate) ||
                other.customStartDate == customStartDate) &&
            (identical(other.customEndDate, customEndDate) ||
                other.customEndDate == customEndDate) &&
            (identical(other.summaryStats, summaryStats) ||
                other.summaryStats == summaryStats) &&
            const DeepCollectionEquality().equals(
              other._perItemStats,
              _perItemStats,
            ) &&
            (identical(other.perItemCurrentPage, perItemCurrentPage) ||
                other.perItemCurrentPage == perItemCurrentPage) &&
            (identical(other.perItemTotalPages, perItemTotalPages) ||
                other.perItemTotalPages == perItemTotalPages) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.selectedTitle, selectedTitle) ||
                other.selectedTitle == selectedTitle) &&
            const DeepCollectionEquality().equals(
              other._selectedTitleHistory,
              _selectedTitleHistory,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_dailyStats),
    dailyCurrentPage,
    dailyTotalPages,
    dateRange,
    customStartDate,
    customEndDate,
    summaryStats,
    const DeepCollectionEquality().hash(_perItemStats),
    perItemCurrentPage,
    perItemTotalPages,
    searchQuery,
    selectedTitle,
    const DeepCollectionEquality().hash(_selectedTitleHistory),
    isLoading,
    error,
  );

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatisticsStateImplCopyWith<_$StatisticsStateImpl> get copyWith =>
      __$$StatisticsStateImplCopyWithImpl<_$StatisticsStateImpl>(
        this,
        _$identity,
      );
}

abstract class _StatisticsState implements StatisticsState {
  const factory _StatisticsState({
    final List<DayStats> dailyStats,
    final int dailyCurrentPage,
    final int dailyTotalPages,
    final DateRange dateRange,
    final DateTime? customStartDate,
    final DateTime? customEndDate,
    final SummaryStats summaryStats,
    final List<TodoTimeStats> perItemStats,
    final int perItemCurrentPage,
    final int perItemTotalPages,
    final String searchQuery,
    final String? selectedTitle,
    final List<TitleTimePoint> selectedTitleHistory,
    final bool isLoading,
    final String? error,
  }) = _$StatisticsStateImpl;

  @override
  List<DayStats> get dailyStats;
  @override
  int get dailyCurrentPage;
  @override
  int get dailyTotalPages;
  @override
  DateRange get dateRange;
  @override
  DateTime? get customStartDate;
  @override
  DateTime? get customEndDate;
  @override
  SummaryStats get summaryStats;
  @override
  List<TodoTimeStats> get perItemStats;
  @override
  int get perItemCurrentPage;
  @override
  int get perItemTotalPages;
  @override
  String get searchQuery;
  @override
  String? get selectedTitle;
  @override
  List<TitleTimePoint> get selectedTitleHistory;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of StatisticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatisticsStateImplCopyWith<_$StatisticsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
