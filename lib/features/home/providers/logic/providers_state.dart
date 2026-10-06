import 'package:waqty_user_application/features/home/providers/data/models/provider_model.dart';

abstract class ProvidersState {
  final List<ProviderModel> providers;
  const ProvidersState([this.providers = const []]);
}

class ProvidersInitialState extends ProvidersState {
  const ProvidersInitialState();
}

class ProvidersLoadingState extends ProvidersState {
  const ProvidersLoadingState([super.providers]);
}

class ProvidersLoadedState extends ProvidersState {
  const ProvidersLoadedState(super.providers);
}

class ProvidersErrorState extends ProvidersState {
  const ProvidersErrorState([super.providers]);
}
