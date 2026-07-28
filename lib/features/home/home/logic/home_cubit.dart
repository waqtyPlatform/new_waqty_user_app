import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/mock/mock_bookings.dart';
import 'package:waqty_user_application/core/mock/mock_categories.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_source.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/category_ui_model.dart';
import 'package:waqty_user_application/core/models/provider_ui_model.dart';
import 'package:waqty_user_application/features/home/home/logic/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(InitialState());

  List<CategoryUiModel> categories = <CategoryUiModel>[];
  List<ProviderUiModel> popularProviders = <ProviderUiModel>[];
  List<ProviderUiModel> nearbyProviders = <ProviderUiModel>[];

  /// أقرب حجز جاي. `null` معناها مفيش حجوزات — وساعتها الكارت
  /// **مايظهرش خالص**، مش كارت فاضي.
  BookingUiModel? upcomingBooking;

  String selectedCity = 'القاهرة';

  Future<void> loadHome() async {
    emit(HomeLoadingState());

    // TODO(api): GET /api/public/categories
    final categoriesResult = await MockSource.fetchList(MockCategories.all);

    final failure = categoriesResult.fold<String?>((l) => l, (_) => null);
    if (failure != null) {
      emit(HomeErrorState(message: failure));
      return;
    }

    categories = categoriesResult.getOrElse(() => <CategoryUiModel>[]);

    // TODO(api): GET /api/public/providers
    final providersResult = await MockSource.fetchList(MockProviders.all);
    popularProviders = providersResult.getOrElse(() => <ProviderUiModel>[]);
    nearbyProviders = MockProviders.nearby.take(3).toList();

    // TODO(api): GET /api/user/bookings?upcoming=true&per_page=1
    final bookings = MockBookings.upcoming;
    upcomingBooking = bookings.isEmpty ? null : bookings.first;

    emit(HomeSuccessState());
  }

  void changeCity(String city) {
    selectedCity = city;
    emit(OnCityChangedState());
  }

  static HomeCubit get(context) => BlocProvider.of(context);
}
