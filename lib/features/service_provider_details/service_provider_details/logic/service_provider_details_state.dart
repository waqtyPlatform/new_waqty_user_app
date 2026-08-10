abstract class ServiceProviderDetailsState {}

class InitialState extends ServiceProviderDetailsState {}

class DetailsLoadingState extends ServiceProviderDetailsState {}

class DetailsSuccessState extends ServiceProviderDetailsState {}

class DetailsErrorState extends ServiceProviderDetailsState {
  final String message;
  DetailsErrorState({required this.message});
}

/// الفرع اتغيّر — الخدمات والمواعيد بتتحمّل من الأول.
class OnBranchChangedState extends ServiceProviderDetailsState {}
