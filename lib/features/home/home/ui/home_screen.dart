import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waqty_user_application/core/services/check_network.dart';
import 'package:waqty_user_application/core/utils/app_colors_white_theme.dart';
import 'package:waqty_user_application/features/home/home/ui/widgets/home_design_widgets.dart';

class HomeScreen extends StatelessWidget {
  final bool isLoading;
  final bool isLocationDisabled;
  final bool isCityUnavailable;
  final bool isOffline;

  const HomeScreen({
    super.key,
    this.isLoading = false,
    this.isLocationDisabled = false,
    this.isCityUnavailable = false,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageColor,
      body: StreamBuilder<Map<String, bool>>(
        stream: MyConnectivity.myStream,
        initialData: {'result': MyConnectivity.isOnline()},
        builder: (context, snapshot) {
          final streamOffline = snapshot.data?['result'] == false;
          return SafeArea(
            child: isLoading
                ? HomeLoadingContent()
                : isOffline || streamOffline
                ? HomeOfflineContent()
                : isLocationDisabled || isCityUnavailable
                ? HomeLocationDisabledContent(
                    requestLocation: isLocationDisabled,
                  )
                : HomeContent(),
          );
        },
      ),
    );
  }
}
