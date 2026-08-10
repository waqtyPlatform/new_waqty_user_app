import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/widgets/auth_header_widget.dart';
import 'package:waqty_user_application/core/widgets/resend_code_widget.dart';
import 'package:waqty_user_application/design_system/design_system.dart';

/// **ويدجتس المصادقة المشتركة.**
///
/// شاشات المصادقة الستة مالهاش اختبار رسم في السويت — بتجرّ
/// `EasyLocalization` و`GetIt` والريبوهات معاها. اللي اتغيّر فيها في
/// التبنّي حاجتين قابلين للاختبار لوحدهم:
///
///  • [AuthHeaderWidget] — بلوك كان مكرر بالحرف في الست شاشات.
///  • [ResendCodeWidget] — كان نسختين متطابقتين.
///
/// وحاجة تالتة أهم منهم: **ملء البيانات التلقائي**.
void main() {
  setUp(() => AppSemanticColors.apply(Brightness.light));
  tearDown(() => AppSemanticColors.apply(Brightness.light));

  Future<void> pump(WidgetTester tester, Widget child) async {
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
            child: Scaffold(body: SingleChildScrollView(child: child)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('AuthHeaderWidget', () {
    testWidgets('العنوان والوصف بيبانوا', (tester) async {
      await pump(
        tester,
        const AuthHeaderWidget(title: 'أهلاً بيك', description: 'سجّل دخولك'),
      );

      expect(find.text('أهلاً بيك'), findsOneWidget);
      expect(find.text('سجّل دخولك'), findsOneWidget);
    });

    /// أربع شاشات من الستة مالهاش لوجو — هي جوه رحلة وليها `AppBar`.
    testWidgets('من غير لوجو مافيش صورة', (tester) async {
      await pump(tester, const AuthHeaderWidget(title: 'ت', description: 'و'));

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('مع لوجو فيه صورة واحدة', (tester) async {
      await pump(
        tester,
        const AuthHeaderWidget(title: 'ت', description: 'و', showLogo: true),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    /// المبدّل بيقعد في صف اللوجو، فمن غير لوجو مالوش مكان يرسم فيه.
    /// لو اتبعت من غير `showLogo` المفروض يتجاهل بدل ما يطلع في مكان غلط.
    testWidgets('الـtrailing بيتجاهل من غير لوجو', (tester) async {
      await pump(
        tester,
        const AuthHeaderWidget(
          title: 'ت',
          description: 'و',
          trailing: Text('مبدّل'),
        ),
      );

      expect(find.text('مبدّل'), findsNothing);
    });

    testWidgets('الـtrailing بيبان مع اللوجو', (tester) async {
      await pump(
        tester,
        const AuthHeaderWidget(
          title: 'ت',
          description: 'و',
          showLogo: true,
          trailing: Text('مبدّل'),
        ),
      );

      expect(find.text('مبدّل'), findsOneWidget);
    });
  });

  group('ResendCodeWidget', () {
    testWidgets('وقت ما ينفع الإرسال بيبقى زرار حقيقي', (tester) async {
      var taps = 0;

      await pump(
        tester,
        ResendCodeWidget(
          canResend: true,
          timerText: '00',
          onResend: () => taps++,
          resendLabel: 'ابعت تاني',
          countdownPrefix: 'تقدر تبعت بعد',
          countdownSuffix: 'ثانية',
        ),
      );

      // زرار مش `GestureDetector` — عشان يبقى له هدف لمس ودور لقارئ الشاشة.
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('ابعت تاني'), findsOneWidget);
      expect(find.text('تقدر تبعت بعد'), findsNothing);

      await tester.tap(find.text('ابعت تاني'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('وقت العد بيبقى نص مش زرار', (tester) async {
      await pump(
        tester,
        ResendCodeWidget(
          canResend: false,
          timerText: '42',
          onResend: () {},
          resendLabel: 'ابعت تاني',
          countdownPrefix: 'تقدر تبعت بعد',
          countdownSuffix: 'ثانية',
        ),
      );

      expect(find.byType(TextButton), findsNothing);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('تقدر تبعت بعد'), findsOneWidget);
      expect(find.text('ثانية'), findsOneWidget);
    });
  });

  /// **الحارس اللي مافيش غيره.**
  ///
  /// حقول الكيت (`AppTextFormField` و`AppPasswordFieldWidget`) نزلت من
  /// غير `autofillHints` خالص. تبنّيها زي ما هي كان معناه إن مدير كلمات
  /// السر وملء كود الـOTP التلقائي **يموتوا في كل فورمة مصادقة** — انحدار
  /// وظيفي مافيش analyzer ولا اختبار رسم بيمسكه، واليوزر بيحسّه «التطبيق
  /// نسي باسوردي».
  ///
  /// الإضافة اتعملت في الكيت نفسه (إصدار `1.0.1`). الاختبارات دي بتثبّت
  /// إن التمرير واصل للحقل فعلاً — مش بس الباراميتر موجود.
  group('ملء البيانات التلقائي', () {
    testWidgets('AppTextFormField بيمرّر autofillHints', (tester) async {
      await pump(
        tester,
        const AppTextFormField(
          hintText: 'رقم الموبايل',
          autofillHints: [AutofillHints.telephoneNumber],
        ),
      );

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.autofillHints, contains(AutofillHints.telephoneNumber));
    });

    testWidgets('AppPasswordFieldWidget بيمرّر autofillHints', (tester) async {
      await pump(
        tester,
        const AppPasswordFieldWidget(
          hintText: 'كلمة السر',
          autofillHints: [AutofillHints.password],
        ),
      );

      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.autofillHints, contains(AutofillHints.password));
      // ومخفية من البداية.
      expect(field.obscureText, isTrue);
    });

    testWidgets('زرار العين بيقلب الإخفاء', (tester) async {
      await pump(tester, const AppPasswordFieldWidget(hintText: 'كلمة السر'));

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
    });
  });
}
