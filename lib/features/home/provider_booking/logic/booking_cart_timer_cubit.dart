import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class BookingCartTimerCubit extends Cubit<int> {
  Timer? _timer;

  BookingCartTimerCubit({
    int? remainingSeconds,
    required DateTime? expiresAt,
    required DateTime? serverTime,
  }) : super(
         _nonNegative(remainingSeconds) ??
             _remainingSeconds(expiresAt, serverTime),
       );

  void start() {
    _timer?.cancel();
    if (state <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state <= 1) {
        _timer?.cancel();
        emit(0);
      } else {
        emit(state - 1);
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

int _remainingSeconds(DateTime? expiresAt, DateTime? serverTime) {
  if (expiresAt == null || serverTime == null) return 0;
  return _nonNegative(expiresAt.difference(serverTime).inSeconds) ?? 0;
}

int? _nonNegative(int? value) => value == null
    ? null
    : value < 0
    ? 0
    : value;
