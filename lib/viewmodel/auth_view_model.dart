import 'package:flutter/material.dart';
import 'package:sebastian_diaz_supabase/core/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier{
  final AuthService _authService = AuthService();

  bool isLoading = false;
  Session? session;

  AuthViewModel(){session = _authService.currentSession;}

  //* metodo login
  Future<void> login(String email, String password) async{
    isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.signIn(email, password);
      session = response.session;
    } catch (e) {
      print("errore login $e");
    }

    isLoading = false;
    notifyListeners();
  }

  //* metodo registrazione
  Future<void> register(String email, String password) async{
    isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.signUp(email, password);
      session = response.session;
    } catch (e) {
      print("errore in registrazione $e");
    }

    isLoading = false;
    notifyListeners();
  }
}