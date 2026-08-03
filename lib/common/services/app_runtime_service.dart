class AppRuntimeService {
  static const String deploymentStage =
      String.fromEnvironment('PRAXIS_STAGE', defaultValue: 'local');
  static const String supabaseUrl =
      String.fromEnvironment('PRAXIS_SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('PRAXIS_SUPABASE_ANON_KEY', defaultValue: '');
  static const String managedAiBaseUrl =
      String.fromEnvironment('PRAXIS_AI_API_BASE_URL', defaultValue: '');
  static const String managedAiToken =
      String.fromEnvironment('PRAXIS_AI_API_TOKEN', defaultValue: '');
  static const bool requireCloudAuth = bool.fromEnvironment(
    'PRAXIS_REQUIRE_CLOUD_AUTH',
    defaultValue: false,
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isManagedAiConfigured => managedAiBaseUrl.isNotEmpty;
}
