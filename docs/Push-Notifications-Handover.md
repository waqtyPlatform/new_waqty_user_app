# الإشعارات — اللي اتعمل واللي فاضل

نص الأبلكيشن **خلص وشغّال**. الإشعارات مطفية عشان حاجتين برّا الأبلكيشن.

---

## اللي خلص في الأبلكيشن

| | الملف |
|---|---|
| استقبال الرسايل — مقدمة · خلفية · مقفول | [firebase_notification_service.dart](../lib/core/services/firebase_notification_service.dart) |
| رسم إشعار وقت ما الأبلكيشن مفتوح | [local_notification_service.dart](../lib/core/services/local_notification_service.dart) |
| التوجيه للشاشة الصح | [push_router.dart](../lib/core/services/push_router.dart) |
| تسجيل التوكن على السيرفر | `POST /api/v1/app/device-token` |
| تجديد التوكن لما يتغيّر | `onTokenRefresh` |
| صلاحية أندرويد ١٣+ | `POST_NOTIFICATIONS` في الـmanifest |
| القناة | `waqty_bookings` بأولوية عالية |
| `core library desugaring` | مفعّل في `build.gradle.kts` |

**٩ اختبارات** في [push_router_test.dart](../test/push_router_test.dart).

⚠ الأبلكيشن **بيقلع ويشتغل عادي من غير أي إعداد** — `init()` بترجع من غير ما
تعمل حاجة، وبتطبع سطر في الديبج بس.

---

## الحاجة الأولى: إعداد Firebase

مشروع Firebase مربوط بحساب Google بتاع الفريق، فمحدش يقدر يعمله من الكود.

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<waqty-firebase-project>
```

الأمر ده بيعمل حاجتين: بيملّي
[firebase_options.dart](../lib/firebase_options.dart) وبينزّل
`google-services.json` في `android/app/`.

بعده `DefaultFirebaseOptions.isConfigured` بتبقى `true` والأبلكيشن يبدأ
يستقبل — **من غير أي تعديل في الكود**.

⚠ اختبار في `push_router_test.dart` بيتوقّع `isConfigured == false`. أول ما
تظبطوا Firebase، اقلبوه لـ`isTrue`.

---

## الحاجة التانية: المرسل في الباك-إند

`app_device_tokens` بتتملى دلوقتي — بس **محدش بيقراها**.

الناقص في `backend/`:

**١. `EventServiceProvider` وlisteners.**
`BookingReassignmentLifecycleEvent` بيتبعت بفلاجات `notifyCustomer` و
`notifyBranch` و**مفيش أي listener مسجّل**. نفس الحاجة لأحداث قايمة الانتظار.

**٢. مرسل FCM.** يقرا `AppDeviceToken` للمستخدم ويبعت عن طريق HTTP v1 API.

**٣. queued job.** الإرسال مايتعملش في دورة الطلب — الفرع بيستنى الرد.

### شكل الحمولة اللي الأبلكيشن مستنيها

`PushRouter.destinationOf` بيقرا `data.type` و`data.uuid`:

| `type` | بيفتح | ملاحظة |
|---|---|---|
| `booking_reassignment` · `reassignment_proposal` | شاشة إعادة التوزيع | **مهلة ١٥ دقيقة** |
| `waitlist_offer` · `waitlist` | تبويب الحجوزات | **مهلة ٥ دقايق** |
| `booking` · `booking_status` | تفاصيل الحجز | محتاج `uuid` |

```json
{
  "notification": { "title": "فيه تغيير في حجزك", "body": "الفرع اقترحلك ميعاد بديل" },
  "data": { "type": "booking_reassignment", "uuid": "01K…" }
}
```

⚠ **نوع مش معروف مابيفتحش حاجة** — مش الرئيسية. إشعار من نسخة سيرفر أحدث
بيفتح شاشة عشوائية أوحش من إنه مايفتحش.

⚠ **رسالة داتا-فقط (من غير `notification`) مابتترسمش** وقت ما الأبلكيشن
مفتوح — ده مقصود عشان السيرفر يقدر يبعت تحديث صامت.

---

## ليه ده مستعجل

**فلوين بتوقيت محدود بيعتمدوا عليه:**

| الفلو | المهلة | لو مفيش إشعار |
|---|---|---|
| إعادة توزيع الحجز | **١٥ دقيقة** · ٣ محاولات | التلاتة بيخلصوا في صمت والفرع يستنتج إن الفيتشر مش شغالة |
| عرض قايمة الانتظار | **٥ دقايق** | الميعاد بيروح لحد تاني |

**التعويض الحالي** (بانر على الرئيسية + إعادة تحميل عند فتح الأبلكيشن)
بيقلّل الضرر — **مابيشيلهوش**. مهلة العميل بيعرف بيها بالصدفة مش مهلة.
