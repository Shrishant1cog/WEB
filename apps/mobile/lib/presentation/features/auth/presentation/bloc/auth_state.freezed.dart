// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthStatus {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus()';
}


}

/// @nodoc
class $AuthStatusCopyWith<$Res>  {
$AuthStatusCopyWith(AuthStatus _, $Res Function(AuthStatus) __);
}


/// Adds pattern-matching-related methods to [AuthStatus].
extension AuthStatusPatterns on AuthStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Unauthenticated value)?  unauthenticated,TResult Function( _Loading value)?  loading,TResult Function( _Authenticated value)?  authenticated,TResult Function( _VerificationPending value)?  verificationPending,TResult Function( _MfaRequired value)?  mfaRequired,TResult Function( _MfaEnrollment value)?  mfaEnrollment,TResult Function( _MfaChallenge value)?  mfaChallenge,TResult Function( _Failure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _Loading() when loading != null:
return loading(_that);case _Authenticated() when authenticated != null:
return authenticated(_that);case _VerificationPending() when verificationPending != null:
return verificationPending(_that);case _MfaRequired() when mfaRequired != null:
return mfaRequired(_that);case _MfaEnrollment() when mfaEnrollment != null:
return mfaEnrollment(_that);case _MfaChallenge() when mfaChallenge != null:
return mfaChallenge(_that);case _Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Unauthenticated value)  unauthenticated,required TResult Function( _Loading value)  loading,required TResult Function( _Authenticated value)  authenticated,required TResult Function( _VerificationPending value)  verificationPending,required TResult Function( _MfaRequired value)  mfaRequired,required TResult Function( _MfaEnrollment value)  mfaEnrollment,required TResult Function( _MfaChallenge value)  mfaChallenge,required TResult Function( _Failure value)  failure,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Unauthenticated():
return unauthenticated(_that);case _Loading():
return loading(_that);case _Authenticated():
return authenticated(_that);case _VerificationPending():
return verificationPending(_that);case _MfaRequired():
return mfaRequired(_that);case _MfaEnrollment():
return mfaEnrollment(_that);case _MfaChallenge():
return mfaChallenge(_that);case _Failure():
return failure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Unauthenticated value)?  unauthenticated,TResult? Function( _Loading value)?  loading,TResult? Function( _Authenticated value)?  authenticated,TResult? Function( _VerificationPending value)?  verificationPending,TResult? Function( _MfaRequired value)?  mfaRequired,TResult? Function( _MfaEnrollment value)?  mfaEnrollment,TResult? Function( _MfaChallenge value)?  mfaChallenge,TResult? Function( _Failure value)?  failure,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _Loading() when loading != null:
return loading(_that);case _Authenticated() when authenticated != null:
return authenticated(_that);case _VerificationPending() when verificationPending != null:
return verificationPending(_that);case _MfaRequired() when mfaRequired != null:
return mfaRequired(_that);case _MfaEnrollment() when mfaEnrollment != null:
return mfaEnrollment(_that);case _MfaChallenge() when mfaChallenge != null:
return mfaChallenge(_that);case _Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  unauthenticated,TResult Function()?  loading,TResult Function()?  authenticated,TResult Function()?  verificationPending,TResult Function()?  mfaRequired,TResult Function()?  mfaEnrollment,TResult Function()?  mfaChallenge,TResult Function()?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _Loading() when loading != null:
return loading();case _Authenticated() when authenticated != null:
return authenticated();case _VerificationPending() when verificationPending != null:
return verificationPending();case _MfaRequired() when mfaRequired != null:
return mfaRequired();case _MfaEnrollment() when mfaEnrollment != null:
return mfaEnrollment();case _MfaChallenge() when mfaChallenge != null:
return mfaChallenge();case _Failure() when failure != null:
return failure();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  unauthenticated,required TResult Function()  loading,required TResult Function()  authenticated,required TResult Function()  verificationPending,required TResult Function()  mfaRequired,required TResult Function()  mfaEnrollment,required TResult Function()  mfaChallenge,required TResult Function()  failure,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Unauthenticated():
return unauthenticated();case _Loading():
return loading();case _Authenticated():
return authenticated();case _VerificationPending():
return verificationPending();case _MfaRequired():
return mfaRequired();case _MfaEnrollment():
return mfaEnrollment();case _MfaChallenge():
return mfaChallenge();case _Failure():
return failure();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  unauthenticated,TResult? Function()?  loading,TResult? Function()?  authenticated,TResult? Function()?  verificationPending,TResult? Function()?  mfaRequired,TResult? Function()?  mfaEnrollment,TResult? Function()?  mfaChallenge,TResult? Function()?  failure,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Unauthenticated() when unauthenticated != null:
return unauthenticated();case _Loading() when loading != null:
return loading();case _Authenticated() when authenticated != null:
return authenticated();case _VerificationPending() when verificationPending != null:
return verificationPending();case _MfaRequired() when mfaRequired != null:
return mfaRequired();case _MfaEnrollment() when mfaEnrollment != null:
return mfaEnrollment();case _MfaChallenge() when mfaChallenge != null:
return mfaChallenge();case _Failure() when failure != null:
return failure();case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements AuthStatus {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus.initial()';
}


}




/// @nodoc


class _Unauthenticated implements AuthStatus {
  const _Unauthenticated();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus.unauthenticated()';
}


}




/// @nodoc


class _Loading implements AuthStatus {
  const _Loading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus.loading()';
}


}




/// @nodoc


class _Authenticated implements AuthStatus {
  const _Authenticated();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Authenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus.authenticated()';
}


}




/// @nodoc


class _VerificationPending implements AuthStatus {
  const _VerificationPending();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationPending);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus.verificationPending()';
}


}




/// @nodoc


class _MfaRequired implements AuthStatus {
  const _MfaRequired();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaRequired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus.mfaRequired()';
}


}




/// @nodoc


class _MfaEnrollment implements AuthStatus {
  const _MfaEnrollment();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaEnrollment);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus.mfaEnrollment()';
}


}




/// @nodoc


class _MfaChallenge implements AuthStatus {
  const _MfaChallenge();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaChallenge);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus.mfaChallenge()';
}


}




/// @nodoc


class _Failure implements AuthStatus {
  const _Failure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Failure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthStatus.failure()';
}


}





/// @nodoc
mixin _$AuthState {

@AuthStatusConverter() AuthStatus get status; String? get userId; String? get email; String? get accessToken; String? get refreshToken; bool get emailVerified; bool get mfaRequired; String get aalLevel; String? get error;@AuthResponseConverter() AuthResponse? get authResponse;@ProfileConverter() Profile? get profile;@MfaEnrollResponseConverter() MfaEnrollResponse? get mfaEnrollment;@MfaChallengeResponseConverter() MfaChallengeResponse? get mfaChallenge;@MfaFactorModelConverter() List<MfaFactorModel> get mfaFactors; bool get isPasswordResetSent; bool get isPasswordChanged; bool get isEmailChangePending; bool get isDeletingAccount; bool get isLoading;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);

  /// Serializes this AuthState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.emailVerified, _this.emailVerified) || other.emailVerified == _this.emailVerified)&&(identical(other.mfaRequired, _this.mfaRequired) || other.mfaRequired == _this.mfaRequired)&&(identical(other.aalLevel, _this.aalLevel) || other.aalLevel == _this.aalLevel)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.authResponse, _this.authResponse) || other.authResponse == _this.authResponse)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.mfaEnrollment, _this.mfaEnrollment) || other.mfaEnrollment == _this.mfaEnrollment)&&(identical(other.mfaChallenge, _this.mfaChallenge) || other.mfaChallenge == _this.mfaChallenge)&&const DeepCollectionEquality().equals(other.mfaFactors, _this.mfaFactors)&&(identical(other.isPasswordResetSent, _this.isPasswordResetSent) || other.isPasswordResetSent == _this.isPasswordResetSent)&&(identical(other.isPasswordChanged, _this.isPasswordChanged) || other.isPasswordChanged == _this.isPasswordChanged)&&(identical(other.isEmailChangePending, _this.isEmailChangePending) || other.isEmailChangePending == _this.isEmailChangePending)&&(identical(other.isDeletingAccount, _this.isDeletingAccount) || other.isDeletingAccount == _this.isDeletingAccount)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthState;
  return Object.hashAll([runtimeType,_this.status,_this.userId,_this.email,_this.accessToken,_this.refreshToken,_this.emailVerified,_this.mfaRequired,_this.aalLevel,_this.error,_this.authResponse,_this.profile,_this.mfaEnrollment,_this.mfaChallenge,const DeepCollectionEquality().hash(_this.mfaFactors),_this.isPasswordResetSent,_this.isPasswordChanged,_this.isEmailChangePending,_this.isDeletingAccount,_this.isLoading]);
}

@override
String toString() {
  final _this = this as AuthState;
  return 'AuthState(status: ${_this.status}, userId: ${_this.userId}, email: ${_this.email}, accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken}, emailVerified: ${_this.emailVerified}, mfaRequired: ${_this.mfaRequired}, aalLevel: ${_this.aalLevel}, error: ${_this.error}, authResponse: ${_this.authResponse}, profile: ${_this.profile}, mfaEnrollment: ${_this.mfaEnrollment}, mfaChallenge: ${_this.mfaChallenge}, mfaFactors: ${_this.mfaFactors}, isPasswordResetSent: ${_this.isPasswordResetSent}, isPasswordChanged: ${_this.isPasswordChanged}, isEmailChangePending: ${_this.isEmailChangePending}, isDeletingAccount: ${_this.isDeletingAccount}, isLoading: ${_this.isLoading})';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
@AuthStatusConverter() AuthStatus status, String? userId, String? email, String? accessToken, String? refreshToken, bool emailVerified, bool mfaRequired, String aalLevel, String? error,@AuthResponseConverter() AuthResponse? authResponse,@ProfileConverter() Profile? profile,@MfaEnrollResponseConverter() MfaEnrollResponse? mfaEnrollment,@MfaChallengeResponseConverter() MfaChallengeResponse? mfaChallenge,@MfaFactorModelConverter() List<MfaFactorModel> mfaFactors, bool isPasswordResetSent, bool isPasswordChanged, bool isEmailChangePending, bool isDeletingAccount, bool isLoading
});


$AuthStatusCopyWith<$Res> get status;$AuthResponseCopyWith<$Res>? get authResponse;$ProfileCopyWith<$Res>? get profile;$MfaEnrollResponseCopyWith<$Res>? get mfaEnrollment;$MfaChallengeResponseCopyWith<$Res>? get mfaChallenge;

}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? userId = freezed,Object? email = freezed,Object? accessToken = freezed,Object? refreshToken = freezed,Object? emailVerified = null,Object? mfaRequired = null,Object? aalLevel = null,Object? error = freezed,Object? authResponse = freezed,Object? profile = freezed,Object? mfaEnrollment = freezed,Object? mfaChallenge = freezed,Object? mfaFactors = null,Object? isPasswordResetSent = null,Object? isPasswordChanged = null,Object? isEmailChangePending = null,Object? isDeletingAccount = null,Object? isLoading = null,}) {
  return _then(AuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthStatus,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,mfaRequired: null == mfaRequired ? _self.mfaRequired : mfaRequired // ignore: cast_nullable_to_non_nullable
as bool,aalLevel: null == aalLevel ? _self.aalLevel : aalLevel // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,authResponse: freezed == authResponse ? _self.authResponse : authResponse // ignore: cast_nullable_to_non_nullable
as AuthResponse?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,mfaEnrollment: freezed == mfaEnrollment ? _self.mfaEnrollment : mfaEnrollment // ignore: cast_nullable_to_non_nullable
as MfaEnrollResponse?,mfaChallenge: freezed == mfaChallenge ? _self.mfaChallenge : mfaChallenge // ignore: cast_nullable_to_non_nullable
as MfaChallengeResponse?,mfaFactors: null == mfaFactors ? _self.mfaFactors : mfaFactors // ignore: cast_nullable_to_non_nullable
as List<MfaFactorModel>,isPasswordResetSent: null == isPasswordResetSent ? _self.isPasswordResetSent : isPasswordResetSent // ignore: cast_nullable_to_non_nullable
as bool,isPasswordChanged: null == isPasswordChanged ? _self.isPasswordChanged : isPasswordChanged // ignore: cast_nullable_to_non_nullable
as bool,isEmailChangePending: null == isEmailChangePending ? _self.isEmailChangePending : isEmailChangePending // ignore: cast_nullable_to_non_nullable
as bool,isDeletingAccount: null == isDeletingAccount ? _self.isDeletingAccount : isDeletingAccount // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthStatusCopyWith<$Res> get status {
  
  return $AuthStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthResponseCopyWith<$Res>? get authResponse {
    if (_self.authResponse == null) {
    return null;
  }

  return $AuthResponseCopyWith<$Res>(_self.authResponse!, (value) {
    return _then(_self.copyWith(authResponse: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MfaEnrollResponseCopyWith<$Res>? get mfaEnrollment {
    if (_self.mfaEnrollment == null) {
    return null;
  }

  return $MfaEnrollResponseCopyWith<$Res>(_self.mfaEnrollment!, (value) {
    return _then(_self.copyWith(mfaEnrollment: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MfaChallengeResponseCopyWith<$Res>? get mfaChallenge {
    if (_self.mfaChallenge == null) {
    return null;
  }

  return $MfaChallengeResponseCopyWith<$Res>(_self.mfaChallenge!, (value) {
    return _then(_self.copyWith(mfaChallenge: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthState value)  $default,){
final _that = this;
switch (_that) {
case _AuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@AuthStatusConverter()  AuthStatus status,  String? userId,  String? email,  String? accessToken,  String? refreshToken,  bool emailVerified,  bool mfaRequired,  String aalLevel,  String? error, @AuthResponseConverter()  AuthResponse? authResponse, @ProfileConverter()  Profile? profile, @MfaEnrollResponseConverter()  MfaEnrollResponse? mfaEnrollment, @MfaChallengeResponseConverter()  MfaChallengeResponse? mfaChallenge, @MfaFactorModelConverter()  List<MfaFactorModel> mfaFactors,  bool isPasswordResetSent,  bool isPasswordChanged,  bool isEmailChangePending,  bool isDeletingAccount,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.status,_that.userId,_that.email,_that.accessToken,_that.refreshToken,_that.emailVerified,_that.mfaRequired,_that.aalLevel,_that.error,_that.authResponse,_that.profile,_that.mfaEnrollment,_that.mfaChallenge,_that.mfaFactors,_that.isPasswordResetSent,_that.isPasswordChanged,_that.isEmailChangePending,_that.isDeletingAccount,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@AuthStatusConverter()  AuthStatus status,  String? userId,  String? email,  String? accessToken,  String? refreshToken,  bool emailVerified,  bool mfaRequired,  String aalLevel,  String? error, @AuthResponseConverter()  AuthResponse? authResponse, @ProfileConverter()  Profile? profile, @MfaEnrollResponseConverter()  MfaEnrollResponse? mfaEnrollment, @MfaChallengeResponseConverter()  MfaChallengeResponse? mfaChallenge, @MfaFactorModelConverter()  List<MfaFactorModel> mfaFactors,  bool isPasswordResetSent,  bool isPasswordChanged,  bool isEmailChangePending,  bool isDeletingAccount,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _AuthState():
return $default(_that.status,_that.userId,_that.email,_that.accessToken,_that.refreshToken,_that.emailVerified,_that.mfaRequired,_that.aalLevel,_that.error,_that.authResponse,_that.profile,_that.mfaEnrollment,_that.mfaChallenge,_that.mfaFactors,_that.isPasswordResetSent,_that.isPasswordChanged,_that.isEmailChangePending,_that.isDeletingAccount,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@AuthStatusConverter()  AuthStatus status,  String? userId,  String? email,  String? accessToken,  String? refreshToken,  bool emailVerified,  bool mfaRequired,  String aalLevel,  String? error, @AuthResponseConverter()  AuthResponse? authResponse, @ProfileConverter()  Profile? profile, @MfaEnrollResponseConverter()  MfaEnrollResponse? mfaEnrollment, @MfaChallengeResponseConverter()  MfaChallengeResponse? mfaChallenge, @MfaFactorModelConverter()  List<MfaFactorModel> mfaFactors,  bool isPasswordResetSent,  bool isPasswordChanged,  bool isEmailChangePending,  bool isDeletingAccount,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.status,_that.userId,_that.email,_that.accessToken,_that.refreshToken,_that.emailVerified,_that.mfaRequired,_that.aalLevel,_that.error,_that.authResponse,_that.profile,_that.mfaEnrollment,_that.mfaChallenge,_that.mfaFactors,_that.isPasswordResetSent,_that.isPasswordChanged,_that.isEmailChangePending,_that.isDeletingAccount,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthState implements AuthState {
  const _AuthState({@AuthStatusConverter() this.status = const AuthStatus.initial(), this.userId, this.email, this.accessToken, this.refreshToken, this.emailVerified = false, this.mfaRequired = false, this.aalLevel = 'aal1', this.error, @AuthResponseConverter() this.authResponse, @ProfileConverter() this.profile, @MfaEnrollResponseConverter() this.mfaEnrollment, @MfaChallengeResponseConverter() this.mfaChallenge, @MfaFactorModelConverter()  List<MfaFactorModel> mfaFactors = const [], this.isPasswordResetSent = false, this.isPasswordChanged = false, this.isEmailChangePending = false, this.isDeletingAccount = false, this.isLoading = false}): _mfaFactors = mfaFactors;
  factory _AuthState.fromJson(Map<String, dynamic> json) => _$AuthStateFromJson(json);

@override@JsonKey()@AuthStatusConverter() final  AuthStatus status;
@override final  String? userId;
@override final  String? email;
@override final  String? accessToken;
@override final  String? refreshToken;
@override@JsonKey() final  bool emailVerified;
@override@JsonKey() final  bool mfaRequired;
@override@JsonKey() final  String aalLevel;
@override final  String? error;
@override@AuthResponseConverter() final  AuthResponse? authResponse;
@override@ProfileConverter() final  Profile? profile;
@override@MfaEnrollResponseConverter() final  MfaEnrollResponse? mfaEnrollment;
@override@MfaChallengeResponseConverter() final  MfaChallengeResponse? mfaChallenge;
 final  List<MfaFactorModel> _mfaFactors;
@override@JsonKey()@MfaFactorModelConverter() List<MfaFactorModel> get mfaFactors {
  if (_mfaFactors is EqualUnmodifiableListView) return _mfaFactors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mfaFactors);
}

@override@JsonKey() final  bool isPasswordResetSent;
@override@JsonKey() final  bool isPasswordChanged;
@override@JsonKey() final  bool isEmailChangePending;
@override@JsonKey() final  bool isDeletingAccount;
@override@JsonKey() final  bool isLoading;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateCopyWith<_AuthState> get copyWith => __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.mfaRequired, mfaRequired) || other.mfaRequired == mfaRequired)&&(identical(other.aalLevel, aalLevel) || other.aalLevel == aalLevel)&&(identical(other.error, error) || other.error == error)&&(identical(other.authResponse, authResponse) || other.authResponse == authResponse)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.mfaEnrollment, mfaEnrollment) || other.mfaEnrollment == mfaEnrollment)&&(identical(other.mfaChallenge, mfaChallenge) || other.mfaChallenge == mfaChallenge)&&const DeepCollectionEquality().equals(other.mfaFactors, _mfaFactors)&&(identical(other.isPasswordResetSent, isPasswordResetSent) || other.isPasswordResetSent == isPasswordResetSent)&&(identical(other.isPasswordChanged, isPasswordChanged) || other.isPasswordChanged == isPasswordChanged)&&(identical(other.isEmailChangePending, isEmailChangePending) || other.isEmailChangePending == isEmailChangePending)&&(identical(other.isDeletingAccount, isDeletingAccount) || other.isDeletingAccount == isDeletingAccount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,status,userId,email,accessToken,refreshToken,emailVerified,mfaRequired,aalLevel,error,authResponse,profile,mfaEnrollment,mfaChallenge,const DeepCollectionEquality().hash(_mfaFactors),isPasswordResetSent,isPasswordChanged,isEmailChangePending,isDeletingAccount,isLoading]);
}

@override
String toString() {
    return 'AuthState(status: $status, userId: $userId, email: $email, accessToken: $accessToken, refreshToken: $refreshToken, emailVerified: $emailVerified, mfaRequired: $mfaRequired, aalLevel: $aalLevel, error: $error, authResponse: $authResponse, profile: $profile, mfaEnrollment: $mfaEnrollment, mfaChallenge: $mfaChallenge, mfaFactors: $mfaFactors, isPasswordResetSent: $isPasswordResetSent, isPasswordChanged: $isPasswordChanged, isEmailChangePending: $isEmailChangePending, isDeletingAccount: $isDeletingAccount, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(_AuthState value, $Res Function(_AuthState) _then) = __$AuthStateCopyWithImpl;
@override @useResult
$Res call({
@AuthStatusConverter() AuthStatus status, String? userId, String? email, String? accessToken, String? refreshToken, bool emailVerified, bool mfaRequired, String aalLevel, String? error,@AuthResponseConverter() AuthResponse? authResponse,@ProfileConverter() Profile? profile,@MfaEnrollResponseConverter() MfaEnrollResponse? mfaEnrollment,@MfaChallengeResponseConverter() MfaChallengeResponse? mfaChallenge,@MfaFactorModelConverter() List<MfaFactorModel> mfaFactors, bool isPasswordResetSent, bool isPasswordChanged, bool isEmailChangePending, bool isDeletingAccount, bool isLoading
});


@override $AuthStatusCopyWith<$Res> get status;@override $AuthResponseCopyWith<$Res>? get authResponse;@override $ProfileCopyWith<$Res>? get profile;@override $MfaEnrollResponseCopyWith<$Res>? get mfaEnrollment;@override $MfaChallengeResponseCopyWith<$Res>? get mfaChallenge;

}
/// @nodoc
class __$AuthStateCopyWithImpl<$Res>
    implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? userId = freezed,Object? email = freezed,Object? accessToken = freezed,Object? refreshToken = freezed,Object? emailVerified = null,Object? mfaRequired = null,Object? aalLevel = null,Object? error = freezed,Object? authResponse = freezed,Object? profile = freezed,Object? mfaEnrollment = freezed,Object? mfaChallenge = freezed,Object? mfaFactors = null,Object? isPasswordResetSent = null,Object? isPasswordChanged = null,Object? isEmailChangePending = null,Object? isDeletingAccount = null,Object? isLoading = null,}) {
  return _then(_AuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthStatus,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,mfaRequired: null == mfaRequired ? _self.mfaRequired : mfaRequired // ignore: cast_nullable_to_non_nullable
as bool,aalLevel: null == aalLevel ? _self.aalLevel : aalLevel // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,authResponse: freezed == authResponse ? _self.authResponse : authResponse // ignore: cast_nullable_to_non_nullable
as AuthResponse?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as Profile?,mfaEnrollment: freezed == mfaEnrollment ? _self.mfaEnrollment : mfaEnrollment // ignore: cast_nullable_to_non_nullable
as MfaEnrollResponse?,mfaChallenge: freezed == mfaChallenge ? _self.mfaChallenge : mfaChallenge // ignore: cast_nullable_to_non_nullable
as MfaChallengeResponse?,mfaFactors: null == mfaFactors ? _self._mfaFactors : mfaFactors // ignore: cast_nullable_to_non_nullable
as List<MfaFactorModel>,isPasswordResetSent: null == isPasswordResetSent ? _self.isPasswordResetSent : isPasswordResetSent // ignore: cast_nullable_to_non_nullable
as bool,isPasswordChanged: null == isPasswordChanged ? _self.isPasswordChanged : isPasswordChanged // ignore: cast_nullable_to_non_nullable
as bool,isEmailChangePending: null == isEmailChangePending ? _self.isEmailChangePending : isEmailChangePending // ignore: cast_nullable_to_non_nullable
as bool,isDeletingAccount: null == isDeletingAccount ? _self.isDeletingAccount : isDeletingAccount // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthStatusCopyWith<$Res> get status {
  
  return $AuthStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthResponseCopyWith<$Res>? get authResponse {
    if (_self.authResponse == null) {
    return null;
  }

  return $AuthResponseCopyWith<$Res>(_self.authResponse!, (value) {
    return _then(_self.copyWith(authResponse: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MfaEnrollResponseCopyWith<$Res>? get mfaEnrollment {
    if (_self.mfaEnrollment == null) {
    return null;
  }

  return $MfaEnrollResponseCopyWith<$Res>(_self.mfaEnrollment!, (value) {
    return _then(_self.copyWith(mfaEnrollment: value));
  });
}/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MfaChallengeResponseCopyWith<$Res>? get mfaChallenge {
    if (_self.mfaChallenge == null) {
    return null;
  }

  return $MfaChallengeResponseCopyWith<$Res>(_self.mfaChallenge!, (value) {
    return _then(_self.copyWith(mfaChallenge: value));
  });
}
}

// dart format on
