// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get id; String get displayName; String? get username; String? get avatarUrl; String? get inGameName; String? get inGameUid; String get privacyProfileVisibility; bool get privacyShowInGameInfo; Map<String, dynamic> get notificationPrefs; String? get createdAt; String? get updatedAt; String? get deletedAt;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.inGameName, _this.inGameName) || other.inGameName == _this.inGameName)&&(identical(other.inGameUid, _this.inGameUid) || other.inGameUid == _this.inGameUid)&&(identical(other.privacyProfileVisibility, _this.privacyProfileVisibility) || other.privacyProfileVisibility == _this.privacyProfileVisibility)&&(identical(other.privacyShowInGameInfo, _this.privacyShowInGameInfo) || other.privacyShowInGameInfo == _this.privacyShowInGameInfo)&&const DeepCollectionEquality().equals(other.notificationPrefs, _this.notificationPrefs)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.id,_this.displayName,_this.username,_this.avatarUrl,_this.inGameName,_this.inGameUid,_this.privacyProfileVisibility,_this.privacyShowInGameInfo,const DeepCollectionEquality().hash(_this.notificationPrefs),_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, displayName: ${_this.displayName}, username: ${_this.username}, avatarUrl: ${_this.avatarUrl}, inGameName: ${_this.inGameName}, inGameUid: ${_this.inGameUid}, privacyProfileVisibility: ${_this.privacyProfileVisibility}, privacyShowInGameInfo: ${_this.privacyShowInGameInfo}, notificationPrefs: ${_this.notificationPrefs}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String? username, String? avatarUrl, String? inGameName, String? inGameUid, String privacyProfileVisibility, bool privacyShowInGameInfo, Map<String, dynamic> notificationPrefs, String? createdAt, String? updatedAt, String? deletedAt
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? username = freezed,Object? avatarUrl = freezed,Object? inGameName = freezed,Object? inGameUid = freezed,Object? privacyProfileVisibility = null,Object? privacyShowInGameInfo = null,Object? notificationPrefs = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,inGameName: freezed == inGameName ? _self.inGameName : inGameName // ignore: cast_nullable_to_non_nullable
as String?,inGameUid: freezed == inGameUid ? _self.inGameUid : inGameUid // ignore: cast_nullable_to_non_nullable
as String?,privacyProfileVisibility: null == privacyProfileVisibility ? _self.privacyProfileVisibility : privacyProfileVisibility // ignore: cast_nullable_to_non_nullable
as String,privacyShowInGameInfo: null == privacyShowInGameInfo ? _self.privacyShowInGameInfo : privacyShowInGameInfo // ignore: cast_nullable_to_non_nullable
as bool,notificationPrefs: null == notificationPrefs ? _self.notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String? username,  String? avatarUrl,  String? inGameName,  String? inGameUid,  String privacyProfileVisibility,  bool privacyShowInGameInfo,  Map<String, dynamic> notificationPrefs,  String? createdAt,  String? updatedAt,  String? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.displayName,_that.username,_that.avatarUrl,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String? username,  String? avatarUrl,  String? inGameName,  String? inGameUid,  String privacyProfileVisibility,  bool privacyShowInGameInfo,  Map<String, dynamic> notificationPrefs,  String? createdAt,  String? updatedAt,  String? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.displayName,_that.username,_that.avatarUrl,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String? username,  String? avatarUrl,  String? inGameName,  String? inGameUid,  String privacyProfileVisibility,  bool privacyShowInGameInfo,  Map<String, dynamic> notificationPrefs,  String? createdAt,  String? updatedAt,  String? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.displayName,_that.username,_that.avatarUrl,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, required this.displayName, this.username, this.avatarUrl, this.inGameName, this.inGameUid, this.privacyProfileVisibility = 'public', this.privacyShowInGameInfo = false,  Map<String, dynamic> notificationPrefs = const {}, this.createdAt, this.updatedAt, this.deletedAt}): _notificationPrefs = notificationPrefs;
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String displayName;
@override final  String? username;
@override final  String? avatarUrl;
@override final  String? inGameName;
@override final  String? inGameUid;
@override@JsonKey() final  String privacyProfileVisibility;
@override@JsonKey() final  bool privacyShowInGameInfo;
 final  Map<String, dynamic> _notificationPrefs;
@override@JsonKey() Map<String, dynamic> get notificationPrefs {
  if (_notificationPrefs is EqualUnmodifiableMapView) return _notificationPrefs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_notificationPrefs);
}

@override final  String? createdAt;
@override final  String? updatedAt;
@override final  String? deletedAt;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.inGameName, inGameName) || other.inGameName == inGameName)&&(identical(other.inGameUid, inGameUid) || other.inGameUid == inGameUid)&&(identical(other.privacyProfileVisibility, privacyProfileVisibility) || other.privacyProfileVisibility == privacyProfileVisibility)&&(identical(other.privacyShowInGameInfo, privacyShowInGameInfo) || other.privacyShowInGameInfo == privacyShowInGameInfo)&&const DeepCollectionEquality().equals(other.notificationPrefs, _notificationPrefs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,displayName,username,avatarUrl,inGameName,inGameUid,privacyProfileVisibility,privacyShowInGameInfo,const DeepCollectionEquality().hash(_notificationPrefs),createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'Profile(id: $id, displayName: $displayName, username: $username, avatarUrl: $avatarUrl, inGameName: $inGameName, inGameUid: $inGameUid, privacyProfileVisibility: $privacyProfileVisibility, privacyShowInGameInfo: $privacyShowInGameInfo, notificationPrefs: $notificationPrefs, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String? username, String? avatarUrl, String? inGameName, String? inGameUid, String privacyProfileVisibility, bool privacyShowInGameInfo, Map<String, dynamic> notificationPrefs, String? createdAt, String? updatedAt, String? deletedAt
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? username = freezed,Object? avatarUrl = freezed,Object? inGameName = freezed,Object? inGameUid = freezed,Object? privacyProfileVisibility = null,Object? privacyShowInGameInfo = null,Object? notificationPrefs = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,inGameName: freezed == inGameName ? _self.inGameName : inGameName // ignore: cast_nullable_to_non_nullable
as String?,inGameUid: freezed == inGameUid ? _self.inGameUid : inGameUid // ignore: cast_nullable_to_non_nullable
as String?,privacyProfileVisibility: null == privacyProfileVisibility ? _self.privacyProfileVisibility : privacyProfileVisibility // ignore: cast_nullable_to_non_nullable
as String,privacyShowInGameInfo: null == privacyShowInGameInfo ? _self.privacyShowInGameInfo : privacyShowInGameInfo // ignore: cast_nullable_to_non_nullable
as bool,notificationPrefs: null == notificationPrefs ? _self._notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateProfileRequest {

 String? get displayName; String? get username; String? get inGameName; String? get inGameUid; String? get privacyProfileVisibility; bool? get privacyShowInGameInfo; Map<String, dynamic>? get notificationPrefs; String? get avatarUrl;
/// Create a copy of UpdateProfileRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProfileRequestCopyWith<UpdateProfileRequest> get copyWith => _$UpdateProfileRequestCopyWithImpl<UpdateProfileRequest>(this as UpdateProfileRequest, _$identity);

  /// Serializes this UpdateProfileRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateProfileRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProfileRequest&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.inGameName, _this.inGameName) || other.inGameName == _this.inGameName)&&(identical(other.inGameUid, _this.inGameUid) || other.inGameUid == _this.inGameUid)&&(identical(other.privacyProfileVisibility, _this.privacyProfileVisibility) || other.privacyProfileVisibility == _this.privacyProfileVisibility)&&(identical(other.privacyShowInGameInfo, _this.privacyShowInGameInfo) || other.privacyShowInGameInfo == _this.privacyShowInGameInfo)&&const DeepCollectionEquality().equals(other.notificationPrefs, _this.notificationPrefs)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateProfileRequest;
  return Object.hash(runtimeType,_this.displayName,_this.username,_this.inGameName,_this.inGameUid,_this.privacyProfileVisibility,_this.privacyShowInGameInfo,const DeepCollectionEquality().hash(_this.notificationPrefs),_this.avatarUrl);
}

@override
String toString() {
  final _this = this as UpdateProfileRequest;
  return 'UpdateProfileRequest(displayName: ${_this.displayName}, username: ${_this.username}, inGameName: ${_this.inGameName}, inGameUid: ${_this.inGameUid}, privacyProfileVisibility: ${_this.privacyProfileVisibility}, privacyShowInGameInfo: ${_this.privacyShowInGameInfo}, notificationPrefs: ${_this.notificationPrefs}, avatarUrl: ${_this.avatarUrl})';
}


}

/// @nodoc
abstract mixin class $UpdateProfileRequestCopyWith<$Res>  {
  factory $UpdateProfileRequestCopyWith(UpdateProfileRequest value, $Res Function(UpdateProfileRequest) _then) = _$UpdateProfileRequestCopyWithImpl;
@useResult
$Res call({
 String? displayName, String? username, String? inGameName, String? inGameUid, String? privacyProfileVisibility, bool? privacyShowInGameInfo, Map<String, dynamic>? notificationPrefs, String? avatarUrl
});




}
/// @nodoc
class _$UpdateProfileRequestCopyWithImpl<$Res>
    implements $UpdateProfileRequestCopyWith<$Res> {
  _$UpdateProfileRequestCopyWithImpl(this._self, this._then);

  final UpdateProfileRequest _self;
  final $Res Function(UpdateProfileRequest) _then;

/// Create a copy of UpdateProfileRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? username = freezed,Object? inGameName = freezed,Object? inGameUid = freezed,Object? privacyProfileVisibility = freezed,Object? privacyShowInGameInfo = freezed,Object? notificationPrefs = freezed,Object? avatarUrl = freezed,}) {
  return _then(UpdateProfileRequest(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,inGameName: freezed == inGameName ? _self.inGameName : inGameName // ignore: cast_nullable_to_non_nullable
as String?,inGameUid: freezed == inGameUid ? _self.inGameUid : inGameUid // ignore: cast_nullable_to_non_nullable
as String?,privacyProfileVisibility: freezed == privacyProfileVisibility ? _self.privacyProfileVisibility : privacyProfileVisibility // ignore: cast_nullable_to_non_nullable
as String?,privacyShowInGameInfo: freezed == privacyShowInGameInfo ? _self.privacyShowInGameInfo : privacyShowInGameInfo // ignore: cast_nullable_to_non_nullable
as bool?,notificationPrefs: freezed == notificationPrefs ? _self.notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateProfileRequest].
extension UpdateProfileRequestPatterns on UpdateProfileRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProfileRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProfileRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProfileRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProfileRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProfileRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProfileRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? displayName,  String? username,  String? inGameName,  String? inGameUid,  String? privacyProfileVisibility,  bool? privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProfileRequest() when $default != null:
return $default(_that.displayName,_that.username,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? displayName,  String? username,  String? inGameName,  String? inGameUid,  String? privacyProfileVisibility,  bool? privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _UpdateProfileRequest():
return $default(_that.displayName,_that.username,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? displayName,  String? username,  String? inGameName,  String? inGameUid,  String? privacyProfileVisibility,  bool? privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProfileRequest() when $default != null:
return $default(_that.displayName,_that.username,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateProfileRequest implements UpdateProfileRequest {
  const _UpdateProfileRequest({this.displayName, this.username, this.inGameName, this.inGameUid, this.privacyProfileVisibility, this.privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs, this.avatarUrl}): _notificationPrefs = notificationPrefs;
  factory _UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);

@override final  String? displayName;
@override final  String? username;
@override final  String? inGameName;
@override final  String? inGameUid;
@override final  String? privacyProfileVisibility;
@override final  bool? privacyShowInGameInfo;
 final  Map<String, dynamic>? _notificationPrefs;
@override Map<String, dynamic>? get notificationPrefs {
  final value = _notificationPrefs;
  if (value == null) return null;
  if (_notificationPrefs is EqualUnmodifiableMapView) return _notificationPrefs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? avatarUrl;

/// Create a copy of UpdateProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProfileRequestCopyWith<_UpdateProfileRequest> get copyWith => __$UpdateProfileRequestCopyWithImpl<_UpdateProfileRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProfileRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProfileRequest&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.inGameName, inGameName) || other.inGameName == inGameName)&&(identical(other.inGameUid, inGameUid) || other.inGameUid == inGameUid)&&(identical(other.privacyProfileVisibility, privacyProfileVisibility) || other.privacyProfileVisibility == privacyProfileVisibility)&&(identical(other.privacyShowInGameInfo, privacyShowInGameInfo) || other.privacyShowInGameInfo == privacyShowInGameInfo)&&const DeepCollectionEquality().equals(other.notificationPrefs, _notificationPrefs)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,displayName,username,inGameName,inGameUid,privacyProfileVisibility,privacyShowInGameInfo,const DeepCollectionEquality().hash(_notificationPrefs),avatarUrl);
}

@override
String toString() {
    return 'UpdateProfileRequest(displayName: $displayName, username: $username, inGameName: $inGameName, inGameUid: $inGameUid, privacyProfileVisibility: $privacyProfileVisibility, privacyShowInGameInfo: $privacyShowInGameInfo, notificationPrefs: $notificationPrefs, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$UpdateProfileRequestCopyWith<$Res> implements $UpdateProfileRequestCopyWith<$Res> {
  factory _$UpdateProfileRequestCopyWith(_UpdateProfileRequest value, $Res Function(_UpdateProfileRequest) _then) = __$UpdateProfileRequestCopyWithImpl;
@override @useResult
$Res call({
 String? displayName, String? username, String? inGameName, String? inGameUid, String? privacyProfileVisibility, bool? privacyShowInGameInfo, Map<String, dynamic>? notificationPrefs, String? avatarUrl
});




}
/// @nodoc
class __$UpdateProfileRequestCopyWithImpl<$Res>
    implements _$UpdateProfileRequestCopyWith<$Res> {
  __$UpdateProfileRequestCopyWithImpl(this._self, this._then);

  final _UpdateProfileRequest _self;
  final $Res Function(_UpdateProfileRequest) _then;

/// Create a copy of UpdateProfileRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? username = freezed,Object? inGameName = freezed,Object? inGameUid = freezed,Object? privacyProfileVisibility = freezed,Object? privacyShowInGameInfo = freezed,Object? notificationPrefs = freezed,Object? avatarUrl = freezed,}) {
  return _then(_UpdateProfileRequest(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,inGameName: freezed == inGameName ? _self.inGameName : inGameName // ignore: cast_nullable_to_non_nullable
as String?,inGameUid: freezed == inGameUid ? _self.inGameUid : inGameUid // ignore: cast_nullable_to_non_nullable
as String?,privacyProfileVisibility: freezed == privacyProfileVisibility ? _self.privacyProfileVisibility : privacyProfileVisibility // ignore: cast_nullable_to_non_nullable
as String?,privacyShowInGameInfo: freezed == privacyShowInGameInfo ? _self.privacyShowInGameInfo : privacyShowInGameInfo // ignore: cast_nullable_to_non_nullable
as bool?,notificationPrefs: freezed == notificationPrefs ? _self._notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
