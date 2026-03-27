import 'dart:io';
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

  Future<void> createUserProfile(String username, DateTime birthdate, {String? avatarUrl}) async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return;

    String? finalUrl = avatarUrl;
    if (avatarUrl != null && !avatarUrl.startsWith('http')) {
      try {
        final file = File(avatarUrl);
        final fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'avatars/$fileName';
        await _client.storage.from('media').upload(path, file);
        finalUrl = _client.storage.from('media').getPublicUrl(path);
      } catch (e) {
        print("errore upload $e");
      }
    }

    final newProfile = UserProfile(
      id: id,
      username: username,
      birthdate: birthdate,
      avatarUrl: finalUrl,
    );

    try {
      await _profileService.createUserProfile(newProfile);
      profile = newProfile;
    } catch (e) {
      print('errore nella creazione del profilo utente $e');
    }
    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    String? finalUrl = userProfile.avatarUrl;
    if (finalUrl != null && !finalUrl.startsWith('http')) {
      try {
        final file = File(finalUrl);
        final fileName = '${userProfile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'avatars/$fileName';
        await _client.storage.from('media').upload(path, file);
        finalUrl = _client.storage.from('media').getPublicUrl(path);
      } catch (e) {
        print("errore upload $e");
      }
    }

    final profileToSave = UserProfile(
      id: userProfile.id,
      username: userProfile.username,
      birthdate: userProfile.birthdate,
      avatarUrl: finalUrl,
    );

    try {
      await _profileService.updateUserProfile(profileToSave);
      profile = profileToSave;
    } catch (e) {
      print("errore aggiornamento profilo utente $e");
    }
    notifyListeners();
  }
}