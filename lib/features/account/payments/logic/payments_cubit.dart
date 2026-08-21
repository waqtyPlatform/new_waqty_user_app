import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/payment_ui_model.dart';
import 'package:waqty_user_application/features/account/payments/data/repo/payments_repo.dart';
import 'package:waqty_user_application/features/account/payments/logic/payments_state.dart';

/// سجل المدفوعات — **قراية بس**.
///
/// ⚠ `/api/user/payments` فيه `index` و`show` وخلاص. مفيش `create` —
/// الأبلكيشن مايقدرش ياخد فلوس، والدفع بيتسجّل من الفرع.
class PaymentsCubit extends Cubit<PaymentsState> {
  final PaymentsRepo _repo;

  PaymentsCubit(this._repo) : super(const PaymentsInitialState());

  static const int perPage = 15;

  List<PaymentUiModel> payments = <PaymentUiModel>[];

  int _page = 1;
  bool hasMore = false;
  bool isLoadingMore = false;

  Future<void> load() async {
    emit(const PaymentsLoadingState());

    _page = 1;
    isLoadingMore = false;

    final result = await _repo.payments(page: 1, perPage: perPage);
    if (isClosed) return;

    result.fold(
      (failure) => emit(PaymentsErrorState(message: failure.message)),
      (page) {
        payments = page.data;
        _page = page.currentPage;
        hasMore = page.hasMore;
        emit(
          page.isEmpty
              ? const PaymentsEmptyState()
              : const PaymentsSuccessState(),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    emit(const PaymentsLoadingMoreState());

    final result = await _repo.payments(page: _page + 1, perPage: perPage);
    if (isClosed) return;

    isLoadingMore = false;

    result.fold(
      (_) {
        // فشل صفحة إضافية مابيمسحش اللي قدام العميل.
        hasMore = false;
        emit(const PaymentsSuccessState());
      },
      (page) {
        payments = [...payments, ...page.data];
        _page = page.currentPage;
        hasMore = page.hasMore;
        emit(const PaymentsSuccessState());
      },
    );
  }

  static PaymentsCubit get(context) => BlocProvider.of(context);
}
