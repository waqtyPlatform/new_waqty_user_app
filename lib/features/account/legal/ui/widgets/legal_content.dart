import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waqty_user_application/features/account/legal/logic/legal_cubit.dart';
import 'package:waqty_user_application/features/account/legal/logic/legal_state.dart';
import 'package:waqty_user_application/features/account/legal/ui/widgets/legal_header.dart';
import 'package:waqty_user_application/features/account/legal/ui/widgets/legal_sections_card.dart';
import 'package:waqty_user_application/features/account/legal/ui/widgets/legal_segmented_tabs.dart';
import 'package:waqty_user_application/features/account/legal/ui/widgets/legal_summary_card.dart';
import 'package:waqty_user_application/features/account/legal/ui/widgets/legal_support_card.dart';

class LegalContent extends StatelessWidget {
  const LegalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LegalCubit, LegalState>(
      builder: (context, state) {
        return ListView(
          padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 104.h),
          children: [
            const LegalHeader(),
            SizedBox(height: 14.h),
            LegalSegmentedTabs(selectedTab: state.selectedTab),
            SizedBox(height: 16.h),
            LegalSummaryCard(tab: state.selectedTab),
            SizedBox(height: 12.h),
            LegalSectionsCard(tab: state.selectedTab),
            SizedBox(height: 12.h),
            const LegalSupportCard(),
          ],
        );
      },
    );
  }
}
