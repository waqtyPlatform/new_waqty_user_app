abstract class SplashState {}

class InitialState extends SplashState {}

class SplashLoadingState extends SplashState {}

/// معاه توكن — يروح على التبويبات على طول.
class GoToHomeState extends SplashState {}

/// مفيش توكن — يروح على تسجيل الدخول، مش التسجيل الجديد.
/// بعد أول أسبوع، اللي بيرجعوا أكتر من اللي بيسجلوا لأول مرة.
class GoToLoginState extends SplashState {}
