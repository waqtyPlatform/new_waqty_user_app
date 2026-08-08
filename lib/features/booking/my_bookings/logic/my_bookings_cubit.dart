import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/features/booking/my_bookings/logic/my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  MyBookingsCubit() : super(InitialState());

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

  void changeTab(int value) {
    selectedTab = value;
    emit(OnTabChangedState());
    loadBookings();
  }

  /// أول تحميل — أو إعادة تحميل من السحب.
  Future<void> loadBookings() async {
    emit(MyBookingsLoadingState());

    _page = 1;
    isLoadingMore = false;

    final requestedTab = selectedTab;

    // TODO(api): GET /api/user/bookings?upcoming={selectedTab == 0}&page=1&per_page=15
    final result = await MockSource.fetchPage(
      MockBookings.forTab(upcoming: requestedTab == 0),
      page: 1,
      perPage: perPage,
    );

    if (selectedTab != requestedTab) return;

    result.fold((failure) => emit(MyBookingsErrorState(message: failure)), (
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

    // TODO(api): GET /api/user/bookings?upcoming={selectedTab == 0}&page={_page + 1}&per_page=15
    final result = await MockSource.fetchPage(
      MockBookings.forTab(upcoming: requestedTab == 0),
      page: _page + 1,
      perPage: perPage,
    );

    if (selectedTab != requestedTab) return;

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

  /// إشعارات النهايات المش مكتملة — فوق تبويب «السابقة».
  ///
  /// مكانها هناك مش في «القادمة»: العميل بيدوّر على حجز خلص، فبيلاقي
  /// اللي حصل معاه فوق اللي اتم بنجاح.
  List<BookingUiModel> get notices =>
      selectedTab == 1 ? MockBookings.notices : const <BookingUiModel>[];

  void dismissNotice(String uuid) {
    MockBookings.dismissNotice(uuid);
    emit(OnTabChangedState());
  }

  static MyBookingsCubit get(context) => BlocProvider.of(context);
}
