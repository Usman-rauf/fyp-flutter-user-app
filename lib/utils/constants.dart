const appName = "Plant Shop";
const appDesc = "Plant Admin";

const baseUrl =
    'http://localhost/wordpress'; //NOTE: Do not end base url with Slash (/)
const mDomainUrl = '$baseUrl/wp-json/';
const ConsumerKey = 'ck_e5e195c65ba735ce9e3ed2c427907c356f772606';
const ConsumerSecret = 'cs_7f590cfea935c8de254afd668545d2e4c9975d88';

class PaymentKeys {
  final String razorKey = "YOUR_RAZOR_KEY";
  final String payStackPublicKey = 'PAY_STACK_PUBLIC_KEY';
  final String razorPayDescription = "Woocommerce Store";
}

const BANNER_AD_ID_ANDROID = "ca-app-pub-1399327544318575/4470508727";
const BANNER_AD_ID_IOS = "ca-app-pub-1399327544318575/3368345890";
const INTERSTITIAL_AD_ID_ANDROID = "ca-app-pub-1399327544318575/5592018700";
const INTERSTITIAL_AD_ID_IOS = "ca-app-pub-1399327544318575/8792897113";

const ENABLE_ADS = true;

const IS_RAZORPAY = true;
const IS_PAY_STACK = true;

const PAYMENT_METHOD_NATIVE = "native";

bool ENABLE_APPLE_LOGIN = true;
PaymentKeys paymentKeys = PaymentKeys();

class DefaultValues {
  final String defaultLanguage = "en";
}

DefaultValues defaultValues = DefaultValues();

const LoginTypeApp = 'app';
const LoginTypeGoogle = 'google';
const LoginTypeOTP = 'otp';
const LoginTypeApple = 'apple';

const COMPLETED = "completed";
const REFUNDED = "refunded";
const CANCELED = "cancelled";
const TRASH = "trash";
const FAILED = "failed";
const SUCCESS = 'Success';

class SharedPref {
  final String selectedLanguage = "selectedLanguage";
  final String isRemember = "IsRemember";
  final String isFirstTime = "isFirstTime";
  final String appThemeMode = "appThemeMode";

  ///User
  final String userPassword = "userPassword";
  final String userPhotoUrl = "userPhotoUrl";
  final String userId = "userId";
  final String isLoggedIn = "isLoggedIn";
  final String firstName = "firstName";
  final String lastName = "lastName";
  final String userEmail = "userEmail";
  final String userName = "userName";
  final String apiToken = "apiToken";
  final String wishlistData = "wishlistData";
  final String cartItemList = "cartItemList";
  final String billingAddress = "billingAddress";
  final String shippingAddress = "shippingAddress";

  final String contact = "contact";
  final String copyrightText = "copyrightText";
  final String facebook = "facebook";
  final String instagram = "instagram";
  final String privacyPolicy = "privacyPolicy";
  final String refundPolicy = "refundPolicy";
  final String shippingPolicy = "shippingPolicy";
  final String termCondition = "termCondition";
  final String twitter = "twitter";
  final String websiteUrl = "websiteUrl";
  final String whatsapp = "whatsapp";
  final String appLang = "appLang";
  final String currencySymbol = "currencySymbol";
  final String enableCustomDashboard = "enableCustomDashboard";
  final String paymentMethod = "paymentMethod";

  final String isSocial="isSocial";
}

SharedPref sharedPref = SharedPref();
const cartUpdate = "cartUpdate";
const wishListUpdate = "wishListUpdate";

class AppThemeMode {
  final int themeModeLight = 1;
  final int themeModeDark = 2;
  final int themeModeSystem = 0;
}

const VideoTypeCustom = 'custom_url';
const VideoTypeYouTube = 'youtube';
const VideoTypeIFrame = 'iframe';

const WISHLIST_ITEM_LIST = 'WISHLIST_ITEM_LIST';
const CART_ITEM_LIST = 'CART_ITEM_LIST';

AppThemeMode appThemeMode = AppThemeMode();
const DASHBOARD_ITEMS = 6;
const appBarTextSize = 22;
