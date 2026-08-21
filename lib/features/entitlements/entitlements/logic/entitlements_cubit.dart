import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/follow_up_entitlement_ui_model.dart';
import 'package:waqty_user_application/core/models/package_entitlement_ui_model.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/repo/entitlements_repo.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/logic/entitlements_state.dart';

/// **اللي العميلة مالكاه** — باقات اشترتها من الفرع ومتابعات استحقّتها.
///
/// ## ليه ده موجود
///
/// عميلة بتشتري باقة ١٠ جلسات كاش من الكاشير. الداشبورد بيسجّلها في
/// `customer_package_purchases`. التطبيق كان بيوريها **مفيش حاجة** — مش
/// عارفة فاضل كام ولا بتنتهي إمتى ولا إزاي تحجز منها.
///
/// ⚠ **بيتعمل مرة واحدة فوق التبويبات** في `ButtonNavigationBarScreen`،
/// زي `WaitlistCubit` و`ReassignmentCubit`. الشريط في «حجوزاتي»، والصف في
/// «حسابي»، والقايمة نفسها — تلاتتهم بيقروا نفس النسخة. نسختين = العدّاد
/// في «حسابي» يقول ٣ والقايمة توري ٢ في نفس اللحظة.
class EntitlementsCubit extends Cubit<EntitlementsState> {
  EntitlementsCubit(this._repo) : super(const EntitlementsInitial());

  final EntitlementsRepo _repo;

  List<PackageEntitlementUiModel> packages = <PackageEntitlementUiModel>[];
  List<FollowUpEntitlementUiModel> followUps = <FollowUpEntitlementUiModel>[];

  EntitlementTab tab = EntitlementTab.packages;

  /// آخر رسالة فشل في الحجز — الشيت بيقراها وهو مفتوح.
  String bookingError = '';

  /// إجمالي اللي **ينفع تتصرف فيه** — ده الرقم اللي بيتعرض في «حسابي»
  /// وفي الشريط.
  ///
  /// الباقات المنتهية والمكتملة **مش داخلة**: عدّاد بيقول ٥ وفيهم ٣
  /// منتهيين بيدّي وعد كاذب.
  int get actionableCount =>
      packages.where((p) => p.status == PackageStatus.active).length +
      followUps.where((f) => f.isBookableFromApp).length;

  /// فيه أي حاجة أصلاً — حتى المنتهي؟ بيفرّق «مالكة حاجة» عن «فاضي خالص».
  bool get hasAnything => packages.isNotEmpty || followUps.isNotEmpty;

  /// أول باقة ينفع يتقال عنها حاجة في الشريط.
  PackageEntitlementUiModel? get highlightPackage {
    for (final package in packages) {
      if (package.status == PackageStatus.active) return package;
    }
    return null;
  }

  bool get isCurrentTabEmpty => switch (tab) {
    EntitlementTab.packages => packages.isEmpty,
    EntitlementTab.followUps => followUps.isEmpty,
  };

  /// **بيحمّل الاتنين مع بعض، وماينهارش لو واحد فشل.**
  ///
  /// دي حالة «جزئي» بتاعت §9: لو المتابعات فشلت والباقات نجحت، العميلة
  /// المفروض تشوف باقاتها. فشل الشاشة كلها عشان نداء تاني بيخفي داتا
  /// موجودة وشغّالة.
  Future<void> load() async {
    emit(const EntitlementsLoading());

    // النداءين بيتبدوا مع بعض وبعدين بننتظرهم — متوازيين زي `Future.wait`
    // بالظبط، بس **بأنواعهم محفوظة**. `Future.wait` بيرجّع `List<Object>`
    // وبيجبرنا على `dynamic` في الـ`fold`، واللي بيخلّي أي تغيير في شكل
    // الرد خطأ وقت تشغيل بدل خطأ compile.
    final packagesFuture = _repo.packages();
    final followUpsFuture = _repo.followUps();

    final packagesResult = await packagesFuture;
    final followUpsResult = await followUpsFuture;
    if (isClosed) return;

    var failure = '';

    packagesResult.fold(
      (f) => failure = f.message,
      (data) => packages = data,
    );
    followUpsResult.fold(
      (f) => failure = failure.isEmpty ? f.message : failure,
      (data) => followUps = data,
    );

    // الخطأ بيكسب **بس لما مافيش أي حاجة اتحمّلت**. لو حاجة وصلت،
    // بنعرضها والخطأ بيتاكل — إعادة التحميل بره متاحة على أي حال.
    if (failure.isNotEmpty && !hasAnything) {
      emit(EntitlementsError(failure));
      return;
    }

    emit(isCurrentTabEmpty ? const EntitlementsEmpty() : const EntitlementsLoaded());
  }

  void selectTab(EntitlementTab next) {
    if (tab == next) return;
    tab = next;
    emit(isCurrentTabEmpty ? const EntitlementsEmpty() : const EntitlementsLoaded());
  }

  /// حجز متابعة.
  ///
  /// ⚠ **المتابعات بس.** الباقات مالهاش طريق للفرع (BE-A1) فمالهاش دالة
  /// حجز أصلاً — شوف `EntitlementsService`.
  Future<void> bookFollowUp({
    required String uuid,
    required String bookingDate,
    required String startTime,
    String? employeeUuid,
    String? notes,
  }) async {
    bookingError = '';
    emit(const EntitlementBookingSubmitting());

    final result = await _repo.bookFollowUp(
      uuid: uuid,
      bookingDate: bookingDate,
      startTime: startTime,
      employeeUuid: employeeUuid,
      notes: notes,
    );
    if (isClosed) return;

    await result.fold(
      (failure) async {
        bookingError = failure.message;
        emit(EntitlementBookingFailed(failure.message));
      },
      (_) async {
        emit(const EntitlementBookingSucceeded());
        // الاستحقاق اتغيّر (جلسة اتحجزت) فلازم نعيد التحميل — من غير كده
        // العدّاد بيفضل على قيمته القديمة لحد ما التبويب يتقفل ويتفتح.
        await load();
      },
    );
  }

  static EntitlementsCubit get(context) => BlocProvider.of(context);
}
