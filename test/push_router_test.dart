import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/services/push_router.dart';
import 'package:waqty_user_application/firebase_options.dart';

/// **قواعد توجيه الإشعارات.**
///
/// ⚠ الاختبار ده بيغطي كود **مش متنادى دلوقتي** — مفيش مرسل push في
/// المنظومة (مفيش `app/Listeners` ولا `firebase_core` ولا
/// `google-services.json`).
///
/// موجود لأن القواعد نفسها هي الجزء اللي بيتنسى: أنهي نوع بيروح فين،
/// وإيه اللي بيحصل لنوع مش معروف. لما المرسل ينزل، اللي ناقص هو الربط بس.
void main() {
  group('الأنواع المعروفة', () {
    test('اقتراح إعادة توزيع بيفتح شاشته', () {
      final destination = PushRouter.destinationOf({
        'type': 'booking_reassignment',
        'uuid': 'rsg-1',
      });

      expect(destination, isNotNull);
      expect(destination!.route, Routes.reassignmentScreen);
    });

    test('الاسم البديل للنوع بيشتغل برضه', () {
      // السيرفر ممكن يبعت أي واحد فيهم — الاتنين مذكورين في الأحداث.
      expect(
        PushRouter.destinationOf({'type': 'reassignment_proposal'})?.route,
        Routes.reassignmentScreen,
      );
    });

    test('عرض قايمة الانتظار بيفتح تبويب الحجوزات', () {
      final destination = PushRouter.destinationOf({'type': 'waitlist_offer'});

      expect(destination, isNotNull);
      expect(destination!.route, Routes.buttonNavigationBarScreen);
      // ⚠ تبويب الحجوزات مش الرئيسية — قايمة الانتظار عايشة جواه.
      expect(destination.arguments['initialIndex'], 2);
    });

    test('تغيير حالة حجز بيفتح تفاصيله بالـuuid', () {
      final destination = PushRouter.destinationOf({
        'type': 'booking',
        'uuid': '01KZHF7KVH440GQ3A9VW5GRS8V',
      });

      expect(destination!.route, Routes.bookingDetailsScreen);
      expect(
        destination.arguments['bookingUuid'],
        '01KZHF7KVH440GQ3A9VW5GRS8V',
      );
    });
  });

  group('⚠ الحالات اللي مابتفتحش حاجة', () {
    test('نوع مش معروف بيرجّع null مش الرئيسية', () {
      // إشعار من نسخة سيرفر أحدث بيفتح شاشة عشوائية أوحش من إنه مايفتحش
      // — العميل ياخد باله إن الأبلكيشن محتاج تحديث.
      expect(
        PushRouter.destinationOf({'type': 'loyalty_points_earned'}),
        isNull,
      );
    });

    test('حمولة فاضية', () {
      expect(PushRouter.destinationOf(const {}), isNull);
    });

    test('حجز من غير uuid مابيفتحش تفاصيل فاضية', () {
      // `bookingUuid: ''` كان هيفتح شاشة تفاصيل بتحمّل وتفشل. مايفتحش
      // أحسن من يفتح على خطأ.
      expect(PushRouter.destinationOf({'type': 'booking'}), isNull);
    });

    test('القيم مش نصوص — مابيرميش', () {
      expect(
        PushRouter.destinationOf({'type': 123, 'uuid': null}),
        isNull,
      );
    });
  });

  group('⚠ حارس إعداد Firebase', () {
    test('الإعداد لسه فاضي — الإشعارات مطفية', () {
      // الاختبار ده **متوقّع يوقع** يوم ما حد يشغّل
      // `flutterfire configure` — وساعتها يتقلب لـ`isTrue`.
      //
      // موجود عشان محدش يفتكر إن الإشعارات شغّالة وهي مش شغّالة:
      // كل السباكة مبنية ومختبَرة، والناقص الأرقام بس.
      expect(
        DefaultFirebaseOptions.isConfigured,
        isFalse,
        reason:
            'لو بقت true يبقى Firebase اتظبط — اقلب التوقّع ده لـisTrue.',
      );
    });
  });
}
