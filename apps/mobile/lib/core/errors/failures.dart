/// Base failure classes for error handling across the application.
/// Uses dartz Either for functional error handling.

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code, originalError];

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (code: $code)' : ''}';
}

/// Server-side failures (API, database, RPC)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Validation failures (client-side)
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Permission/Authorization failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Type alias for Result (Either<Failure, T>)
typedef Result<T> = Either<Failure, T>;

/// Extension methods for Result handling
extension ResultX<T> on Result<T> {
  /// Returns the value if Right, throws if Left
  T getOrThrow() => fold(
        (failure) => throw FailureException(failure),
        (value) => value,
      );

  /// Returns the value if Right, or default if Left
  T getOrElse(T Function(Failure) onFailure) => fold(onFailure, (value) => value);

  /// Maps the success value
  Result<U> map<U>(U Function(T) transform) => fold(
        (failure) => Left(failure),
        (value) => Right(transform(value)),
      );

  /// Flat maps the success value
  Result<U> flatMap<U>(Result<U> Function(T) transform) => fold(
        (failure) => Left(failure),
        (value) => transform(value),
      );

  /// Executes side effect on success
  Result<T> onSuccess(void Function(T) action) {
    fold((_) {}, action);
    return this;
  }

  /// Executes side effect on failure
  Result<T> onFailure(void Function(Failure) action) {
    fold(action, (_) {});
    return this;
  }

  /// Checks if this is a success
  bool get isSuccess => fold((_) => false, (_) => true);

  /// Checks if this is a failure
  bool get isFailure => fold((_) => true, (_) => false);

  /// Gets the failure if any
  Failure? get failure => fold((f) => f, (_) => null);

  /// Gets the value if any
  T? get value => fold((_) => null, (v) => v);
}

/// Exception wrapper for failures (for use with getOrThrow)
class FailureException implements Exception {
  final Failure failure;

  FailureException(this.failure);

  @override
  String toString() => failure.toString();
}

/// Common error codes
class ErrorCodes {
  static const String unauthenticated = 'UNAUTHENTICATED';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String notFound = 'NOT_FOUND';
  static const String conflict = 'CONFLICT';
  static const String validation = 'VALIDATION_ERROR';
  static const String rateLimited = 'RATE_LIMITED';
  static const String serverError = 'SERVER_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String unknown = 'UNKNOWN';
}