// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class MediaCard extends StatefulWidget {
//   final String path;
//   const MediaCard({required this.path, Key? key}) : super(key: key);
//
//   @override
//   State<MediaCard> createState() => _MediaCardState();
// }
//
// class _MediaCardState extends State<MediaCard> {
//   VideoPlayerController? _controller;
//   bool isVideo = false;
//
//   @override
//   void initState() {
//     super.initState();
//     String ext = widget.path.split('.').last.toLowerCase();
//     if (['mp4', 'mov', 'avi'].contains(ext)) {
//       isVideo = true;
//       _controller = VideoPlayerController.file(File(widget.path))
//         ..initialize().then((_) {
//           setState(() {});
//           _controller!.setLooping(true);
//           _controller!.pause();
//         });
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: SizedBox(
//         height: 150,
//         width: 150,
//         child: isVideo
//             ? (_controller != null && _controller!.value.isInitialized)
//                   ? Stack(
//                       children: [
//                         AspectRatio(
//                           aspectRatio: _controller!.value.aspectRatio,
//                           child: VideoPlayer(_controller!),
//                         ),
//                         Positioned(
//                           bottom: 5,
//                           right: 5,
//                           child: IconButton(
//                             icon: Icon(
//                               _controller!.value.isPlaying
//                                   ? Icons.pause_circle
//                                   : Icons.play_circle,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _controller!.value.isPlaying
//                                     ? _controller!.pause()
//                                     : _controller!.play();
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     )
//                   : const Center(child: CircularProgressIndicator())
//             : Image.file(File(widget.path), fit: BoxFit.cover),
//       ),
//     );
//   }
// }
//
// class MediaDialogContent extends StatefulWidget {
//   final String filePath;
//   final bool isVideo;
//
//   const MediaDialogContent({
//     required this.filePath,
//     required this.isVideo,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<MediaDialogContent> createState() => _MediaDialogContentState();
// }
//
// class _MediaDialogContentState extends State<MediaDialogContent> {
//   VideoPlayerController? _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.isVideo) {
//       _controller = VideoPlayerController.file(File(widget.filePath))
//         ..initialize().then((_) {
//           setState(() {});
//           _controller!.play();
//           _controller!.setLooping(true);
//         });
//       _controller!.addListener(() {
//         setState(() {}); // لتحديث شريط التقدم أثناء التشغيل
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             color: Colors.black,
//             child: widget.isVideo
//                 ? (_controller != null && _controller!.value.isInitialized
//                 ? Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 AspectRatio(
//                   aspectRatio: _controller!.value.aspectRatio,
//                   child: VideoPlayer(_controller!),
//                 ),
//                 VideoProgressIndicator(
//                   _controller!,
//                   allowScrubbing: true, // يسمح بالسحب للتحكم
//                   colors: VideoProgressColors(
//                     playedColor: Colors.red,
//                     backgroundColor: Colors.grey,
//                     bufferedColor: Colors.white54,
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         _controller!.value.isPlaying
//                             ? Icons.pause_circle_filled
//                             : Icons.play_circle_filled,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           if (_controller!.value.isPlaying) {
//                             _controller!.pause();
//                           } else {
//                             _controller!.play();
//                           }
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             )
//                 : const SizedBox(
//               height: 200,
//               child: Center(child: CircularProgressIndicator()),
//             ))
//                 : InteractiveViewer(
//               child: Image.file(
//                 File(widget.filePath),
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           top: 8,
//           right: 8,
//           child: GestureDetector(
//             onTap: () => Navigator.of(context).pop(),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(4),
//               child: const Icon(
//                 Icons.close,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
//
//
// /////
//
//
//
// class NetworkMediaCard extends StatefulWidget {
//   final String url;
//   const NetworkMediaCard({required this.url, Key? key}) : super(key: key);
//
//   @override
//   State<NetworkMediaCard> createState() => _NetworkMediaCardState();
// }
//
// class _NetworkMediaCardState extends State<NetworkMediaCard> {
//   VideoPlayerController? _controller;
//   bool isVideo = false;
//
//   @override
//   void initState() {
//     super.initState();
//     String ext = widget.url.split('.').last.toLowerCase();
//     if (['mp4', 'mov', 'avi', 'webm', 'mkv'].contains(ext)) {
//       isVideo = true;
//       _controller = VideoPlayerController.network(widget.url)
//         ..initialize().then((_) {
//           setState(() {});
//           _controller!.setLooping(true);
//           _controller!.pause();
//         });
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: SizedBox(
//         height: 150,
//         width: 150,
//         child: isVideo
//             ? (_controller != null && _controller!.value.isInitialized)
//             ? Stack(
//           children: [
//             AspectRatio(
//               aspectRatio: _controller!.value.aspectRatio,
//               child: VideoPlayer(_controller!),
//             ),
//             Positioned(
//               bottom: 5,
//               right: 5,
//               child: IconButton(
//                 icon: Icon(
//                   _controller!.value.isPlaying
//                       ? Icons.pause_circle
//                       : Icons.play_circle,
//                   color: Colors.white,
//                   size: 30,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _controller!.value.isPlaying
//                         ? _controller!.pause()
//                         : _controller!.play();
//                   });
//                 },
//               ),
//             ),
//           ],
//         )
//             : const Center(child: CircularProgressIndicator())
//             : Image.network(
//           widget.url,
//           fit: BoxFit.cover,
//           loadingBuilder: (context, child, progress) {
//             if (progress == null) return child;
//             return const Center(child: CircularProgressIndicator());
//           },
//           errorBuilder: (context, error, stackTrace) {
//             return const Center(
//                 child: Icon(Icons.broken_image, size: 40));
//           },
//         ),
//       ),
//     );
//   }
// }
//
//
//
// class NetworkMediaDialogContent extends StatefulWidget {
//   final String url;
//   final bool isVideo;
//
//   const NetworkMediaDialogContent({
//     required this.url,
//     required this.isVideo,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<NetworkMediaDialogContent> createState() => _NetworkMediaDialogContentState();
// }
//
// class _NetworkMediaDialogContentState extends State<NetworkMediaDialogContent> {
//   VideoPlayerController? _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.isVideo) {
//       _controller = VideoPlayerController.network(widget.url)
//         ..initialize().then((_) {
//           setState(() {});
//           _controller!.play();
//           _controller!.setLooping(true);
//         });
//       _controller!.addListener(() {
//         setState(() {}); // لتحديث شريط التقدم أثناء التشغيل
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             color: Colors.black,
//             child: widget.isVideo
//                 ? (_controller != null && _controller!.value.isInitialized
//                 ? Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 AspectRatio(
//                   aspectRatio: _controller!.value.aspectRatio,
//                   child: VideoPlayer(_controller!),
//                 ),
//                 VideoProgressIndicator(
//                   _controller!,
//                   allowScrubbing: true,
//                   colors: VideoProgressColors(
//                     playedColor: Colors.red,
//                     backgroundColor: Colors.grey,
//                     bufferedColor: Colors.white54,
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         _controller!.value.isPlaying
//                             ? Icons.pause_circle_filled
//                             : Icons.play_circle_filled,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           if (_controller!.value.isPlaying) {
//                             _controller!.pause();
//                           } else {
//                             _controller!.play();
//                           }
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             )
//                 : const SizedBox(
//               height: 200,
//               child: Center(child: CircularProgressIndicator()),
//             ))
//                 : InteractiveViewer(
//               child: Image.network(
//                 widget.url,
//                 fit: BoxFit.contain,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return const Center(child: CircularProgressIndicator());
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   return const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey));
//                 },
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           top: 8,
//           right: 8,
//           child: GestureDetector(
//             onTap: () => Navigator.of(context).pop(),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(4),
//               child: const Icon(
//                 Icons.close,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
