import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:get_it/get_it.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/repo/forget_password_repo.dart';
import 'package:waqty_user_application/features/auth/forget_password/data/services/forget_password_service.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/repo/forget_verify_code_repo.dart';
import 'package:waqty_user_application/features/auth/forget_verify_code/data/services/forget_verify_code_service.dart';
import 'package:waqty_user_application/features/auth/login/data/repo/login_repo.dart';
import 'package:waqty_user_application/features/auth/login/data/services/login_service.dart';
import 'package:waqty_user_application/features/auth/register/data/repo/register_repo.dart';
import 'package:waqty_user_application/features/auth/register/data/services/register_service.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/repo/register_verify_code_repo.dart';
import 'package:waqty_user_application/features/auth/register_verify_code/data/services/register_verify_code_service.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/repo/reseat_password_repo.dart';
import 'package:waqty_user_application/features/auth/reseat_password/data/services/reseat_password_service.dart';
import 'package:waqty_user_application/features/home/home/data/repo/home_repo.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_mock_service.dart';
import 'package:waqty_user_application/features/home/home/data/services/home_remote_service.dart';
import 'package:waqty_user_application/features/providers/providers_list/data/repo/providers_list_repo.dart';
import 'package:waqty_user_application/features/providers/providers_list/data/services/providers_list_mock_service.dart';
import 'package:waqty_user_application/features/providers/providers_list/data/services/providers_list_remote_service.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/repo/service_provider_details_repo.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_mock_service.dart';
import 'package:waqty_user_application/features/service_provider_details/service_provider_details/data/services/service_provider_details_remote_service.dart';

import 'package:http_interceptor/http_interceptor.dart';

import '../api/api_client.dart';
import '../api/api_consumer.dart';
import '../api/app_interceptor.dart';
import '../api/http_consumer.dart';
import '../api/session_store.dart';
import 'package:waqty_user_application/features/booking/my_bookings/data/repo/my_bookings_repo.dart';
import 'package:waqty_user_application/features/booking/my_bookings/data/services/my_bookings_mock_service.dart';
import 'package:waqty_user_application/features/booking/my_bookings/data/services/my_bookings_remote_service.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/repo/booking_details_repo.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/services/booking_details_mock_service.dart';
import 'package:waqty_user_application/features/booking/booking_details/data/services/booking_details_remote_service.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/repo/create_booking_repo.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/services/create_booking_mock_service.dart';
import 'package:waqty_user_application/features/booking/create_booking/data/services/create_booking_remote_service.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/repo/reassignment_repo.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/services/reassignment_mock_service.dart';
import 'package:waqty_user_application/features/booking/reassignment/data/services/reassignment_remote_service.dart';
import 'package:waqty_user_application/features/booking/waitlist/data/repo/waitlist_repo.dart';
import 'package:waqty_user_application/features/booking/waitlist/data/services/waitlist_mock_service.dart';
import 'package:waqty_user_application/features/booking/waitlist/data/services/waitlist_remote_service.dart';
import 'package:waqty_user_application/features/account/account/data/repo/account_repo.dart';
import 'package:waqty_user_application/features/account/account/data/services/account_mock_service.dart';
import 'package:waqty_user_application/features/account/account/data/services/account_remote_service.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/repo/entitlements_repo.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_mock_service.dart';
import 'package:waqty_user_application/features/entitlements/entitlements/data/services/entitlements_remote_service.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/repo/phone_verification_repo.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/services/phone_verification_mock_service.dart';
import 'package:waqty_user_application/features/account/phone_verification/data/services/phone_verification_remote_service.dart';
import 'package:waqty_user_application/features/account/payments/data/repo/payments_repo.dart';
import 'package:waqty_user_application/features/account/payments/data/services/payments_mock_service.dart';
import 'package:waqty_user_application/features/account/payments/data/services/payments_remote_service.dart';
import 'package:waqty_user_application/features/splash/data/repo/app_gate_repo.dart';
import 'package:waqty_user_application/features/splash/data/services/app_gate_mock_service.dart';
import 'package:waqty_user_application/features/splash/data/services/app_gate_remote_service.dart';
import 'package:waqty_user_application/features/booking/in_branch/data/repo/in_branch_repo.dart';
import 'package:waqty_user_application/features/booking/in_branch/data/services/in_branch_mock_service.dart';
import 'package:waqty_user_application/features/booking/in_branch/data/services/in_branch_remote_service.dart';

final getIt = GetIt.instance;

class ServicesLocator {
  static Future<void> init() async {
    /// Register
    getIt.registerLazySingleton<RegisterRepo>(() => RegisterRepo(getIt()));
    getIt.registerLazySingleton<RegisterService>(
      () => RegisterService(apiConsumer: getIt()),
    );

    /// Login
    getIt.registerLazySingleton<LoginRepo>(() => LoginRepo(getIt()));
    getIt.registerLazySingleton<LoginService>(
      () => LoginService(apiConsumer: getIt()),
    );

    /// ForgetPassword
    getIt.registerLazySingleton<ForgetPasswordRepo>(
      () => ForgetPasswordRepo(getIt()),
    );
    getIt.registerLazySingleton<ForgetPasswordService>(
      () => ForgetPasswordService(apiConsumer: getIt()),
    );

    /// ForgetVerifyCode
    getIt.registerLazySingleton<ForgetVerifyCodeRepo>(
      () => ForgetVerifyCodeRepo(getIt()),
    );
    getIt.registerLazySingleton<ForgetVerifyCodeService>(
      () => ForgetVerifyCodeService(apiConsumer: getIt()),
    );

    /// RegisterVerifyCode
    getIt.registerLazySingleton<RegisterVerifyCodeRepo>(
      () => RegisterVerifyCodeRepo(getIt()),
    );
    getIt.registerLazySingleton<RegisterVerifyCodeService>(
      () => RegisterVerifyCodeService(apiConsumer: getIt()),
    );

    /// ReseatPassword
    getIt.registerLazySingleton<ReseatPasswordRepo>(
      () => ReseatPasswordRepo(getIt()),
    );
    getIt.registerLazySingleton<ReseatPasswordService>(
      () => ReseatPasswordService(apiConsumer: getIt()),
    );

    /// Home
    getIt.registerLazySingleton<HomeRepo>(
      () => HomeRepo(
        HomeRemoteService(getIt<ApiClient>()),
        const HomeMockService(),
      ),
    );

    /// ProvidersList
    getIt.registerLazySingleton<ProvidersListRepo>(
      () => ProvidersListRepo(
        ProvidersListRemoteService(getIt<ApiClient>()),
        const ProvidersListMockService(),
      ),
    );

    /// CreateBooking
    ///
    /// ⚠ **`registerFactory` مش `registerLazySingleton`.** الـrepo ده شايل كاش
    /// مواعيد، والمواعيد بتبوظ بسرعة. singleton معناه إن عميل
    /// فتح الويزارد الصبح وفتحه تاني بالليل بيشوف مواعيد اتحجزت خلاص.
    getIt.registerFactory<CreateBookingRepo>(
      () => CreateBookingRepo(
        CreateBookingRemoteService(getIt<ApiClient>()),
        const CreateBookingMockService(),
      ),
    );

    /// AppGate
    getIt.registerLazySingleton<AppGateRepo>(
      () => AppGateRepo(
        AppGateRemoteService(getIt<ApiClient>()),
        const AppGateMockService(),
      ),
    );

    /// Account
    getIt.registerLazySingleton<AccountRepo>(
      () => AccountRepo(
        AccountRemoteService(getIt<ApiClient>()),
        const AccountMockService(),
      ),
    );

    /// Entitlements
    ///
    /// `registerLazySingleton` زي `WaitlistRepo` — الاستحقاقات بتتغيّر
    /// نادرًا (شرا من الفرع أو خدمة تخلص)، فمفيش سبب لكاش قصير.
    getIt.registerLazySingleton<EntitlementsRepo>(
      () => EntitlementsRepo(
        EntitlementsRemoteService(getIt<ApiClient>()),
        const EntitlementsMockService(),
      ),
    );

    /// PhoneVerification
    getIt.registerLazySingleton<PhoneVerificationRepo>(
      () => PhoneVerificationRepo(
        PhoneVerificationRemoteService(getIt<ApiClient>()),
        const PhoneVerificationMockService(),
      ),
    );

    /// Payments
    getIt.registerLazySingleton<PaymentsRepo>(
      () => PaymentsRepo(
        PaymentsRemoteService(getIt<ApiClient>()),
        const PaymentsMockService(),
      ),
    );

    /// InBranch
    getIt.registerLazySingleton<InBranchRepo>(
      () => InBranchRepo(
        InBranchRemoteService(getIt<ApiClient>()),
        const InBranchMockService(),
      ),
    );

    /// Waitlist
    getIt.registerLazySingleton<WaitlistRepo>(
      () => WaitlistRepo(
        WaitlistRemoteService(getIt<ApiClient>()),
        const WaitlistMockService(),
      ),
    );

    /// Reassignment
    getIt.registerLazySingleton<ReassignmentRepo>(
      () => ReassignmentRepo(
        ReassignmentRemoteService(getIt<ApiClient>()),
        const ReassignmentMockService(),
      ),
    );

    /// MyBookings
    getIt.registerLazySingleton<MyBookingsRepo>(
      () => MyBookingsRepo(
        MyBookingsRemoteService(getIt<ApiClient>()),
        const MyBookingsMockService(),
      ),
    );

    /// BookingDetails
    getIt.registerLazySingleton<BookingDetailsRepo>(
      () => BookingDetailsRepo(
        BookingDetailsRemoteService(getIt<ApiClient>()),
        const BookingDetailsMockService(),
      ),
    );

    /// ServiceProviderDetails
    getIt.registerLazySingleton<ServiceProviderDetailsRepo>(
      () => ServiceProviderDetailsRepo(
        ServiceProviderDetailsRemoteService(getIt<ApiClient>()),
        const ServiceProviderDetailsMockService(),
      ),
    );

    // التعليق القديم: Home اتشال من هنا — الشاشة بقت شغالة على طبقة الـ mock لحد ما
    // الربط يتعمل، والـ repo/service كانوا فاضيين (كلهم كومنت) فوجودهم
    // في الـ DI كان بيوحي إن في ربط وهو مفيش.

    // /// RegisterOtp
    // getIt.registerLazySingleton<SenderRegisterOtpRepo>(
    //   () => SenderRegisterOtpRepo(getIt()),
    // );
    // getIt.registerFactory<SenderRegisterOtpService>(
    //   () => SenderRegisterOtpService(apiConsumer: getIt()),
    // );

    ///core

    // ⚠ الترتيب مهم: الجلسة قبل الـinterceptor لأنه بيقرا منها التوكن،
    // والـinterceptor قبل الـclient.
    // ⚠ **مفيش `hydrate()` هنا.** `SessionStore` بيقرا من `CacheHelper`،
    // و`CacheHelper._secureStorage` حقل `late` بيتعيّن في `CacheHelper.init()`
    // اللي بتتنادى **بعد** الدالة دي في `main()`. الترطيب هنا كان
    // بيرمي `LateInitializationError` قبل `runApp` — الأبلكيشن كان بيقعد
    // رمادي ويطلع ANR. الترطيب مكانه `main()` بعد `CacheHelper.init()`.
    getIt.registerLazySingleton<SessionStore>(() => SessionStore());

    getIt.registerLazySingleton<AppInterceptor>(
      () => AppInterceptor(getIt<SessionStore>()),
    );

    // الـ`InterceptedClient` بيتبنى **هنا** وبيتحقن في `HttpConsumer`.
    // قبل كده كان بيتبنى جوّه الكونستركتور وبيدوس على الـclient
    // المحقون، فمكنش فيه طريقة تخلي اختبار يحط `MockClient` مكانه.
    getIt.registerLazySingleton<http.Client>(
      () => InterceptedClient.build(interceptors: [getIt<AppInterceptor>()]),
    );

    getIt.registerLazySingleton<ApiConsumer>(
      () => HttpConsumer(getIt<http.Client>()),
    );

    getIt.registerLazySingleton<ApiClient>(
      () => ApiClient(getIt<ApiConsumer>(), getIt<SessionStore>()),
    );

    ///shared secure
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    getIt.registerLazySingleton(() => secureStorage);
  }
}
