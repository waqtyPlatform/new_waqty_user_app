import 'dart:io' show Platform;

import 'package:dartz/dartz.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/models/app_gate_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/splash/data/services/app_gate_service.dart';

class AppGateRemoteService implements AppGateService {
  final ApiClient _client;

  const AppGateRemoteService(this._client);

  @override
  Future<Either<Failure, AppGateUiModel>> evaluate() async {
    final info = await PackageInfo.fromPlatform();

    return _client.get(
      ApiPaths.appGate,
      query: {
        // `AppType` في الباك-إند فيه `user` و`employee` بس — مفيش `provider`.
        'app': 'user',
        'platform': _platform,
        'version': info.version,
      },
      parse: (envelope) =>
          AppGateUiModel.fromJson(JsonParse.mapValue(envelope.data)),
    );
  }

  @override
  Future<Either<Failure, Unit>> registerDeviceToken(String fcmToken) async {
    final info = await PackageInfo.fromPlatform();

    return _client.post(
      ApiPaths.deviceToken,
      body: {
        'fcm_token': fcmToken,
        'app': 'user',
        'platform': _platform,
        'app_version': info.version,
      },
      parse: (_) => unit,
    );
  }

  /// `AppGateRequest` بيقبل `android` و`ios` بس.
  String get _platform => Platform.isIOS ? 'ios' : 'android';
}
