# Waqty Design Kit — الفولدر ده

الفولدر ده **منسوخ** من `Waqty-Platform/design-kit`. الملف ده بيسافر معاه
عشان اللي يفتحه بعد سنة يعرف إيه ده ومنين جه.

| | |
|---|---|
| الإصدار | شوف `kit_version.dart` |
| المصدر | `Waqty-Platform/design-kit` |
| التوثيق الكامل | `design-kit/docs/Waqty-Design-DNA-Kit.md` |

## القواعد الأربعة في `main.dart`

```
ScreenUtilInit فوق كل حاجة          ← التوكنز بتنادي .sp/.r وقت الـ getter
AppSemanticColors.apply(brightness)  ← قبل appTheme()
key: ValueKey(brightness)            ← التوكنز statics مش InheritedWidget
مفيش darkTheme:                      ← palette واحد = تيمين متطابقين
```

## القواعد اللي بتنكسر أكتر حاجة

```dart
AppSemanticColors.surfaceAccentDeep + textOnAccentDeep  // تعبئة خضرا تحت نص
AppSemanticColors.accentText                            // الأخضر كنص/رابط
AppSemanticColors.dangerOnSoft                          // الأحمر على خلفيته
AppSemanticColors.textOnDanger                          // نص على تعبئة حمرا
EdgeInsetsDirectional · PositionedDirectional · AlignmentDirectional
```

**مفيش `Color(0x…)` ولا `Colors.x` ولا `BorderRadius.circular(رقم)` هنا.**
لو محتاج لون مالوش دور — **الدور هو اللي ناقص مش اللون**.

## لو عدّلت حاجة هنا

زوّد لاحقة في `kit_version.dart` (`1.0.0+app.1`) وسطر في `KIT_CHANGES.md`
عندك. ده كل التخفيف المتاح لانحراف النسخ.

## الاختبارات

انسخ `wcag.dart` · `contrast_test.dart` · `dark_mode_test.dart` ·
`row_height_test.dart` · `icons_test.dart` · `portability_test.dart` من
`design-kit/test/`، واستبدل بادئة الباكدج:

```bash
sed -i 's/package:waqty_design_kit/package:<your_app>/g' test/*.dart
```
