// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
// class DownloadPDf{
//   Future<void> requestStoragePermission() async {
//     if (Platform.isAndroid) {
//       if (await Permission.manageExternalStorage.isGranted) return;
//
//       var status = await Permission.manageExternalStorage.request();
//       if (!status.isGranted) {
//         print("Storage permission denied");
//       }
//     }
//   }
//   Future<void> downloadPdf(String url) async {
//     try {
//       // Request storage permission (for Android)
//       if (Platform.isAndroid) {
//         var status = await Permission.storage.request();
//         if (!status.isGranted) {
//           print("Storage permission denied");
//           return;
//         }
//       }
//
//       // Get the document directory (iOS) or download directory (Android)
//       Directory? dir;
//       if (Platform.isAndroid) {
//         dir = Directory('/storage/emulated/0/Download');
//       } else {
//         dir = await getApplicationDocumentsDirectory();
//       }
//
//       final response = await http.get(Uri.parse(url));
//
//       if (response.statusCode == 200) {
//         String fileName = url.split('/').last;
//         File file = File('${dir.path}/$fileName');
//
//         await file.writeAsBytes(response.bodyBytes);
//         print("PDF downloaded to ${file.path}");
//       } else {
//         print("Failed to download file: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Download error: $e");
//     }
//   }
//
// }