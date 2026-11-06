// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignUpRequest {

 String get email; String get password; String get displayName; bool get termsAccepted; bool get ageAttestation;
/// Create a copy of SignUpRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpRequestCopyWith<SignUpRequest> get copyWith => _$SignUpRequestCopyWithImpl<SignUpRequest>(this as SignUpRequest, _$identity);

  /// Serializes this SignUpRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SignUpRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpRequest&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.termsAccepted, _this.termsAccepted) || other.termsAccepted == _this.termsAccepted)&&(identical(other.ageAttestation, _this.ageAttestation) || other.ageAttestation == _this.ageAttestation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SignUpRequest;
  return Object.hash(runtimeType,_this.email,_this.password,_this.displayName,_this.termsAccepted,_this.ageAttestation);
}

@override
String toString() {
  final _this = this as SignUpRequest;
  return 'SignUpRequest(email: ${_this.email}, password: ${_this.password}, displayName: ${_this.displayName}, termsAccepted: ${_this.termsAccepted}, ageAttestation: ${_this.ageAttestation})';
}


}

/// @nodoc
abstract mixin class $SignUpRequestCopyWith<$Res>  {
  factory $SignUpRequestCopyWith(SignUpRequest value, $Res Function(SignUpRequest) _then) = _$SignUpRequestCopyWithImpl;
@useResult
$Res call({
 String email, String password, String displayName, bool termsAccepted, bool ageAttestation
});




}
/// @nodoc
class _$SignUpRequestCopyWithImpl<$Res>
    implements $SignUpRequestCopyWith<$Res> {
  _$SignUpRequestCopyWithImpl(this._self, this._then);

  final SignUpRequest _self;
  final $Res Function(SignUpRequest) _then;

/// Create a copy of SignUpRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? displayName = null,Object? termsAccepted = null,Object? ageAttestation = null,}) {
  return _then(SignUpRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,ageAttestation: null == ageAttestation ? _self.ageAttestation : ageAttestation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SignUpRequest].
extension SignUpRequestPatterns on SignUpRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignUpRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignUpRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignUpRequest value)  $default,){
final _that = this;
switch (_that) {
case _SignUpRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignUpRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SignUpRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password,  String displayName,  bool termsAccepted,  bool ageAttestation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignUpRequest() when $default != null:
return $default(_that.email,_that.password,_that.displayName,_that.termsAccepted,_that.ageAttestation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password,  String displayName,  bool termsAccepted,  bool ageAttestation)  $default,) {final _that = this;
switch (_that) {
case _SignUpRequest():
return $default(_that.email,_that.password,_that.displayName,_that.termsAccepted,_that.ageAttestation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password,  String displayName,  bool termsAccepted,  bool ageAttestation)?  $default,) {final _that = this;
switch (_that) {
case _SignUpRequest() when $default != null:
return $default(_that.email,_that.password,_that.displayName,_that.termsAccepted,_that.ageAttestation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignUpRequest implements SignUpRequest {
  const _SignUpRequest({required this.email, required this.password, required this.displayName, required this.termsAccepted, required this.ageAttestation});
  factory _SignUpRequest.fromJson(Map<String, dynamic> json) => _$SignUpRequestFromJson(json);

@override final  String email;
@override final  String password;
@override final  String displayName;
@override final  bool termsAccepted;
@override final  bool ageAttestation;

/// Create a copy of SignUpRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpRequestCopyWith<_SignUpRequest> get copyWith => __$SignUpRequestCopyWithImpl<_SignUpRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignUpRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.ageAttestation, ageAttestation) || other.ageAttestation == ageAttestation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,password,displayName,termsAccepted,ageAttestation);
}

@override
String toString() {
    return 'SignUpRequest(email: $email, password: $password, displayName: $displayName, termsAccepted: $termsAccepted, ageAttestation: $ageAttestation)';
}


}

/// @nodoc
abstract mixin class _$SignUpRequestCopyWith<$Res> implements $SignUpRequestCopyWith<$Res> {
  factory _$SignUpRequestCopyWith(_SignUpRequest value, $Res Function(_SignUpRequest) _then) = __$SignUpRequestCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String displayName, bool termsAccepted, bool ageAttestation
});




}
/// @nodoc
class __$SignUpRequestCopyWithImpl<$Res>
    implements _$SignUpRequestCopyWith<$Res> {
  __$SignUpRequestCopyWithImpl(this._self, this._then);

  final _SignUpRequest _self;
  final $Res Function(_SignUpRequest) _then;

/// Create a copy of SignUpRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? displayName = null,Object? termsAccepted = null,Object? ageAttestation = null,}) {
  return _then(_SignUpRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,ageAttestation: null == ageAttestation ? _self.ageAttestation : ageAttestation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SignInRequest {

 String get email; String get password;
/// Create a copy of SignInRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInRequestCopyWith<SignInRequest> get copyWith => _$SignInRequestCopyWithImpl<SignInRequest>(this as SignInRequest, _$identity);

  /// Serializes this SignInRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SignInRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInRequest&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SignInRequest;
  return Object.hash(runtimeType,_this.email,_this.password);
}

@override
String toString() {
  final _this = this as SignInRequest;
  return 'SignInRequest(email: ${_this.email}, password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $SignInRequestCopyWith<$Res>  {
  factory $SignInRequestCopyWith(SignInRequest value, $Res Function(SignInRequest) _then) = _$SignInRequestCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$SignInRequestCopyWithImpl<$Res>
    implements $SignInRequestCopyWith<$Res> {
  _$SignInRequestCopyWithImpl(this._self, this._then);

  final SignInRequest _self;
  final $Res Function(SignInRequest) _then;

/// Create a copy of SignInRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,}) {
  return _then(SignInRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SignInRequest].
extension SignInRequestPatterns on SignInRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignInRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignInRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignInRequest value)  $default,){
final _that = this;
switch (_that) {
case _SignInRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignInRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SignInRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignInRequest() when $default != null:
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password)  $default,) {final _that = this;
switch (_that) {
case _SignInRequest():
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password)?  $default,) {final _that = this;
switch (_that) {
case _SignInRequest() when $default != null:
return $default(_that.email,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignInRequest implements SignInRequest {
  const _SignInRequest({required this.email, required this.password});
  factory _SignInRequest.fromJson(Map<String, dynamic> json) => _$SignInRequestFromJson(json);

@override final  String email;
@override final  String password;

/// Create a copy of SignInRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignInRequestCopyWith<_SignInRequest> get copyWith => __$SignInRequestCopyWithImpl<_SignInRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignInRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email,password);
}

@override
String toString() {
    return 'SignInRequest(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$SignInRequestCopyWith<$Res> implements $SignInRequestCopyWith<$Res> {
  factory _$SignInRequestCopyWith(_SignInRequest value, $Res Function(_SignInRequest) _then) = __$SignInRequestCopyWithImpl;
@override @useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$SignInRequestCopyWithImpl<$Res>
    implements _$SignInRequestCopyWith<$Res> {
  __$SignInRequestCopyWithImpl(this._self, this._then);

  final _SignInRequest _self;
  final $Res Function(_SignInRequest) _then;

/// Create a copy of SignInRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_SignInRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ResetPasswordRequest {

 String get email;
/// Create a copy of ResetPasswordRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResetPasswordRequestCopyWith<ResetPasswordRequest> get copyWith => _$ResetPasswordRequestCopyWithImpl<ResetPasswordRequest>(this as ResetPasswordRequest, _$identity);

  /// Serializes this ResetPasswordRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ResetPasswordRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetPasswordRequest&&(identical(other.email, _this.email) || other.email == _this.email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ResetPasswordRequest;
  return Object.hash(runtimeType,_this.email);
}

@override
String toString() {
  final _this = this as ResetPasswordRequest;
  return 'ResetPasswordRequest(email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $ResetPasswordRequestCopyWith<$Res>  {
  factory $ResetPasswordRequestCopyWith(ResetPasswordRequest value, $Res Function(ResetPasswordRequest) _then) = _$ResetPasswordRequestCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$ResetPasswordRequestCopyWithImpl<$Res>
    implements $ResetPasswordRequestCopyWith<$Res> {
  _$ResetPasswordRequestCopyWithImpl(this._self, this._then);

  final ResetPasswordRequest _self;
  final $Res Function(ResetPasswordRequest) _then;

/// Create a copy of ResetPasswordRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(ResetPasswordRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResetPasswordRequest].
extension ResetPasswordRequestPatterns on ResetPasswordRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResetPasswordRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResetPasswordRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResetPasswordRequest value)  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResetPasswordRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResetPasswordRequest() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordRequest():
return $default(_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordRequest() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResetPasswordRequest implements ResetPasswordRequest {
  const _ResetPasswordRequest({required this.email});
  factory _ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);

@override final  String email;

/// Create a copy of ResetPasswordRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetPasswordRequestCopyWith<_ResetPasswordRequest> get copyWith => __$ResetPasswordRequestCopyWithImpl<_ResetPasswordRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResetPasswordRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordRequest&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'ResetPasswordRequest(email: $email)';
}


}

/// @nodoc
abstract mixin class _$ResetPasswordRequestCopyWith<$Res> implements $ResetPasswordRequestCopyWith<$Res> {
  factory _$ResetPasswordRequestCopyWith(_ResetPasswordRequest value, $Res Function(_ResetPasswordRequest) _then) = __$ResetPasswordRequestCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$ResetPasswordRequestCopyWithImpl<$Res>
    implements _$ResetPasswordRequestCopyWith<$Res> {
  __$ResetPasswordRequestCopyWithImpl(this._self, this._then);

  final _ResetPasswordRequest _self;
  final $Res Function(_ResetPasswordRequest) _then;

/// Create a copy of ResetPasswordRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_ResetPasswordRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UpdatePasswordRequest {

 String get password;
/// Create a copy of UpdatePasswordRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePasswordRequestCopyWith<UpdatePasswordRequest> get copyWith => _$UpdatePasswordRequestCopyWithImpl<UpdatePasswordRequest>(this as UpdatePasswordRequest, _$identity);

  /// Serializes this UpdatePasswordRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdatePasswordRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePasswordRequest&&(identical(other.password, _this.password) || other.password == _this.password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdatePasswordRequest;
  return Object.hash(runtimeType,_this.password);
}

@override
String toString() {
  final _this = this as UpdatePasswordRequest;
  return 'UpdatePasswordRequest(password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $UpdatePasswordRequestCopyWith<$Res>  {
  factory $UpdatePasswordRequestCopyWith(UpdatePasswordRequest value, $Res Function(UpdatePasswordRequest) _then) = _$UpdatePasswordRequestCopyWithImpl;
@useResult
$Res call({
 String password
});




}
/// @nodoc
class _$UpdatePasswordRequestCopyWithImpl<$Res>
    implements $UpdatePasswordRequestCopyWith<$Res> {
  _$UpdatePasswordRequestCopyWithImpl(this._self, this._then);

  final UpdatePasswordRequest _self;
  final $Res Function(UpdatePasswordRequest) _then;

/// Create a copy of UpdatePasswordRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? password = null,}) {
  return _then(UpdatePasswordRequest(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdatePasswordRequest].
extension UpdatePasswordRequestPatterns on UpdatePasswordRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatePasswordRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePasswordRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatePasswordRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdatePasswordRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatePasswordRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatePasswordRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatePasswordRequest() when $default != null:
return $default(_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String password)  $default,) {final _that = this;
switch (_that) {
case _UpdatePasswordRequest():
return $default(_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String password)?  $default,) {final _that = this;
switch (_that) {
case _UpdatePasswordRequest() when $default != null:
return $default(_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdatePasswordRequest implements UpdatePasswordRequest {
  const _UpdatePasswordRequest({required this.password});
  factory _UpdatePasswordRequest.fromJson(Map<String, dynamic> json) => _$UpdatePasswordRequestFromJson(json);

@override final  String password;

/// Create a copy of UpdatePasswordRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePasswordRequestCopyWith<_UpdatePasswordRequest> get copyWith => __$UpdatePasswordRequestCopyWithImpl<_UpdatePasswordRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdatePasswordRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePasswordRequest&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,password);
}

@override
String toString() {
    return 'UpdatePasswordRequest(password: $password)';
}


}

/// @nodoc
abstract mixin class _$UpdatePasswordRequestCopyWith<$Res> implements $UpdatePasswordRequestCopyWith<$Res> {
  factory _$UpdatePasswordRequestCopyWith(_UpdatePasswordRequest value, $Res Function(_UpdatePasswordRequest) _then) = __$UpdatePasswordRequestCopyWithImpl;
@override @useResult
$Res call({
 String password
});




}
/// @nodoc
class __$UpdatePasswordRequestCopyWithImpl<$Res>
    implements _$UpdatePasswordRequestCopyWith<$Res> {
  __$UpdatePasswordRequestCopyWithImpl(this._self, this._then);

  final _UpdatePasswordRequest _self;
  final $Res Function(_UpdatePasswordRequest) _then;

/// Create a copy of UpdatePasswordRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? password = null,}) {
  return _then(_UpdatePasswordRequest(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UpdateEmailRequest {

 String get email;
/// Create a copy of UpdateEmailRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateEmailRequestCopyWith<UpdateEmailRequest> get copyWith => _$UpdateEmailRequestCopyWithImpl<UpdateEmailRequest>(this as UpdateEmailRequest, _$identity);

  /// Serializes this UpdateEmailRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateEmailRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateEmailRequest&&(identical(other.email, _this.email) || other.email == _this.email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateEmailRequest;
  return Object.hash(runtimeType,_this.email);
}

@override
String toString() {
  final _this = this as UpdateEmailRequest;
  return 'UpdateEmailRequest(email: ${_this.email})';
}


}

/// @nodoc
abstract mixin class $UpdateEmailRequestCopyWith<$Res>  {
  factory $UpdateEmailRequestCopyWith(UpdateEmailRequest value, $Res Function(UpdateEmailRequest) _then) = _$UpdateEmailRequestCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$UpdateEmailRequestCopyWithImpl<$Res>
    implements $UpdateEmailRequestCopyWith<$Res> {
  _$UpdateEmailRequestCopyWithImpl(this._self, this._then);

  final UpdateEmailRequest _self;
  final $Res Function(UpdateEmailRequest) _then;

/// Create a copy of UpdateEmailRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(UpdateEmailRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateEmailRequest].
extension UpdateEmailRequestPatterns on UpdateEmailRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateEmailRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateEmailRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateEmailRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateEmailRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateEmailRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateEmailRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateEmailRequest() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _UpdateEmailRequest():
return $default(_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _UpdateEmailRequest() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateEmailRequest implements UpdateEmailRequest {
  const _UpdateEmailRequest({required this.email});
  factory _UpdateEmailRequest.fromJson(Map<String, dynamic> json) => _$UpdateEmailRequestFromJson(json);

@override final  String email;

/// Create a copy of UpdateEmailRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateEmailRequestCopyWith<_UpdateEmailRequest> get copyWith => __$UpdateEmailRequestCopyWithImpl<_UpdateEmailRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateEmailRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateEmailRequest&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'UpdateEmailRequest(email: $email)';
}


}

/// @nodoc
abstract mixin class _$UpdateEmailRequestCopyWith<$Res> implements $UpdateEmailRequestCopyWith<$Res> {
  factory _$UpdateEmailRequestCopyWith(_UpdateEmailRequest value, $Res Function(_UpdateEmailRequest) _then) = __$UpdateEmailRequestCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$UpdateEmailRequestCopyWithImpl<$Res>
    implements _$UpdateEmailRequestCopyWith<$Res> {
  __$UpdateEmailRequestCopyWithImpl(this._self, this._then);

  final _UpdateEmailRequest _self;
  final $Res Function(_UpdateEmailRequest) _then;

/// Create a copy of UpdateEmailRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_UpdateEmailRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AuthResponse {

 String get userId; String? get email; String? get accessToken; String? get refreshToken; bool? get emailVerified; String? get message;
/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResponseCopyWith<AuthResponse> get copyWith => _$AuthResponseCopyWithImpl<AuthResponse>(this as AuthResponse, _$identity);

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResponse&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.emailVerified, _this.emailVerified) || other.emailVerified == _this.emailVerified)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthResponse;
  return Object.hash(runtimeType,_this.userId,_this.email,_this.accessToken,_this.refreshToken,_this.emailVerified,_this.message);
}

@override
String toString() {
  final _this = this as AuthResponse;
  return 'AuthResponse(userId: ${_this.userId}, email: ${_this.email}, accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken}, emailVerified: ${_this.emailVerified}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $AuthResponseCopyWith<$Res>  {
  factory $AuthResponseCopyWith(AuthResponse value, $Res Function(AuthResponse) _then) = _$AuthResponseCopyWithImpl;
@useResult
$Res call({
 String userId, String? email, String? accessToken, String? refreshToken, bool? emailVerified, String? message
});




}
/// @nodoc
class _$AuthResponseCopyWithImpl<$Res>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._self, this._then);

  final AuthResponse _self;
  final $Res Function(AuthResponse) _then;

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? email = freezed,Object? accessToken = freezed,Object? refreshToken = freezed,Object? emailVerified = freezed,Object? message = freezed,}) {
  return _then(AuthResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: freezed == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthResponse].
extension AuthResponsePatterns on AuthResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResponse value)  $default,){
final _that = this;
switch (_that) {
case _AuthResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? email,  String? accessToken,  String? refreshToken,  bool? emailVerified,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
return $default(_that.userId,_that.email,_that.accessToken,_that.refreshToken,_that.emailVerified,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? email,  String? accessToken,  String? refreshToken,  bool? emailVerified,  String? message)  $default,) {final _that = this;
switch (_that) {
case _AuthResponse():
return $default(_that.userId,_that.email,_that.accessToken,_that.refreshToken,_that.emailVerified,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? email,  String? accessToken,  String? refreshToken,  bool? emailVerified,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
return $default(_that.userId,_that.email,_that.accessToken,_that.refreshToken,_that.emailVerified,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResponse implements AuthResponse {
  const _AuthResponse({required this.userId, this.email, this.accessToken, this.refreshToken, this.emailVerified, this.message});
  factory _AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

@override final  String userId;
@override final  String? email;
@override final  String? accessToken;
@override final  String? refreshToken;
@override final  bool? emailVerified;
@override final  String? message;

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResponseCopyWith<_AuthResponse> get copyWith => __$AuthResponseCopyWithImpl<_AuthResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,email,accessToken,refreshToken,emailVerified,message);
}

@override
String toString() {
    return 'AuthResponse(userId: $userId, email: $email, accessToken: $accessToken, refreshToken: $refreshToken, emailVerified: $emailVerified, message: $message)';
}


}

/// @nodoc
abstract mixin class _$AuthResponseCopyWith<$Res> implements $AuthResponseCopyWith<$Res> {
  factory _$AuthResponseCopyWith(_AuthResponse value, $Res Function(_AuthResponse) _then) = __$AuthResponseCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? email, String? accessToken, String? refreshToken, bool? emailVerified, String? message
});




}
/// @nodoc
class __$AuthResponseCopyWithImpl<$Res>
    implements _$AuthResponseCopyWith<$Res> {
  __$AuthResponseCopyWithImpl(this._self, this._then);

  final _AuthResponse _self;
  final $Res Function(_AuthResponse) _then;

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? email = freezed,Object? accessToken = freezed,Object? refreshToken = freezed,Object? emailVerified = freezed,Object? message = freezed,}) {
  return _then(_AuthResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: freezed == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserProfileModel {

 String get id; String get displayName; String? get avatarUrl; String? get inGameName; String? get inGameUid; String? get privacyProfileVisibility; bool? get privacyShowInGameInfo; Map<String, dynamic>? get notificationPrefs; String? get createdAt; String? get updatedAt; String? get deletedAt;
/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileModelCopyWith<UserProfileModel> get copyWith => _$UserProfileModelCopyWithImpl<UserProfileModel>(this as UserProfileModel, _$identity);

  /// Serializes this UserProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserProfileModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.inGameName, _this.inGameName) || other.inGameName == _this.inGameName)&&(identical(other.inGameUid, _this.inGameUid) || other.inGameUid == _this.inGameUid)&&(identical(other.privacyProfileVisibility, _this.privacyProfileVisibility) || other.privacyProfileVisibility == _this.privacyProfileVisibility)&&(identical(other.privacyShowInGameInfo, _this.privacyShowInGameInfo) || other.privacyShowInGameInfo == _this.privacyShowInGameInfo)&&const DeepCollectionEquality().equals(other.notificationPrefs, _this.notificationPrefs)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserProfileModel;
  return Object.hash(runtimeType,_this.id,_this.displayName,_this.avatarUrl,_this.inGameName,_this.inGameUid,_this.privacyProfileVisibility,_this.privacyShowInGameInfo,const DeepCollectionEquality().hash(_this.notificationPrefs),_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as UserProfileModel;
  return 'UserProfileModel(id: ${_this.id}, displayName: ${_this.displayName}, avatarUrl: ${_this.avatarUrl}, inGameName: ${_this.inGameName}, inGameUid: ${_this.inGameUid}, privacyProfileVisibility: ${_this.privacyProfileVisibility}, privacyShowInGameInfo: ${_this.privacyShowInGameInfo}, notificationPrefs: ${_this.notificationPrefs}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $UserProfileModelCopyWith<$Res>  {
  factory $UserProfileModelCopyWith(UserProfileModel value, $Res Function(UserProfileModel) _then) = _$UserProfileModelCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String? avatarUrl, String? inGameName, String? inGameUid, String? privacyProfileVisibility, bool? privacyShowInGameInfo, Map<String, dynamic>? notificationPrefs, String? createdAt, String? updatedAt, String? deletedAt
});




}
/// @nodoc
class _$UserProfileModelCopyWithImpl<$Res>
    implements $UserProfileModelCopyWith<$Res> {
  _$UserProfileModelCopyWithImpl(this._self, this._then);

  final UserProfileModel _self;
  final $Res Function(UserProfileModel) _then;

/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? avatarUrl = freezed,Object? inGameName = freezed,Object? inGameUid = freezed,Object? privacyProfileVisibility = freezed,Object? privacyShowInGameInfo = freezed,Object? notificationPrefs = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(UserProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,inGameName: freezed == inGameName ? _self.inGameName : inGameName // ignore: cast_nullable_to_non_nullable
as String?,inGameUid: freezed == inGameUid ? _self.inGameUid : inGameUid // ignore: cast_nullable_to_non_nullable
as String?,privacyProfileVisibility: freezed == privacyProfileVisibility ? _self.privacyProfileVisibility : privacyProfileVisibility // ignore: cast_nullable_to_non_nullable
as String?,privacyShowInGameInfo: freezed == privacyShowInGameInfo ? _self.privacyShowInGameInfo : privacyShowInGameInfo // ignore: cast_nullable_to_non_nullable
as bool?,notificationPrefs: freezed == notificationPrefs ? _self.notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileModel].
extension UserProfileModelPatterns on UserProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String? avatarUrl,  String? inGameName,  String? inGameUid,  String? privacyProfileVisibility,  bool? privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs,  String? createdAt,  String? updatedAt,  String? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String? avatarUrl,  String? inGameName,  String? inGameUid,  String? privacyProfileVisibility,  bool? privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs,  String? createdAt,  String? updatedAt,  String? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfileModel():
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String? avatarUrl,  String? inGameName,  String? inGameUid,  String? privacyProfileVisibility,  bool? privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs,  String? createdAt,  String? updatedAt,  String? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileModel implements UserProfileModel {
  const _UserProfileModel({required this.id, required this.displayName, this.avatarUrl, this.inGameName, this.inGameUid, this.privacyProfileVisibility, this.privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs, this.createdAt, this.updatedAt, this.deletedAt}): _notificationPrefs = notificationPrefs;
  factory _UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);

@override final  String id;
@override final  String displayName;
@override final  String? avatarUrl;
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

@override final  String? createdAt;
@override final  String? updatedAt;
@override final  String? deletedAt;

/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileModelCopyWith<_UserProfileModel> get copyWith => __$UserProfileModelCopyWithImpl<_UserProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.inGameName, inGameName) || other.inGameName == inGameName)&&(identical(other.inGameUid, inGameUid) || other.inGameUid == inGameUid)&&(identical(other.privacyProfileVisibility, privacyProfileVisibility) || other.privacyProfileVisibility == privacyProfileVisibility)&&(identical(other.privacyShowInGameInfo, privacyShowInGameInfo) || other.privacyShowInGameInfo == privacyShowInGameInfo)&&const DeepCollectionEquality().equals(other.notificationPrefs, _notificationPrefs)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,displayName,avatarUrl,inGameName,inGameUid,privacyProfileVisibility,privacyShowInGameInfo,const DeepCollectionEquality().hash(_notificationPrefs),createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'UserProfileModel(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, inGameName: $inGameName, inGameUid: $inGameUid, privacyProfileVisibility: $privacyProfileVisibility, privacyShowInGameInfo: $privacyShowInGameInfo, notificationPrefs: $notificationPrefs, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileModelCopyWith<$Res> implements $UserProfileModelCopyWith<$Res> {
  factory _$UserProfileModelCopyWith(_UserProfileModel value, $Res Function(_UserProfileModel) _then) = __$UserProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String? avatarUrl, String? inGameName, String? inGameUid, String? privacyProfileVisibility, bool? privacyShowInGameInfo, Map<String, dynamic>? notificationPrefs, String? createdAt, String? updatedAt, String? deletedAt
});




}
/// @nodoc
class __$UserProfileModelCopyWithImpl<$Res>
    implements _$UserProfileModelCopyWith<$Res> {
  __$UserProfileModelCopyWithImpl(this._self, this._then);

  final _UserProfileModel _self;
  final $Res Function(_UserProfileModel) _then;

/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? avatarUrl = freezed,Object? inGameName = freezed,Object? inGameUid = freezed,Object? privacyProfileVisibility = freezed,Object? privacyShowInGameInfo = freezed,Object? notificationPrefs = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_UserProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,inGameName: freezed == inGameName ? _self.inGameName : inGameName // ignore: cast_nullable_to_non_nullable
as String?,inGameUid: freezed == inGameUid ? _self.inGameUid : inGameUid // ignore: cast_nullable_to_non_nullable
as String?,privacyProfileVisibility: freezed == privacyProfileVisibility ? _self.privacyProfileVisibility : privacyProfileVisibility // ignore: cast_nullable_to_non_nullable
as String?,privacyShowInGameInfo: freezed == privacyShowInGameInfo ? _self.privacyShowInGameInfo : privacyShowInGameInfo // ignore: cast_nullable_to_non_nullable
as bool?,notificationPrefs: freezed == notificationPrefs ? _self._notificationPrefs : notificationPrefs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MfaEnrollResponse {

 String get factorId; String get qrCode; String get secret; String get uri;
/// Create a copy of MfaEnrollResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaEnrollResponseCopyWith<MfaEnrollResponse> get copyWith => _$MfaEnrollResponseCopyWithImpl<MfaEnrollResponse>(this as MfaEnrollResponse, _$identity);

  /// Serializes this MfaEnrollResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MfaEnrollResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaEnrollResponse&&(identical(other.factorId, _this.factorId) || other.factorId == _this.factorId)&&(identical(other.qrCode, _this.qrCode) || other.qrCode == _this.qrCode)&&(identical(other.secret, _this.secret) || other.secret == _this.secret)&&(identical(other.uri, _this.uri) || other.uri == _this.uri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MfaEnrollResponse;
  return Object.hash(runtimeType,_this.factorId,_this.qrCode,_this.secret,_this.uri);
}

@override
String toString() {
  final _this = this as MfaEnrollResponse;
  return 'MfaEnrollResponse(factorId: ${_this.factorId}, qrCode: ${_this.qrCode}, secret: ${_this.secret}, uri: ${_this.uri})';
}


}

/// @nodoc
abstract mixin class $MfaEnrollResponseCopyWith<$Res>  {
  factory $MfaEnrollResponseCopyWith(MfaEnrollResponse value, $Res Function(MfaEnrollResponse) _then) = _$MfaEnrollResponseCopyWithImpl;
@useResult
$Res call({
 String factorId, String qrCode, String secret, String uri
});




}
/// @nodoc
class _$MfaEnrollResponseCopyWithImpl<$Res>
    implements $MfaEnrollResponseCopyWith<$Res> {
  _$MfaEnrollResponseCopyWithImpl(this._self, this._then);

  final MfaEnrollResponse _self;
  final $Res Function(MfaEnrollResponse) _then;

/// Create a copy of MfaEnrollResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? factorId = null,Object? qrCode = null,Object? secret = null,Object? uri = null,}) {
  return _then(MfaEnrollResponse(
factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,qrCode: null == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MfaEnrollResponse].
extension MfaEnrollResponsePatterns on MfaEnrollResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MfaEnrollResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MfaEnrollResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MfaEnrollResponse value)  $default,){
final _that = this;
switch (_that) {
case _MfaEnrollResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MfaEnrollResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MfaEnrollResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String factorId,  String qrCode,  String secret,  String uri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MfaEnrollResponse() when $default != null:
return $default(_that.factorId,_that.qrCode,_that.secret,_that.uri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String factorId,  String qrCode,  String secret,  String uri)  $default,) {final _that = this;
switch (_that) {
case _MfaEnrollResponse():
return $default(_that.factorId,_that.qrCode,_that.secret,_that.uri);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String factorId,  String qrCode,  String secret,  String uri)?  $default,) {final _that = this;
switch (_that) {
case _MfaEnrollResponse() when $default != null:
return $default(_that.factorId,_that.qrCode,_that.secret,_that.uri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MfaEnrollResponse implements MfaEnrollResponse {
  const _MfaEnrollResponse({required this.factorId, required this.qrCode, required this.secret, required this.uri});
  factory _MfaEnrollResponse.fromJson(Map<String, dynamic> json) => _$MfaEnrollResponseFromJson(json);

@override final  String factorId;
@override final  String qrCode;
@override final  String secret;
@override final  String uri;

/// Create a copy of MfaEnrollResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MfaEnrollResponseCopyWith<_MfaEnrollResponse> get copyWith => __$MfaEnrollResponseCopyWithImpl<_MfaEnrollResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MfaEnrollResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaEnrollResponse&&(identical(other.factorId, factorId) || other.factorId == factorId)&&(identical(other.qrCode, qrCode) || other.qrCode == qrCode)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.uri, uri) || other.uri == uri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,factorId,qrCode,secret,uri);
}

@override
String toString() {
    return 'MfaEnrollResponse(factorId: $factorId, qrCode: $qrCode, secret: $secret, uri: $uri)';
}


}

/// @nodoc
abstract mixin class _$MfaEnrollResponseCopyWith<$Res> implements $MfaEnrollResponseCopyWith<$Res> {
  factory _$MfaEnrollResponseCopyWith(_MfaEnrollResponse value, $Res Function(_MfaEnrollResponse) _then) = __$MfaEnrollResponseCopyWithImpl;
@override @useResult
$Res call({
 String factorId, String qrCode, String secret, String uri
});




}
/// @nodoc
class __$MfaEnrollResponseCopyWithImpl<$Res>
    implements _$MfaEnrollResponseCopyWith<$Res> {
  __$MfaEnrollResponseCopyWithImpl(this._self, this._then);

  final _MfaEnrollResponse _self;
  final $Res Function(_MfaEnrollResponse) _then;

/// Create a copy of MfaEnrollResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? factorId = null,Object? qrCode = null,Object? secret = null,Object? uri = null,}) {
  return _then(_MfaEnrollResponse(
factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,qrCode: null == qrCode ? _self.qrCode : qrCode // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MfaChallengeResponse {

 String get factorId; String get challengeId;
/// Create a copy of MfaChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaChallengeResponseCopyWith<MfaChallengeResponse> get copyWith => _$MfaChallengeResponseCopyWithImpl<MfaChallengeResponse>(this as MfaChallengeResponse, _$identity);

  /// Serializes this MfaChallengeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MfaChallengeResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaChallengeResponse&&(identical(other.factorId, _this.factorId) || other.factorId == _this.factorId)&&(identical(other.challengeId, _this.challengeId) || other.challengeId == _this.challengeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MfaChallengeResponse;
  return Object.hash(runtimeType,_this.factorId,_this.challengeId);
}

@override
String toString() {
  final _this = this as MfaChallengeResponse;
  return 'MfaChallengeResponse(factorId: ${_this.factorId}, challengeId: ${_this.challengeId})';
}


}

/// @nodoc
abstract mixin class $MfaChallengeResponseCopyWith<$Res>  {
  factory $MfaChallengeResponseCopyWith(MfaChallengeResponse value, $Res Function(MfaChallengeResponse) _then) = _$MfaChallengeResponseCopyWithImpl;
@useResult
$Res call({
 String factorId, String challengeId
});




}
/// @nodoc
class _$MfaChallengeResponseCopyWithImpl<$Res>
    implements $MfaChallengeResponseCopyWith<$Res> {
  _$MfaChallengeResponseCopyWithImpl(this._self, this._then);

  final MfaChallengeResponse _self;
  final $Res Function(MfaChallengeResponse) _then;

/// Create a copy of MfaChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? factorId = null,Object? challengeId = null,}) {
  return _then(MfaChallengeResponse(
factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MfaChallengeResponse].
extension MfaChallengeResponsePatterns on MfaChallengeResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MfaChallengeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MfaChallengeResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MfaChallengeResponse value)  $default,){
final _that = this;
switch (_that) {
case _MfaChallengeResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MfaChallengeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MfaChallengeResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String factorId,  String challengeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MfaChallengeResponse() when $default != null:
return $default(_that.factorId,_that.challengeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String factorId,  String challengeId)  $default,) {final _that = this;
switch (_that) {
case _MfaChallengeResponse():
return $default(_that.factorId,_that.challengeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String factorId,  String challengeId)?  $default,) {final _that = this;
switch (_that) {
case _MfaChallengeResponse() when $default != null:
return $default(_that.factorId,_that.challengeId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MfaChallengeResponse implements MfaChallengeResponse {
  const _MfaChallengeResponse({required this.factorId, required this.challengeId});
  factory _MfaChallengeResponse.fromJson(Map<String, dynamic> json) => _$MfaChallengeResponseFromJson(json);

@override final  String factorId;
@override final  String challengeId;

/// Create a copy of MfaChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MfaChallengeResponseCopyWith<_MfaChallengeResponse> get copyWith => __$MfaChallengeResponseCopyWithImpl<_MfaChallengeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MfaChallengeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaChallengeResponse&&(identical(other.factorId, factorId) || other.factorId == factorId)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,factorId,challengeId);
}

@override
String toString() {
    return 'MfaChallengeResponse(factorId: $factorId, challengeId: $challengeId)';
}


}

/// @nodoc
abstract mixin class _$MfaChallengeResponseCopyWith<$Res> implements $MfaChallengeResponseCopyWith<$Res> {
  factory _$MfaChallengeResponseCopyWith(_MfaChallengeResponse value, $Res Function(_MfaChallengeResponse) _then) = __$MfaChallengeResponseCopyWithImpl;
@override @useResult
$Res call({
 String factorId, String challengeId
});




}
/// @nodoc
class __$MfaChallengeResponseCopyWithImpl<$Res>
    implements _$MfaChallengeResponseCopyWith<$Res> {
  __$MfaChallengeResponseCopyWithImpl(this._self, this._then);

  final _MfaChallengeResponse _self;
  final $Res Function(_MfaChallengeResponse) _then;

/// Create a copy of MfaChallengeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? factorId = null,Object? challengeId = null,}) {
  return _then(_MfaChallengeResponse(
factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MfaVerifyResponse {

 bool get verified; String? get accessToken; String? get refreshToken;
/// Create a copy of MfaVerifyResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaVerifyResponseCopyWith<MfaVerifyResponse> get copyWith => _$MfaVerifyResponseCopyWithImpl<MfaVerifyResponse>(this as MfaVerifyResponse, _$identity);

  /// Serializes this MfaVerifyResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MfaVerifyResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaVerifyResponse&&(identical(other.verified, _this.verified) || other.verified == _this.verified)&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MfaVerifyResponse;
  return Object.hash(runtimeType,_this.verified,_this.accessToken,_this.refreshToken);
}

@override
String toString() {
  final _this = this as MfaVerifyResponse;
  return 'MfaVerifyResponse(verified: ${_this.verified}, accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken})';
}


}

/// @nodoc
abstract mixin class $MfaVerifyResponseCopyWith<$Res>  {
  factory $MfaVerifyResponseCopyWith(MfaVerifyResponse value, $Res Function(MfaVerifyResponse) _then) = _$MfaVerifyResponseCopyWithImpl;
@useResult
$Res call({
 bool verified, String? accessToken, String? refreshToken
});




}
/// @nodoc
class _$MfaVerifyResponseCopyWithImpl<$Res>
    implements $MfaVerifyResponseCopyWith<$Res> {
  _$MfaVerifyResponseCopyWithImpl(this._self, this._then);

  final MfaVerifyResponse _self;
  final $Res Function(MfaVerifyResponse) _then;

/// Create a copy of MfaVerifyResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verified = null,Object? accessToken = freezed,Object? refreshToken = freezed,}) {
  return _then(MfaVerifyResponse(
verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MfaVerifyResponse].
extension MfaVerifyResponsePatterns on MfaVerifyResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MfaVerifyResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MfaVerifyResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MfaVerifyResponse value)  $default,){
final _that = this;
switch (_that) {
case _MfaVerifyResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MfaVerifyResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MfaVerifyResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool verified,  String? accessToken,  String? refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MfaVerifyResponse() when $default != null:
return $default(_that.verified,_that.accessToken,_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool verified,  String? accessToken,  String? refreshToken)  $default,) {final _that = this;
switch (_that) {
case _MfaVerifyResponse():
return $default(_that.verified,_that.accessToken,_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool verified,  String? accessToken,  String? refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _MfaVerifyResponse() when $default != null:
return $default(_that.verified,_that.accessToken,_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MfaVerifyResponse implements MfaVerifyResponse {
  const _MfaVerifyResponse({required this.verified, this.accessToken, this.refreshToken});
  factory _MfaVerifyResponse.fromJson(Map<String, dynamic> json) => _$MfaVerifyResponseFromJson(json);

@override final  bool verified;
@override final  String? accessToken;
@override final  String? refreshToken;

/// Create a copy of MfaVerifyResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MfaVerifyResponseCopyWith<_MfaVerifyResponse> get copyWith => __$MfaVerifyResponseCopyWithImpl<_MfaVerifyResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MfaVerifyResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaVerifyResponse&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,verified,accessToken,refreshToken);
}

@override
String toString() {
    return 'MfaVerifyResponse(verified: $verified, accessToken: $accessToken, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$MfaVerifyResponseCopyWith<$Res> implements $MfaVerifyResponseCopyWith<$Res> {
  factory _$MfaVerifyResponseCopyWith(_MfaVerifyResponse value, $Res Function(_MfaVerifyResponse) _then) = __$MfaVerifyResponseCopyWithImpl;
@override @useResult
$Res call({
 bool verified, String? accessToken, String? refreshToken
});




}
/// @nodoc
class __$MfaVerifyResponseCopyWithImpl<$Res>
    implements _$MfaVerifyResponseCopyWith<$Res> {
  __$MfaVerifyResponseCopyWithImpl(this._self, this._then);

  final _MfaVerifyResponse _self;
  final $Res Function(_MfaVerifyResponse) _then;

/// Create a copy of MfaVerifyResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verified = null,Object? accessToken = freezed,Object? refreshToken = freezed,}) {
  return _then(_MfaVerifyResponse(
verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SessionState {

 String? get userId; String? get email; String? get accessToken; String? get refreshToken; bool? get emailVerified; String? get aalLevel; List<String>? get factors;
/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStateCopyWith<SessionState> get copyWith => _$SessionStateCopyWithImpl<SessionState>(this as SessionState, _$identity);

  /// Serializes this SessionState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionState&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.emailVerified, _this.emailVerified) || other.emailVerified == _this.emailVerified)&&(identical(other.aalLevel, _this.aalLevel) || other.aalLevel == _this.aalLevel)&&const DeepCollectionEquality().equals(other.factors, _this.factors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionState;
  return Object.hash(runtimeType,_this.userId,_this.email,_this.accessToken,_this.refreshToken,_this.emailVerified,_this.aalLevel,const DeepCollectionEquality().hash(_this.factors));
}

@override
String toString() {
  final _this = this as SessionState;
  return 'SessionState(userId: ${_this.userId}, email: ${_this.email}, accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken}, emailVerified: ${_this.emailVerified}, aalLevel: ${_this.aalLevel}, factors: ${_this.factors})';
}


}

/// @nodoc
abstract mixin class $SessionStateCopyWith<$Res>  {
  factory $SessionStateCopyWith(SessionState value, $Res Function(SessionState) _then) = _$SessionStateCopyWithImpl;
@useResult
$Res call({
 String? userId, String? email, String? accessToken, String? refreshToken, bool? emailVerified, String? aalLevel, List<String>? factors
});




}
/// @nodoc
class _$SessionStateCopyWithImpl<$Res>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._self, this._then);

  final SessionState _self;
  final $Res Function(SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = freezed,Object? email = freezed,Object? accessToken = freezed,Object? refreshToken = freezed,Object? emailVerified = freezed,Object? aalLevel = freezed,Object? factors = freezed,}) {
  return _then(SessionState(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: freezed == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool?,aalLevel: freezed == aalLevel ? _self.aalLevel : aalLevel // ignore: cast_nullable_to_non_nullable
as String?,factors: freezed == factors ? _self.factors : factors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionState].
extension SessionStatePatterns on SessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionState value)  $default,){
final _that = this;
switch (_that) {
case _SessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionState value)?  $default,){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? userId,  String? email,  String? accessToken,  String? refreshToken,  bool? emailVerified,  String? aalLevel,  List<String>? factors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.userId,_that.email,_that.accessToken,_that.refreshToken,_that.emailVerified,_that.aalLevel,_that.factors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? userId,  String? email,  String? accessToken,  String? refreshToken,  bool? emailVerified,  String? aalLevel,  List<String>? factors)  $default,) {final _that = this;
switch (_that) {
case _SessionState():
return $default(_that.userId,_that.email,_that.accessToken,_that.refreshToken,_that.emailVerified,_that.aalLevel,_that.factors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? userId,  String? email,  String? accessToken,  String? refreshToken,  bool? emailVerified,  String? aalLevel,  List<String>? factors)?  $default,) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.userId,_that.email,_that.accessToken,_that.refreshToken,_that.emailVerified,_that.aalLevel,_that.factors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionState implements SessionState {
  const _SessionState({this.userId, this.email, this.accessToken, this.refreshToken, this.emailVerified, this.aalLevel,  List<String>? factors}): _factors = factors;
  factory _SessionState.fromJson(Map<String, dynamic> json) => _$SessionStateFromJson(json);

@override final  String? userId;
@override final  String? email;
@override final  String? accessToken;
@override final  String? refreshToken;
@override final  bool? emailVerified;
@override final  String? aalLevel;
 final  List<String>? _factors;
@override List<String>? get factors {
  final value = _factors;
  if (value == null) return null;
  if (_factors is EqualUnmodifiableListView) return _factors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionStateCopyWith<_SessionState> get copyWith => __$SessionStateCopyWithImpl<_SessionState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionState&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.aalLevel, aalLevel) || other.aalLevel == aalLevel)&&const DeepCollectionEquality().equals(other.factors, _factors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,email,accessToken,refreshToken,emailVerified,aalLevel,const DeepCollectionEquality().hash(_factors));
}

@override
String toString() {
    return 'SessionState(userId: $userId, email: $email, accessToken: $accessToken, refreshToken: $refreshToken, emailVerified: $emailVerified, aalLevel: $aalLevel, factors: $factors)';
}


}

/// @nodoc
abstract mixin class _$SessionStateCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory _$SessionStateCopyWith(_SessionState value, $Res Function(_SessionState) _then) = __$SessionStateCopyWithImpl;
@override @useResult
$Res call({
 String? userId, String? email, String? accessToken, String? refreshToken, bool? emailVerified, String? aalLevel, List<String>? factors
});




}
/// @nodoc
class __$SessionStateCopyWithImpl<$Res>
    implements _$SessionStateCopyWith<$Res> {
  __$SessionStateCopyWithImpl(this._self, this._then);

  final _SessionState _self;
  final $Res Function(_SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = freezed,Object? email = freezed,Object? accessToken = freezed,Object? refreshToken = freezed,Object? emailVerified = freezed,Object? aalLevel = freezed,Object? factors = freezed,}) {
  return _then(_SessionState(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: freezed == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool?,aalLevel: freezed == aalLevel ? _self.aalLevel : aalLevel // ignore: cast_nullable_to_non_nullable
as String?,factors: freezed == factors ? _self._factors : factors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$MfaFactorModel {

 String get id; String get factorType; String get status; String? get createdAt; String? get updatedAt;
/// Create a copy of MfaFactorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaFactorModelCopyWith<MfaFactorModel> get copyWith => _$MfaFactorModelCopyWithImpl<MfaFactorModel>(this as MfaFactorModel, _$identity);

  /// Serializes this MfaFactorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MfaFactorModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaFactorModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.factorType, _this.factorType) || other.factorType == _this.factorType)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MfaFactorModel;
  return Object.hash(runtimeType,_this.id,_this.factorType,_this.status,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as MfaFactorModel;
  return 'MfaFactorModel(id: ${_this.id}, factorType: ${_this.factorType}, status: ${_this.status}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $MfaFactorModelCopyWith<$Res>  {
  factory $MfaFactorModelCopyWith(MfaFactorModel value, $Res Function(MfaFactorModel) _then) = _$MfaFactorModelCopyWithImpl;
@useResult
$Res call({
 String id, String factorType, String status, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$MfaFactorModelCopyWithImpl<$Res>
    implements $MfaFactorModelCopyWith<$Res> {
  _$MfaFactorModelCopyWithImpl(this._self, this._then);

  final MfaFactorModel _self;
  final $Res Function(MfaFactorModel) _then;

/// Create a copy of MfaFactorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? factorType = null,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(MfaFactorModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,factorType: null == factorType ? _self.factorType : factorType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MfaFactorModel].
extension MfaFactorModelPatterns on MfaFactorModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MfaFactorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MfaFactorModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MfaFactorModel value)  $default,){
final _that = this;
switch (_that) {
case _MfaFactorModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MfaFactorModel value)?  $default,){
final _that = this;
switch (_that) {
case _MfaFactorModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String factorType,  String status,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MfaFactorModel() when $default != null:
return $default(_that.id,_that.factorType,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String factorType,  String status,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MfaFactorModel():
return $default(_that.id,_that.factorType,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String factorType,  String status,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MfaFactorModel() when $default != null:
return $default(_that.id,_that.factorType,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MfaFactorModel implements MfaFactorModel {
  const _MfaFactorModel({required this.id, required this.factorType, required this.status, this.createdAt, this.updatedAt});
  factory _MfaFactorModel.fromJson(Map<String, dynamic> json) => _$MfaFactorModelFromJson(json);

@override final  String id;
@override final  String factorType;
@override final  String status;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of MfaFactorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MfaFactorModelCopyWith<_MfaFactorModel> get copyWith => __$MfaFactorModelCopyWithImpl<_MfaFactorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MfaFactorModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaFactorModel&&(identical(other.id, id) || other.id == id)&&(identical(other.factorType, factorType) || other.factorType == factorType)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,factorType,status,createdAt,updatedAt);
}

@override
String toString() {
    return 'MfaFactorModel(id: $id, factorType: $factorType, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MfaFactorModelCopyWith<$Res> implements $MfaFactorModelCopyWith<$Res> {
  factory _$MfaFactorModelCopyWith(_MfaFactorModel value, $Res Function(_MfaFactorModel) _then) = __$MfaFactorModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String factorType, String status, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$MfaFactorModelCopyWithImpl<$Res>
    implements _$MfaFactorModelCopyWith<$Res> {
  __$MfaFactorModelCopyWithImpl(this._self, this._then);

  final _MfaFactorModel _self;
  final $Res Function(_MfaFactorModel) _then;

/// Create a copy of MfaFactorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? factorType = null,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_MfaFactorModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,factorType: null == factorType ? _self.factorType : factorType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AccountDeletionRequest {

 String get password;
/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountDeletionRequestCopyWith<AccountDeletionRequest> get copyWith => _$AccountDeletionRequestCopyWithImpl<AccountDeletionRequest>(this as AccountDeletionRequest, _$identity);

  /// Serializes this AccountDeletionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccountDeletionRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDeletionRequest&&(identical(other.password, _this.password) || other.password == _this.password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccountDeletionRequest;
  return Object.hash(runtimeType,_this.password);
}

@override
String toString() {
  final _this = this as AccountDeletionRequest;
  return 'AccountDeletionRequest(password: ${_this.password})';
}


}

/// @nodoc
abstract mixin class $AccountDeletionRequestCopyWith<$Res>  {
  factory $AccountDeletionRequestCopyWith(AccountDeletionRequest value, $Res Function(AccountDeletionRequest) _then) = _$AccountDeletionRequestCopyWithImpl;
@useResult
$Res call({
 String password
});




}
/// @nodoc
class _$AccountDeletionRequestCopyWithImpl<$Res>
    implements $AccountDeletionRequestCopyWith<$Res> {
  _$AccountDeletionRequestCopyWithImpl(this._self, this._then);

  final AccountDeletionRequest _self;
  final $Res Function(AccountDeletionRequest) _then;

/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? password = null,}) {
  return _then(AccountDeletionRequest(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountDeletionRequest].
extension AccountDeletionRequestPatterns on AccountDeletionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountDeletionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountDeletionRequest value)  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountDeletionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
return $default(_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String password)  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionRequest():
return $default(_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String password)?  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
return $default(_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountDeletionRequest implements AccountDeletionRequest {
  const _AccountDeletionRequest({required this.password});
  factory _AccountDeletionRequest.fromJson(Map<String, dynamic> json) => _$AccountDeletionRequestFromJson(json);

@override final  String password;

/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountDeletionRequestCopyWith<_AccountDeletionRequest> get copyWith => __$AccountDeletionRequestCopyWithImpl<_AccountDeletionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountDeletionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountDeletionRequest&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,password);
}

@override
String toString() {
    return 'AccountDeletionRequest(password: $password)';
}


}

/// @nodoc
abstract mixin class _$AccountDeletionRequestCopyWith<$Res> implements $AccountDeletionRequestCopyWith<$Res> {
  factory _$AccountDeletionRequestCopyWith(_AccountDeletionRequest value, $Res Function(_AccountDeletionRequest) _then) = __$AccountDeletionRequestCopyWithImpl;
@override @useResult
$Res call({
 String password
});




}
/// @nodoc
class __$AccountDeletionRequestCopyWithImpl<$Res>
    implements _$AccountDeletionRequestCopyWith<$Res> {
  __$AccountDeletionRequestCopyWithImpl(this._self, this._then);

  final _AccountDeletionRequest _self;
  final $Res Function(_AccountDeletionRequest) _then;

/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? password = null,}) {
  return _then(_AccountDeletionRequest(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
