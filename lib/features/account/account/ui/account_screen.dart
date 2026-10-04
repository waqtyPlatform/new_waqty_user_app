import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/config/routes/routes.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/account/account/logic/account_cubit.dart';
import 'package:waqty_user_application/features/account/account/logic/account_state.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_header_card.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_top_bar.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/account_user_content.dart';
import 'package:waqty_user_application/features/account/account/ui/widgets/guest_account_content.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountLogoutSuccessState) {
          context.pushNamedAndRemoveUntil(
            Routes.loginScreen,
            predicate: (_) => false,
          );
        }
      },
      builder: (context, state) {
        final cubit = AccountCubit.get(context);
        final isGuest = state is AccountLoadedState
            ? state.isGuest
            : cubit.isGuest;

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 118.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AccountTopBar(),
                AccountHeaderCard(isGuest: isGuest),
                if (isGuest)
                  const GuestAccountContent()
                else
                  const AccountUserContent(),
              ],
            ),
          ),
        );
      },
    );
  }
}
