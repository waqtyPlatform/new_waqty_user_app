import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
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
        MyBookingRowWidget(booking: MockBookings.upcoming.first, onTap: () {}),
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
        MyBookingRowWidget(booking: MockBookings.upcoming.first, onTap: () {}),
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
    /// الصف بقى [AppMenuRowWidget] بتاع الكيت — كارت لكل صف بدل مجموعة
    /// بفواصل. الاختبار ده بيفضل يحرس نفس الحاجة: **الارتفاع مايقعش تحت
    /// الحد الأدنى للمس (٤٤)**، مهما اتغيّر شكل الصف.
    ///
    /// وبيتحقق كمان إن الـ skeleton بيقرا **نفس** الـ `heightOf` — من غير
    /// كده قايمة الحساب بتنطّ أول ما الداتا توصل.
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
                  height = AppMenuRowWidget.heightOf(innerContext);
                  return Scaffold(
                    body: Column(
                      children: [
                        AppMenuRowWidget(
                          icon: Icons.language_rounded,
                          title: 'اللغة',
                          subtitle: 'العربية',
                          onTap: () {},
                        ),
                        const AppMenuRowSkeletonWidget(),
                      ],
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

      // الصف الحقيقي والـ skeleton بنفس الارتفاع بالظبط — العقد اللي
      // بيمنع اللستة تنطّ.
      final real = tester.getSize(find.byType(AppMenuRowWidget)).height;
      final fake = tester.getSize(find.byType(AppMenuRowSkeletonWidget)).height;
      expect(fake, closeTo(real, 0.5));

      expect(tester.takeException(), isNull);
    });
  });
}
