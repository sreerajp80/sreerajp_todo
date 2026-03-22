// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DayStats {
  String get date => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get completed => throw _privateConstructorUsedError;
  int get dropped => throw _privateConstructorUsedError;
  int get ported => throw _privateConstructorUsedError;
  int get pending => throw _privateConstructorUsedError;
  int get totalSeconds => throw _privateConstructorUsedError;

  /// Create a copy of DayStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayStatsCopyWith<DayStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayStatsCopyWith<$Res> {
  factory $DayStatsCopyWith(DayStats value, $Res Function(DayStats) then) =
      _$DayStatsCopyWithImpl<$Res, DayStats>;
  @useResult
  $Res call({
    String date,
    int total,
    int completed,
    int dropped,
    int ported,
    int pending,
    int totalSeconds,
  });
}

/// @nodoc
class _$DayStatsCopyWithImpl<$Res, $Val extends DayStats>
    implements $DayStatsCopyWith<$Res> {
  _$DayStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? total = null,
    Object? completed = null,
    Object? dropped = null,
    Object? ported = null,
    Object? pending = null,
    Object? totalSeconds = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as int,
            dropped: null == dropped
                ? _value.dropped
                : dropped // ignore: cast_nullable_to_non_nullable
                      as int,
            ported: null == ported
                ? _value.ported
                : ported // ignore: cast_nullable_to_non_nullable
                      as int,
            pending: null == pending
                ? _value.pending
                : pending // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSeconds: null == totalSeconds
                ? _value.totalSeconds
                : totalSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DayStatsImplCopyWith<$Res>
    implements $DayStatsCopyWith<$Res> {
  factory _$$DayStatsImplCopyWith(
    _$DayStatsImpl value,
    $Res Function(_$DayStatsImpl) then,
  ) = __$$DayStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    int total,
    int completed,
    int dropped,
    int ported,
    int pending,
    int totalSeconds,
  });
}

/// @nodoc
class __$$DayStatsImplCopyWithImpl<$Res>
    extends _$DayStatsCopyWithImpl<$Res, _$DayStatsImpl>
    implements _$$DayStatsImplCopyWith<$Res> {
  __$$DayStatsImplCopyWithImpl(
    _$DayStatsImpl _value,
    $Res Function(_$DayStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DayStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? total = null,
    Object? completed = null,
    Object? dropped = null,
    Object? ported = null,
    Object? pending = null,
    Object? totalSeconds = null,
  }) {
    return _then(
      _$DayStatsImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as int,
        dropped: null == dropped
            ? _value.dropped
            : dropped // ignore: cast_nullable_to_non_nullable
                  as int,
        ported: null == ported
            ? _value.ported
            : ported // ignore: cast_nullable_to_non_nullable
                  as int,
        pending: null == pending
            ? _value.pending
            : pending // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSeconds: null == totalSeconds
            ? _value.totalSeconds
            : totalSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DayStatsImpl implements _DayStats {
  const _$DayStatsImpl({
    required this.date,
    required this.total,
    required this.completed,
    required this.dropped,
    required this.ported,
    required this.pending,
    this.totalSeconds = 0,
  });

  @override
  final String date;
  @override
  final int total;
  @override
  final int completed;
  @override
  final int dropped;
  @override
  final int ported;
  @override
  final int pending;
  @override
  @JsonKey()
  final int totalSeconds;

  @override
  String toString() {
    return 'DayStats(date: $date, total: $total, completed: $completed, dropped: $dropped, ported: $ported, pending: $pending, totalSeconds: $totalSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayStatsImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.dropped, dropped) || other.dropped == dropped) &&
            (identical(other.ported, ported) || other.ported == ported) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.totalSeconds, totalSeconds) ||
                other.totalSeconds == totalSeconds));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    total,
    completed,
    dropped,
    ported,
    pending,
    totalSeconds,
  );

  /// Create a copy of DayStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayStatsImplCopyWith<_$DayStatsImpl> get copyWith =>
      __$$DayStatsImplCopyWithImpl<_$DayStatsImpl>(this, _$identity);
}

abstract class _DayStats implements DayStats {
  const factory _DayStats({
    required final String date,
    required final int total,
    required final int completed,
    required final int dropped,
    required final int ported,
    required final int pending,
    final int totalSeconds,
  }) = _$DayStatsImpl;

  @override
  String get date;
  @override
  int get total;
  @override
  int get completed;
  @override
  int get dropped;
  @override
  int get ported;
  @override
  int get pending;
  @override
  int get totalSeconds;

  /// Create a copy of DayStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayStatsImplCopyWith<_$DayStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TodoTimeStats {
  String get title => throw _privateConstructorUsedError;
  int get appearances => throw _privateConstructorUsedError;
  int get completed => throw _privateConstructorUsedError;
  int get dropped => throw _privateConstructorUsedError;
  int get ported => throw _privateConstructorUsedError;
  int get pending => throw _privateConstructorUsedError;
  int get totalSeconds => throw _privateConstructorUsedError;

  /// Create a copy of TodoTimeStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoTimeStatsCopyWith<TodoTimeStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoTimeStatsCopyWith<$Res> {
  factory $TodoTimeStatsCopyWith(
    TodoTimeStats value,
    $Res Function(TodoTimeStats) then,
  ) = _$TodoTimeStatsCopyWithImpl<$Res, TodoTimeStats>;
  @useResult
  $Res call({
    String title,
    int appearances,
    int completed,
    int dropped,
    int ported,
    int pending,
    int totalSeconds,
  });
}

/// @nodoc
class _$TodoTimeStatsCopyWithImpl<$Res, $Val extends TodoTimeStats>
    implements $TodoTimeStatsCopyWith<$Res> {
  _$TodoTimeStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoTimeStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? appearances = null,
    Object? completed = null,
    Object? dropped = null,
    Object? ported = null,
    Object? pending = null,
    Object? totalSeconds = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            appearances: null == appearances
                ? _value.appearances
                : appearances // ignore: cast_nullable_to_non_nullable
                      as int,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as int,
            dropped: null == dropped
                ? _value.dropped
                : dropped // ignore: cast_nullable_to_non_nullable
                      as int,
            ported: null == ported
                ? _value.ported
                : ported // ignore: cast_nullable_to_non_nullable
                      as int,
            pending: null == pending
                ? _value.pending
                : pending // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSeconds: null == totalSeconds
                ? _value.totalSeconds
                : totalSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodoTimeStatsImplCopyWith<$Res>
    implements $TodoTimeStatsCopyWith<$Res> {
  factory _$$TodoTimeStatsImplCopyWith(
    _$TodoTimeStatsImpl value,
    $Res Function(_$TodoTimeStatsImpl) then,
  ) = __$$TodoTimeStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    int appearances,
    int completed,
    int dropped,
    int ported,
    int pending,
    int totalSeconds,
  });
}

/// @nodoc
class __$$TodoTimeStatsImplCopyWithImpl<$Res>
    extends _$TodoTimeStatsCopyWithImpl<$Res, _$TodoTimeStatsImpl>
    implements _$$TodoTimeStatsImplCopyWith<$Res> {
  __$$TodoTimeStatsImplCopyWithImpl(
    _$TodoTimeStatsImpl _value,
    $Res Function(_$TodoTimeStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoTimeStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? appearances = null,
    Object? completed = null,
    Object? dropped = null,
    Object? ported = null,
    Object? pending = null,
    Object? totalSeconds = null,
  }) {
    return _then(
      _$TodoTimeStatsImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        appearances: null == appearances
            ? _value.appearances
            : appearances // ignore: cast_nullable_to_non_nullable
                  as int,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as int,
        dropped: null == dropped
            ? _value.dropped
            : dropped // ignore: cast_nullable_to_non_nullable
                  as int,
        ported: null == ported
            ? _value.ported
            : ported // ignore: cast_nullable_to_non_nullable
                  as int,
        pending: null == pending
            ? _value.pending
            : pending // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSeconds: null == totalSeconds
            ? _value.totalSeconds
            : totalSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TodoTimeStatsImpl implements _TodoTimeStats {
  const _$TodoTimeStatsImpl({
    required this.title,
    this.appearances = 0,
    this.completed = 0,
    this.dropped = 0,
    this.ported = 0,
    this.pending = 0,
    this.totalSeconds = 0,
  });

  @override
  final String title;
  @override
  @JsonKey()
  final int appearances;
  @override
  @JsonKey()
  final int completed;
  @override
  @JsonKey()
  final int dropped;
  @override
  @JsonKey()
  final int ported;
  @override
  @JsonKey()
  final int pending;
  @override
  @JsonKey()
  final int totalSeconds;

  @override
  String toString() {
    return 'TodoTimeStats(title: $title, appearances: $appearances, completed: $completed, dropped: $dropped, ported: $ported, pending: $pending, totalSeconds: $totalSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoTimeStatsImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.appearances, appearances) ||
                other.appearances == appearances) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.dropped, dropped) || other.dropped == dropped) &&
            (identical(other.ported, ported) || other.ported == ported) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.totalSeconds, totalSeconds) ||
                other.totalSeconds == totalSeconds));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    appearances,
    completed,
    dropped,
    ported,
    pending,
    totalSeconds,
  );

  /// Create a copy of TodoTimeStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoTimeStatsImplCopyWith<_$TodoTimeStatsImpl> get copyWith =>
      __$$TodoTimeStatsImplCopyWithImpl<_$TodoTimeStatsImpl>(this, _$identity);
}

abstract class _TodoTimeStats implements TodoTimeStats {
  const factory _TodoTimeStats({
    required final String title,
    final int appearances,
    final int completed,
    final int dropped,
    final int ported,
    final int pending,
    final int totalSeconds,
  }) = _$TodoTimeStatsImpl;

  @override
  String get title;
  @override
  int get appearances;
  @override
  int get completed;
  @override
  int get dropped;
  @override
  int get ported;
  @override
  int get pending;
  @override
  int get totalSeconds;

  /// Create a copy of TodoTimeStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoTimeStatsImplCopyWith<_$TodoTimeStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TitleTimePoint {
  String get title => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get totalSeconds => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Create a copy of TitleTimePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TitleTimePointCopyWith<TitleTimePoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TitleTimePointCopyWith<$Res> {
  factory $TitleTimePointCopyWith(
    TitleTimePoint value,
    $Res Function(TitleTimePoint) then,
  ) = _$TitleTimePointCopyWithImpl<$Res, TitleTimePoint>;
  @useResult
  $Res call({String title, String date, int totalSeconds, String? status});
}

/// @nodoc
class _$TitleTimePointCopyWithImpl<$Res, $Val extends TitleTimePoint>
    implements $TitleTimePointCopyWith<$Res> {
  _$TitleTimePointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TitleTimePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? date = null,
    Object? totalSeconds = null,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            totalSeconds: null == totalSeconds
                ? _value.totalSeconds
                : totalSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TitleTimePointImplCopyWith<$Res>
    implements $TitleTimePointCopyWith<$Res> {
  factory _$$TitleTimePointImplCopyWith(
    _$TitleTimePointImpl value,
    $Res Function(_$TitleTimePointImpl) then,
  ) = __$$TitleTimePointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String date, int totalSeconds, String? status});
}

/// @nodoc
class __$$TitleTimePointImplCopyWithImpl<$Res>
    extends _$TitleTimePointCopyWithImpl<$Res, _$TitleTimePointImpl>
    implements _$$TitleTimePointImplCopyWith<$Res> {
  __$$TitleTimePointImplCopyWithImpl(
    _$TitleTimePointImpl _value,
    $Res Function(_$TitleTimePointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TitleTimePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? date = null,
    Object? totalSeconds = null,
    Object? status = freezed,
  }) {
    return _then(
      _$TitleTimePointImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        totalSeconds: null == totalSeconds
            ? _value.totalSeconds
            : totalSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TitleTimePointImpl implements _TitleTimePoint {
  const _$TitleTimePointImpl({
    required this.title,
    required this.date,
    this.totalSeconds = 0,
    this.status,
  });

  @override
  final String title;
  @override
  final String date;
  @override
  @JsonKey()
  final int totalSeconds;
  @override
  final String? status;

  @override
  String toString() {
    return 'TitleTimePoint(title: $title, date: $date, totalSeconds: $totalSeconds, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TitleTimePointImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalSeconds, totalSeconds) ||
                other.totalSeconds == totalSeconds) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, title, date, totalSeconds, status);

  /// Create a copy of TitleTimePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TitleTimePointImplCopyWith<_$TitleTimePointImpl> get copyWith =>
      __$$TitleTimePointImplCopyWithImpl<_$TitleTimePointImpl>(
        this,
        _$identity,
      );
}

abstract class _TitleTimePoint implements TitleTimePoint {
  const factory _TitleTimePoint({
    required final String title,
    required final String date,
    final int totalSeconds,
    final String? status,
  }) = _$TitleTimePointImpl;

  @override
  String get title;
  @override
  String get date;
  @override
  int get totalSeconds;
  @override
  String? get status;

  /// Create a copy of TitleTimePoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TitleTimePointImplCopyWith<_$TitleTimePointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SummaryStats {
  int get totalTodos => throw _privateConstructorUsedError;
  double get avgCompletedPerDay => throw _privateConstructorUsedError;
  int get avgTimePerDaySeconds => throw _privateConstructorUsedError;
  int get totalProductiveTimeSeconds => throw _privateConstructorUsedError;
  int get totalDroppedTimeSeconds => throw _privateConstructorUsedError;

  /// Create a copy of SummaryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SummaryStatsCopyWith<SummaryStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryStatsCopyWith<$Res> {
  factory $SummaryStatsCopyWith(
    SummaryStats value,
    $Res Function(SummaryStats) then,
  ) = _$SummaryStatsCopyWithImpl<$Res, SummaryStats>;
  @useResult
  $Res call({
    int totalTodos,
    double avgCompletedPerDay,
    int avgTimePerDaySeconds,
    int totalProductiveTimeSeconds,
    int totalDroppedTimeSeconds,
  });
}

/// @nodoc
class _$SummaryStatsCopyWithImpl<$Res, $Val extends SummaryStats>
    implements $SummaryStatsCopyWith<$Res> {
  _$SummaryStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SummaryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTodos = null,
    Object? avgCompletedPerDay = null,
    Object? avgTimePerDaySeconds = null,
    Object? totalProductiveTimeSeconds = null,
    Object? totalDroppedTimeSeconds = null,
  }) {
    return _then(
      _value.copyWith(
            totalTodos: null == totalTodos
                ? _value.totalTodos
                : totalTodos // ignore: cast_nullable_to_non_nullable
                      as int,
            avgCompletedPerDay: null == avgCompletedPerDay
                ? _value.avgCompletedPerDay
                : avgCompletedPerDay // ignore: cast_nullable_to_non_nullable
                      as double,
            avgTimePerDaySeconds: null == avgTimePerDaySeconds
                ? _value.avgTimePerDaySeconds
                : avgTimePerDaySeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            totalProductiveTimeSeconds: null == totalProductiveTimeSeconds
                ? _value.totalProductiveTimeSeconds
                : totalProductiveTimeSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDroppedTimeSeconds: null == totalDroppedTimeSeconds
                ? _value.totalDroppedTimeSeconds
                : totalDroppedTimeSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SummaryStatsImplCopyWith<$Res>
    implements $SummaryStatsCopyWith<$Res> {
  factory _$$SummaryStatsImplCopyWith(
    _$SummaryStatsImpl value,
    $Res Function(_$SummaryStatsImpl) then,
  ) = __$$SummaryStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalTodos,
    double avgCompletedPerDay,
    int avgTimePerDaySeconds,
    int totalProductiveTimeSeconds,
    int totalDroppedTimeSeconds,
  });
}

/// @nodoc
class __$$SummaryStatsImplCopyWithImpl<$Res>
    extends _$SummaryStatsCopyWithImpl<$Res, _$SummaryStatsImpl>
    implements _$$SummaryStatsImplCopyWith<$Res> {
  __$$SummaryStatsImplCopyWithImpl(
    _$SummaryStatsImpl _value,
    $Res Function(_$SummaryStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SummaryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTodos = null,
    Object? avgCompletedPerDay = null,
    Object? avgTimePerDaySeconds = null,
    Object? totalProductiveTimeSeconds = null,
    Object? totalDroppedTimeSeconds = null,
  }) {
    return _then(
      _$SummaryStatsImpl(
        totalTodos: null == totalTodos
            ? _value.totalTodos
            : totalTodos // ignore: cast_nullable_to_non_nullable
                  as int,
        avgCompletedPerDay: null == avgCompletedPerDay
            ? _value.avgCompletedPerDay
            : avgCompletedPerDay // ignore: cast_nullable_to_non_nullable
                  as double,
        avgTimePerDaySeconds: null == avgTimePerDaySeconds
            ? _value.avgTimePerDaySeconds
            : avgTimePerDaySeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        totalProductiveTimeSeconds: null == totalProductiveTimeSeconds
            ? _value.totalProductiveTimeSeconds
            : totalProductiveTimeSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDroppedTimeSeconds: null == totalDroppedTimeSeconds
            ? _value.totalDroppedTimeSeconds
            : totalDroppedTimeSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$SummaryStatsImpl implements _SummaryStats {
  const _$SummaryStatsImpl({
    this.totalTodos = 0,
    this.avgCompletedPerDay = 0,
    this.avgTimePerDaySeconds = 0,
    this.totalProductiveTimeSeconds = 0,
    this.totalDroppedTimeSeconds = 0,
  });

  @override
  @JsonKey()
  final int totalTodos;
  @override
  @JsonKey()
  final double avgCompletedPerDay;
  @override
  @JsonKey()
  final int avgTimePerDaySeconds;
  @override
  @JsonKey()
  final int totalProductiveTimeSeconds;
  @override
  @JsonKey()
  final int totalDroppedTimeSeconds;

  @override
  String toString() {
    return 'SummaryStats(totalTodos: $totalTodos, avgCompletedPerDay: $avgCompletedPerDay, avgTimePerDaySeconds: $avgTimePerDaySeconds, totalProductiveTimeSeconds: $totalProductiveTimeSeconds, totalDroppedTimeSeconds: $totalDroppedTimeSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryStatsImpl &&
            (identical(other.totalTodos, totalTodos) ||
                other.totalTodos == totalTodos) &&
            (identical(other.avgCompletedPerDay, avgCompletedPerDay) ||
                other.avgCompletedPerDay == avgCompletedPerDay) &&
            (identical(other.avgTimePerDaySeconds, avgTimePerDaySeconds) ||
                other.avgTimePerDaySeconds == avgTimePerDaySeconds) &&
            (identical(
                  other.totalProductiveTimeSeconds,
                  totalProductiveTimeSeconds,
                ) ||
                other.totalProductiveTimeSeconds ==
                    totalProductiveTimeSeconds) &&
            (identical(
                  other.totalDroppedTimeSeconds,
                  totalDroppedTimeSeconds,
                ) ||
                other.totalDroppedTimeSeconds == totalDroppedTimeSeconds));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalTodos,
    avgCompletedPerDay,
    avgTimePerDaySeconds,
    totalProductiveTimeSeconds,
    totalDroppedTimeSeconds,
  );

  /// Create a copy of SummaryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryStatsImplCopyWith<_$SummaryStatsImpl> get copyWith =>
      __$$SummaryStatsImplCopyWithImpl<_$SummaryStatsImpl>(this, _$identity);
}

abstract class _SummaryStats implements SummaryStats {
  const factory _SummaryStats({
    final int totalTodos,
    final double avgCompletedPerDay,
    final int avgTimePerDaySeconds,
    final int totalProductiveTimeSeconds,
    final int totalDroppedTimeSeconds,
  }) = _$SummaryStatsImpl;

  @override
  int get totalTodos;
  @override
  double get avgCompletedPerDay;
  @override
  int get avgTimePerDaySeconds;
  @override
  int get totalProductiveTimeSeconds;
  @override
  int get totalDroppedTimeSeconds;

  /// Create a copy of SummaryStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SummaryStatsImplCopyWith<_$SummaryStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
