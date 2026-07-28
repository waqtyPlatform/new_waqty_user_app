abstract class ProvidersListState {}

class InitialState extends ProvidersListState {}

class ProvidersListLoadingState extends ProvidersListState {}

class ProvidersListSuccessState extends ProvidersListState {}

/// مفيش نتايج — شاشة فاضية فيها إجراء، مش مساحة بيضا.
class ProvidersListEmptyState extends ProvidersListState {}

class ProvidersListErrorState extends ProvidersListState {
  final String message;
  ProvidersListErrorState({required this.message});
}

class OnFilterChangedState extends ProvidersListState {}
