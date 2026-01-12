// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
// import 'package:smart_app/core/api/end_points.dart';
// import 'package:smart_app/core/services/cache_helper.dart';
// import 'package:smart_app/core/services/services_locator.dart';
// import 'package:smart_app/core/utils/constant_keys.dart';
// import 'package:smart_app/features/room/all_chats/logic/cubit/all_chats_cubit.dart';
// import 'package:smart_app/features/room/chat_details/logic/cubit/chat_details_cubit.dart';
// import 'package:smart_app/my_app.dart';
//
// class PusherService {
//   static PusherService? _instance;
//   static late PusherChannelsFlutter _pusher;
//   BuildContext? context;
//
//   // late int myId;
//
//   factory PusherService(BuildContext context) {
//     _instance ??= PusherService._(context);
//     return _instance!;
//   }
//
//   PusherService._(BuildContext context) {
//     this.context = context;
//     _pusher = PusherChannelsFlutter.getInstance();
//     // myId=id;
//   }
//
//   Future<void> initPusher() async {
//     try {
//       await _pusher.init(
//         apiKey: '2642dec84e0542203b0e',
//         cluster: 'eu',
//         onConnectionStateChange: onConnectionStateChange,
//         onError: onError,
//         onSubscriptionSucceeded: onSubscriptionSucceeded,
//         onEvent: onEvent,
//         onSubscriptionError: onSubscriptionError,
//         onDecryptionFailure: onDecryptionFailure,
//         onMemberAdded: onMemberAdded,
//         onMemberRemoved: onMemberRemoved,
//         onAuthorizer: onAuthorizer,
//       );
//     } catch (e) {
//       print('Error initializing Pusher: $e');
//     }
//   }
//
//   Future<void> subscribeToChannel(String channelName) async {
//     try {
//       print('success subscribing to channel $channelName');
//       await _pusher.subscribe(channelName: channelName);
//     } catch (e) {
//       print('Error subscribing to channel $channelName: $e');
//     }
//   }
//
//   Future<void> unsubscribeFromChannel(String channelName) async {
//     try {
//       print('success Unsubscribing to channel $channelName');
//       await _pusher.unsubscribe(channelName: channelName);
//     } catch (e) {
//       print('Error unsubscribing from channel $channelName: $e');
//     }
//   }
//
//   void connectPusher() {
//     try {
//       _pusher.connect();
//     } catch (e) {
//       print('Error connecting Pusher: $e');
//     }
//   }
//
//   static disconnectPusher() {
//     try {
//       _pusher.disconnect();
//     } catch (e) {
//       print('Error disconnecting Pusher: $e');
//     }
//   }
//
//   Future<void> triggerEvent(
//     String channelName,
//     String eventName,
//     dynamic data,
//   ) async {
//     try {
//       await _pusher.trigger(
//         PusherEvent(channelName: channelName, eventName: eventName, data: data),
//       );
//     } catch (e) {
//       print('Error triggering event on channel $channelName: $e');
//     }
//   }
//
//   void onConnectionStateChange(dynamic currentState, dynamic previousState) {
//     print('Connection state changed: $currentState');
//   }
//
//   void onError(String message, int? code, dynamic e) {
//     print('Error: $message, code: $code, exception: $e');
//   }
//
//   void onSubscriptionSucceeded(String channelName, dynamic data) {
//     print('Subscription succeeded on channel $channelName');
//   }
//
//   void onEvent(PusherEvent event) {
//     print('onEvent onEvent onEvent onEvent1111');
//     print(event);
//     AllChatsCubit.instance.updateLiveMessages(event);
//     ChatDetailsCubit.instance.updateLiveMessages(event);
//
//
//     print('onEvent onEvent onEvent onEvent2222');
//   }
//
//   void onSubscriptionError(String message, dynamic e) {
//     print('Subscription error: $message, exception: $e');
//   }
//
//   void onDecryptionFailure(String event, String reason) {
//     print('Decryption failure on event $event: $reason');
//   }
//
//   void onMemberAdded(String channelName, PusherMember member) {
//     print('Member added to channel $channelName: $member');
//   }
//
//   void onMemberRemoved(String channelName, PusherMember member) {
//     print('Member removed from channel $channelName: $member');
//   }
//
//   Future<dynamic> onAuthorizer(
//     String channelName,
//     String socketId,
//     dynamic options,
//   ) async {
//     print('onAuthorizer onAuthorizer onAuthorizer');
//     var authUrl = "${EndPoints.baseUrl}api/chat/direct/pusher/auth";
//     try {
//       var result = await http.post(
//         Uri.parse(authUrl),
//         headers: {
//           ConstantKeys.acceptText: ConstantKeys.applicationJson,
//           ConstantKeys.appAuthorization:
//               "${ConstantKeys.appBearer} ${await CacheHelper.getSecuredString(ConstantKeys.saveTokenToShared)}",
//         },
//         body: {'socket_id': socketId, 'channel_name': channelName},
//       );
//
//       var jsonResponse = jsonDecode(result.body);
//       print("Authorization response: $jsonResponse");
//       return jsonResponse;
//     } catch (e) {
//       print("Error during authorization: $e");
//       throw e;
//     }
//   }
// }
