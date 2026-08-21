/// التبويب المعروض — باقات ولا متابعات.
enum EntitlementTab { packages, followUps }

extension EntitlementTabLabel on EntitlementTab {
  String get label => switch (this) {
    EntitlementTab.packages => 'باقات',
    EntitlementTab.followUps => 'متابعات',
  };
}

/// حالات «اللي عندي».
///
/// ## ليه الفاضي حالة لوحده
///
/// لأن **الفاضي هنا مش نهاية طريق واحدة**. عميلة رقمها مش مأكّد بتشوف
/// array فاضية من السيرفر وهي ماسكة باقة مدفوعة — الليستة فاضية بس السبب
/// مختلف تمامًا، والنص لازم يختلف معاه. لو الفاضي كان `Loaded` بليستة
/// طولها صفر، الفرق ده كان هيتحط في الـwidget وهيتنسى.
sealed class EntitlementsState {
  const EntitlementsState();
}

class EntitlementsInitial extends EntitlementsState {
  const EntitlementsInitial();
}

class EntitlementsLoading extends EntitlementsState {
  const EntitlementsLoading();
}

class EntitlementsLoaded extends EntitlementsState {
  const EntitlementsLoaded();
}

/// التبويب الحالي مالوش محتوى.
///
/// ⚠ **مش معناها إن الاتنين فاضيين** — ممكن يبقى عندها باقات ومفيش
/// متابعات. الشاشة بتفضل موريّة الـsegmented عشان تقدر تعدّي للتاني.
class EntitlementsEmpty extends EntitlementsState {
  const EntitlementsEmpty();
}

class EntitlementsError extends EntitlementsState {
  const EntitlementsError(this.message);

  final String message;
}

/// بنحجز متابعة — الشيت مقفول والزرار بيلف.
class EntitlementBookingSubmitting extends EntitlementsState {
  const EntitlementBookingSubmitting();
}

/// الحجز نجح.
///
/// ⚠ **من غير payload — ومش سهو.** `bookFollowUp` بيرجّع `Booking` خام مش
/// `UserBookingResource` (BE-A2)، فمافيش `uuid` نقدر نعتمد عليه للتنقّل.
/// الشاشة بتقفل الشيت وتروح «حجوزاتي» وتعمل refresh — ده صادق وبيكلّف سطر،
/// والبديل بيبني اعتماد على شكل محدش وعد بيه.
class EntitlementBookingSucceeded extends EntitlementsState {
  const EntitlementBookingSucceeded();
}

/// الحجز فشل — الشيت **بيفضل مفتوح** بالرسالة دي فوق زرار التأكيد.
class EntitlementBookingFailed extends EntitlementsState {
  const EntitlementBookingFailed(this.message);

  final String message;
}
