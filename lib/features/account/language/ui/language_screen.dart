import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/core/utils/extentions.dart';
import 'package:waqty_user_application/features/account/language/logic/language_cubit.dart';
import 'package:waqty_user_application/features/account/language/logic/language_state.dart';
import 'package:waqty_user_application/features/account/language/ui/widgets/language_content.dart';
import 'package:waqty_user_application/features/account/language/ui/widgets/save_language_footer.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanguageCubit, LanguageState>(
      listener: (context, state) {
        if (state is LanguageSavedState) context.pop();
      },
      builder: (context, state) {
        final cubit = LanguageCubit.get(context);
        return Scaffold(
          backgroundColor: AppColors.pageColor,
          bottomNavigationBar: SaveLanguageFooter(cubit: cubit),
          body: const LanguageContent(),
        );
      },
    );
  }
}
