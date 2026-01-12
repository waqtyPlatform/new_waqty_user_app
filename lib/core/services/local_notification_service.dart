// import 'package:awesome_notifications/awesome_notifications.dart';
//
// import 'package:flutter/material.dart';
// import 'package:egk_app/config/routes/routes.dart';
// import 'package:egk_app/core/services/cache_helper.dart';
// import 'package:egk_app/core/utils/constant_keys.dart';
// import 'package:egk_app/my_app.dart';
//
// class LocalNotificationService {
//   // static final wesomeNotifications=AwesomeNotifications();
//   static Future<void> initializedNotification() async {
//     await AwesomeNotifications().initialize(
//       null,
//       [
//         NotificationChannel(
//           channelGroupKey: 'basic_channel_group',
//           channelKey: 'basic_channel',
//           channelName: 'Basic notifications',
//           channelDescription: 'Notification channel for basic tests',
//           defaultColor: Color(0xFF9D50DD),
//           ledColor: Colors.white,
//           importance: NotificationImportance.Max,
//           channelShowBadge: true,
//           onlyAlertOnce: true,
//           playSound: true,
//           criticalAlerts: true,
//         ),
//       ],
//       channelGroups: [
//         NotificationChannelGroup(
//           channelGroupKey: 'basic_channel_group',
//           channelGroupName: 'Basic group',
//         ),
//       ],
//       debug: true,
//     );
//
//     await AwesomeNotifications().isNotificationAllowed().then((
//       isAllowed,
//     ) async {
//       if (!isAllowed) {
//         await AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });
//
//     await AwesomeNotifications().setListeners(
//       onActionReceivedMethod: onActionReceivedMethod,
//       onNotificationCreatedMethod: onNotificationCreatedMethod,
//       onNotificationDisplayedMethod: onNotificationDisplayedMethod,
//       onDismissActionReceivedMethod: onDismissActionReceivedMethod,
//     );
//   }
//
//   static Future<void> onActionReceivedMethod(
//     ReceivedAction receivedAction,
//   ) async {
//     print(
//       "onActionReceivedMethod onActionReceivedMethod onActionReceivedMethod ${receivedAction.payload}",
//     );
//
//     // if (receivedAction.payload != null) {
//     //   String? userType = await CacheHelper.getSecuredString(
//     //     ConstantKeys.saveUserTypeToShared,
//     //   );
//     //   if (userType != null && navigatorKey.currentContext != null) {
//     //     if (userType == 'client') {
//     //       if (receivedAction.payload!['subject_type'] == 'chatroom') {
//     //         Navigator.pushNamed(
//     //           navigatorKey.currentContext!,
//     //           Routes.chatDetailsScreen,
//     //           arguments: {
//     //             'id':
//     //                 int.tryParse(
//     //                   receivedAction.payload!['subject_id'].toString(),
//     //                 ) ??
//     //                 0,
//     //             'isRoom': true,
//     //             'isNotification': true,
//     //           },
//     //         );
//     //       } else if (receivedAction.payload!['subject_type'] == 'chatdirect') {
//     //         Navigator.pushNamed(
//     //           navigatorKey.currentContext!,
//     //           Routes.chatDetailsScreen,
//     //           arguments: {
//     //             'id':
//     //                 int.tryParse(
//     //                   receivedAction.payload!['subject_id'].toString(),
//     //                 ) ??
//     //                 0,
//     //             'isRoom': false,
//     //             'isNotification': true,
//     //           },
//     //         );
//     //       } else if (receivedAction.payload!['subject_type'] == 'Booking') {
//     //         Navigator.pushNamed(
//     //           navigatorKey.currentContext!,
//     //           Routes.userMyBookingScreen,
//     //         );
//     //       }
//     //     } else {
//     //       if (receivedAction.payload!['subject_type'] == 'chatroom') {
//     //         Navigator.pushNamed(
//     //           navigatorKey.currentContext!,
//     //           Routes.chatDetailsScreen,
//     //           arguments: {
//     //             'id':
//     //                 int.tryParse(
//     //                   receivedAction.payload!['subject_id'].toString(),
//     //                 ) ??
//     //                 0,
//     //             'isRoom': true,
//     //             'isNotification': true,
//     //           },
//     //         );
//     //       } else if (receivedAction.payload!['subject_type'] == 'chatdirect') {
//     //         Navigator.pushNamed(
//     //           navigatorKey.currentContext!,
//     //           Routes.chatDetailsScreen,
//     //           arguments: {
//     //             'id':
//     //                 int.tryParse(
//     //                   receivedAction.payload!['subject_id'].toString(),
//     //                 ) ??
//     //                 0,
//     //             'isRoom': false,
//     //             'isNotification': true,
//     //           },
//     //         );
//     //       } else if (receivedAction.payload!['subject_type'] == 'Booking') {
//     //         Navigator.pushNamed(
//     //           navigatorKey.currentContext!,
//     //           Routes.sponsorMyBookingScreen,
//     //           arguments: {'isPending': true},
//     //         );
//     //       }
//     //     }
//     //   }
//     // }
//   }
//
//   static Future<void> onNotificationCreatedMethod(
//     ReceivedNotification receivedAction,
//   ) async {
//     print("onNotificationCreatedMethod");
//   }
//
//   static Future<void> onNotificationDisplayedMethod(
//     ReceivedNotification receivedAction,
//   ) async {
//     print("onNotificationDisplayedMethod");
//   }
//
//   static Future<void> onDismissActionReceivedMethod(
//     ReceivedAction receivedAction,
//   ) async {
//     print("onDismissActionReceivedMethod");
//   }
//
//   static Future<void> showNotification({
//     required final String title,
//     required final String body,
//     final String? summary,
//     final Map<String, String>? payload,
//     final ActionType actionType = ActionType.Default,
//     final NotificationLayout notificationLayout = NotificationLayout.Default,
//     final NotificationCategory? category,
//     final String? bigPicture,
//     final List<NotificationActionButton>? actionButtons,
//     final bool schedule = false,
//     final Duration? interval,
//   }) async {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: -1,
//         channelKey: 'basic_channel',
//         title: title,
//         body: body,
//         actionType: actionType,
//         notificationLayout: notificationLayout,
//         summary: summary,
//         category: category,
//         payload: payload,
//         bigPicture: bigPicture,
//       ),
//       actionButtons: actionButtons,
//       schedule: schedule
//           ? NotificationInterval(
//               interval: interval,
//               timeZone: await AwesomeNotifications()
//                   .getLocalTimeZoneIdentifier(),
//               preciseAlarm: true,
//             )
//           : null,
//     );
//   }
// }
