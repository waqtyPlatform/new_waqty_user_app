//  import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//  import 'package:egk_app/core/utils/app_colors_white_theme.dart';
// import 'package:egk_app/core/utils/spacing.dart';
// import 'package:egk_app/core/utils/styles.dart';
// import 'package:egk_app/core/widgets/cached_network_image.dart';
//
// class CustomCardWidget extends StatelessWidget {
//   final String? follower;
//   final String imageUrl;
//   final String name;
//   final String title;
//   final double? width;
//   final Object opject;
//   final void Function()? onTap;
//
//   const CustomCardWidget({
//     super.key,
//     required this.follower,
//     required this.imageUrl,
//     required this.name,
//     required this.title,
//     required this.opject,
//     required this.onTap,
//     this.width,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 250,
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         margin: const EdgeInsets.symmetric(horizontal: 8),
//         decoration: BoxDecoration(
//           color: AppColors.whiteColor,
//           borderRadius: BorderRadius.circular(8.r),
//           border: Border.all(
//             color: AppColors.greyColor44.withValues(alpha: .2),
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             verticalSpace(6),
//             Container(
//               padding: const EdgeInsets.all(3),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color:AppColors.redColor,
//                   width: 2,
//                 ),
//               ),
//               child: ClipOval(
//                 child: SizedBox(
//                   width: 90.r,
//                   height: 90.r,
//                   child: Stack(
//                     alignment: Alignment.bottomCenter,
//                     children: [
//                       CachedNetworkImageWidget(
//                         imgUrl: imageUrl,
//                         radius: BorderRadius.zero,
//                       ),
//
//                       if (follower != null)
//                         Container(
//                           width: double.infinity,
//                           color: Colors.red.withOpacity(0.7), // شفاف
//                           padding: const EdgeInsets.symmetric(vertical: 5),
//                           child: Text(
//                             follower!,
//                             textAlign: TextAlign.center,
//                             style: TextStyles.font12WhiteColorWeightBold
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             verticalSpace(14),
//             Text(
//               name,
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               style: TextStyles.font14BlackColorW500.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//             verticalSpace(6),
//             SizedBox(
//               width: 150,
//               child: AutoSizeText(
//                 title,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyles.font12Grey8DColorW500,
//                 minFontSize: 14,
//                 maxFontSize: 16,
//               ),
//             ),
//             verticalSpace(6),
//           ],
//         ),
//       ),
//     );
//   }
// }
