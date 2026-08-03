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

    // TODO(api): GET /api/user/bookings?upcoming=true&page=1&per_page=15
    final result = await MockSource.fetchList(_pageOf(1));

    result.fold((failure) => emit(MyBookingsErrorState(message: failure)), (
      data,
    ) {
      bookings = data;
      hasMore = data.length >= perPage && _source.length > data.length;
      emit(data.isEmpty ? MyBookingsEmptyState() : MyBookingsSuccessState());
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

    // TODO(api): GET /api/user/bookings?page={_page + 1}&per_page=15
    final result = await MockSource.fetchList(_pageOf(_page + 1));

    result.fold(
      (failure) {
        // فشل صفحة إضافية **مش** بيمسح اللي قدام العميل. بيرجع زي ما هو
        // ويقدر يجرّب تاني بالسحب.
        isLoadingMore = false;
        hasMore = false;
        emit(MyBookingsSuccessState());
      },
      (data) {
        _page += 1;
        bookings = <BookingUiModel>[...bookings, ...data];
        hasMore = bookings.length < _source.length;
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

  List<BookingUiModel> get _source =>
      selectedTab == 0 ? MockBookings.upcoming : MockBookings.past;

  /// شريحة الصفحة من الـ mock — بيقلّد `LengthAwarePaginator`.
  List<BookingUiModel> _pageOf(int page) {
    final all = _source;
    final start = (page - 1) * perPage;
    if (start >= all.length) return <BookingUiModel>[];
    final end = start + perPage;
    return all.sublist(start, end > all.length ? all.length : end);
  }

  static MyBookingsCubit get(context) => BlocProvider.of(context);
}
