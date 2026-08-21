import 'package:dartz/dartz.dart';
import 'package:waqty_user_application/core/api/api_client.dart';
import 'package:waqty_user_application/core/api/api_paths.dart';
import 'package:waqty_user_application/core/exceptions/failure.dart';
import 'package:waqty_user_application/core/mock/mock_in_branch.dart';
import 'package:waqty_user_application/core/models/booking_ui_model.dart';
import 'package:waqty_user_application/core/models/in_branch_ui_model.dart';
import 'package:waqty_user_application/core/utils/json_parse.dart';
import 'package:waqty_user_application/features/booking/in_branch/data/services/in_branch_service.dart';

class InBranchRemoteService implements InBranchService {
  final ApiClient _client;

  const InBranchRemoteService(this._client);

  @override
  Future<Either<Failure, InBranchUiModel?>> status(
    BookingUiModel booking,
  ) => _client.get(
    ApiPaths.booking(booking.uuid),
    parse: (envelope) {
      final json = JsonParse.mapValue(envelope.data);
      final fresh = BookingUiModel.fromJson(json);

      // الحالة اللي بتحط العميل «جوّه الفرع» — نفس المنطق اللي الموك
      // بيمشي عليه، بس مبني على حالة حقيقية من السيرفر.
      final isInBranch =
          fresh.status == BookingStatus.arrived ||
          fresh.status == BookingStatus.waiting ||
          fresh.status == BookingStatus.inProgress;

      if (!isInBranch) return null;

      // ⚠ **التقدير من الموك.** مفيش أي إشارة في الـAPI عن ترتيب الطابور
      // ولا الوقت المتوقّع — شوف `InBranchService`. بناخد الحالة الحقيقية
      // ونسيب التقدير للفكسشر لحد ما السيرفر يوفّره.
      final estimate = MockInBranch.forBooking(fresh, DateTime.now());

      return InBranchUiModel.fromJson(
        json,
        estimateLow: estimate?.estimateLow,
        estimateHigh: estimate?.estimateHigh,
        expectedFinishAt: estimate?.expectedFinishAt,
      );
    },
  );
}
