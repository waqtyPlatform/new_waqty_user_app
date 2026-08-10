import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/design_system/design_system.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/booking/booking_details/logic/booking_details_cubit.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/booking_details_screen.dart';
import 'package:waqty_user_application/features/booking/booking_details/ui/widgets/booking_details_info_widget.dart';
import 'package:waqty_user_application/features/booking/create_booking/ui/widgets/create_booking_service_picker_widget.dart';

/// شاشات الحجز — **تفاصيل الحجز و`sheet` الحجز**.
///
/// نفس فكرة `home_render_test`: `flutter analyze` مابيشوفش الفيضان، وده
/// النوع اللي بيكسر الشاشات فعلاً. الشاشات دي بالذات فيها كتل بتظهر
/// وتختفي (خصم · تقييم · ملاحظات · سبب إلغاء · حجز بكذا زيارة)، فكل
/// تركيبة منهم ليها ارتفاع مختلف.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  Future<void> pump(
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
              child: Scaffold(
                body: ListView(padding: AppSpacing.page, children: [child]),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // حجز بخدمة واحدة، وحجز بأكتر من خدمة — الاتنين ليهم تخطيط مختلف تمامًا
  // جوه نفس الكارت. والخصم بيزوّد سعر مشطوب جنب السعر.
  final List<BookingUiModel> allBookings = [
    ...MockBookings.upcoming,
    ...MockBookings.past,
  ];

  final BookingUiModel single = allBookings.firstWhere(
    (b) => !b.isMultiService,
    orElse: () => allBookings.first,
  );
  final BookingUiModel multi = allBookings.firstWhere(
    (b) => b.isMultiService,
    orElse: () => allBookings.first,
  );
  final BookingUiModel discounted = allBookings.firstWhere(
    (b) => b.hasDiscount,
    orElse: () => allBookings.first,
  );

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, AppSpacing.maxTextScale]) {
      group('$brightness عند مقياس خط $scale', () {
        testWidgets('كارت التفاصيل — خدمة واحدة', (tester) async {
          await pump(
            tester,
            BookingDetailsInfoWidget(booking: single),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('كارت التفاصيل — أكتر من خدمة', (tester) async {
          await pump(
            tester,
            BookingDetailsInfoWidget(booking: multi),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('كارت التفاصيل — فيه خصم', (tester) async {
          await pump(
            tester,
            BookingDetailsInfoWidget(booking: discounted),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('اختيار الخدمات في الـ sheet', (tester) async {
          await pump(
            tester,
            CreateBookingServicePickerWidget(
              services: MockServices.ofProvider(single.providerUuid),
              isSelected: (_) => false,
              onToggle: (_) {},
            ),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('صف مختار بيرسم من غير فيضان', (tester) async {
          await pump(
            tester,
            CreateBookingServicePickerWidget(
              services: MockServices.ofProvider(single.providerUuid),
              // كل الصفوف مختارة — الحالة اللي فيها خلفية وأيقونة صح.
              isSelected: (_) => true,
              onToggle: (_) {},
            ),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });
      });
    }
  }

  group('شاشة تفاصيل الحجز كاملة', () {
    for (final scale in [1.0, AppSpacing.maxTextScale]) {
      testWidgets('بترسم عند مقياس خط $scale', (tester) async {
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
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: BlocProvider(
                    create: (_) =>
                        BookingDetailsCubit(bookingUuid: single.uuid)
                          ..loadBooking(),
                    child: const BookingDetailsScreen(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('تفاصيل الحجز'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
