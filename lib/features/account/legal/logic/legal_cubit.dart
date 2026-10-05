import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/features/account/legal/logic/legal_state.dart';

class LegalCubit extends Cubit<LegalState> {
  LegalCubit() : super(const LegalState(selectedTab: LegalTab.privacy));

  void changeTab(LegalTab tab) {
    if (state.selectedTab == tab) return;
    emit(LegalState(selectedTab: tab));
  }

  static LegalCubit get(context) => BlocProvider.of(context);
}
