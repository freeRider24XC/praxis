import 'package:praxis/common/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static bool get isEnabled => SupabaseService.isEnabled;

  static User? get currentUser => SupabaseService.client?.auth.currentUser;

  static String? get currentUserId => currentUser?.id;

  static Stream<AuthState>? get authStateChanges =>
      SupabaseService.client?.auth.onAuthStateChange;

  static bool get isSignedIn => currentUser != null;

  static Future<void> signInWithMagicLink(String email) async {
    final client = SupabaseService.client;
    if (client == null) {
      throw StateError('Supabase is not configured');
    }

    await client.auth.signInWithOtp(email: email);
  }

  static Future<void> signOut() async {
    final client = SupabaseService.client;
    if (client == null) {
      return;
    }
    await client.auth.signOut();
  }
}
