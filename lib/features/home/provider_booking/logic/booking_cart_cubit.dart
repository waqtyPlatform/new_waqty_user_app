import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/booking_cart_model.dart';
import '../data/repo/booking_cart_repo.dart';
import 'booking_cart_state.dart';

class BookingCartCubit extends Cubit<BookingCartState> {
  final BookingCartRepo _repo;
  String? _checkoutCartUuid;
  String? _checkoutIdempotencyKey;

  BookingCartCubit(this._repo) : super(const BookingCartState());

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(loading: true, errorCode: null, errorMessage: null));
    }
    final result = await _repo.getCart();
    if (isClosed) return;
    result.fold(_failure, (cart) {
      if (cart == null ||
          (_checkoutCartUuid != null && _checkoutCartUuid != cart.uuid)) {
        _resetCheckoutKey();
      }
      emit(
        state.copyWith(
          cart: cart,
          loading: false,
          action: BookingCartAction.none,
          errorCode: null,
          errorMessage: null,
        ),
      );
    });
  }

  Future<void> addItem(BookingCartAddRequest request) async {
    if (state.mutating) return;
    emit(state.copyWith(mutating: true, errorCode: null, errorMessage: null));
    var result = await _repo.addItem(request);
    if (isClosed) return;
    final failure = result.fold((failure) => failure, (_) => null);
    if (failure is BookingCartFailure &&
        failure.code == 'CART_CONTEXT_MISMATCH') {
      final cleared = await _repo.clear();
      if (isClosed) return;
      if (cleared.isRight()) result = await _repo.addItem(request);
      if (isClosed) return;
    }
    result.fold(_failure, (cart) {
      _resetCheckoutKey();
      emit(
        state.copyWith(
          cart: cart,
          mutating: false,
          action: BookingCartAction.itemAdded,
          actionId: state.actionId + 1,
          errorCode: null,
          errorMessage: null,
        ),
      );
    });
  }

  Future<void> deleteItem(String itemUuid) async {
    if (state.mutating) return;
    emit(state.copyWith(mutating: true));
    final result = await _repo.deleteItem(itemUuid);
    if (isClosed) return;
    result.fold(_failure, (cart) {
      _resetCheckoutKey();
      emit(
        state.copyWith(
          cart: cart,
          mutating: false,
          action: BookingCartAction.itemDeleted,
          actionId: state.actionId + 1,
          errorCode: null,
          errorMessage: null,
        ),
      );
    });
  }

  Future<void> clear() async {
    if (state.mutating) return;
    emit(state.copyWith(mutating: true));
    final result = await _repo.clear();
    if (isClosed) return;
    result.fold(_failure, (_) {
      _resetCheckoutKey();
      emit(
        state.copyWith(
          cart: null,
          mutating: false,
          action: BookingCartAction.cartCleared,
          actionId: state.actionId + 1,
          errorCode: null,
          errorMessage: null,
        ),
      );
    });
  }

  Future<void> checkout() async {
    final cart = state.cart;
    if (state.mutating || cart == null || cart.itemsCount == 0) return;
    emit(state.copyWith(mutating: true, errorCode: null, errorMessage: null));
    final result = await _repo.checkout(
      cartUuid: cart.uuid,
      idempotencyKey: _checkoutKeyFor(cart.uuid),
    );
    if (isClosed) return;
    await result.fold<Future<void>>(
      (failure) async {
        if (failure is BookingCartFailure &&
            failure.code == 'CART_ITEM_EXPIRED') {
          _resetCheckoutKey();
          await load(silent: true);
          if (isClosed) return;
        }
        _failure(failure);
      },
      (checkout) async {
        _resetCheckoutKey();
        emit(
          state.copyWith(
            cart: null,
            checkout: checkout,
            mutating: false,
            action: BookingCartAction.checkedOut,
            actionId: state.actionId + 1,
            errorCode: null,
            errorMessage: null,
          ),
        );
      },
    );
  }

  String _checkoutKeyFor(String cartUuid) {
    if (_checkoutCartUuid != cartUuid || _checkoutIdempotencyKey == null) {
      _checkoutCartUuid = cartUuid;
      _checkoutIdempotencyKey = newIdempotencyKey();
    }
    return _checkoutIdempotencyKey!;
  }

  void _resetCheckoutKey() {
    _checkoutCartUuid = null;
    _checkoutIdempotencyKey = null;
  }

  void _failure(Object failure) {
    final cartFailure = failure is BookingCartFailure ? failure : null;
    if (cartFailure?.code == 'CART_CONTEXT_MISMATCH') {
      _resetCheckoutKey();
    }
    emit(
      state.copyWith(
        cart: cartFailure?.code == 'CART_CONTEXT_MISMATCH' ? null : state.cart,
        loading: false,
        mutating: false,
        action: BookingCartAction.failed,
        actionId: state.actionId + 1,
        errorCode: cartFailure?.code ?? 'REQUEST_FAILED',
        errorMessage: cartFailure?.message ?? failure.toString(),
        expiredItemUuids: cartFailure?.expiredItemUuids ?? const [],
      ),
    );
  }
}

String newIdempotencyKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}
