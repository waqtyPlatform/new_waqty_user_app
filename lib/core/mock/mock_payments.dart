import 'package:waqty_user_application/core/models/payment_ui_model.dart';

/// فكسشرز المدفوعات — سجل قراية بس.
class MockPayments {
  const MockPayments._();

  static List<PaymentUiModel> get all {
    final now = DateTime.now();

    return [
      PaymentUiModel(
        uuid: 'pay-1',
        method: 'cash',
        amount: 250,
        status: PaymentStatusUi.completed,
        createdAt: now.subtract(const Duration(days: 3)),
        bookingUuid: 'bkg-1',
        bookingDate: now.subtract(const Duration(days: 3)),
        notes: 'دفعة مقدّم',
      ),
      PaymentUiModel(
        uuid: 'pay-2',
        method: 'card',
        amount: 480,
        status: PaymentStatusUi.completed,
        transactionId: 'TXN-260808-K4M9P',
        createdAt: now.subtract(const Duration(days: 12)),
        bookingUuid: 'bkg-2',
        bookingDate: now.subtract(const Duration(days: 12)),
      ),
      PaymentUiModel(
        uuid: 'pay-3',
        method: 'cash',
        amount: 150,
        status: PaymentStatusUi.refunded,
        createdAt: now.subtract(const Duration(days: 30)),
        bookingUuid: 'bkg-3',
        bookingDate: now.subtract(const Duration(days: 30)),
        notes: 'استرجاع بعد إلغاء',
      ),
    ];
  }
}
