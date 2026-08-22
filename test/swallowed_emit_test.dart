import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/features/entitlements/entitlement_booking/logic/entitlement_booking_state.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_state.dart';

/// **حالات `const` من غير حقول — الفصيلة اللي بلعت إرسالين.**
///
/// ## الغلطة
///
/// دارت بتوحّد نسخ الـ`const`: `const Foo()` بترجّع **نفس الأوبجكت** كل
/// مرة. وbloc بيتجاهل `emit` لما `state == newState`. فحالة `const`
/// مالهاش حقول = أي انتقال من نفسها لنفسها **بيتبلع في صمت**، والشاشة
/// ماتتبنيش.
///
/// حصلت مرتين في نفس الفيتشر:
///
///  • `EntitlementsLoaded` — التبديل بين تبويبين **الاتنين فيهم داتا**
///    كان بيغيّر `tab` في الكيوبت والشاشة تفضل على القايمة القديمة.
///  • `EntitlementBookingReady` — اختيار ميعاد كان مابيتحدّدش وزرار
///    «أكّد الحجز» يفضل مقفول للأبد.
///
/// ⚠ **الاتنين عدّوا من `flutter analyze` ومن ٦٤٢ اختبار**، واتشافوا على
/// الإيموليتور بس. الاختبارات القديمة كانت بتجرّب انتقالات بين **أنواع**
/// مختلفة، وهي بتشتغل دايمًا — الحالة المكسورة هي الانتقال من النوع
/// لنفسه.
///
/// الملف ده بيقفل الفصيلة: كل حالة بتتبعت أكتر من مرة بقيم مختلفة لازم
/// تبقى **غير متساوية**.
void main() {
  group('EntitlementsLoaded', () {
    test('تبويبين مختلفين = حالتين مختلفتين', () {
      expect(
        const EntitlementsLoaded(EntitlementTab.packages),
        isNot(equals(const EntitlementsLoaded(EntitlementTab.followUps))),
      );
    });

    test('نفس التبويب = نفس الحالة', () {
      expect(
        const EntitlementsLoaded(EntitlementTab.packages),
        equals(const EntitlementsLoaded(EntitlementTab.packages)),
      );
    });

    test('الفاضي كمان بيفرّق بالتبويب', () {
      expect(
        const EntitlementsEmpty(EntitlementTab.packages),
        isNot(equals(const EntitlementsEmpty(EntitlementTab.followUps))),
      );
    });

    test('فاضي ومليان مايتساووش حتى لو نفس التبويب', () {
      expect(
        const EntitlementsEmpty(EntitlementTab.packages),
        isNot(equals(const EntitlementsLoaded(EntitlementTab.packages))),
      );
    });
  });

  group('EntitlementBookingReady', () {
    final day = DateTime(2026, 8, 24);
    final morning = DateTime(2026, 8, 24, 9);
    final evening = DateTime(2026, 8, 24, 17);

    test('اختيار ميعاد بيغيّر الحالة', () {
      expect(
        EntitlementBookingReady(selectedDate: day, selectedSlotStart: morning),
        isNot(
          equals(
            EntitlementBookingReady(selectedDate: day, selectedSlotStart: null),
          ),
        ),
      );
    });

    test('تغيير الميعاد من واحد لتاني بيغيّر الحالة', () {
      expect(
        EntitlementBookingReady(selectedDate: day, selectedSlotStart: morning),
        isNot(
          equals(
            EntitlementBookingReady(
              selectedDate: day,
              selectedSlotStart: evening,
            ),
          ),
        ),
      );
    });

    test('تغيير اليوم بيغيّر الحالة', () {
      expect(
        EntitlementBookingReady(selectedDate: day),
        isNot(
          equals(
            EntitlementBookingReady(selectedDate: DateTime(2026, 8, 25)),
          ),
        ),
      );
    });

    test('نفس الاختيار = نفس الحالة', () {
      expect(
        EntitlementBookingReady(selectedDate: day, selectedSlotStart: morning),
        equals(
          EntitlementBookingReady(
            selectedDate: day,
            selectedSlotStart: morning,
          ),
        ),
      );
    });
  });
}
