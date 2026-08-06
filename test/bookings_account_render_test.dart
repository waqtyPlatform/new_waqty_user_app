import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/config/themes/app_theme.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/utils/app_semantic_colors.dart';
import 'package:waqty_user_application/core/utils/app_spacing.dart';
import 'package:waqty_user_application/core/widgets/app_surface_widget.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_menu_item_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_booking_row_skeleton_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_booking_row_widget.dart';

/// صفوف الحجوزات والحساب.
///
/// ## ليه الصفوف مش الشاشات
///
/// شاشة الحساب بتقرا `context.locale`، وشاشة الحجوزات جواها `WaitlistCubit`
/// بمؤقت — يعني اختبار الشاشة الكاملة بيجرّ `EasyLocalization` و
/// `SharedPreferences` و`ServicesLocator` معاه. والفيضان اللي بندوّر عليه
/// **مش في الشاشة، هو في الصف**: الشاشة `ListView` والصفوف هي اللي ارتفاعها
/// محسوب.
///
/// اللي الاختبارات دي مسكته فعلاً:
///
///  • **شارة «قيّم الخدمة» ما كانتش متحسوبة خالص** — أي حجز مكتمل من غير
///    تقييم كان صفه بيفيض ~٢٠ بكسل رأسيًا.
///  • **صف البيانات كان بيفيض ١٠٣ بكسل عرضًا** عند مقياس خط ١٫٣: أيقونة +
///    تاريخ + أيقونة + وقت + سعر على عرض ٣٧٥ مابيدخلوش.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  Future<double> pumpRow(
    WidgetTester tester,
    Widget child, {
    required Brightness brightness,
    required double textScale,
  }) async {
    AppSemanticColors.apply(brightness);

    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: appTheme(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(body: ListView(children: [child])),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    return tester.getSize(find.byType(AppSurfaceWidget).first).height;
  }

  // حجز مكتمل ولسه فيه خدمات مستنية تقييم — الحالة اللي كانت بتفيض.
  final BookingUiModel pendingRating = MockBookings.past.firstWhere(
    (b) => b.hasPendingRatings,
    orElse: () => MockBookings.past.first,
  );

  group('صف الحجز', () {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, AppSpacing.maxTextScale]) {
        testWidgets('حجز جاي بيرسم في $brightness عند $scale', (tester) async {
          await pumpRow(
            tester,
            MyBookingRowWidget(
              booking: MockBookings.upcoming.first,
              onTap: () {},
            ),
            brightness: brightness,
            textScale: scale,
          );

          expect(tester.takeException(), isNull);
        });

        testWidgets('حجز مستني تقييم بيرسم في $brightness عند $scale', (
          tester,
        ) async {
          await pumpRow(
            tester,
            MyBookingRowWidget(booking: pendingRating, onTap: () {}),
            brightness: brightness,
            textScale: scale,
          );

          expect(tester.takeException(), isNull);
        });
      }
    }

    /// شارة التقييم بتزوّد سطر، فالصف **لازم** يطلع أطول. لو الاتنين
    /// بنفس الارتفاع يبقى `hasRatingLine` مش متبعت والشارة بتترسم في
    /// مساحة مش بتاعتها.
    testWidgets('صف التقييم أطول من الصف العادي', (tester) async {
      final plain = await pumpRow(
        tester,
        MyBookingRowWidget(
          booking: MockBookings.upcoming.first,
          onTap: () {},
        ),
        brightness: Brightness.light,
        textScale: 1.0,
      );

      final withRating = await pumpRow(
        tester,
        MyBookingRowWidget(booking: pendingRating, onTap: () {}),
        brightness: Brightness.light,
        textScale: 1.0,
      );

      expect(withRating, greaterThan(plain));
    });

    testWidgets('الـ skeleton بنفس ارتفاع الصف العادي', (tester) async {
      final real = await pumpRow(
        tester,
        MyBookingRowWidget(
          booking: MockBookings.upcoming.first,
          onTap: () {},
        ),
        brightness: Brightness.light,
        textScale: 1.0,
      );

      final fake = await pumpRow(
        tester,
        const MyBookingRowSkeletonWidget(showHairline: false),
        brightness: Brightness.light,
        textScale: 1.0,
      );

      expect(fake, closeTo(real, 1), reason: 'اللستة هتنطّ لما الداتا توصل');
    });
  });

  group('صف قايمة الحساب', () {
    /// **٥٢ مش ٥٦** — بس لسه فوق الحد الأدنى للمس (٤٤). لو حد نزّلها تحت
    /// ٤٤ بكرة، الاختبار ده هو اللي هيمسكه.
    testWidgets('ارتفاعه فوق الحد الأدنى للمس', (tester) async {
      late double height;

      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            theme: appTheme(),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (innerContext) {
                  height = AccountMenuItemWidget.heightOf(innerContext);
                  return Scaffold(
                    body: AccountMenuItemWidget(
                      icon: Icons.language_rounded,
                      label: 'اللغة',
                      trailingText: 'العربية',
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(height, greaterThanOrEqualTo(AppSpacing.touchTarget));
      expect(tester.takeException(), isNull);
    });
  });
}
