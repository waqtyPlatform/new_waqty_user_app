sealed class PaymentsState {
  const PaymentsState();
}

class PaymentsInitialState extends PaymentsState {
  const PaymentsInitialState();
}

class PaymentsLoadingState extends PaymentsState {
  const PaymentsLoadingState();
}

class PaymentsLoadingMoreState extends PaymentsState {
  const PaymentsLoadingMoreState();
}

class PaymentsSuccessState extends PaymentsState {
  const PaymentsSuccessState();
}

/// مفيش مدفوعات — **الحالة الغالبة** لعميل بيدفع في الفرع كاش.
class PaymentsEmptyState extends PaymentsState {
  const PaymentsEmptyState();
}

class PaymentsErrorState extends PaymentsState {
  final String message;

  const PaymentsErrorState({required this.message});
}
