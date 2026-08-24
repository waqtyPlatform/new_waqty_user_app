import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/core/api/api_envelope.dart';
import 'package:waqty_user_application/core/api/session_store.dart';
import 'package:waqty_user_application/core/api/status_code.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';

/// المكان الوحيد اللي بيفهم رد السيرفر.
///
/// كل `*RemoteService` بينده من هنا، فمحدش بيكرّر: فك الظرف، تحويل الحالة
/// لـ[Failure]، ولا معالجة الـ٤٠١.
///
/// ## العقد
///
/// كل دالة بترجّع `Either<Failure, T>` — **مابترميش**. الـcubit بيعمل `.fold`
/// وخلاص. ده نفس العقد اللي `MockSource` بيمشي عليه، عشان تبديل المصدر
/// مايغيّرش شكل الـcubit.
class ApiClient {
  final ApiConsumer _consumer;
  final SessionStore _session;

  const ApiClient(this._consumer, this._session);

  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(ApiEnvelope envelope) parse,
  }) => _send(() => _consumer.get(path, null, query: query), parse);

  Future<Either<Failure, T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(ApiEnvelope envelope) parse,
  }) => _send(() => _consumer.post(path, body, null), parse);

  Future<Either<Failure, T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(ApiEnvelope envelope) parse,
  }) => _send(() => _consumer.patch(path, body, null), parse);

  Future<Either<Failure, T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(ApiEnvelope envelope) parse,
  }) => _send(() => _consumer.put(path, body, null), parse);

  Future<Either<Failure, T>> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(ApiEnvelope envelope) parse,
  }) => _send(() => _consumer.delete(path, body, null), parse);

  Future<Either<Failure, T>> _send<T>(
    Future<dynamic> Function() call,
    T Function(ApiEnvelope envelope) parse,
  ) async {
    final ApiEnvelope envelope;
    try {
      envelope = ApiEnvelope.of(await call());
    } on SocketException {
      return const Left(NetworkFailure());
    } on HttpException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(
        NetworkFailure(message: 'السيرفر أخد وقت طويل، جرّب تاني'),
      );
    } catch (_) {
      // أي حاجة تانية من طبقة النقل — مش قادرين نفرّقها، فبتتعامل كشبكة.
      return const Left(NetworkFailure());
    }

    final failure = await _failureFor(envelope);
    if (failure != null) return Left(failure);

    try {
      return Right(parse(envelope));
    } catch (_) {
      // الرد عدّى بس شكله مش اللي متوقعينه — فرق عقد، مش خطأ مستخدم.
      return const Left(
        ServerFailure(message: 'الرد من السيرفر مش مفهوم، جرّب تاني'),
      );
    }
  }

  /// بتحوّل الحالة لـ[Failure]، أو `null` لو الرد سليم.
  ///
  /// ⚠ **`success: false` بحالة ٢٠٠ لازم تتمسك.** `ApiResponse::error` بياخد
  /// حالة افتراضية ٤٠٠ بس بعض الكونترولرز بتبعت خطأ داخل ٢٠٠، فالاعتماد على
  /// الحالة لوحدها بيسيب الخطأ يعدّي كنجاح.
  Future<Failure?> _failureFor(ApiEnvelope envelope) async {
    if (envelope.statusCode == StatusCode.unauthorized) {
      await _session.expire();
      return UnauthorizedFailure(
        message: envelope.message ?? const UnauthorizedFailure().message,
      );
    }

    if (envelope.statusCode == StatusCode.tooManyRequests) {
      return const ThrottleFailure();
    }

    if (envelope.statusCode == StatusCode.unprocessable) {
      return ValidationFailure(
        // رسالة لارافيل العامة («The given data was invalid.») إنجليزي
        // ومالهاش قيمة للمستخدم — أول خطأ حقل أوضح منها بكتير.
        message:
            envelope.firstFieldError ??
            envelope.message ??
            'فيه بيانات ناقصة أو غلط',
        fields: envelope.errors,
      );
    }

    if (!envelope.isOk || !envelope.success) {
      return ServerFailure(
        message: envelope.message ?? ServerFailure.fallbackMessage,
      );
    }

    return null;
  }
}
