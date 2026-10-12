// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayStats {

 String get date; int get total; int get completed; int get dropped; int get ported; int get pending; int get working; int get totalSeconds;
/// Create a copy of DayStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayStatsCopyWith<DayStats> get copyWith => _$DayStatsCopyWithImpl<DayStats>(this as DayStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DayStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayStats&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.dropped, _this.dropped) || other.dropped == _this.dropped)&&(identical(other.ported, _this.ported) || other.ported == _this.ported)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.working, _this.working) || other.working == _this.working)&&(identical(other.totalSeconds, _this.totalSeconds) || other.totalSeconds == _this.totalSeconds));
}


@override
int get hashCode {
  final _this = this as DayStats;
  return Object.hash(runtimeType,_this.date,_this.total,_this.completed,_this.dropped,_this.ported,_this.pending,_this.working,_this.totalSeconds);
}

@override
String toString() {
  final _this = this as DayStats;
  return 'DayStats(date: ${_this.date}, total: ${_this.total}, completed: ${_this.completed}, dropped: ${_this.dropped}, ported: ${_this.ported}, pending: ${_this.pending}, working: ${_this.working}, totalSeconds: ${_this.totalSeconds})';
}


}

/// @nodoc
abstract mixin class $DayStatsCopyWith<$Res>  {
  factory $DayStatsCopyWith(DayStats value, $Res Function(DayStats) _then) = _$DayStatsCopyWithImpl;
@useResult
$Res call({
 String date, int total, int completed, int dropped, int ported, int pending, int working, int totalSeconds
});




}
/// @nodoc
class _$DayStatsCopyWithImpl<$Res>
    implements $DayStatsCopyWith<$Res> {
  _$DayStatsCopyWithImpl(this._self, this._then);

  final DayStats _self;
  final $Res Function(DayStats) _then;

/// Create a copy of DayStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? total = null,Object? completed = null,Object? dropped = null,Object? ported = null,Object? pending = null,Object? working = null,Object? totalSeconds = null,}) {
  return _then(DayStats(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as int,ported: null == ported ? _self.ported : ported // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as int,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DayStats].
extension DayStatsPatterns on DayStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayStats value)  $default,){
final _that = this;
switch (_that) {
case _DayStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayStats value)?  $default,){
final _that = this;
switch (_that) {
case _DayStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  int total,  int completed,  int dropped,  int ported,  int pending,  int working,  int totalSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayStats() when $default != null:
return $default(_that.date,_that.total,_that.completed,_that.dropped,_that.ported,_that.pending,_that.working,_that.totalSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  int total,  int completed,  int dropped,  int ported,  int pending,  int working,  int totalSeconds)  $default,) {final _that = this;
switch (_that) {
case _DayStats():
return $default(_that.date,_that.total,_that.completed,_that.dropped,_that.ported,_that.pending,_that.working,_that.totalSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  int total,  int completed,  int dropped,  int ported,  int pending,  int working,  int totalSeconds)?  $default,) {final _that = this;
switch (_that) {
case _DayStats() when $default != null:
return $default(_that.date,_that.total,_that.completed,_that.dropped,_that.ported,_that.pending,_that.working,_that.totalSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _DayStats implements DayStats {
  const _DayStats({required this.date, required this.total, required this.completed, required this.dropped, required this.ported, required this.pending, this.working = 0, this.totalSeconds = 0});
  

@override final  String date;
@override final  int total;
@override final  int completed;
@override final  int dropped;
@override final  int ported;
@override final  int pending;
@override@JsonKey() final  int working;
@override@JsonKey() final  int totalSeconds;

/// Create a copy of DayStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayStatsCopyWith<_DayStats> get copyWith => __$DayStatsCopyWithImpl<_DayStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayStats&&(identical(other.date, date) || other.date == date)&&(identical(other.total, total) || other.total == total)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.dropped, dropped) || other.dropped == dropped)&&(identical(other.ported, ported) || other.ported == ported)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.working, working) || other.working == working)&&(identical(other.totalSeconds, totalSeconds) || other.totalSeconds == totalSeconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,total,completed,dropped,ported,pending,working,totalSeconds);
}

@override
String toString() {
    return 'DayStats(date: $date, total: $total, completed: $completed, dropped: $dropped, ported: $ported, pending: $pending, working: $working, totalSeconds: $totalSeconds)';
}


}

/// @nodoc
abstract mixin class _$DayStatsCopyWith<$Res> implements $DayStatsCopyWith<$Res> {
  factory _$DayStatsCopyWith(_DayStats value, $Res Function(_DayStats) _then) = __$DayStatsCopyWithImpl;
@override @useResult
$Res call({
 String date, int total, int completed, int dropped, int ported, int pending, int working, int totalSeconds
});




}
/// @nodoc
class __$DayStatsCopyWithImpl<$Res>
    implements _$DayStatsCopyWith<$Res> {
  __$DayStatsCopyWithImpl(this._self, this._then);

  final _DayStats _self;
  final $Res Function(_DayStats) _then;

/// Create a copy of DayStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? total = null,Object? completed = null,Object? dropped = null,Object? ported = null,Object? pending = null,Object? working = null,Object? totalSeconds = null,}) {
  return _then(_DayStats(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as int,ported: null == ported ? _self.ported : ported // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as int,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TodoTimeStats {

 String get title; int get appearances; int get completed; int get dropped; int get ported; int get pending; int get working; int get totalSeconds;
/// Create a copy of TodoTimeStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoTimeStatsCopyWith<TodoTimeStats> get copyWith => _$TodoTimeStatsCopyWithImpl<TodoTimeStats>(this as TodoTimeStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TodoTimeStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoTimeStats&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.appearances, _this.appearances) || other.appearances == _this.appearances)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.dropped, _this.dropped) || other.dropped == _this.dropped)&&(identical(other.ported, _this.ported) || other.ported == _this.ported)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.working, _this.working) || other.working == _this.working)&&(identical(other.totalSeconds, _this.totalSeconds) || other.totalSeconds == _this.totalSeconds));
}


@override
int get hashCode {
  final _this = this as TodoTimeStats;
  return Object.hash(runtimeType,_this.title,_this.appearances,_this.completed,_this.dropped,_this.ported,_this.pending,_this.working,_this.totalSeconds);
}

@override
String toString() {
  final _this = this as TodoTimeStats;
  return 'TodoTimeStats(title: ${_this.title}, appearances: ${_this.appearances}, completed: ${_this.completed}, dropped: ${_this.dropped}, ported: ${_this.ported}, pending: ${_this.pending}, working: ${_this.working}, totalSeconds: ${_this.totalSeconds})';
}


}

/// @nodoc
abstract mixin class $TodoTimeStatsCopyWith<$Res>  {
  factory $TodoTimeStatsCopyWith(TodoTimeStats value, $Res Function(TodoTimeStats) _then) = _$TodoTimeStatsCopyWithImpl;
@useResult
$Res call({
 String title, int appearances, int completed, int dropped, int ported, int pending, int working, int totalSeconds
});




}
/// @nodoc
class _$TodoTimeStatsCopyWithImpl<$Res>
    implements $TodoTimeStatsCopyWith<$Res> {
  _$TodoTimeStatsCopyWithImpl(this._self, this._then);

  final TodoTimeStats _self;
  final $Res Function(TodoTimeStats) _then;

/// Create a copy of TodoTimeStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? appearances = null,Object? completed = null,Object? dropped = null,Object? ported = null,Object? pending = null,Object? working = null,Object? totalSeconds = null,}) {
  return _then(TodoTimeStats(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,appearances: null == appearances ? _self.appearances : appearances // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as int,ported: null == ported ? _self.ported : ported // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as int,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoTimeStats].
extension TodoTimeStatsPatterns on TodoTimeStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoTimeStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoTimeStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoTimeStats value)  $default,){
final _that = this;
switch (_that) {
case _TodoTimeStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoTimeStats value)?  $default,){
final _that = this;
switch (_that) {
case _TodoTimeStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  int appearances,  int completed,  int dropped,  int ported,  int pending,  int working,  int totalSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoTimeStats() when $default != null:
return $default(_that.title,_that.appearances,_that.completed,_that.dropped,_that.ported,_that.pending,_that.working,_that.totalSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  int appearances,  int completed,  int dropped,  int ported,  int pending,  int working,  int totalSeconds)  $default,) {final _that = this;
switch (_that) {
case _TodoTimeStats():
return $default(_that.title,_that.appearances,_that.completed,_that.dropped,_that.ported,_that.pending,_that.working,_that.totalSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  int appearances,  int completed,  int dropped,  int ported,  int pending,  int working,  int totalSeconds)?  $default,) {final _that = this;
switch (_that) {
case _TodoTimeStats() when $default != null:
return $default(_that.title,_that.appearances,_that.completed,_that.dropped,_that.ported,_that.pending,_that.working,_that.totalSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _TodoTimeStats implements TodoTimeStats {
  const _TodoTimeStats({required this.title, this.appearances = 0, this.completed = 0, this.dropped = 0, this.ported = 0, this.pending = 0, this.working = 0, this.totalSeconds = 0});
  

@override final  String title;
@override@JsonKey() final  int appearances;
@override@JsonKey() final  int completed;
@override@JsonKey() final  int dropped;
@override@JsonKey() final  int ported;
@override@JsonKey() final  int pending;
@override@JsonKey() final  int working;
@override@JsonKey() final  int totalSeconds;

/// Create a copy of TodoTimeStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoTimeStatsCopyWith<_TodoTimeStats> get copyWith => __$TodoTimeStatsCopyWithImpl<_TodoTimeStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoTimeStats&&(identical(other.title, title) || other.title == title)&&(identical(other.appearances, appearances) || other.appearances == appearances)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.dropped, dropped) || other.dropped == dropped)&&(identical(other.ported, ported) || other.ported == ported)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.working, working) || other.working == working)&&(identical(other.totalSeconds, totalSeconds) || other.totalSeconds == totalSeconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,appearances,completed,dropped,ported,pending,working,totalSeconds);
}

@override
String toString() {
    return 'TodoTimeStats(title: $title, appearances: $appearances, completed: $completed, dropped: $dropped, ported: $ported, pending: $pending, working: $working, totalSeconds: $totalSeconds)';
}


}

/// @nodoc
abstract mixin class _$TodoTimeStatsCopyWith<$Res> implements $TodoTimeStatsCopyWith<$Res> {
  factory _$TodoTimeStatsCopyWith(_TodoTimeStats value, $Res Function(_TodoTimeStats) _then) = __$TodoTimeStatsCopyWithImpl;
@override @useResult
$Res call({
 String title, int appearances, int completed, int dropped, int ported, int pending, int working, int totalSeconds
});




}
/// @nodoc
class __$TodoTimeStatsCopyWithImpl<$Res>
    implements _$TodoTimeStatsCopyWith<$Res> {
  __$TodoTimeStatsCopyWithImpl(this._self, this._then);

  final _TodoTimeStats _self;
  final $Res Function(_TodoTimeStats) _then;

/// Create a copy of TodoTimeStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? appearances = null,Object? completed = null,Object? dropped = null,Object? ported = null,Object? pending = null,Object? working = null,Object? totalSeconds = null,}) {
  return _then(_TodoTimeStats(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,appearances: null == appearances ? _self.appearances : appearances // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as int,ported: null == ported ? _self.ported : ported // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as int,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TitleTimePoint {

 String get title; String get date; int get totalSeconds; String? get status;
/// Create a copy of TitleTimePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TitleTimePointCopyWith<TitleTimePoint> get copyWith => _$TitleTimePointCopyWithImpl<TitleTimePoint>(this as TitleTimePoint, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TitleTimePoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TitleTimePoint&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.totalSeconds, _this.totalSeconds) || other.totalSeconds == _this.totalSeconds)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as TitleTimePoint;
  return Object.hash(runtimeType,_this.title,_this.date,_this.totalSeconds,_this.status);
}

@override
String toString() {
  final _this = this as TitleTimePoint;
  return 'TitleTimePoint(title: ${_this.title}, date: ${_this.date}, totalSeconds: ${_this.totalSeconds}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $TitleTimePointCopyWith<$Res>  {
  factory $TitleTimePointCopyWith(TitleTimePoint value, $Res Function(TitleTimePoint) _then) = _$TitleTimePointCopyWithImpl;
@useResult
$Res call({
 String title, String date, int totalSeconds, String? status
});




}
/// @nodoc
class _$TitleTimePointCopyWithImpl<$Res>
    implements $TitleTimePointCopyWith<$Res> {
  _$TitleTimePointCopyWithImpl(this._self, this._then);

  final TitleTimePoint _self;
  final $Res Function(TitleTimePoint) _then;

/// Create a copy of TitleTimePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? date = null,Object? totalSeconds = null,Object? status = freezed,}) {
  return _then(TitleTimePoint(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TitleTimePoint].
extension TitleTimePointPatterns on TitleTimePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TitleTimePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TitleTimePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TitleTimePoint value)  $default,){
final _that = this;
switch (_that) {
case _TitleTimePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TitleTimePoint value)?  $default,){
final _that = this;
switch (_that) {
case _TitleTimePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String date,  int totalSeconds,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TitleTimePoint() when $default != null:
return $default(_that.title,_that.date,_that.totalSeconds,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String date,  int totalSeconds,  String? status)  $default,) {final _that = this;
switch (_that) {
case _TitleTimePoint():
return $default(_that.title,_that.date,_that.totalSeconds,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String date,  int totalSeconds,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _TitleTimePoint() when $default != null:
return $default(_that.title,_that.date,_that.totalSeconds,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _TitleTimePoint implements TitleTimePoint {
  const _TitleTimePoint({required this.title, required this.date, this.totalSeconds = 0, this.status});
  

@override final  String title;
@override final  String date;
@override@JsonKey() final  int totalSeconds;
@override final  String? status;

/// Create a copy of TitleTimePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TitleTimePointCopyWith<_TitleTimePoint> get copyWith => __$TitleTimePointCopyWithImpl<_TitleTimePoint>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TitleTimePoint&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.totalSeconds, totalSeconds) || other.totalSeconds == totalSeconds)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,date,totalSeconds,status);
}

@override
String toString() {
    return 'TitleTimePoint(title: $title, date: $date, totalSeconds: $totalSeconds, status: $status)';
}


}

/// @nodoc
abstract mixin class _$TitleTimePointCopyWith<$Res> implements $TitleTimePointCopyWith<$Res> {
  factory _$TitleTimePointCopyWith(_TitleTimePoint value, $Res Function(_TitleTimePoint) _then) = __$TitleTimePointCopyWithImpl;
@override @useResult
$Res call({
 String title, String date, int totalSeconds, String? status
});




}
/// @nodoc
class __$TitleTimePointCopyWithImpl<$Res>
    implements _$TitleTimePointCopyWith<$Res> {
  __$TitleTimePointCopyWithImpl(this._self, this._then);

  final _TitleTimePoint _self;
  final $Res Function(_TitleTimePoint) _then;

/// Create a copy of TitleTimePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? date = null,Object? totalSeconds = null,Object? status = freezed,}) {
  return _then(_TitleTimePoint(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SummaryStats {

 int get totalTodos; double get avgCompletedPerDay; int get avgTimePerDaySeconds; int get totalProductiveTimeSeconds; int get totalDroppedTimeSeconds;
/// Create a copy of SummaryStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryStatsCopyWith<SummaryStats> get copyWith => _$SummaryStatsCopyWithImpl<SummaryStats>(this as SummaryStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SummaryStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryStats&&(identical(other.totalTodos, _this.totalTodos) || other.totalTodos == _this.totalTodos)&&(identical(other.avgCompletedPerDay, _this.avgCompletedPerDay) || other.avgCompletedPerDay == _this.avgCompletedPerDay)&&(identical(other.avgTimePerDaySeconds, _this.avgTimePerDaySeconds) || other.avgTimePerDaySeconds == _this.avgTimePerDaySeconds)&&(identical(other.totalProductiveTimeSeconds, _this.totalProductiveTimeSeconds) || other.totalProductiveTimeSeconds == _this.totalProductiveTimeSeconds)&&(identical(other.totalDroppedTimeSeconds, _this.totalDroppedTimeSeconds) || other.totalDroppedTimeSeconds == _this.totalDroppedTimeSeconds));
}


@override
int get hashCode {
  final _this = this as SummaryStats;
  return Object.hash(runtimeType,_this.totalTodos,_this.avgCompletedPerDay,_this.avgTimePerDaySeconds,_this.totalProductiveTimeSeconds,_this.totalDroppedTimeSeconds);
}

@override
String toString() {
  final _this = this as SummaryStats;
  return 'SummaryStats(totalTodos: ${_this.totalTodos}, avgCompletedPerDay: ${_this.avgCompletedPerDay}, avgTimePerDaySeconds: ${_this.avgTimePerDaySeconds}, totalProductiveTimeSeconds: ${_this.totalProductiveTimeSeconds}, totalDroppedTimeSeconds: ${_this.totalDroppedTimeSeconds})';
}


}

/// @nodoc
abstract mixin class $SummaryStatsCopyWith<$Res>  {
  factory $SummaryStatsCopyWith(SummaryStats value, $Res Function(SummaryStats) _then) = _$SummaryStatsCopyWithImpl;
@useResult
$Res call({
 int totalTodos, double avgCompletedPerDay, int avgTimePerDaySeconds, int totalProductiveTimeSeconds, int totalDroppedTimeSeconds
});




}
/// @nodoc
class _$SummaryStatsCopyWithImpl<$Res>
    implements $SummaryStatsCopyWith<$Res> {
  _$SummaryStatsCopyWithImpl(this._self, this._then);

  final SummaryStats _self;
  final $Res Function(SummaryStats) _then;

/// Create a copy of SummaryStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalTodos = null,Object? avgCompletedPerDay = null,Object? avgTimePerDaySeconds = null,Object? totalProductiveTimeSeconds = null,Object? totalDroppedTimeSeconds = null,}) {
  return _then(SummaryStats(
totalTodos: null == totalTodos ? _self.totalTodos : totalTodos // ignore: cast_nullable_to_non_nullable
as int,avgCompletedPerDay: null == avgCompletedPerDay ? _self.avgCompletedPerDay : avgCompletedPerDay // ignore: cast_nullable_to_non_nullable
as double,avgTimePerDaySeconds: null == avgTimePerDaySeconds ? _self.avgTimePerDaySeconds : avgTimePerDaySeconds // ignore: cast_nullable_to_non_nullable
as int,totalProductiveTimeSeconds: null == totalProductiveTimeSeconds ? _self.totalProductiveTimeSeconds : totalProductiveTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,totalDroppedTimeSeconds: null == totalDroppedTimeSeconds ? _self.totalDroppedTimeSeconds : totalDroppedTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SummaryStats].
extension SummaryStatsPatterns on SummaryStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryStats value)  $default,){
final _that = this;
switch (_that) {
case _SummaryStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryStats value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalTodos,  double avgCompletedPerDay,  int avgTimePerDaySeconds,  int totalProductiveTimeSeconds,  int totalDroppedTimeSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryStats() when $default != null:
return $default(_that.totalTodos,_that.avgCompletedPerDay,_that.avgTimePerDaySeconds,_that.totalProductiveTimeSeconds,_that.totalDroppedTimeSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalTodos,  double avgCompletedPerDay,  int avgTimePerDaySeconds,  int totalProductiveTimeSeconds,  int totalDroppedTimeSeconds)  $default,) {final _that = this;
switch (_that) {
case _SummaryStats():
return $default(_that.totalTodos,_that.avgCompletedPerDay,_that.avgTimePerDaySeconds,_that.totalProductiveTimeSeconds,_that.totalDroppedTimeSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalTodos,  double avgCompletedPerDay,  int avgTimePerDaySeconds,  int totalProductiveTimeSeconds,  int totalDroppedTimeSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SummaryStats() when $default != null:
return $default(_that.totalTodos,_that.avgCompletedPerDay,_that.avgTimePerDaySeconds,_that.totalProductiveTimeSeconds,_that.totalDroppedTimeSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _SummaryStats implements SummaryStats {
  const _SummaryStats({this.totalTodos = 0, this.avgCompletedPerDay = 0, this.avgTimePerDaySeconds = 0, this.totalProductiveTimeSeconds = 0, this.totalDroppedTimeSeconds = 0});
  

@override@JsonKey() final  int totalTodos;
@override@JsonKey() final  double avgCompletedPerDay;
@override@JsonKey() final  int avgTimePerDaySeconds;
@override@JsonKey() final  int totalProductiveTimeSeconds;
@override@JsonKey() final  int totalDroppedTimeSeconds;

/// Create a copy of SummaryStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryStatsCopyWith<_SummaryStats> get copyWith => __$SummaryStatsCopyWithImpl<_SummaryStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryStats&&(identical(other.totalTodos, totalTodos) || other.totalTodos == totalTodos)&&(identical(other.avgCompletedPerDay, avgCompletedPerDay) || other.avgCompletedPerDay == avgCompletedPerDay)&&(identical(other.avgTimePerDaySeconds, avgTimePerDaySeconds) || other.avgTimePerDaySeconds == avgTimePerDaySeconds)&&(identical(other.totalProductiveTimeSeconds, totalProductiveTimeSeconds) || other.totalProductiveTimeSeconds == totalProductiveTimeSeconds)&&(identical(other.totalDroppedTimeSeconds, totalDroppedTimeSeconds) || other.totalDroppedTimeSeconds == totalDroppedTimeSeconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,totalTodos,avgCompletedPerDay,avgTimePerDaySeconds,totalProductiveTimeSeconds,totalDroppedTimeSeconds);
}

@override
String toString() {
    return 'SummaryStats(totalTodos: $totalTodos, avgCompletedPerDay: $avgCompletedPerDay, avgTimePerDaySeconds: $avgTimePerDaySeconds, totalProductiveTimeSeconds: $totalProductiveTimeSeconds, totalDroppedTimeSeconds: $totalDroppedTimeSeconds)';
}


}

/// @nodoc
abstract mixin class _$SummaryStatsCopyWith<$Res> implements $SummaryStatsCopyWith<$Res> {
  factory _$SummaryStatsCopyWith(_SummaryStats value, $Res Function(_SummaryStats) _then) = __$SummaryStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalTodos, double avgCompletedPerDay, int avgTimePerDaySeconds, int totalProductiveTimeSeconds, int totalDroppedTimeSeconds
});




}
/// @nodoc
class __$SummaryStatsCopyWithImpl<$Res>
    implements _$SummaryStatsCopyWith<$Res> {
  __$SummaryStatsCopyWithImpl(this._self, this._then);

  final _SummaryStats _self;
  final $Res Function(_SummaryStats) _then;

/// Create a copy of SummaryStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalTodos = null,Object? avgCompletedPerDay = null,Object? avgTimePerDaySeconds = null,Object? totalProductiveTimeSeconds = null,Object? totalDroppedTimeSeconds = null,}) {
  return _then(_SummaryStats(
totalTodos: null == totalTodos ? _self.totalTodos : totalTodos // ignore: cast_nullable_to_non_nullable
as int,avgCompletedPerDay: null == avgCompletedPerDay ? _self.avgCompletedPerDay : avgCompletedPerDay // ignore: cast_nullable_to_non_nullable
as double,avgTimePerDaySeconds: null == avgTimePerDaySeconds ? _self.avgTimePerDaySeconds : avgTimePerDaySeconds // ignore: cast_nullable_to_non_nullable
as int,totalProductiveTimeSeconds: null == totalProductiveTimeSeconds ? _self.totalProductiveTimeSeconds : totalProductiveTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,totalDroppedTimeSeconds: null == totalDroppedTimeSeconds ? _self.totalDroppedTimeSeconds : totalDroppedTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
