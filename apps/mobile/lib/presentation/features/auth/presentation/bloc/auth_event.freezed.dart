// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthEvent()';
}


}

/// @nodoc
class $AuthEventCopyWith<$Res>  {
$AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}


/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthSignUpRequested value)?  signUpRequested,TResult Function( AuthSignInRequested value)?  signInRequested,TResult Function( AuthSignOutRequested value)?  signOutRequested,TResult Function( AuthResetPasswordRequested value)?  resetPasswordRequested,TResult Function( AuthVerifyEmailRequested value)?  verifyEmailRequested,TResult Function( AuthResendVerificationRequested value)?  resendVerificationRequested,TResult Function( AuthDeleteAccountRequested value)?  deleteAccountRequested,TResult Function( AuthChangePasswordRequested value)?  changePasswordRequested,TResult Function( AuthUpdateEmailRequested value)?  updateEmailRequested,TResult Function( AuthEnrollMfaTotpRequested value)?  enrollMfaTotpRequested,TResult Function( AuthChallengeMfaTotpRequested value)?  challengeMfaTotpRequested,TResult Function( AuthVerifyMfaTotpRequested value)?  verifyMfaTotpRequested,TResult Function( AuthListMfaFactorsRequested value)?  listMfaFactorsRequested,TResult Function( AuthUnenrollMfaFactorRequested value)?  unenrollMfaFactorRequested,TResult Function( AuthUpdatePasswordRequested value)?  updatePasswordRequested,TResult Function( AuthRestoreSession value)?  restoreSession,TResult Function( AuthUpdateProfileRequested value)?  updateProfileRequested,TResult Function( AuthUpdatePrivacySettingsRequested value)?  updatePrivacySettingsRequested,TResult Function( AuthLoadProfile value)?  loadProfile,TResult Function( AuthSessionExpired value)?  sessionExpired,TResult Function( AuthMfaRequired value)?  mfaRequired,TResult Function( AuthAuthCallback value)?  authCallback,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthSignUpRequested() when signUpRequested != null:
return signUpRequested(_that);case AuthSignInRequested() when signInRequested != null:
return signInRequested(_that);case AuthSignOutRequested() when signOutRequested != null:
return signOutRequested(_that);case AuthResetPasswordRequested() when resetPasswordRequested != null:
return resetPasswordRequested(_that);case AuthVerifyEmailRequested() when verifyEmailRequested != null:
return verifyEmailRequested(_that);case AuthResendVerificationRequested() when resendVerificationRequested != null:
return resendVerificationRequested(_that);case AuthDeleteAccountRequested() when deleteAccountRequested != null:
return deleteAccountRequested(_that);case AuthChangePasswordRequested() when changePasswordRequested != null:
return changePasswordRequested(_that);case AuthUpdateEmailRequested() when updateEmailRequested != null:
return updateEmailRequested(_that);case AuthEnrollMfaTotpRequested() when enrollMfaTotpRequested != null:
return enrollMfaTotpRequested(_that);case AuthChallengeMfaTotpRequested() when challengeMfaTotpRequested != null:
return challengeMfaTotpRequested(_that);case AuthVerifyMfaTotpRequested() when verifyMfaTotpRequested != null:
return verifyMfaTotpRequested(_that);case AuthListMfaFactorsRequested() when listMfaFactorsRequested != null:
return listMfaFactorsRequested(_that);case AuthUnenrollMfaFactorRequested() when unenrollMfaFactorRequested != null:
return unenrollMfaFactorRequested(_that);case AuthUpdatePasswordRequested() when updatePasswordRequested != null:
return updatePasswordRequested(_that);case AuthRestoreSession() when restoreSession != null:
return restoreSession(_that);case AuthUpdateProfileRequested() when updateProfileRequested != null:
return updateProfileRequested(_that);case AuthUpdatePrivacySettingsRequested() when updatePrivacySettingsRequested != null:
return updatePrivacySettingsRequested(_that);case AuthLoadProfile() when loadProfile != null:
return loadProfile(_that);case AuthSessionExpired() when sessionExpired != null:
return sessionExpired(_that);case AuthMfaRequired() when mfaRequired != null:
return mfaRequired(_that);case AuthAuthCallback() when authCallback != null:
return authCallback(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthSignUpRequested value)  signUpRequested,required TResult Function( AuthSignInRequested value)  signInRequested,required TResult Function( AuthSignOutRequested value)  signOutRequested,required TResult Function( AuthResetPasswordRequested value)  resetPasswordRequested,required TResult Function( AuthVerifyEmailRequested value)  verifyEmailRequested,required TResult Function( AuthResendVerificationRequested value)  resendVerificationRequested,required TResult Function( AuthDeleteAccountRequested value)  deleteAccountRequested,required TResult Function( AuthChangePasswordRequested value)  changePasswordRequested,required TResult Function( AuthUpdateEmailRequested value)  updateEmailRequested,required TResult Function( AuthEnrollMfaTotpRequested value)  enrollMfaTotpRequested,required TResult Function( AuthChallengeMfaTotpRequested value)  challengeMfaTotpRequested,required TResult Function( AuthVerifyMfaTotpRequested value)  verifyMfaTotpRequested,required TResult Function( AuthListMfaFactorsRequested value)  listMfaFactorsRequested,required TResult Function( AuthUnenrollMfaFactorRequested value)  unenrollMfaFactorRequested,required TResult Function( AuthUpdatePasswordRequested value)  updatePasswordRequested,required TResult Function( AuthRestoreSession value)  restoreSession,required TResult Function( AuthUpdateProfileRequested value)  updateProfileRequested,required TResult Function( AuthUpdatePrivacySettingsRequested value)  updatePrivacySettingsRequested,required TResult Function( AuthLoadProfile value)  loadProfile,required TResult Function( AuthSessionExpired value)  sessionExpired,required TResult Function( AuthMfaRequired value)  mfaRequired,required TResult Function( AuthAuthCallback value)  authCallback,}){
final _that = this;
switch (_that) {
case AuthSignUpRequested():
return signUpRequested(_that);case AuthSignInRequested():
return signInRequested(_that);case AuthSignOutRequested():
return signOutRequested(_that);case AuthResetPasswordRequested():
return resetPasswordRequested(_that);case AuthVerifyEmailRequested():
return verifyEmailRequested(_that);case AuthResendVerificationRequested():
return resendVerificationRequested(_that);case AuthDeleteAccountRequested():
return deleteAccountRequested(_that);case AuthChangePasswordRequested():
return changePasswordRequested(_that);case AuthUpdateEmailRequested():
return updateEmailRequested(_that);case AuthEnrollMfaTotpRequested():
return enrollMfaTotpRequested(_that);case AuthChallengeMfaTotpRequested():
return challengeMfaTotpRequested(_that);case AuthVerifyMfaTotpRequested():
return verifyMfaTotpRequested(_that);case AuthListMfaFactorsRequested():
return listMfaFactorsRequested(_that);case AuthUnenrollMfaFactorRequested():
return unenrollMfaFactorRequested(_that);case AuthUpdatePasswordRequested():
return updatePasswordRequested(_that);case AuthRestoreSession():
return restoreSession(_that);case AuthUpdateProfileRequested():
return updateProfileRequested(_that);case AuthUpdatePrivacySettingsRequested():
return updatePrivacySettingsRequested(_that);case AuthLoadProfile():
return loadProfile(_that);case AuthSessionExpired():
return sessionExpired(_that);case AuthMfaRequired():
return mfaRequired(_that);case AuthAuthCallback():
return authCallback(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthSignUpRequested value)?  signUpRequested,TResult? Function( AuthSignInRequested value)?  signInRequested,TResult? Function( AuthSignOutRequested value)?  signOutRequested,TResult? Function( AuthResetPasswordRequested value)?  resetPasswordRequested,TResult? Function( AuthVerifyEmailRequested value)?  verifyEmailRequested,TResult? Function( AuthResendVerificationRequested value)?  resendVerificationRequested,TResult? Function( AuthDeleteAccountRequested value)?  deleteAccountRequested,TResult? Function( AuthChangePasswordRequested value)?  changePasswordRequested,TResult? Function( AuthUpdateEmailRequested value)?  updateEmailRequested,TResult? Function( AuthEnrollMfaTotpRequested value)?  enrollMfaTotpRequested,TResult? Function( AuthChallengeMfaTotpRequested value)?  challengeMfaTotpRequested,TResult? Function( AuthVerifyMfaTotpRequested value)?  verifyMfaTotpRequested,TResult? Function( AuthListMfaFactorsRequested value)?  listMfaFactorsRequested,TResult? Function( AuthUnenrollMfaFactorRequested value)?  unenrollMfaFactorRequested,TResult? Function( AuthUpdatePasswordRequested value)?  updatePasswordRequested,TResult? Function( AuthRestoreSession value)?  restoreSession,TResult? Function( AuthUpdateProfileRequested value)?  updateProfileRequested,TResult? Function( AuthUpdatePrivacySettingsRequested value)?  updatePrivacySettingsRequested,TResult? Function( AuthLoadProfile value)?  loadProfile,TResult? Function( AuthSessionExpired value)?  sessionExpired,TResult? Function( AuthMfaRequired value)?  mfaRequired,TResult? Function( AuthAuthCallback value)?  authCallback,}){
final _that = this;
switch (_that) {
case AuthSignUpRequested() when signUpRequested != null:
return signUpRequested(_that);case AuthSignInRequested() when signInRequested != null:
return signInRequested(_that);case AuthSignOutRequested() when signOutRequested != null:
return signOutRequested(_that);case AuthResetPasswordRequested() when resetPasswordRequested != null:
return resetPasswordRequested(_that);case AuthVerifyEmailRequested() when verifyEmailRequested != null:
return verifyEmailRequested(_that);case AuthResendVerificationRequested() when resendVerificationRequested != null:
return resendVerificationRequested(_that);case AuthDeleteAccountRequested() when deleteAccountRequested != null:
return deleteAccountRequested(_that);case AuthChangePasswordRequested() when changePasswordRequested != null:
return changePasswordRequested(_that);case AuthUpdateEmailRequested() when updateEmailRequested != null:
return updateEmailRequested(_that);case AuthEnrollMfaTotpRequested() when enrollMfaTotpRequested != null:
return enrollMfaTotpRequested(_that);case AuthChallengeMfaTotpRequested() when challengeMfaTotpRequested != null:
return challengeMfaTotpRequested(_that);case AuthVerifyMfaTotpRequested() when verifyMfaTotpRequested != null:
return verifyMfaTotpRequested(_that);case AuthListMfaFactorsRequested() when listMfaFactorsRequested != null:
return listMfaFactorsRequested(_that);case AuthUnenrollMfaFactorRequested() when unenrollMfaFactorRequested != null:
return unenrollMfaFactorRequested(_that);case AuthUpdatePasswordRequested() when updatePasswordRequested != null:
return updatePasswordRequested(_that);case AuthRestoreSession() when restoreSession != null:
return restoreSession(_that);case AuthUpdateProfileRequested() when updateProfileRequested != null:
return updateProfileRequested(_that);case AuthUpdatePrivacySettingsRequested() when updatePrivacySettingsRequested != null:
return updatePrivacySettingsRequested(_that);case AuthLoadProfile() when loadProfile != null:
return loadProfile(_that);case AuthSessionExpired() when sessionExpired != null:
return sessionExpired(_that);case AuthMfaRequired() when mfaRequired != null:
return mfaRequired(_that);case AuthAuthCallback() when authCallback != null:
return authCallback(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String email,  String password,  String displayName,  bool termsAccepted,  bool ageAttestation)?  signUpRequested,TResult Function( String email,  String password)?  signInRequested,TResult Function()?  signOutRequested,TResult Function( String email)?  resetPasswordRequested,TResult Function( String email)?  verifyEmailRequested,TResult Function( String email)?  resendVerificationRequested,TResult Function( String password)?  deleteAccountRequested,TResult Function( String currentPassword,  String newPassword)?  changePasswordRequested,TResult Function( String email)?  updateEmailRequested,TResult Function()?  enrollMfaTotpRequested,TResult Function( String factorId)?  challengeMfaTotpRequested,TResult Function( String factorId,  String challengeId,  String code)?  verifyMfaTotpRequested,TResult Function()?  listMfaFactorsRequested,TResult Function( String factorId)?  unenrollMfaFactorRequested,TResult Function( String password)?  updatePasswordRequested,TResult Function()?  restoreSession,TResult Function( String? displayName,  String? username,  String? inGameName,  String? inGameUid,  String? privacyProfileVisibility,  bool? privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs,  String? avatarUrl)?  updateProfileRequested,TResult Function( String profileVisibility,  bool showInGameInfo)?  updatePrivacySettingsRequested,TResult Function()?  loadProfile,TResult Function()?  sessionExpired,TResult Function()?  mfaRequired,TResult Function( String token,  String type)?  authCallback,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthSignUpRequested() when signUpRequested != null:
return signUpRequested(_that.email,_that.password,_that.displayName,_that.termsAccepted,_that.ageAttestation);case AuthSignInRequested() when signInRequested != null:
return signInRequested(_that.email,_that.password);case AuthSignOutRequested() when signOutRequested != null:
return signOutRequested();case AuthResetPasswordRequested() when resetPasswordRequested != null:
return resetPasswordRequested(_that.email);case AuthVerifyEmailRequested() when verifyEmailRequested != null:
return verifyEmailRequested(_that.email);case AuthResendVerificationRequested() when resendVerificationRequested != null:
return resendVerificationRequested(_that.email);case AuthDeleteAccountRequested() when deleteAccountRequested != null:
return deleteAccountRequested(_that.password);case AuthChangePasswordRequested() when changePasswordRequested != null:
return changePasswordRequested(_that.currentPassword,_that.newPassword);case AuthUpdateEmailRequested() when updateEmailRequested != null:
return updateEmailRequested(_that.email);case AuthEnrollMfaTotpRequested() when enrollMfaTotpRequested != null:
return enrollMfaTotpRequested();case AuthChallengeMfaTotpRequested() when challengeMfaTotpRequested != null:
return challengeMfaTotpRequested(_that.factorId);case AuthVerifyMfaTotpRequested() when verifyMfaTotpRequested != null:
return verifyMfaTotpRequested(_that.factorId,_that.challengeId,_that.code);case AuthListMfaFactorsRequested() when listMfaFactorsRequested != null:
return listMfaFactorsRequested();case AuthUnenrollMfaFactorRequested() when unenrollMfaFactorRequested != null:
return unenrollMfaFactorRequested(_that.factorId);case AuthUpdatePasswordRequested() when updatePasswordRequested != null:
return updatePasswordRequested(_that.password);case AuthRestoreSession() when restoreSession != null:
return restoreSession();case AuthUpdateProfileRequested() when updateProfileRequested != null:
return updateProfileRequested(_that.displayName,_that.username,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.avatarUrl);case AuthUpdatePrivacySettingsRequested() when updatePrivacySettingsRequested != null:
return updatePrivacySettingsRequested(_that.profileVisibility,_that.showInGameInfo);case AuthLoadProfile() when loadProfile != null:
return loadProfile();case AuthSessionExpired() when sessionExpired != null:
return sessionExpired();case AuthMfaRequired() when mfaRequired != null:
return mfaRequired();case AuthAuthCallback() when authCallback != null:
return authCallback(_that.token,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String email,  String password,  String displayName,  bool termsAccepted,  bool ageAttestation)  signUpRequested,required TResult Function( String email,  String password)  signInRequested,required TResult Function()  signOutRequested,required TResult Function( String email)  resetPasswordRequested,required TResult Function( String email)  verifyEmailRequested,required TResult Function( String email)  resendVerificationRequested,required TResult Function( String password)  deleteAccountRequested,required TResult Function( String currentPassword,  String newPassword)  changePasswordRequested,required TResult Function( String email)  updateEmailRequested,required TResult Function()  enrollMfaTotpRequested,required TResult Function( String factorId)  challengeMfaTotpRequested,required TResult Function( String factorId,  String challengeId,  String code)  verifyMfaTotpRequested,required TResult Function()  listMfaFactorsRequested,required TResult Function( String factorId)  unenrollMfaFactorRequested,required TResult Function( String password)  updatePasswordRequested,required TResult Function()  restoreSession,required TResult Function( String? displayName,  String? username,  String? inGameName,  String? inGameUid,  String? privacyProfileVisibility,  bool? privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs,  String? avatarUrl)  updateProfileRequested,required TResult Function( String profileVisibility,  bool showInGameInfo)  updatePrivacySettingsRequested,required TResult Function()  loadProfile,required TResult Function()  sessionExpired,required TResult Function()  mfaRequired,required TResult Function( String token,  String type)  authCallback,}) {final _that = this;
switch (_that) {
case AuthSignUpRequested():
return signUpRequested(_that.email,_that.password,_that.displayName,_that.termsAccepted,_that.ageAttestation);case AuthSignInRequested():
return signInRequested(_that.email,_that.password);case AuthSignOutRequested():
return signOutRequested();case AuthResetPasswordRequested():
return resetPasswordRequested(_that.email);case AuthVerifyEmailRequested():
return verifyEmailRequested(_that.email);case AuthResendVerificationRequested():
return resendVerificationRequested(_that.email);case AuthDeleteAccountRequested():
return deleteAccountRequested(_that.password);case AuthChangePasswordRequested():
return changePasswordRequested(_that.currentPassword,_that.newPassword);case AuthUpdateEmailRequested():
return updateEmailRequested(_that.email);case AuthEnrollMfaTotpRequested():
return enrollMfaTotpRequested();case AuthChallengeMfaTotpRequested():
return challengeMfaTotpRequested(_that.factorId);case AuthVerifyMfaTotpRequested():
return verifyMfaTotpRequested(_that.factorId,_that.challengeId,_that.code);case AuthListMfaFactorsRequested():
return listMfaFactorsRequested();case AuthUnenrollMfaFactorRequested():
return unenrollMfaFactorRequested(_that.factorId);case AuthUpdatePasswordRequested():
return updatePasswordRequested(_that.password);case AuthRestoreSession():
return restoreSession();case AuthUpdateProfileRequested():
return updateProfileRequested(_that.displayName,_that.username,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.avatarUrl);case AuthUpdatePrivacySettingsRequested():
return updatePrivacySettingsRequested(_that.profileVisibility,_that.showInGameInfo);case AuthLoadProfile():
return loadProfile();case AuthSessionExpired():
return sessionExpired();case AuthMfaRequired():
return mfaRequired();case AuthAuthCallback():
return authCallback(_that.token,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String email,  String password,  String displayName,  bool termsAccepted,  bool ageAttestation)?  signUpRequested,TResult? Function( String email,  String password)?  signInRequested,TResult? Function()?  signOutRequested,TResult? Function( String email)?  resetPasswordRequested,TResult? Function( String email)?  verifyEmailRequested,TResult? Function( String email)?  resendVerificationRequested,TResult? Function( String password)?  deleteAccountRequested,TResult? Function( String currentPassword,  String newPassword)?  changePasswordRequested,TResult? Function( String email)?  updateEmailRequested,TResult? Function()?  enrollMfaTotpRequested,TResult? Function( String factorId)?  challengeMfaTotpRequested,TResult? Function( String factorId,  String challengeId,  String code)?  verifyMfaTotpRequested,TResult? Function()?  listMfaFactorsRequested,TResult? Function( String factorId)?  unenrollMfaFactorRequested,TResult? Function( String password)?  updatePasswordRequested,TResult? Function()?  restoreSession,TResult? Function( String? displayName,  String? username,  String? inGameName,  String? inGameUid,  String? privacyProfileVisibility,  bool? privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs,  String? avatarUrl)?  updateProfileRequested,TResult? Function( String profileVisibility,  bool showInGameInfo)?  updatePrivacySettingsRequested,TResult? Function()?  loadProfile,TResult? Function()?  sessionExpired,TResult? Function()?  mfaRequired,TResult? Function( String token,  String type)?  authCallback,}) {final _that = this;
switch (_that) {
case AuthSignUpRequested() when signUpRequested != null:
return signUpRequested(_that.email,_that.password,_that.displayName,_that.termsAccepted,_that.ageAttestation);case AuthSignInRequested() when signInRequested != null:
return signInRequested(_that.email,_that.password);case AuthSignOutRequested() when signOutRequested != null:
return signOutRequested();case AuthResetPasswordRequested() when resetPasswordRequested != null:
return resetPasswordRequested(_that.email);case AuthVerifyEmailRequested() when verifyEmailRequested != null:
return verifyEmailRequested(_that.email);case AuthResendVerificationRequested() when resendVerificationRequested != null:
return resendVerificationRequested(_that.email);case AuthDeleteAccountRequested() when deleteAccountRequested != null:
return deleteAccountRequested(_that.password);case AuthChangePasswordRequested() when changePasswordRequested != null:
return changePasswordRequested(_that.currentPassword,_that.newPassword);case AuthUpdateEmailRequested() when updateEmailRequested != null:
return updateEmailRequested(_that.email);case AuthEnrollMfaTotpRequested() when enrollMfaTotpRequested != null:
return enrollMfaTotpRequested();case AuthChallengeMfaTotpRequested() when challengeMfaTotpRequested != null:
return challengeMfaTotpRequested(_that.factorId);case AuthVerifyMfaTotpRequested() when verifyMfaTotpRequested != null:
return verifyMfaTotpRequested(_that.factorId,_that.challengeId,_that.code);case AuthListMfaFactorsRequested() when listMfaFactorsRequested != null:
return listMfaFactorsRequested();case AuthUnenrollMfaFactorRequested() when unenrollMfaFactorRequested != null:
return unenrollMfaFactorRequested(_that.factorId);case AuthUpdatePasswordRequested() when updatePasswordRequested != null:
return updatePasswordRequested(_that.password);case AuthRestoreSession() when restoreSession != null:
return restoreSession();case AuthUpdateProfileRequested() when updateProfileRequested != null:
return updateProfileRequested(_that.displayName,_that.username,_that.inGameName,_that.inGameUid,_that.privacyProfileVisibility,_that.privacyShowInGameInfo,_that.notificationPrefs,_that.avatarUrl);case AuthUpdatePrivacySettingsRequested() when updatePrivacySettingsRequested != null:
return updatePrivacySettingsRequested(_that.profileVisibility,_that.showInGameInfo);case AuthLoadProfile() when loadProfile != null:
return loadProfile();case AuthSessionExpired() when sessionExpired != null:
return sessionExpired();case AuthMfaRequired() when mfaRequired != null:
return mfaRequired();case AuthAuthCallback() when authCallback != null:
return authCallback(_that.token,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class AuthSignUpRequested implements AuthEvent {
  const AuthSignUpRequested({required this.email, required this.password, required this.displayName, required this.termsAccepted, required this.ageAttestation});
  

 final  String email;
 final  String password;
 final  String displayName;
 final  bool termsAccepted;
 final  bool ageAttestation;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSignUpRequestedCopyWith<AuthSignUpRequested> get copyWith => _$AuthSignUpRequestedCopyWithImpl<AuthSignUpRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSignUpRequested&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.ageAttestation, ageAttestation) || other.ageAttestation == ageAttestation));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email,password,displayName,termsAccepted,ageAttestation);
}

@override
String toString() {
    return 'AuthEvent.signUpRequested(email: $email, password: $password, displayName: $displayName, termsAccepted: $termsAccepted, ageAttestation: $ageAttestation)';
}


}

/// @nodoc
abstract mixin class $AuthSignUpRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthSignUpRequestedCopyWith(AuthSignUpRequested value, $Res Function(AuthSignUpRequested) _then) = _$AuthSignUpRequestedCopyWithImpl;
@useResult
$Res call({
 String email, String password, String displayName, bool termsAccepted, bool ageAttestation
});




}
/// @nodoc
class _$AuthSignUpRequestedCopyWithImpl<$Res>
    implements $AuthSignUpRequestedCopyWith<$Res> {
  _$AuthSignUpRequestedCopyWithImpl(this._self, this._then);

  final AuthSignUpRequested _self;
  final $Res Function(AuthSignUpRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? displayName = null,Object? termsAccepted = null,Object? ageAttestation = null,}) {
  return _then(AuthSignUpRequested(
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


class AuthSignInRequested implements AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});
  

 final  String email;
 final  String password;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSignInRequestedCopyWith<AuthSignInRequested> get copyWith => _$AuthSignInRequestedCopyWithImpl<AuthSignInRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSignInRequested&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email,password);
}

@override
String toString() {
    return 'AuthEvent.signInRequested(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $AuthSignInRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthSignInRequestedCopyWith(AuthSignInRequested value, $Res Function(AuthSignInRequested) _then) = _$AuthSignInRequestedCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$AuthSignInRequestedCopyWithImpl<$Res>
    implements $AuthSignInRequestedCopyWith<$Res> {
  _$AuthSignInRequestedCopyWithImpl(this._self, this._then);

  final AuthSignInRequested _self;
  final $Res Function(AuthSignInRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(AuthSignInRequested(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthSignOutRequested implements AuthEvent {
  const AuthSignOutRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSignOutRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthEvent.signOutRequested()';
}


}




/// @nodoc


class AuthResetPasswordRequested implements AuthEvent {
  const AuthResetPasswordRequested({required this.email});
  

 final  String email;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResetPasswordRequestedCopyWith<AuthResetPasswordRequested> get copyWith => _$AuthResetPasswordRequestedCopyWithImpl<AuthResetPasswordRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResetPasswordRequested&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'AuthEvent.resetPasswordRequested(email: $email)';
}


}

/// @nodoc
abstract mixin class $AuthResetPasswordRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthResetPasswordRequestedCopyWith(AuthResetPasswordRequested value, $Res Function(AuthResetPasswordRequested) _then) = _$AuthResetPasswordRequestedCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$AuthResetPasswordRequestedCopyWithImpl<$Res>
    implements $AuthResetPasswordRequestedCopyWith<$Res> {
  _$AuthResetPasswordRequestedCopyWithImpl(this._self, this._then);

  final AuthResetPasswordRequested _self;
  final $Res Function(AuthResetPasswordRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(AuthResetPasswordRequested(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthVerifyEmailRequested implements AuthEvent {
  const AuthVerifyEmailRequested({required this.email});
  

 final  String email;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthVerifyEmailRequestedCopyWith<AuthVerifyEmailRequested> get copyWith => _$AuthVerifyEmailRequestedCopyWithImpl<AuthVerifyEmailRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthVerifyEmailRequested&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'AuthEvent.verifyEmailRequested(email: $email)';
}


}

/// @nodoc
abstract mixin class $AuthVerifyEmailRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthVerifyEmailRequestedCopyWith(AuthVerifyEmailRequested value, $Res Function(AuthVerifyEmailRequested) _then) = _$AuthVerifyEmailRequestedCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$AuthVerifyEmailRequestedCopyWithImpl<$Res>
    implements $AuthVerifyEmailRequestedCopyWith<$Res> {
  _$AuthVerifyEmailRequestedCopyWithImpl(this._self, this._then);

  final AuthVerifyEmailRequested _self;
  final $Res Function(AuthVerifyEmailRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(AuthVerifyEmailRequested(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthResendVerificationRequested implements AuthEvent {
  const AuthResendVerificationRequested({required this.email});
  

 final  String email;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResendVerificationRequestedCopyWith<AuthResendVerificationRequested> get copyWith => _$AuthResendVerificationRequestedCopyWithImpl<AuthResendVerificationRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResendVerificationRequested&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'AuthEvent.resendVerificationRequested(email: $email)';
}


}

/// @nodoc
abstract mixin class $AuthResendVerificationRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthResendVerificationRequestedCopyWith(AuthResendVerificationRequested value, $Res Function(AuthResendVerificationRequested) _then) = _$AuthResendVerificationRequestedCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$AuthResendVerificationRequestedCopyWithImpl<$Res>
    implements $AuthResendVerificationRequestedCopyWith<$Res> {
  _$AuthResendVerificationRequestedCopyWithImpl(this._self, this._then);

  final AuthResendVerificationRequested _self;
  final $Res Function(AuthResendVerificationRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(AuthResendVerificationRequested(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthDeleteAccountRequested implements AuthEvent {
  const AuthDeleteAccountRequested({required this.password});
  

 final  String password;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthDeleteAccountRequestedCopyWith<AuthDeleteAccountRequested> get copyWith => _$AuthDeleteAccountRequestedCopyWithImpl<AuthDeleteAccountRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthDeleteAccountRequested&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode {
    return Object.hash(runtimeType,password);
}

@override
String toString() {
    return 'AuthEvent.deleteAccountRequested(password: $password)';
}


}

/// @nodoc
abstract mixin class $AuthDeleteAccountRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthDeleteAccountRequestedCopyWith(AuthDeleteAccountRequested value, $Res Function(AuthDeleteAccountRequested) _then) = _$AuthDeleteAccountRequestedCopyWithImpl;
@useResult
$Res call({
 String password
});




}
/// @nodoc
class _$AuthDeleteAccountRequestedCopyWithImpl<$Res>
    implements $AuthDeleteAccountRequestedCopyWith<$Res> {
  _$AuthDeleteAccountRequestedCopyWithImpl(this._self, this._then);

  final AuthDeleteAccountRequested _self;
  final $Res Function(AuthDeleteAccountRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? password = null,}) {
  return _then(AuthDeleteAccountRequested(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthChangePasswordRequested implements AuthEvent {
  const AuthChangePasswordRequested({required this.currentPassword, required this.newPassword});
  

 final  String currentPassword;
 final  String newPassword;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthChangePasswordRequestedCopyWith<AuthChangePasswordRequested> get copyWith => _$AuthChangePasswordRequestedCopyWithImpl<AuthChangePasswordRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthChangePasswordRequested&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}


@override
int get hashCode {
    return Object.hash(runtimeType,currentPassword,newPassword);
}

@override
String toString() {
    return 'AuthEvent.changePasswordRequested(currentPassword: $currentPassword, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class $AuthChangePasswordRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthChangePasswordRequestedCopyWith(AuthChangePasswordRequested value, $Res Function(AuthChangePasswordRequested) _then) = _$AuthChangePasswordRequestedCopyWithImpl;
@useResult
$Res call({
 String currentPassword, String newPassword
});




}
/// @nodoc
class _$AuthChangePasswordRequestedCopyWithImpl<$Res>
    implements $AuthChangePasswordRequestedCopyWith<$Res> {
  _$AuthChangePasswordRequestedCopyWithImpl(this._self, this._then);

  final AuthChangePasswordRequested _self;
  final $Res Function(AuthChangePasswordRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentPassword = null,Object? newPassword = null,}) {
  return _then(AuthChangePasswordRequested(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthUpdateEmailRequested implements AuthEvent {
  const AuthUpdateEmailRequested({required this.email});
  

 final  String email;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUpdateEmailRequestedCopyWith<AuthUpdateEmailRequested> get copyWith => _$AuthUpdateEmailRequestedCopyWithImpl<AuthUpdateEmailRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUpdateEmailRequested&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode {
    return Object.hash(runtimeType,email);
}

@override
String toString() {
    return 'AuthEvent.updateEmailRequested(email: $email)';
}


}

/// @nodoc
abstract mixin class $AuthUpdateEmailRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthUpdateEmailRequestedCopyWith(AuthUpdateEmailRequested value, $Res Function(AuthUpdateEmailRequested) _then) = _$AuthUpdateEmailRequestedCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$AuthUpdateEmailRequestedCopyWithImpl<$Res>
    implements $AuthUpdateEmailRequestedCopyWith<$Res> {
  _$AuthUpdateEmailRequestedCopyWithImpl(this._self, this._then);

  final AuthUpdateEmailRequested _self;
  final $Res Function(AuthUpdateEmailRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(AuthUpdateEmailRequested(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthEnrollMfaTotpRequested implements AuthEvent {
  const AuthEnrollMfaTotpRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEnrollMfaTotpRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthEvent.enrollMfaTotpRequested()';
}


}




/// @nodoc


class AuthChallengeMfaTotpRequested implements AuthEvent {
  const AuthChallengeMfaTotpRequested({required this.factorId});
  

 final  String factorId;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthChallengeMfaTotpRequestedCopyWith<AuthChallengeMfaTotpRequested> get copyWith => _$AuthChallengeMfaTotpRequestedCopyWithImpl<AuthChallengeMfaTotpRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthChallengeMfaTotpRequested&&(identical(other.factorId, factorId) || other.factorId == factorId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,factorId);
}

@override
String toString() {
    return 'AuthEvent.challengeMfaTotpRequested(factorId: $factorId)';
}


}

/// @nodoc
abstract mixin class $AuthChallengeMfaTotpRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthChallengeMfaTotpRequestedCopyWith(AuthChallengeMfaTotpRequested value, $Res Function(AuthChallengeMfaTotpRequested) _then) = _$AuthChallengeMfaTotpRequestedCopyWithImpl;
@useResult
$Res call({
 String factorId
});




}
/// @nodoc
class _$AuthChallengeMfaTotpRequestedCopyWithImpl<$Res>
    implements $AuthChallengeMfaTotpRequestedCopyWith<$Res> {
  _$AuthChallengeMfaTotpRequestedCopyWithImpl(this._self, this._then);

  final AuthChallengeMfaTotpRequested _self;
  final $Res Function(AuthChallengeMfaTotpRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? factorId = null,}) {
  return _then(AuthChallengeMfaTotpRequested(
factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthVerifyMfaTotpRequested implements AuthEvent {
  const AuthVerifyMfaTotpRequested({required this.factorId, required this.challengeId, required this.code});
  

 final  String factorId;
 final  String challengeId;
 final  String code;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthVerifyMfaTotpRequestedCopyWith<AuthVerifyMfaTotpRequested> get copyWith => _$AuthVerifyMfaTotpRequestedCopyWithImpl<AuthVerifyMfaTotpRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthVerifyMfaTotpRequested&&(identical(other.factorId, factorId) || other.factorId == factorId)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode {
    return Object.hash(runtimeType,factorId,challengeId,code);
}

@override
String toString() {
    return 'AuthEvent.verifyMfaTotpRequested(factorId: $factorId, challengeId: $challengeId, code: $code)';
}


}

/// @nodoc
abstract mixin class $AuthVerifyMfaTotpRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthVerifyMfaTotpRequestedCopyWith(AuthVerifyMfaTotpRequested value, $Res Function(AuthVerifyMfaTotpRequested) _then) = _$AuthVerifyMfaTotpRequestedCopyWithImpl;
@useResult
$Res call({
 String factorId, String challengeId, String code
});




}
/// @nodoc
class _$AuthVerifyMfaTotpRequestedCopyWithImpl<$Res>
    implements $AuthVerifyMfaTotpRequestedCopyWith<$Res> {
  _$AuthVerifyMfaTotpRequestedCopyWithImpl(this._self, this._then);

  final AuthVerifyMfaTotpRequested _self;
  final $Res Function(AuthVerifyMfaTotpRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? factorId = null,Object? challengeId = null,Object? code = null,}) {
  return _then(AuthVerifyMfaTotpRequested(
factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthListMfaFactorsRequested implements AuthEvent {
  const AuthListMfaFactorsRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthListMfaFactorsRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthEvent.listMfaFactorsRequested()';
}


}




/// @nodoc


class AuthUnenrollMfaFactorRequested implements AuthEvent {
  const AuthUnenrollMfaFactorRequested({required this.factorId});
  

 final  String factorId;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUnenrollMfaFactorRequestedCopyWith<AuthUnenrollMfaFactorRequested> get copyWith => _$AuthUnenrollMfaFactorRequestedCopyWithImpl<AuthUnenrollMfaFactorRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUnenrollMfaFactorRequested&&(identical(other.factorId, factorId) || other.factorId == factorId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,factorId);
}

@override
String toString() {
    return 'AuthEvent.unenrollMfaFactorRequested(factorId: $factorId)';
}


}

/// @nodoc
abstract mixin class $AuthUnenrollMfaFactorRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthUnenrollMfaFactorRequestedCopyWith(AuthUnenrollMfaFactorRequested value, $Res Function(AuthUnenrollMfaFactorRequested) _then) = _$AuthUnenrollMfaFactorRequestedCopyWithImpl;
@useResult
$Res call({
 String factorId
});




}
/// @nodoc
class _$AuthUnenrollMfaFactorRequestedCopyWithImpl<$Res>
    implements $AuthUnenrollMfaFactorRequestedCopyWith<$Res> {
  _$AuthUnenrollMfaFactorRequestedCopyWithImpl(this._self, this._then);

  final AuthUnenrollMfaFactorRequested _self;
  final $Res Function(AuthUnenrollMfaFactorRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? factorId = null,}) {
  return _then(AuthUnenrollMfaFactorRequested(
factorId: null == factorId ? _self.factorId : factorId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthUpdatePasswordRequested implements AuthEvent {
  const AuthUpdatePasswordRequested({required this.password});
  

 final  String password;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUpdatePasswordRequestedCopyWith<AuthUpdatePasswordRequested> get copyWith => _$AuthUpdatePasswordRequestedCopyWithImpl<AuthUpdatePasswordRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUpdatePasswordRequested&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode {
    return Object.hash(runtimeType,password);
}

@override
String toString() {
    return 'AuthEvent.updatePasswordRequested(password: $password)';
}


}

/// @nodoc
abstract mixin class $AuthUpdatePasswordRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthUpdatePasswordRequestedCopyWith(AuthUpdatePasswordRequested value, $Res Function(AuthUpdatePasswordRequested) _then) = _$AuthUpdatePasswordRequestedCopyWithImpl;
@useResult
$Res call({
 String password
});




}
/// @nodoc
class _$AuthUpdatePasswordRequestedCopyWithImpl<$Res>
    implements $AuthUpdatePasswordRequestedCopyWith<$Res> {
  _$AuthUpdatePasswordRequestedCopyWithImpl(this._self, this._then);

  final AuthUpdatePasswordRequested _self;
  final $Res Function(AuthUpdatePasswordRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? password = null,}) {
  return _then(AuthUpdatePasswordRequested(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthRestoreSession implements AuthEvent {
  const AuthRestoreSession();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthRestoreSession);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthEvent.restoreSession()';
}


}




/// @nodoc


class AuthUpdateProfileRequested implements AuthEvent {
  const AuthUpdateProfileRequested({this.displayName, this.username, this.inGameName, this.inGameUid, this.privacyProfileVisibility, this.privacyShowInGameInfo,  Map<String, dynamic>? notificationPrefs, this.avatarUrl}): _notificationPrefs = notificationPrefs;
  

 final  String? displayName;
 final  String? username;
 final  String? inGameName;
 final  String? inGameUid;
 final  String? privacyProfileVisibility;
 final  bool? privacyShowInGameInfo;
 final  Map<String, dynamic>? _notificationPrefs;
 Map<String, dynamic>? get notificationPrefs {
  final value = _notificationPrefs;
  if (value == null) return null;
  if (_notificationPrefs is EqualUnmodifiableMapView) return _notificationPrefs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  String? avatarUrl;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUpdateProfileRequestedCopyWith<AuthUpdateProfileRequested> get copyWith => _$AuthUpdateProfileRequestedCopyWithImpl<AuthUpdateProfileRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUpdateProfileRequested&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.inGameName, inGameName) || other.inGameName == inGameName)&&(identical(other.inGameUid, inGameUid) || other.inGameUid == inGameUid)&&(identical(other.privacyProfileVisibility, privacyProfileVisibility) || other.privacyProfileVisibility == privacyProfileVisibility)&&(identical(other.privacyShowInGameInfo, privacyShowInGameInfo) || other.privacyShowInGameInfo == privacyShowInGameInfo)&&const DeepCollectionEquality().equals(other.notificationPrefs, _notificationPrefs)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,displayName,username,inGameName,inGameUid,privacyProfileVisibility,privacyShowInGameInfo,const DeepCollectionEquality().hash(_notificationPrefs),avatarUrl);
}

@override
String toString() {
    return 'AuthEvent.updateProfileRequested(displayName: $displayName, username: $username, inGameName: $inGameName, inGameUid: $inGameUid, privacyProfileVisibility: $privacyProfileVisibility, privacyShowInGameInfo: $privacyShowInGameInfo, notificationPrefs: $notificationPrefs, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $AuthUpdateProfileRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthUpdateProfileRequestedCopyWith(AuthUpdateProfileRequested value, $Res Function(AuthUpdateProfileRequested) _then) = _$AuthUpdateProfileRequestedCopyWithImpl;
@useResult
$Res call({
 String? displayName, String? username, String? inGameName, String? inGameUid, String? privacyProfileVisibility, bool? privacyShowInGameInfo, Map<String, dynamic>? notificationPrefs, String? avatarUrl
});




}
/// @nodoc
class _$AuthUpdateProfileRequestedCopyWithImpl<$Res>
    implements $AuthUpdateProfileRequestedCopyWith<$Res> {
  _$AuthUpdateProfileRequestedCopyWithImpl(this._self, this._then);

  final AuthUpdateProfileRequested _self;
  final $Res Function(AuthUpdateProfileRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? username = freezed,Object? inGameName = freezed,Object? inGameUid = freezed,Object? privacyProfileVisibility = freezed,Object? privacyShowInGameInfo = freezed,Object? notificationPrefs = freezed,Object? avatarUrl = freezed,}) {
  return _then(AuthUpdateProfileRequested(
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

/// @nodoc


class AuthUpdatePrivacySettingsRequested implements AuthEvent {
  const AuthUpdatePrivacySettingsRequested({required this.profileVisibility, required this.showInGameInfo});
  

 final  String profileVisibility;
 final  bool showInGameInfo;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUpdatePrivacySettingsRequestedCopyWith<AuthUpdatePrivacySettingsRequested> get copyWith => _$AuthUpdatePrivacySettingsRequestedCopyWithImpl<AuthUpdatePrivacySettingsRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUpdatePrivacySettingsRequested&&(identical(other.profileVisibility, profileVisibility) || other.profileVisibility == profileVisibility)&&(identical(other.showInGameInfo, showInGameInfo) || other.showInGameInfo == showInGameInfo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,profileVisibility,showInGameInfo);
}

@override
String toString() {
    return 'AuthEvent.updatePrivacySettingsRequested(profileVisibility: $profileVisibility, showInGameInfo: $showInGameInfo)';
}


}

/// @nodoc
abstract mixin class $AuthUpdatePrivacySettingsRequestedCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthUpdatePrivacySettingsRequestedCopyWith(AuthUpdatePrivacySettingsRequested value, $Res Function(AuthUpdatePrivacySettingsRequested) _then) = _$AuthUpdatePrivacySettingsRequestedCopyWithImpl;
@useResult
$Res call({
 String profileVisibility, bool showInGameInfo
});




}
/// @nodoc
class _$AuthUpdatePrivacySettingsRequestedCopyWithImpl<$Res>
    implements $AuthUpdatePrivacySettingsRequestedCopyWith<$Res> {
  _$AuthUpdatePrivacySettingsRequestedCopyWithImpl(this._self, this._then);

  final AuthUpdatePrivacySettingsRequested _self;
  final $Res Function(AuthUpdatePrivacySettingsRequested) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? profileVisibility = null,Object? showInGameInfo = null,}) {
  return _then(AuthUpdatePrivacySettingsRequested(
profileVisibility: null == profileVisibility ? _self.profileVisibility : profileVisibility // ignore: cast_nullable_to_non_nullable
as String,showInGameInfo: null == showInGameInfo ? _self.showInGameInfo : showInGameInfo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class AuthLoadProfile implements AuthEvent {
  const AuthLoadProfile();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthLoadProfile);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthEvent.loadProfile()';
}


}




/// @nodoc


class AuthSessionExpired implements AuthEvent {
  const AuthSessionExpired();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthEvent.sessionExpired()';
}


}




/// @nodoc


class AuthMfaRequired implements AuthEvent {
  const AuthMfaRequired();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthMfaRequired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthEvent.mfaRequired()';
}


}




/// @nodoc


class AuthAuthCallback implements AuthEvent {
  const AuthAuthCallback({required this.token, required this.type});
  

 final  String token;
 final  String type;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAuthCallbackCopyWith<AuthAuthCallback> get copyWith => _$AuthAuthCallbackCopyWithImpl<AuthAuthCallback>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAuthCallback&&(identical(other.token, token) || other.token == token)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode {
    return Object.hash(runtimeType,token,type);
}

@override
String toString() {
    return 'AuthEvent.authCallback(token: $token, type: $type)';
}


}

/// @nodoc
abstract mixin class $AuthAuthCallbackCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $AuthAuthCallbackCopyWith(AuthAuthCallback value, $Res Function(AuthAuthCallback) _then) = _$AuthAuthCallbackCopyWithImpl;
@useResult
$Res call({
 String token, String type
});




}
/// @nodoc
class _$AuthAuthCallbackCopyWithImpl<$Res>
    implements $AuthAuthCallbackCopyWith<$Res> {
  _$AuthAuthCallbackCopyWithImpl(this._self, this._then);

  final AuthAuthCallback _self;
  final $Res Function(AuthAuthCallback) _then;

/// Create a copy of AuthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,Object? type = null,}) {
  return _then(AuthAuthCallback(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
