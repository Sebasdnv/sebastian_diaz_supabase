import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  final SupabaseClient _client = Supabase.instance.client;

  //* registrazione
  Future<AuthResponse> signUp(String email, String password) async{
    return await _client.auth.signUp(email: email, password: password);
  }

  //* login
  Future<AuthResponse> signIn(String email, String password) async{
    return await _client.auth.signInWithPassword(email: email ,password: password);
  }

  //*logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Session? get currentSession => _client.auth.currentSession;
}