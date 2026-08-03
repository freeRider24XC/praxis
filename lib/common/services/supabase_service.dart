import 'package:praxis/common/services/app_runtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _initialized = false;

  static bool get isEnabled => AppRuntimeService.isSupabaseConfigured;

  static Future<void> init() async {
    if (_initialized || !isEnabled) {
      return;
    }

    await Supabase.initialize(
      url: AppRuntimeService.supabaseUrl,
      publishableKey: AppRuntimeService.supabaseAnonKey,
    );
    _initialized = true;
  }

  static SupabaseClient? get client =>
      isEnabled && _initialized ? Supabase.instance.client : null;
}
