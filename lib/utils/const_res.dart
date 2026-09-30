class ConstRes {
  /// Backend configuration. Values are supplied at build time with --dart-define.
  static const String base = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8787/',
  );
  static const String aBaseUrl = '${base}api/';
  static const String aImageBaseUrl = '${base}public/storage/';

  /// Kept only for source compatibility. The Cloudflare backend uses Bearer sessions.
  static const String apiKey = '';

  /// Agora App ID is public. Customer ID/secret and App Certificate stay on Cloudflare.
  static const String agoraAppId = String.fromEnvironment('AGORA_APP_ID', defaultValue: '');
  static const String customerId = '';
  static const String customerSecret = '';

  /// RevenueCat public SDK keys. The RevenueCat secret key stays on Cloudflare.
  static const String revenueCatAndroidApiKey = String.fromEnvironment('REVENUECAT_ANDROID_PUBLIC_KEY', defaultValue: '');
  static const String revenueCatAppleApiKey = String.fromEnvironment('REVENUECAT_IOS_PUBLIC_KEY', defaultValue: '');
}
