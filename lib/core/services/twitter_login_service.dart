// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:twitter_login/twitter_login.dart';
//
// class TwitterLoginService {
//   Future<UserCredential> signInWithTwitter() async {
//     final twitterLogin = TwitterLogin(
//         apiKey: '3v8dX8uAfO399stdljVFM3uG6',
//         apiSecretKey: 'qbUUeBWknxkkWzQAd3LcdmBD3RlYHyHMNhHyTP8c7p6r7ZrNXl',
//         redirectURI: 'https://magic-suite.firebaseapp.com/__/auth/handler');
//
//     // Create a credential from the access token
//     // Trigger the sender_sign-in flow
//     final authResult = await twitterLogin.sender_sign();
//
//     // Create a credential from the access token
//     final twitterAuthCredential = TwitterAuthProvider.credential(
//       accessToken: authResult.authToken!,
//       secret: authResult.authTokenSecret!,
//     );
//
//     // Once signed in, return the UserCredential
//     return await FirebaseAuth.instance
//         .signInWithCredential(twitterAuthCredential);
//   }
// }
