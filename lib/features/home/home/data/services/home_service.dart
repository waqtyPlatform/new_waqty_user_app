import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';

/// عقد داتا الرئيسية — بينفّذه [HomeRemoteService] و[HomeMockService].
///
/// الاتنين بيرجّعوا `Either<Failure, T>` فالـrepo مابيفرقش بينهم، والـcubit
/// مايعرفش إن فيه مصدرين أصلاً.
abstract class HomeService {
  Future<Either<Failure, List<CategoryUiModel>>> categories();

  /// المقدّمين المعروضين على الرئيسية.
  ///
  /// [cityUuid] بيفلتر على المدينة المختارة. `null` = كل المدن.
  Future<Either<Failure, List<ProviderUiModel>>> providers({String? cityUuid});

  /// أقرب حجز جاي — `null` لو مفيش.
  Future<Either<Failure, BookingUiModel?>> upcomingBooking();

  /// آخر حجز **مكتمل** — مصدر كارت «زي المرة اللي فاتت».
  ///
  /// ⚠ المكتمل بس: الملغي واللي ما حضرش **مش** «مرة فاتت»، وعرض إعادة
  /// حجز لموعد العميل لغاه بنفسه بيقرا استهبال.
  Future<Either<Failure, BookingUiModel?>> lastCompletedBooking();
}
