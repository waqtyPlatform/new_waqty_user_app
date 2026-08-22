/// حالات شيت حجز المتابعة.
///
/// الفلو تلات مراحل: **بنحلّ الفرع** (نداء زيادة على الحجز الأصلي) →
/// **بنجيب تواريخ** → **بنجيب مواعيد**. كل واحدة ليها حالة تحميل لوحدها
/// عشان الشيت يقول اللي بيحصل بالظبط — «بنحمّل» واحدة لتلات نداءات
/// مختلفة بتخلّي أي بطء يبان زي التعليق.
sealed class EntitlementBookingState {
  const EntitlementBookingState();
}

/// بنجيب الفرع والخدمة من الحجز الأصلي. TODO(api): BE-A1 بيشيل دي.
class EntitlementBookingResolving extends EntitlementBookingState {
  const EntitlementBookingResolving();
}

class EntitlementBookingLoadingDates extends EntitlementBookingState {
  const EntitlementBookingLoadingDates();
}

class EntitlementBookingLoadingSlots extends EntitlementBookingState {
  const EntitlementBookingLoadingSlots();
}

/// جاهز — والاختيار الحالي **جوه الحالة**.
///
/// ⚠ **الحقول دي مش زخرفة، دي اللي بتخلّي الاختيار يترسم.**
///
/// الحالة كانت `const EntitlementBookingReady()` من غير حقول. دارت بتوحّد
/// نسخ الـ`const`، وbloc بيتجاهل `emit` لما `state == newState` — فاختيار
/// ميعاد وإحنا أصلاً في `Ready` كان بيتبلع، الشيب مايتحدّدش، وزرار
/// «أكّد الحجز» يفضل مقفول للأبد.
///
/// اختيار **اليوم** كان شغّال بالصدفة لأنه بيمرّ بـ`LoadingSlots` الأول
/// (نوع مختلف) — وده اللي خلّى الباج يبان كإن المشكلة في المواعيد بس.
///
/// نفس الغلطة كانت في `EntitlementsLoaded` — شوفها هناك.
class EntitlementBookingReady extends EntitlementBookingState {
  const EntitlementBookingReady({
    this.selectedDate,
    this.selectedSlotStart,
    this.serviceUuid = '',
  });

  final DateTime? selectedDate;
  final DateTime? selectedSlotStart;

  /// البركة بتسيب العميلة تغيّر الخدمة، وده بيغيّر المواعيد — فلازم يدخل
  /// في المقارنة زي الباقي.
  final String serviceUuid;

  @override
  bool operator ==(Object other) =>
      other is EntitlementBookingReady &&
      other.selectedDate == selectedDate &&
      other.selectedSlotStart == selectedSlotStart &&
      other.serviceUuid == serviceUuid;

  @override
  int get hashCode => Object.hash(selectedDate, selectedSlotStart, serviceUuid);
}

class EntitlementBookingError extends EntitlementBookingState {
  const EntitlementBookingError(this.message);

  final String message;
}
