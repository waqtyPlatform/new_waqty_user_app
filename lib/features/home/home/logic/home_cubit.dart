import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/home/logic/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _repo;

  HomeCubit(this._repo) : super(InitialState());

  List<CategoryUiModel> categories = <CategoryUiModel>[];
  List<ProviderUiModel> popularProviders = <ProviderUiModel>[];
  List<ProviderUiModel> nearbyProviders = <ProviderUiModel>[];

  /// أقرب حجز جاي. `null` معناها مفيش حجوزات — وساعتها الكارت
  /// **مايظهرش خالص**، مش كارت فاضي.
  BookingUiModel? upcomingBooking;

  /// آخر حجز مكتمل — مصدر كارت «زي المرة اللي فاتت».
  ///
  /// **«نفس اللي فات» هو السلوك الغالب** عند الكوافير والباربر، ومكانش
  /// ليه أي سطح في الأبلكيشن: مدفون في تبويب اسمه «السابقة»، ورا زرار
  /// «احجز تاني» كان بيعمل `context.pop()`.
  BookingUiModel? lastCompleted;

  String selectedCity = 'القاهرة';

  Future<void> loadHome() async {
    emit(HomeLoadingState());

    // ⚠ التصنيفات هي الوحيدة اللي فشلها بيوقف الشاشة — من غيرها مفيش
    // نقطة دخول لأي حاجة. الباقي بيتحمّل بالتوازي وكل واحد بيطوي سطره
    // لوحده لو فشل: رئيسية من غير «موعدك الجاي» أحسن من شاشة خطأ.
    final categoriesResult = await _repo.categories();

    // ⚠ **حراسة `isClosed` بعد كل انتظار.**
    //
    // القشرة بتعمل `HomeCubit` جوّه `IndexedStack`، وأي إعادة بناء
    // للقشرة (مبدّل السيناريوهات مثلاً، أو الرمية بتاعة ٤٠١) بتقفله
    // والنداءات لسه ماشية. `emit` بعد القفل بيرمي
    // «Cannot emit new states after calling close» — وده اتمسك فعلاً
    // في لوج المحاكي.
    if (isClosed) return;

    final failure = categoriesResult.fold<String?>(
      (f) => f.message,
      (_) => null,
    );
    if (failure != null) {
      emit(HomeErrorState(message: failure));
      return;
    }
    categories = categoriesResult.getOrElse(() => <CategoryUiModel>[]);

    // التلاتة بيبدأوا مع بعض — الـfuture بيشتغل ساعة ما يتنده مش ساعة ما
    // يتعمله `await`. (`Future.wait` كان هيحتاج كاست لأن الأنواع مختلفة.)
    final providersCall = _repo.providers();
    final upcomingCall = _repo.upcomingBooking();
    final lastCompletedCall = _repo.lastCompletedBooking();

    popularProviders = (await providersCall).getOrElse(
      () => <ProviderUiModel>[],
    );
    if (isClosed) return;

    // «قريب منك» تلاتة بس — الليستة الكاملة تحتها على طول، فالتكرار
    // بياخد شاشة من غير ما يضيف اختيار.
    nearbyProviders = popularProviders.take(3).toList();

    // ⚠ `getOrElse(() => null)` مقصودة: الحجز مش موجود والحجز فشل تحميله
    // **نفس النتيجة على الشاشة** — الكارت مايظهرش. مفيش داعي لحالة خطأ
    // لكارت اختياري.
    upcomingBooking = (await upcomingCall).getOrElse(() => null);
    lastCompleted = (await lastCompletedCall).getOrElse(() => null);

    if (isClosed) return;
    emit(HomeSuccessState());
  }

  void changeCity(String city) {
    selectedCity = city;
    emit(OnCityChangedState());
  }

  static HomeCubit get(context) => BlocProvider.of(context);
}
