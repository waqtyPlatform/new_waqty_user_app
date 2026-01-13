import 'package:waqty_user_application/core/api/api_consumer.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_api_end_points.dart';

class ForgetPasswordService {
  ApiConsumer apiConsumer;

  ForgetPasswordService({required this.apiConsumer});

  // Future<GetMyAddressResponseModel> myAddress(
  //   String type,
  //   String search,
  // ) async {
  //   final response = await apiConsumer.get(
  //     ForgetPasswordApiEndPoints.myAddressURl(type, search),
  //     {
  //       ConstantKeys.appAuthorization:
  //           "${ConstantKeys.appBearer} ${await CacheHelper.getSecuredString(ConstantKeys.saveTokenToShared)}",
  //     },
  //   );
  //   if (response.statusCode == StatusCode.ok) {
  //     return GetMyAddressResponseModel.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw ServerException(
  //       serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
  //     );
  //   }
  // }
  //
  // Future<SuccessResponseModel> deleteAddress(
  //   int id,
  // ) async {
  //   final response = await apiConsumer.delete(
  //     MyAddressApiEndPoints.deleteURl(id),
  //     null,
  //     {
  //       ConstantKeys.appAuthorization:
  //           "${ConstantKeys.appBearer} ${await CacheHelper.getSecuredString(ConstantKeys.saveTokenToShared)}",
  //     },
  //   );
  //
  //   if (response.statusCode == StatusCode.ok) {
  //     return SuccessResponseModel.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw ServerException(
  //       serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
  //     );
  //   }
  // }
  // Future<SuccessResponseModel> setAddressDefault(
  //   int id,
  // ) async {
  //   final response = await apiConsumer.post(
  //     MyAddressApiEndPoints.setAddressDefaultURl(id),
  //     null,
  //     {
  //       ConstantKeys.appAuthorization:
  //           "${ConstantKeys.appBearer} ${await CacheHelper.getSecuredString(ConstantKeys.saveTokenToShared)}",
  //     },
  //   );
  //   if (response.statusCode == StatusCode.ok) {
  //     return SuccessResponseModel.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw ServerException(
  //       serverFailure: ServerFailure.fromJson(jsonDecode(response.body)),
  //     );
  //   }
  // }
}
