import 'package:flutter/foundation.dart';
import 'package:waqty_user_application/core/utils/demo_mode.dart';

/// مصدر الداتا: السيرفر الحقيقي ولا الفكسشرز الوهمية.
enum DataSourceMode { live, mock }

/// مبدّل المصدر — **أداة مراجعة مش سقالة**.
///
/// ## ليه الوهمي بيفضل بعد الربط
///
/// `MockScenario` فيه ٣١ سيناريو، منهم حالات **السيرفر مايقدرش يطلّعها عند
/// الطلب**: `slotLostAtConfirm` (حد خطف الميعاد بينك وبين التأكيد)،
/// `cancelWindowClosed`، `waitlistExpired`، `waitingNoEstimate`. دي الحالات
/// اللي الشاشات اتصمّمت حواليها، ومن غيرها المراجعة بتبقى على المسار السعيد بس.
///
/// فالمبدّل بيفضل، والفاصل عند طبقة الـservice: كل feature عندها
/// `<Name>RemoteService` و`<Name>MockService` بينفّذوا نفس العقد، والـrepo
/// بيختار بينهم من هنا.
///
/// ⚠ **بيتشال من الـrelease.** [isMock] بترجّع `false` دايمًا في بيلد
/// الإنتاج مهما كانت [mode]، فمفيش طريق يوصّل الداتا الوهمية لعميل حقيقي.
/// (`kDemoMode` استثناء مقصود — بيلد العرض المتشحن للستيك هولدرز.)
class DataSource {
  const DataSource._();

  /// بتتقرا في الـrepo عند كل نداء، فالتبديل بياخد أثره من غير إعادة تشغيل.
  static final ValueNotifier<DataSourceMode> mode =
      ValueNotifier<DataSourceMode>(_defaultMode);

  /// ⚠ الافتراضي **`live`** — الأبلكيشن بيقلع على السيرفر الحقيقي، والوهمي
  /// اختيار صريح من المبدّل. العكس بيخلي واحد ينسى نفسه في مراجعة ويفتكر
  /// إن الربط شغال وهو مش شغال.
  static DataSourceMode get _defaultMode => DataSourceMode.live;

  static bool get isMock =>
      (kDebugMode || kDemoMode) && mode.value == DataSourceMode.mock;

  static bool get isLive => !isMock;

  static void use(DataSourceMode next) => mode.value = next;

  static void toggle() => use(isMock ? DataSourceMode.live : DataSourceMode.mock);
}
