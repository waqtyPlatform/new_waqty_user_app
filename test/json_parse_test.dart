import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';

/// **التواريخ الجاية من الـ API بساعة الفرع.**
///
/// `DateTime.parse` على نص فيه إزاحة بترجّع UTC، و`AppFormat` بيقرا
/// `.hour` على طول. النتيجة إن ميعاد `18:00+03:00` كان بيتعرض **٣:٠٠ م**.
///
/// الاختبارات دي **مستقلة عن منطقة الجهاز** بالقصد: الغرض إن نفس الرد
/// يدي نفس الرقم على أي جهاز، فأي اختبار بيعتمد على إزاحة الجهاز بيقيس
/// العكس.
void main() {
  group('JsonParse.dateOrNull — ساعة الفرع', () {
    test('الإزاحة بتتشال والساعة بتفضل زي ما وصلت', () {
      final parsed = JsonParse.dateOrNull('2026-08-10T18:00:00+03:00')!;

      expect(parsed.hour, 18);
      expect(parsed.minute, 0);
      expect(parsed.isUtc, isFalse);
    });

    test('نفس الرقم مهما اتغيّرت الإزاحة في الرد', () {
      // ساعة الفرع هي المعروضة — مش لحظة مطلقة بتتحوّل.
      for (final offset in <String>['+03:00', '+02:00', '-05:00', '+0530']) {
        expect(
          JsonParse.dateOrNull('2026-08-10T18:00:00$offset')!.hour,
          18,
          reason: 'الإزاحة «$offset» غيّرت الساعة',
        );
      }
    });

    test('الوقت من غير إزاحة زي ما هو', () {
      final parsed = JsonParse.dateOrNull('2026-08-10T18:00:00')!;

      expect(parsed.hour, 18);
      expect(parsed.isUtc, isFalse);
    });

    test('تاريخ من غير وقت مابيتكسرش', () {
      // ⚠ `2026-08-10` آخره `-10` — رقمين بعد إشارة. لو النمط كان
      // بياخد رقمين، كان هيقص التاريخ نفسه ويطلع سنة غلط.
      final parsed = JsonParse.dateOrNull('2026-08-10')!;

      expect(parsed.year, 2026);
      expect(parsed.month, 8);
      expect(parsed.day, 10);
      expect(parsed.hour, 0);
    });

    test('الشكل بمسافة بدل T', () {
      final parsed = JsonParse.dateOrNull('2026-08-10 18:00:00')!;

      expect(parsed.hour, 18);
      expect(parsed.day, 10);
    });

    test('الثواني الكسرية مابتكسرش القراءة', () {
      final parsed = JsonParse.dateOrNull('2026-08-10T18:00:00.000000Z')!;

      expect(parsed.hour, 18);
      expect(parsed.isUtc, isFalse);
    });

    test('النص الفاضي والبايظ بيرجّعوا null', () {
      expect(JsonParse.dateOrNull(null), isNull);
      expect(JsonParse.dateOrNull(''), isNull);
      expect(JsonParse.dateOrNull('   '), isNull);
      expect(JsonParse.dateOrNull('مش تاريخ'), isNull);
    });

    test('الـ DateTime الجاهز بيعدّي زي ما هو', () {
      final now = DateTime(2026, 8, 10, 18);

      expect(JsonParse.dateOrNull(now), now);
    });
  });

  group('الأثر على الشاشة', () {
    test('AppFormat.time بيعرض ساعة الرد مش UTC', () {
      // ده الباج بشكله اللي العميل كان هيشوفه: ميعاد ٦ م بيتعرض ٣ م.
      //
      // الأرقام **غربية** — قرار مقفول في المشروع، و`AppFormat.digits`
      // هي البوابة اللي بتفرضه.
      final at = JsonParse.dateOrNull('2026-08-10T18:00:00+03:00')!;

      expect(AppFormat.time(at), '6:00 م');
    });

    test('اليوم مابيرجعش لورا في المواعيد المتأخرة', () {
      // ⚠ **ده الجزء اللي `toLocal()` مكانش هيحله كفاية.**
      //
      // حجز ١١:٣٠ م بإزاحة موجبة بيبقى في UTC نفس اليوم الساعة ٨:٣٠ م
      // — أو اليوم اللي قبله لو الإزاحة أكبر. وتجميع الزيارات بيبني
      // `DateTime(y, m, d)` من التاريخ ده، فالحجز كان بيتحط في اليوم
      // الغلط في القايمة.
      final late = JsonParse.dateOrNull('2026-08-10T23:30:00+03:00')!;

      expect(late.day, 10);
      expect(late.hour, 23);
    });

    test('الحجز بيتقرا بساعة الفرع من رد كامل', () {
      final booking = BookingUiModel.fromJson(<String, dynamic>{
        'uuid': '01K1M9Q4T7B8XC2VF6ND3RGZPW',
        'status': 'confirmed',
        'provider': <String, dynamic>{'uuid': 'prv-1', 'name': 'صالون كابتن'},
        'branch': <String, dynamic>{'uuid': 'brn-1', 'name': 'فرع المعادي'},
        'visits': <Map<String, dynamic>>[
          <String, dynamic>{
            'uuid': 'vst-1',
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'uuid': 'itm-1',
                'start_at': '2026-08-10T18:00:00+03:00',
                'duration_minutes': 45,
                'booked_price': '150.00',
                'service': <String, dynamic>{'uuid': 'srv-1', 'name': 'قص شعر'},
                'employee': <String, dynamic>{'uuid': 'emp-1', 'name': 'أحمد'},
              },
            ],
          },
        ],
      });

      expect(booking.startAt.hour, 18);
      expect(booking.endAt.hour, 18);
      expect(booking.endAt.minute, 45);
    });
  });
}
