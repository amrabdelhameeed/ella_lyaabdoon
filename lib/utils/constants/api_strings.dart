class ApiStrings {
  // static const String baseUrlForImage = 'https://lavie.orangedigitalcenteregypt.com';
  // static const String baseUrl = 'https://lavie.orangedigitalcenteregypt.com/api/v1/';
  // static const String baseUrl = "your_base_url_here";
  static const String getPaymentData = "/api/Package/GetPaymentData";
  static const String getOptofolioPaymentData = "/api/Package/GetOptofolioPaymentData";
  static const String addPaymentData = "/api/Package/AddPaymentData";
  static const String afBaseUrl = 'http://arabfinance.com:6060';
  static const String login = 'auth/signin';
  static const String signUp = 'auth/signup';
  static const String logout = 'logout';
  static const String profile = 'user/me';
  static const String forgetPassword = 'auth/forget-password';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String products = 'products';
  static const String blogs = 'products/blogs';
  static const String forums = 'forums';
  static const String forumsMe = 'forums/me';
  static const String fantasyaGameUrl = "http://arabfinance.com:6080/api";

  /////////////
  static const String homeData = 'home';
  static const String address = 'addresses';

  static const String cart = 'carts';
  static const String order = 'orders';

  static const String favorites = 'favorites';

  // stocks
  static const String getAllStocks = "api/DelayedFeed/GetAllMarketWatch";

  static const String serviceUrl = "https://thecontrato.com/api/Appointment";
  static const String serviceHeaderValue = "9388be5e2ed2e67e50ae73cadacf72sadaqwcb6435719cedfa0cd06a0ceb37a49d97976";
}

class ApiErrors {
  static const String badRequestError = "badRequestError";
  static const String noContent = "noContent";
  static const String forbiddenError = "forbiddenError";
  static const String unauthorizedError = "unauthorizedError";
  static const String notFoundError = "notFoundError";
  static const String conflictError = "conflictError";
  static const String internalServerError = "internalServerError";
  static const String unknownError = "unknownError";
  static const String timeoutError = "timeoutError";
  static const String defaultError = "defaultError";
  static const String cacheError = "cacheError";
  static const String noInternetError = "noInternetError";
  static const String loadingMessage = "loading_message";
  static const String retryAgainMessage = "retry_again_message";
  static const String ok = "Ok";
}
