abstract class MyBookingsState {}

class InitialState extends MyBookingsState {}

class MyBookingsLoadingState extends MyBookingsState {}

/// بيحمّل **صفحة إضافية** — القايمة اللي على الشاشة بتفضل زي ما هي.
///
/// حالة لوحدها مش `MyBookingsLoadingState`: التانية بتمسح القايمة وتوري
/// سكيلتون، يعني اللي العميل بيقراه بيختفي تحت صباعه وهو بيسحب.
class MyBookingsLoadingMoreState extends MyBookingsState {}

class MyBookingsSuccessState extends MyBookingsState {}

class MyBookingsEmptyState extends MyBookingsState {}

class MyBookingsErrorState extends MyBookingsState {
  final String message;
  MyBookingsErrorState({required this.message});
}

class OnTabChangedState extends MyBookingsState {}
