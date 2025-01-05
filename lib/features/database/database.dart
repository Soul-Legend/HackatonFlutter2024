import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Database {
  static Database? _instance;
  static SupabaseClient? supabase;
  Map<String, dynamic>? _currentUserData;

  factory Database() {
    return _instance ??= Database._();
  }

  Database._();

  // Retorna os dados do usuário logado, se necessário obtem o perfil para isso
  Map<String, dynamic>? getCurrentUserData()  {
    return _currentUserData;
  }

  Future<void> loadCurrentUserData() async {
    _currentUserData = await getUserProfile(getCurrentUser()!.id);
  }

  Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    supabase = Supabase.instance.client;
    if (getIsUserLoggedIn()) {
      await loadCurrentUserData();
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return await supabase!.from('profiles').select().eq('id', userId).single();
  }

  User? getCurrentUser() {
    return supabase!.auth.currentUser;
  }

  Future<void> updateCurrentUserProfile(Map<dynamic, dynamic> updates) async {
    updates.addEntries({'id': getCurrentUser()!.id}.entries);
    await supabase!.from('profiles').upsert(updates);
    await loadCurrentUserData();
  }

  Future<void> signOut() async {
    await supabase!.auth.signOut();
  }

  Future<String> updateAvatar(String filePath, Uint8List bytes, String? mimeType) async {
    await supabase!.storage.from('avatars').uploadBinary(
      filePath,
      bytes,
      fileOptions: FileOptions(contentType: mimeType),
    );
    return await supabase!.storage
        .from('avatars')
        .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
  }

  bool getIsUserLoggedIn() {
    if (supabase == null) {
      return false;
    }
    return supabase!.auth.currentSession != null;
  }

  Future<List<Map<String, dynamic>>> searchForUser(String userInput) async {
    return await supabase!
        .from('profiles')
        .select()
        .ilike('full_name', '%$userInput%');
  }

  Future<void> signInUser(String email, String password) async {
    await supabase!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpUser(String email, String password, String fullName, String cpf) async {
    return await supabase!.auth.signUp(
                email: email,
                password: password,
                emailRedirectTo:
                    'io.supabase.flutterquickstart://login-callback/',
                data: {
                  'full_name': fullName,
                  'cpf': cpf,
                  'email_login': email,
                },);
  }

  StreamSubscription<AuthState> listenToAuthChange(void Function(AuthState)? onDataFunc, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return supabase!.auth.onAuthStateChange.listen(
      onDataFunc,
      onError: onError,
    );
  }
}
