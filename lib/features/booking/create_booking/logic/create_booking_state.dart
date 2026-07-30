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
class SlotTakenState extends CreateBookingState {
  final String itemKey;
  final String serviceName;
  SlotTakenState({required this.itemKey, required this.serviceName});
}

class CreateBookingErrorState extends CreateBookingState {
  final String message;
  CreateBookingErrorState({required this.message});
}
