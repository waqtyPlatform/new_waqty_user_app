/// حالات شيت حجز الاستحقاق — باقة أو متابعة.
///
/// الفلو **مرحلتين**: بنجيب تواريخ → بنجيب مواعيد. لكل واحدة حالة تحميل
/// لوحدها عشان الشيت يقول اللي بيحصل بالظبط — «بنحمّل» واحدة لنداءين
/// مختلفين بتخلّي أي بطء يبان زي التعليق.
///
/// كانت **تلات** مراحل: الأولى كانت «بنحلّ الفرع» — نداء زيادة على
/// `GET /user/bookings/{original_booking_uuid}` عشان نطلّع الفرع من
/// snapshots الحجز الأصلي، والحيلة دي كانت متاحة للمتابعات بس فالباقة
/// مكانتش بتتحجز خالص. BE-A1 نزّل الفرع في الصف نفسه فالمرحلة دي اتشالت.
sealed class EntitlementBookingState {
  const EntitlementBookingState();
}

/// **الحالة الابتدائية** — قبل ما `start()` تنادي أول حاجة.
///
/// كان اسمها بيوصف نداء حلّ الفرع اللي اتشال مع BE-A1. فضلت لأن الكيوبت
/// محتاج حالة يبدأ بيها، والشيت بيرسم سبينر عليها زي `LoadingDates` —
/// المدة بتاعتها دلوقتي جزء من الجزء من الثانية اللي قبل أول نداء.
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
