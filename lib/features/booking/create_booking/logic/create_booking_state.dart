abstract class CreateBookingState {}

class InitialState extends CreateBookingState {}

class LoadingDatesState extends CreateBookingState {}

class LoadingSlotsState extends CreateBookingState {}

/// أي اختيار اتغيّر (فرع / خدمة / أخصائي / يوم / ميعاد).
class OnSelectionChangedState extends CreateBookingState {}

class OnStepChangedState extends CreateBookingState {}

class CreateBookingLoadingState extends CreateBookingState {}

class CreateBookingSuccessState extends CreateBookingState {}

/// حد خد الميعاد وإحنا بنأكد.
///
/// دي حالة لوحدها مش مجرد خطأ — لأن الرد عليها مختلف تمامًا: بنرجع
/// لخطوة الميعاد، نشخط الشيب، ونقترح أقرب بديلين. **من غير ما نرمي أي
/// اختيار العميل عمله.**
class SlotTakenState extends CreateBookingState {}

class CreateBookingErrorState extends CreateBookingState {
  final String message;
  CreateBookingErrorState({required this.message});
}
