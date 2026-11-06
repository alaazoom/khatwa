abstract final class AppConfig {
  /// يُمرَّر عند البناء: flutter run --dart-define=API_BASE_URL=https://your-api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/v1',
  );
  static const Duration requestTimeout = Duration(seconds: 15);

  // ---------- Cloudinary ----------
  static const String cloudinaryCloudName = 'mg0fwvdy';
  static const String cloudinaryUploadPreset = 'ajyal_unsigned';
  static const Duration uploadTimeout = Duration(seconds: 60);
}