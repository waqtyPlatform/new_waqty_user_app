import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_rate_sheet_widget.dart';
import 'package:waqty_user_application/features/booking/my_bookings/ui/widgets/my_bookings_notice_widget.dart';

/// **مكوّنات الحجوزات بعد التبنّي.**
///
/// التلات حاجات اللي اتغيّر شكلها في PR-3 ومحدش كان بيغطّيها:
///
///  • تبويبات «القادمة/السابقة» — كانت حبّة بتزحلق، بقت [AppTabBarWidget].
///  • إشعار الإلغاء — كان سطح غاطس مكتوب بالإيد، بقى [AppBannerWidget].
///  • ورقة التقييم — خمس نجوم `IconButton` بقوا [AppRatingWidget].
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.light,
    double textScale = 1.0,
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
              child: Scaffold(body: SingleChildScrollView(child: child)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('تبويبات الحجوزات', () {
    Widget tabs(int value, ValueChanged<int> onChanged) => AppTabBarWidget<int>(
      value: value,
      onChanged: onChanged,
      tabs: const [
        AppSegment(value: 0, label: 'القادمة'),
        AppSegment(value: 1, label: 'السابقة'),
      ],
    );

    testWidgets('التبويبين موجودين والمختار باللمسة', (tester) async {
      await pump(tester, tabs(0, (_) {}));

      expect(find.text('القادمة'), findsOneWidget);
      expect(find.text('السابقة'), findsOneWidget);

      final selected = tester.widget<Text>(find.text('القادمة'));
      expect(selected.style?.color, AppSemanticColors.accentText);
    });

    testWidgets('الضغط بيبعت فهرس التبويب', (tester) async {
      final taps = <int>[];
      await pump(tester, tabs(0, taps.add));

      await tester.tap(find.text('السابقة'));
      await tester.pump();

      expect(taps, [1]);
    });

    /// كل تبويب هدف لمس كامل — الشريط القديم كان `48.h` ثابت للاتنين.
    testWidgets('كل تبويب فوق الحد الأدنى للمس', (tester) async {
      await pump(tester, tabs(0, (_) {}));

      for (final label in ['القادمة', 'السابقة']) {
        final box = tester.getSize(
          find
              .ancestor(of: find.text(label), matching: find.byType(Container))
              .first,
        );
        expect(box.height, greaterThanOrEqualTo(AppSpacing.touchTarget));
      }
    });
  });

  group('إشعار الإلغاء', () {
    final BookingUiModel cancelled = MockBookings.past.firstWhere(
      (b) => b.status == BookingStatus.cancelled,
      orElse: () => MockBookings.past.first,
    );

    testWidgets('بيوري الحالة والخدمة والمكان', (tester) async {
      await pump(
        tester,
        MyBookingsNoticeWidget(
          booking: cancelled,
          onDismiss: () {},
          onRebook: () {},
        ),
      );

      expect(find.byType(AppBannerWidget), findsOneWidget);
      expect(find.textContaining(cancelled.serviceName), findsOneWidget);
      expect(find.textContaining(cancelled.providerName), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('زرار القفل وزرار «احجز تاني» شغّالين', (tester) async {
      var dismissed = 0;
      var rebooked = 0;

      await pump(
        tester,
        MyBookingsNoticeWidget(
          booking: cancelled,
          onDismiss: () => dismissed++,
          onRebook: () => rebooked++,
        ),
      );

      await tester.tap(find.text('احجز تاني'));
      await tester.pump();
      expect(rebooked, 1);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(dismissed, 1);
    });

    for (final brightness in Brightness.values) {
      testWidgets('بيرسم في $brightness عند ١٫٣ من غير فيض', (tester) async {
        await pump(
          tester,
          MyBookingsNoticeWidget(
            booking: cancelled,
            onDismiss: () {},
            onRebook: () {},
          ),
          brightness: brightness,
          textScale: AppSpacing.maxTextScale,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('ورقة التقييم', () {
    Widget sheet({
      required int rating,
      required ValueChanged<int> onRatingChanged,
      VoidCallback? onSubmit,
      bool isLoading = false,
    }) => BookingRateSheetWidget(
      serviceName: 'قص شعر',
      rating: rating,
      commentController: TextEditingController(),
      isLoading: isLoading,
      onRatingChanged: onRatingChanged,
      onSubmit: onSubmit ?? () {},
    );

    testWidgets('اسم الخدمة في العنوان', (tester) async {
      await pump(tester, sheet(rating: 0, onRatingChanged: (_) {}));

      expect(find.text('قيّم «قص شعر»'), findsOneWidget);
      expect(find.byType(AppRatingWidget), findsOneWidget);
    });

    /// **مفيش تقييم من غير نجوم.** الزرار معطّل لحد أول ضغطة.
    testWidgets('الزرار معطّل عند صفر نجوم', (tester) async {
      await pump(tester, sheet(rating: 0, onRatingChanged: (_) {}));

      final button = tester.widget<AppButtonWidget>(
        find.byType(AppButtonWidget),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('الزرار بيشتغل بعد أول نجمة', (tester) async {
      await pump(tester, sheet(rating: 3, onRatingChanged: (_) {}));

      final button = tester.widget<AppButtonWidget>(
        find.byType(AppButtonWidget),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('الضغط على نجمة بيبعت رقمها', (tester) async {
      final picked = <int>[];
      await pump(tester, sheet(rating: 0, onRatingChanged: picked.add));

      // خمس نجوم — الرابعة من ناحية البداية في اتجاه القراءة.
      final stars = find.byIcon(Icons.star_outline_rounded);
      expect(stars, findsNWidgets(5));

      await tester.tap(stars.at(3));
      await tester.pump();

      expect(picked, [4]);
    });

    testWidgets('التقييم بيتعبّى النجوم', (tester) async {
      await pump(tester, sheet(rating: 3, onRatingChanged: (_) {}));

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
    });
  });
}
