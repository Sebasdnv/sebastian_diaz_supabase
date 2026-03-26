import 'package:flutter/foundation.dart';
import 'package:sebastian_diaz_supabase/core/profile_service.dart';
import 'package:sebastian_diaz_supabase/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final SupabaseClient _client = Supabase.instance.client;

  UserProfile? profile;
  bool isLoading = false;

  Future<void> loadUserProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      profile = await _profileService.fetchUserProfile();
    } catch (e) {
      print("errore caricamento profilo $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createUserProfile(String username, DateTime birthdate) async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return;

    final newProfile = UserProfile(
      id: id,
      username: username,
      birthdate: birthdate,
      avatarUrl: null,
    );

    try {
      await _profileService.createUserProfile(newProfile);
      profile = newProfile;
    } catch (e) {
      print('errore nella creazione del profilo utente $e');
    }
    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile updateUserProfile) async{
    try {
      await _profileService.updateUserProfile(updateUserProfile);
    profile = updateUserProfile;
    } catch (e) {
      print("errore aggiornamento profilo utente $e");
    }
    notifyListeners();
  }
}
