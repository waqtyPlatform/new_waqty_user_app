import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/models/account_ui_model.dart';
import 'package:waqty_user_application/core/models/branch_ui_model.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/employee_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/core/models/service_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';

/// **الـJSON اللي تحت منقول من ردود حقيقية، مش متخيّل.**
///
/// اتجاب بنداء فعلي على الباك-إند المحلي وهو شغال. لو الاختبار ده وقع بعد
/// تغيير في مورد، يبقى العقد اتغيّر — مش الاختبار اللي غلط.
///
/// التلات فخاخ اللي بيغطّيهم:
///
/// | الفخ | فين |
/// |---|---|
/// | الأرقام بتوصل **نصوص** | `latitude:"29.9601000"` · `price:"150.00"` |
/// | الاسم أحيانًا **خريطة** | `{"ar":"غيار جرح","en":"Wound Dressing"}` |
/// | حقول **مش موجودة** أصلاً | `price_from` · `services_count` |
void main() {
  group('CategoryUiModel', () {
    test('الرد الحقيقي من public/categories', () {
      final c = CategoryUiModel.fromJson({
        'uuid': '01KXV6B6HPG6YQS1FRAM2SGATT',
        'name': 'عيادة طبية',
        'image_url': null,
        'requires_specialty': true,
        'has_subcategories': false,
        'subcategories_count': 0,
        'specialties_count': 10,
        'specialties': [
          {'id': 1, 'slug': 'dental', 'name': 'أسنان'},
        ],
      });

      expect(c.uuid, '01KXV6B6HPG6YQS1FRAM2SGATT');
      expect(c.name, 'عيادة طبية');
      expect(c.imagePath, '', reason: 'image_url بيرجع null');
      // ⚠ `specialties_count: 10` **مش** عدد خدمات — ماينفعش يتقرا مكانه.
      expect(c.servicesCount, 0);
    });
  });

  group('ProviderUiModel', () {
    const realJson = {
      'uuid': '01KXV882DBRJXA20NZ08TRDVF1',
      'name': 'مجمع الفيل',
      'category': {'uuid': '01KXV6B6HW7TX5ECYJ991402N5', 'name': 'مجمع عيادات'},
      'main_branch': {
        'uuid': '01KXVFHD44V3YYG1WQ8PTCSWVR',
        'city_name': 'المعادي',
        'latitude': '29.9601000',
        'longitude': '31.2569000',
        'logo_url': null,
      },
    };

    test('الرد الحقيقي من public/providers', () {
      final p = ProviderUiModel.fromJson(realJson);

      expect(p.uuid, '01KXV882DBRJXA20NZ08TRDVF1');
      expect(p.name, 'مجمع الفيل');
      expect(p.categoryName, 'مجمع عيادات');
      expect(p.areaName, 'المعادي', reason: 'المنطقة جوّه main_branch');
    });

    test('⚠ الحقول اللي السيرفر مابيبعتهاش بتفضل صفر مش قيمة مخترعة', () {
      final p = ProviderUiModel.fromJson(realJson);

      expect(p.priceFrom, 0);
      expect(p.servicesCount, 0);
      expect(p.nextAvailableLabel, '');
    });

    test('الإحداثيات نصوص وبتتحوّل أرقام', () {
      final coords = ProviderUiModel.coordinatesOf(realJson);

      expect(coords, isNotNull);
      expect(coords!.latitude, closeTo(29.9601, 0.0001));
      expect(coords.longitude, closeTo(31.2569, 0.0001));
    });

    test('فرع من غير إحداثيات بيرجّع null مش صفر', () {
      final coords = ProviderUiModel.coordinatesOf({
        'uuid': 'x',
        'main_branch': {'city_name': 'المعادي'},
      });

      // صفر/صفر جزيرة في المحيط الأطلنطي — المسافة منها هتبقى آلاف الكيلومترات.
      expect(coords, isNull);
    });

    test('المسافة بتتحقن من بره', () {
      final p = ProviderUiModel.fromJson(realJson, distanceKm: 3.4);
      expect(p.distanceKm, 3.4);
    });
  });

  group('BranchUiModel', () {
    test('الرد الحقيقي من public/provider-branches', () {
      final b = BranchUiModel.fromJson({
        'uuid': '01KXVFHD44V3YYG1WQ8PTCSWVR',
        'name': 'المقر الرئيسي — المعادي',
        'city_name': 'المعادي',
        'country_name': 'مصر',
        'latitude': '29.9601000',
        'longitude': '31.2569000',
      });

      expect(b.name, 'المقر الرئيسي — المعادي');
      expect(b.areaName, 'المعادي');
      expect(b.latitude, closeTo(29.9601, 0.0001));
      // ⚠ المورد مابيبعتش العنوان ولا التليفون ولا ساعات العمل.
      expect(b.address, '');
      expect(b.phone, '');
      expect(b.workingHours, isEmpty);
    });
  });

  group('ServiceUiModel', () {
    const realJson = {
      'uuid': '01KZC1WM96AK8BBK0SVQKXAA6R',
      'name': 'كشف باطنة',
      'description': 'كشف باطنة — [test-data]',
      'image_url': null,
      'sub_category_uuid': null,
      'providers': [
        {
          'uuid': '01KXV882DBRJXA20NZ08TRDVF1',
          'name': 'مجمع الفيل',
          'default_price': null,
          'estimated_duration_minutes': 30,
          'service_name': null,
        },
      ],
    };

    test('السعر والمدة بيتقروا من العرض مش من الخدمة', () {
      final s = ServiceUiModel.fromJson(realJson);

      expect(s.uuid, '01KZC1WM96AK8BBK0SVQKXAA6R');
      expect(s.name, 'كشف باطنة');
      expect(s.durationMinutes, 30, reason: 'جاي من providers[0]');
      expect(s.price, 0, reason: 'default_price بيرجع null');
    });

    test('العرض بيتختار بالـprovider_uuid مش أول واحد', () {
      final s = ServiceUiModel.fromJson({
        ...realJson,
        'providers': [
          {'uuid': 'aaa', 'default_price': '100.00', 'estimated_duration_minutes': 20},
          {'uuid': 'bbb', 'default_price': '250.00', 'estimated_duration_minutes': 45},
        ],
      }, providerUuid: 'bbb');

      expect(s.price, 250, reason: 'السعر نص "250.00" بيتحوّل رقم');
      expect(s.durationMinutes, 45);
    });

    test('السعر المحلول من service-pricing بيغلب على default_price', () {
      final s = ServiceUiModel.fromJson(realJson, resolvedPrice: 187.5);
      expect(s.price, 187.5);
    });

    test('المقدّم لو سمّى الخدمة باسمه، اسمه هو اللي يبان', () {
      final s = ServiceUiModel.fromJson({
        ...realJson,
        'providers': [
          {'uuid': 'aaa', 'service_name': 'كشف باطنة VIP'},
        ],
      });

      expect(s.name, 'كشف باطنة VIP');
    });
  });

  group('EmployeeUiModel', () {
    test('السعر بيتقرا من الخدمة المطلوبة', () {
      final e = EmployeeUiModel.fromJson({
        'uuid': '01KZC1WK51B4T34T0BC26KNKHV',
        'name': 'أسماء رمضان',
        'has_app_access': true,
        'logo_url': null,
        'services': [
          {'uuid': 'svc-a', 'name': 'كشف', 'price': '150.00'},
          {'uuid': 'svc-b', 'name': 'غيار', 'price': '80.00'},
        ],
      }, serviceUuid: 'svc-b');

      expect(e.name, 'أسماء رمضان');
      expect(e.price, 80);
      expect(e.isAnyAvailable, isFalse);
    });
  });

  group('AccountUiModel', () {
    test('user/auth/me بيرجّع موديل خام', () {
      final a = AccountUiModel.fromJson({
        'id': 1,
        'name': 'Layla Hassan',
        'email': 'layla.hassan@example.com',
        'uuid': '01KXV6B72Y88CH0SBZXS2F79VD',
        'phone': '01113000000',
        'normalized_phone': '+201113000000',
        'gender': 'female',
        'image_path': null,
        'active': true,
      });

      expect(a.name, 'Layla Hassan');
      // ⚠ الشاشة بتعرض `phone` مش `normalized_phone`.
      expect(a.phone, '01113000000');
      expect(a.imagePath, '');
      expect(a.initial, 'L');
    });
  });

  group('JsonParse.localizedValue — الاسم بشكلين', () {
    test('نص عادي (public/services)', () {
      expect(JsonParse.localizedValue('كشف باطنة'), 'كشف باطنة');
    });

    test('خريطة (user/bookings)', () {
      expect(
        JsonParse.localizedValue({'ar': 'غيار جرح', 'en': 'Wound Dressing'}),
        'غيار جرح',
      );
    });

    test('الخريطة من غير عربي بترجّع أول قيمة مش فراغ', () {
      expect(
        JsonParse.localizedValue({'en': 'Wound Dressing'}),
        'Wound Dressing',
      );
    });

    test('null بترجّع الاحتياطي', () {
      expect(JsonParse.localizedValue(null, fallback: '—'), '—');
    });
  });
}
