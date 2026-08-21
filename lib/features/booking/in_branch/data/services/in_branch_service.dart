import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';

/// حالة العميل جوّه الفرع.
///
/// ⚠ **جزئي بقصد.** الحالة (`arrived`/`waiting`/`in_progress`) بتيجي من
/// `GET /api/user/bookings/{uuid}` وهي حقيقية. **الترتيب في الطابور والوقت
/// المتوقّع مالهمش أي إشارة في أي endpoint** — لا في مورد الحجز ولا في أي
/// راوت تاني. فالتقدير بيفضل من `MockInBranch`.
///
/// **وماتخترعش تقدير من مدة الخدمة.** «باقي ١٥ دقيقة» محسوبة من الجدول
/// المتوقّع مش من الواقع بتبقى كذبة أوحش من «مفيش تقدير» — والصالون اللي
/// متأخر ساعة هيدفع تمنها في تقييم العميل.
abstract class InBranchService {
  /// بترجّع الحالة، أو `null` لو العميل مش جوّه الفرع دلوقتي.
  Future<Either<Failure, InBranchUiModel?>> status(BookingUiModel booking);
}
