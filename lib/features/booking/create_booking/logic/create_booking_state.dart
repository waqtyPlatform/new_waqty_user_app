abstract class CreateBookingState {}

class InitialState extends CreateBookingState {}

/// بيحمّل أيام خدمة **واحدة** بعينها.
///
/// الـ [itemKey] مش زيادة: من غيره الـ skeleton كان هيظهر في كل كروت
/// السلة مع إن اللي بيحمّل واحد بس.
class LoadingDatesState extends CreateBookingState {
  final String itemKey;
  LoadingDatesState({required this.itemKey});
}

class LoadingSlotsState extends CreateBookingState {
  final String itemKey;
  LoadingSlotsState({required this.itemKey});
}

/// أي اختيار اتغيّر (فرع / خدمة / أخصائي / يوم / ميعاد).
class OnSelectionChangedState extends CreateBookingState {}

class OnStepChangedState extends CreateBookingState {}

class CreateBookingLoadingState extends CreateBookingState {}

class CreateBookingSuccessState extends CreateBookingState {}

/// حد خد الميعاد وإحنا بنأكد.
///
/// دي حالة لوحدها مش مجرد خطأ — لأن الرد عليها مختلف تمامًا: بنرجع
/// لخطوة الميعاد، نفتح **الكارت اللي وقع بالذات**، نشخط الشيب، ونحمّل
/// بدائل. **من غير ما نرمي أي اختيار العميل عمله في باقي الخدمات.**
///
/// ## أكتر من ميعاد ممكن يروح في نفس المرة
///
/// كان الحقل `serviceName` مفرد والـ cubit بيقف عند **أول** خدمة وقعت.
/// في حجز بتلات خدمات ممكن اتنين يروحوا مع بعض: العميل يصلّح الأولى،
/// يدوس تأكيد، ويتفاجأ بالتانية — نفس الصدمة مرتين. دلوقتي بنجمّعهم كلهم
/// ونقولهم في رسالة واحدة، وبنفتح أول واحد عشان يبدأ منه.
class SlotTakenState extends CreateBookingState {
  /// الكارت اللي هيتفتح — أول واحد وقع.
  final String itemKey;

  /// أسماء **كل** الخدمات اللي مواعيدها راحت.
  final List<String> serviceNames;

  SlotTakenState({required this.itemKey, required this.serviceNames});
}

/// العميل دخل قائمة انتظار الفرع.
class JoinedWaitlistState extends CreateBookingState {
  final String serviceName;
  JoinedWaitlistState({required this.serviceName});
}

class CreateBookingErrorState extends CreateBookingState {
  final String message;
  CreateBookingErrorState({required this.message});
}
