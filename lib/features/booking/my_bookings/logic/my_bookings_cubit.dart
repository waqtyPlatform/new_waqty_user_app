import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/booking/my_bookings/data/repo/my_bookings_repo.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final MyBookingsRepo _repo;

  MyBookingsCubit(this._repo) : super(InitialState());

  /// حجم الصفحة — **نفس الافتراضي بتاع السيرفر**.
  ///
  /// `UserBookingController` بياخد `per_page` بافتراضي **١٥** (وحد أقصى
  /// ١٠٠). الرقم مكتوب هنا بنفس القيمة عشان الشكل اللي بنجرّبه يبقى هو
  /// اللي هيحصل فعلاً يوم الربط — عميل عنده ٤٠ حجز بيوصله ١٥ في المرة،
  /// وده شكل الأبلكيشن عمره ما شافه.
  static const int perPage = 15;

  List<BookingUiModel> bookings = <BookingUiModel>[];

  /// ٠ = القادمة · ١ = السابقة
  int selectedTab = 0;

  /// آخر صفحة اتحمّلت. أول صفحة = ١، زي ما السيرفر بيعدّ.
  int _page = 1;

  /// فيه صفحات تانية؟ — من `pagination.last_page` في رد السيرفر.
  bool hasMore = false;

  /// بنمنع نداءين على نفس الصفحة لما العميل يسحب بسرعة.
  bool isLoadingMore = false;

  /// تبويب «باقاتي» — **مالوش نداء حجوزات**.
  ///
  /// المحتوى بتاعه بيجي من `EntitlementsCubit` اللي فوق التبويبات، فنداء
  /// `GET /user/bookings` هنا طلب شبكة مالوش مستهلك — وأسوأ، بيدوس على
  /// `bookings` بنتيجة `upcoming: false` فالعميلة لما ترجع لـ«القادمة»
  /// بتلاقي السابقة.
  static const int entitlementsTab = 2;

  void changeTab(int value) {
    selectedTab = value;
    emit(OnTabChangedState());
    if (value == entitlementsTab) return;
    loadBookings();
  }

  /// أول تحميل — أو إعادة تحميل من السحب.
  Future<void> loadBookings() async {
    emit(MyBookingsLoadingState());

    _page = 1;
    isLoadingMore = false;

    final requestedTab = selectedTab;

    final result = await _repo.bookings(
      upcoming: requestedTab == 0,
      page: 1,
      perPage: perPage,
    );

    if (isClosed || selectedTab != requestedTab) return;

    result.fold((failure) => emit(MyBookingsErrorState(message: failure.message)), (
      page,
    ) {
      bookings = page.data;
      _page = page.currentPage;
      hasMore = page.hasMore;
      emit(page.isEmpty ? MyBookingsEmptyState() : MyBookingsSuccessState());
    });
  }

  /// الصفحة اللي بعدها — بتتنادى لما العميل يقرب من آخر القايمة.
  ///
  /// **مابتعملش `MyBookingsLoadingState`.** الحالة دي بتمسح القايمة
  /// وتوري سكيلتون، يعني اللي العميل بيقراه بيختفي تحت صباعه. الصفحة
  /// الجديدة بتتلحق في الآخر والقايمة مابتتهزش.
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    emit(MyBookingsLoadingMoreState());

    // **التبويب بيتصوّر قبل الانتظار.**
    //
    // لو العميل غيّر التبويب والطلب لسه شغّال، الرد الراجع بتاع التبويب
    // **القديم** كان بيتلحق على قايمة التبويب الجديد — «القادمة» فيها
    // حجوزات خلصت. الحارس ده بيرمي الرد المتأخر، وهو نفس الشكل اللي نداء
    // الـ HTTP هيحتاجه يوم الربط.
    final requestedTab = selectedTab;

    final result = await _repo.bookings(
      upcoming: requestedTab == 0,
      page: _page + 1,
      perPage: perPage,
    );

    if (isClosed || selectedTab != requestedTab) return;

    result.fold(
      (failure) {
        // فشل صفحة إضافية **مش** بيمسح اللي قدام العميل. بيرجع زي ما هو
        // ويقدر يجرّب تاني بالسحب. و`hasMore` بتتقفل عشان التحميل التلقائي
        // يقف — مش لأن السيرفر قال مفيش كمان.
        isLoadingMore = false;
        hasMore = false;
        emit(MyBookingsSuccessState());
      },
      (page) {
        // من الظرف مش `+= 1` — السيرفر هو اللي بيقرر إنت جبت أنهي صفحة.
        _page = page.currentPage;
        bookings = <BookingUiModel>[...bookings, ...page.data];
        hasMore = page.hasMore;
        isLoadingMore = false;
        emit(MyBookingsSuccessState());
      },
    );
  }

  /// **بيتنادى لما حجز يتلغي أو يتقيّم.**
  ///
  /// الـ cubit ده عايش في الـ `IndexedStack` بتاع القشرة، يعني مابيتعملش
  /// من جديد لما العميل يرجع من صفحة التفاصيل. من غير النداء ده، حجز
  /// اتلغى بيفضل ظاهر تحت «القادمة» لحد ما العميل يعمل pull-to-refresh
  /// — والقايمة بتكدب عليه.
  Future<void> refreshAfterChange() => loadBookings();

  /// الـ uuids اللي العميل قفل إشعارها في الجلسة دي.
  ///
  /// ⚠ **محلي بالكامل، بيروح مع قفل الأبلكيشن.** مفيش أي حقل «اتقرا» على
  /// الحجز في الباك-إند ولا endpoint يسجّله. الإخفاء الدايم محتاج شغل
  /// سيرفر — سيبناه بدل ما نخترع تخزين محلي بيفترق عن الحقيقة.
  final Set<String> _dismissedNotices = <String>{};

  /// إشعارات النهايات المش مكتملة — فوق تبويب «السابقة».
  ///
  /// مكانها هناك مش في «القادمة»: العميل بيدوّر على حجز خلص، فبيلاقي
  /// اللي حصل معاه فوق اللي اتم بنجاح.
  ///
  /// ⚠ **بتتشتق من الحجوزات المحمّلة مش من endpoint.** مفيش
  /// `GET /api/user/notifications` أصلاً. فالإشعار هنا = حجز ماضي حالته
  /// ملغي أو ما حضرش — وده اللي الكارت بيقوله بالظبط.
  ///
  /// ونتيجتها إنها بتشوف الصفحة المحمّلة بس: عميل عنده إلغاء من ٦ شهور
  /// مش هيشوفه غير لما يوصّل لصفحته. مقبول — الإشعار عن «حاجة حصلت
  /// قريّب» مش أرشيف.
  List<BookingUiModel> get notices {
    if (selectedTab != 1) return const <BookingUiModel>[];

    return bookings
        .where(
          (b) =>
              b.status == BookingStatus.cancelled ||
              b.status == BookingStatus.noShow,
        )
        .where((b) => !_dismissedNotices.contains(b.uuid))
        .toList();
  }

  void dismissNotice(String uuid) {
    _dismissedNotices.add(uuid);
    emit(OnTabChangedState());
  }

  static MyBookingsCubit get(context) => BlocProvider.of(context);
}
