import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static LanguageController lc = Get.find();
  SharedPreferences? preferences;
  RxBool isEnglish = true.obs;

  RxString sigIn = ''.obs;
  RxString signUp = ''.obs;
  RxString login = ''.obs;
  RxString loginNeeded = ''.obs;
  RxString signInOrSignup = ''.obs;
  RxString mobileNumber = ''.obs;
  RxString password = ''.obs;
  RxString forgotPassword = ''.obs;
  RxString name = ''.obs;
  RxString male = ''.obs;
  RxString female = ''.obs;
  RxString other = ''.obs;
  RxString greatNext = ''.obs;
  RxString category = ''.obs;
  RxString logOut = ''.obs;
  RxString profile = ''.obs;

  RxString setting = ''.obs;
  RxString receive_by_mail = ''.obs;
  RxString receive_by_push_notification = ''.obs;
  RxString language = ''.obs;
  RxString languageType = ''.obs;
  RxString change = ''.obs;

  RxString search = ''.obs;
  RxString onDemandService = ''.obs;
  RxString onDemandServiceSetup = ''.obs;
  RxString longTimeService = ''.obs;
  RxString longTimeServiceSetup = ''.obs;
  RxString personalDetails = ''.obs;

  // menu
  RxString orderHistory = ''.obs;
  RxString lovedOnes = ''.obs;
  RxString coupons = ''.obs;
  RxString helpCenter = ''.obs;
  RxString help = ''.obs;

  RxString seeAll = ''.obs;
  RxString offerNews = ''.obs;

  RxString goodMorning = ''.obs;
  RxString goodNoon = ''.obs;
  RxString goodAfterNoon = ''.obs;
  RxString goodEv = ''.obs;
  RxString goodNight = ''.obs;
  RxString mobileSignup = ''.obs;
  RxString or = ''.obs;
  RxString comingSoon = ''.obs;
  RxString google = ''.obs;
  RxString facebook = ''.obs;
  RxString apple = ''.obs;
  RxString termsPrefix = ''.obs;
  RxString terms = ''.obs;
  RxString go = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  void initializeData() async {
    preferences = await SharedPreferences.getInstance();
    isEnglish.value = preferences!.getBool('isEnglish') ?? true;
    changeVariables();
    update();
  }

  void changeLanguage(bool val) {
    isEnglish(val);
    changeVariables();
    update();
    preferences!.setBool('isEnglish', val);
  }

  void changeVariables() {
    mobileSignup(isEnglish.value
        ? "Sign up with Phone Number"
        : "মোবাইল নাম্বার দিয়ে নিবন্ধন");
    comingSoon(isEnglish.value ? "Coming soon..." : "শীঘ্রই আসছে...");
    google(isEnglish.value ? "Continue with Google" : "গুগল লগইন করুন");
    facebook(isEnglish.value ? "Continue with Facebook" : "ফেসবুক লগইন করুন");
    apple(isEnglish.value ? "Continue with Apple" : "অ্যাপল লগইন করুন");
    termsPrefix(isEnglish.value
        ? "By sign up or Login I agree to the all"
        : "সাইন আপ বা লগইন করে সম্মতি জানাচ্ছি");
    terms(isEnglish.value ? "Terms & conditions " : "টার্ম ও কন্ডিশন ");
    go(isEnglish.value ? "Go" : "চলুন");
    sigIn(isEnglish.value ? 'Login' : 'সাইন ইন');
    signUp(isEnglish.value ? 'Sign Up' : 'সাইন আপ');
    or(isEnglish.value ? "Or" : "অথবা");
    signInOrSignup(isEnglish.value ? "Sign up or" : "সাইন আপ অথবা");
    login(isEnglish.value ? "Login" : "লগইন");
    loginNeeded(isEnglish.value
        ? "You must login to place an order"
        : "অর্ডার করতে লগইন করুন");
    mobileNumber(isEnglish.value ? 'Mobile Number*' : 'মোবাইল নম্বর*');
    password(isEnglish.value ? 'password*' : 'পাসওয়ার্ড*');
    forgotPassword(
        isEnglish.value ? 'Forgot Password?' : 'পাসওয়ার্ড ভুলে গেছেন?');
    name(isEnglish.value ? 'Name*' : 'নাম*');
    male(isEnglish.value ? 'Male' : 'পুরুষ');
    female(isEnglish.value ? 'Female' : 'মহিলা');
    other(isEnglish.value ? 'Others' : 'অন্যান্য');
    greatNext(isEnglish.value ? 'Great! Next' : 'মহান! পরবর্তী');
    category(isEnglish.value ? 'Category' : 'বিভাগ');
    logOut(isEnglish.value ? 'Log Out' : 'প্রস্থান');
    search(isEnglish.value ? 'Search..' : 'অনুসন্ধান করুন');
    profile(isEnglish.value ? 'Profile' : 'প্রোফাইল');
    personalDetails(isEnglish.value ? "Personal Details" : "ব্যক্তিগত বিবরণ");

    onDemandService(isEnglish.value
        ? 'Get Now Or Schedule your service'
        : 'চাহিদা অনুযায়ী সেবা');
    onDemandServiceSetup(isEnglish.value
        ? 'On Demand Service Setup'
        : 'চাহিদা অনুযায়ী সেবা সেটআপ');
    // longTimeService(isEnglish.value?'Long Time Service': 'দীর্ঘ সময়ের পরিষেবা');
    longTimeService(isEnglish.value
        ? 'Personalized Care Package '
        : 'দীর্ঘ সময়ের পরিষেবা');
    longTimeServiceSetup(isEnglish.value
        ? 'Long Time Service Setup'
        : 'দীর্ঘ সময়ের পরিষেবা সেটআপ');

    //Setting
    setting(isEnglish.value ? 'Settings' : 'সেটিংস');
    receive_by_mail(
        isEnglish.value ? 'Receive offers by mail' : 'মেইলের মাধ্যমে অফার পান');
    receive_by_push_notification(isEnglish.value
        ? 'Receive push notifications'
        : 'নোটিফিকেশন মাধ্যমে অফার পান');
    language(isEnglish.value ? 'Language' : 'ভাষা');
    languageType(isEnglish.value ? 'English' : 'বাংলা');
    change(isEnglish.value ? 'Change' : 'পরিবর্তন');

    //Menu
    orderHistory(isEnglish.value ? 'Order History' : 'অর্ডার ইতিহাস');
    lovedOnes(isEnglish.value ? 'Loved One\'s' : 'প্রিয়জনের');
    coupons(isEnglish.value ? 'Coupons' : 'কুপন');
    helpCenter(isEnglish.value ? 'Help Center' : 'সাহায্য কেন্দ্র');
    help(isEnglish.value ? 'Help ' : 'সাহায্য ');

    seeAll(isEnglish.value ? 'View All' : 'সবগুলো দেখুন');
    offerNews(isEnglish.value ? 'Offers & News' : 'অফার এবং খবর');

    goodMorning(isEnglish.value ? 'Good Morning!' : 'সুপ্রভাত!');
    goodNoon(isEnglish.value ? 'Good Noon!' : 'শুভ মধ্যাহ্ন!');
    goodAfterNoon(isEnglish.value ? 'Good Afternoon!' : 'শুভ অপরাহ্ন!');
    goodEv(isEnglish.value ? 'Good Evening!' : 'শুভ সন্ধ্যা!');
    goodNight(isEnglish.value ? 'Good Night!' : 'শুভ রাত্রি!');
  }
}
