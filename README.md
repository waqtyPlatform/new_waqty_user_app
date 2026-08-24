# waqty_user_application

تطبيق العميل في منصة **وقتي** — حجز مواعيد للسوق المصري (حلاقة، كوافير، عناية،
مساج، أظافر). Flutter · عربي · RTL · `ar-EG`.

```bash
flutter pub get
flutter analyze                                # لازم يعدّي نضيف قبل أي تسليم
flutter test
flutter run -d web-server --web-port=8090
flutter run --dart-define=DEMO_MODE=true       # بيتخطى الدخول ويوري مبدّل السيناريوهات
```

---

## نظام التصميم

الشكل كله بييجي من **`lib/design_system/`** — فولدر **منسوخ** من
[`design-kit/`](../design-kit/) في الريبو الأب.

| | |
|---|---|
| **`kDesignKitVersion`** | `1.0.1` |
| **`kDesignKitSourceCommit`** | `2339c8ad41f2a5555e6e7460893297521602c0b1` |

سطر واحد بيجيب كل حاجة:

```dart
import 'package:waqty_user_application/design_system/design_system.dart';
```

### ⚠ الكيت بيتنسخ مش بيتربط

مافيش انتشار تلقائي. أي تعديل جوه `lib/design_system/` **لازم يترفع لـ
`design-kit/` في نفس الكوميت**، وإلا النسختين بيفترقوا في صمت. للمقارنة:

```bash
git diff --no-index ../design-kit/lib/design_system lib/design_system
```

`test/portability_test.dart` بيحرس الفولدر: مافيش `package:` imports جوّاه،
ولا cubit، ولا `w700`، ولا `letterSpacing` موجب، ولا لون خام.

### الفرق عن نسخة `1.0.0`

الإصدار `1.0.1` ضاف `autofillHints` لـ`AppTextFormField`. من غيرها مدير كلمات
السر وملء كود الـOTP التلقائي بيموتوا في كل فورمة دخول، ومافيش اختبار ولا
analyzer بيمسك ده. الإضافة اتعملت **في الكيت نفسه** مش كانحراف محلي، فالنسختين
لسه متطابقتين بالحرف.

---

## الطبقات اللي فوق الكيت

| | |
|---|---|
| `lib/core/widgets/` | ٩ ملفات بس — اللي الكيت مايعرفوش (دومين وقتي: `booking_status_chip` · `category_icon` · `discount_price` · `provider_row` …) |
| `lib/config/themes/theme_cubit.dart` | ملك التطبيق. الكيت بيشحن `appTheme()` بس، مش state |
| `lib/core/mock/` | ٢٥ سيناريو وهمي + المبدّل. الـ`TODO(api):` بيقول الـendpoint المستهدف |

باقي الاتفاقات (Cubit لكل حالة · مفيش `setState` · تنظيم الملفات · قواعد RTL ·
الارتفاعات المحسوبة) في [`CLAUDE.md`](../CLAUDE.md) في الريبو الأب.
