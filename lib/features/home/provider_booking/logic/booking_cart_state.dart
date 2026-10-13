import '../data/models/booking_cart_model.dart';

enum BookingCartAction {
  none,
  itemAdded,
  itemDeleted,
  cartCleared,
  checkedOut,
  failed,
}

class BookingCartState {
  final BookingCartModel? cart;
  final bool loading, mutating;
  final BookingCartAction action;
  final int actionId;
  final String? errorCode, errorMessage;
  final List<String> expiredItemUuids;
  final BookingCartCheckoutModel? checkout;

  const BookingCartState({
    this.cart,
    this.loading = false,
    this.mutating = false,
    this.action = BookingCartAction.none,
    this.actionId = 0,
    this.errorCode,
    this.errorMessage,
    this.expiredItemUuids = const [],
    this.checkout,
  });

  BookingCartState copyWith({
    Object? cart = _keep,
    bool? loading,
    bool? mutating,
    BookingCartAction? action,
    int? actionId,
    Object? errorCode = _keep,
    Object? errorMessage = _keep,
    List<String>? expiredItemUuids,
    Object? checkout = _keep,
  }) => BookingCartState(
    cart: identical(cart, _keep) ? this.cart : cart as BookingCartModel?,
    loading: loading ?? this.loading,
    mutating: mutating ?? this.mutating,
    action: action ?? this.action,
    actionId: actionId ?? this.actionId,
    errorCode: identical(errorCode, _keep)
        ? this.errorCode
        : errorCode as String?,
    errorMessage: identical(errorMessage, _keep)
        ? this.errorMessage
        : errorMessage as String?,
    expiredItemUuids: expiredItemUuids ?? this.expiredItemUuids,
    checkout: identical(checkout, _keep)
        ? this.checkout
        : checkout as BookingCartCheckoutModel?,
  );
}

const _keep = Object();
