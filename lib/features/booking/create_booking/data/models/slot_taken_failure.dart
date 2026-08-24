import 'package:waqty_user_application/core/exceptions/failure.dart';

/// **الميعاد اتحجز من حد تاني بين ما العميل اختاره وما دوس تأكيد.**
///
/// نوع خطأ مستقل لأن الشاشة بتعمل حاجة **مختلفة تمامًا** عنده: مابتعرضش
/// رسالة وخلاص — بترجع لخطوة الميعاد، بتفتح كارت الخدمة اللي وقعت، وبتحمّله
/// مواعيد بديلة. تعافي مش إعلان.
///
/// [serviceUuids] بيقول **أنهي خدمات** بالظبط. حجز بتلات خدمات واتنين
/// مواعيدهم راحوا: من غير القايمة دي الشاشة توري واحدة، العميل يصلّحها،
/// يدوس تأكيد، ويتصدم تاني.
///
/// ⚠ **السيرفر مابيرجّعش المعلومة دي.** `POST /api/user/bookings` بيرد ٤٢٢
/// برسالة عامة من غير ما يقول أنهي عنصر. فالنوع ده بيتولّد من
/// `CreateBookingMockService` بس دلوقتي، والفشل الحقيقي من السيرفر بيتعرض
/// كخطأ عام. **طلب للباك-إند:** يرجّع الـuuids المتعارضة في `errors`.
class SlotTakenFailure extends Failure {
  final List<String> serviceUuids;

  const SlotTakenFailure({
    required this.serviceUuids,
    super.message = 'الميعاد اتحجز من حد تاني، اختار ميعاد تاني',
  });

  @override
  List<Object> get props => [message, serviceUuids];
}
