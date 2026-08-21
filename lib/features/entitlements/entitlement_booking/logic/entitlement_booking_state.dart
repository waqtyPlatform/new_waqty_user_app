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

/// جاهز — الاختيارات كلها في الكيوبت.
class EntitlementBookingReady extends EntitlementBookingState {
  const EntitlementBookingReady();
}

class EntitlementBookingError extends EntitlementBookingState {
  const EntitlementBookingError(this.message);

  final String message;
}
