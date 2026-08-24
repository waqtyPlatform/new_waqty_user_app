import 'package:waqty_user_application/core/api/end_points.dart';

/// كل مسارات الـAPI في مكان واحد.
///
/// ⚠ الـ٦ auth services عندها ملفات `*_api_end_points.dart` بتاعتها وشغالة —
/// **ماتلمسهمش**. الملف ده لكل حاجة جديدة، عشان مايبقاش فيه ٢٦ ملف مسارات.
///
/// المسارات هنا **كاملة** (فيها `EndPoints.baseUrl`) عشان الـservice ينده
/// عليها على طول من غير لزق.
class ApiPaths {
  const ApiPaths._();

  static const String _base = EndPoints.baseUrl;

  // ── عام: مفيش توكن ─────────────────────────────────────────────────────

  static const String categories = '$_base/api/public/categories';
  static String category(String uuid) => '$categories/$uuid';
  static const String subcategories = '$_base/api/public/subcategories';
  static const String specialties = '$_base/api/public/specialties';

  static const String countries = '$_base/api/public/countries';
  static const String cities = '$_base/api/public/cities';
  static const String governorates = '$_base/api/public/governorates';

  static const String providers = '$_base/api/public/providers';
  static String provider(String uuid) => '$providers/$uuid';

  static const String providerBranches = '$_base/api/public/provider-branches';
  static String providerBranch(String uuid) => '$providerBranches/$uuid';

  /// باقات الفرع المعروضة للبيع — **فرعية مش مزوّدية**: نفس الباقة ممكن
  /// يكون ليها سعر تاني في فرع تاني لنفس الصالون.
  static String branchPackages(String branchUuid) =>
      '${providerBranch(branchUuid)}/packages';

  static const String employees = '$_base/api/public/employees';

  static const String services = '$_base/api/public/services';
  static const String servicesNewest = '$services/newest';
  static const String servicesNearest = '$services/nearest';
  static String service(String uuid) => '$services/$uuid';

  static String servicePrice(String uuid) =>
      '$_base/api/public/service-pricing/services/$uuid/price';

  /// ⚠ التلاتة دول عليهم `throttle:60,1` — شوف تعليق الكاش في
  /// `create_booking_cubit`. شريط تواريخ بينده لكل يوم بيحرقهم في ثواني.
  static const String availableEmployees =
      '$_base/api/public/bookings/available-employees';
  static const String availableDates =
      '$_base/api/public/bookings/available-dates';
  static const String availableSlots =
      '$_base/api/public/bookings/available-slots';

  static String image(String type, String uuid) =>
      '$_base/api/images/$type/$uuid';

  // ── العميل: محتاجة توكن ────────────────────────────────────────────────

  static const String me = '$_base/api/user/auth/me';
  static const String logout = '$_base/api/user/auth/logout';
  static const String sendPhoneVerification =
      '$_base/api/user/auth/send-phone-verification';
  static const String verifyPhone = '$_base/api/user/auth/verify-phone';

  static const String bookings = '$_base/api/user/bookings';
  static String booking(String uuid) => '$bookings/$uuid';
  static String cancelBooking(String uuid) => '$bookings/$uuid/cancel';
  static String reviewableItems(String uuid) =>
      '$bookings/$uuid/reviewable-items';
  static String rateBooking(String uuid) => '$bookings/$uuid/rate';

  // ── الاستحقاقات: باقات ومتابعات ───────────────────────────────────────
  //
  // الردود دي بتقول **`provider` و`branch` و`service_uuid`** على كل صف
  // (BE-A1)، وده اللي بيخلّي الحجز من التطبيق ممكن أصلاً — `available-slots`
  // مفتاحه (فرع، خدمة). وحجز الجلسة بيرد بـ`UserBookingResource` (BE-A2).
  static const String entitlementPackages =
      '$_base/api/user/entitlements/packages';
  static const String entitlementFollowUps =
      '$_base/api/user/entitlements/follow-ups';
  static String bookPackageSession(String uuid) =>
      '$entitlementPackages/$uuid/sessions';
  static String bookFollowUp(String uuid) => '$entitlementFollowUps/$uuid/book';

  static const String waitlist = '$_base/api/user/waitlist';
  static String waitlistEntry(String uuid) => '$waitlist/$uuid';
  static String waitlistConversation(String uuid) =>
      '$waitlist/$uuid/conversation';
  static String acceptWaitlist(String uuid) => '$waitlist/$uuid/accept';
  static String requestWaitlistChange(String uuid) =>
      '$waitlist/$uuid/request-change';
  static String cancelWaitlist(String uuid) => '$waitlist/$uuid/cancel';

  static const String reassignments = '$_base/api/user/booking-reassignments';
  static String reassignment(String uuid) => '$reassignments/$uuid';
  static String reassignmentMessages(String uuid) =>
      '$reassignments/$uuid/messages';
  static String acceptProposal(String proposalUuid) =>
      '$reassignments/proposals/$proposalUuid/accept';
  static String requestProposalChange(String proposalUuid) =>
      '$reassignments/proposals/$proposalUuid/request-change';
  static String cancelProposal(String proposalUuid) =>
      '$reassignments/proposals/$proposalUuid/cancel';

  static const String payments = '$_base/api/user/payments';
  static String payment(String uuid) => '$payments/$uuid';

  // ── الأبلكيشن نفسه ─────────────────────────────────────────────────────

  static const String appGate = '$_base/api/v1/app/gate';
  static const String deviceToken = '$_base/api/v1/app/device-token';
}
