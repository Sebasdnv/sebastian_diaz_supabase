import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sebastian_diaz_supabase/core/supabase_client_manager.dart';
import 'package:sebastian_diaz_supabase/viewmodel/auth_view_model.dart';
import 'package:sebastian_diaz_supabase/viewmodel/book_view_model.dart';
import 'package:sebastian_diaz_supabase/viewmodel/explore_view_model.dart';
import 'package:sebastian_diaz_supabase/viewmodel/profile_view_model.dart';
import 'package:sebastian_diaz_supabase/views/auth/login_view.dart';
import 'package:sebastian_diaz_supabase/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseClientManager.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_)=> BookViewModel()),
        ChangeNotifierProvider(create: (_) => ExploreViewModel())
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.lightGreen,
                brightness: Brightness.dark,
              ),
            ),
            home: auth.session != null ? const HomeView() : LoginView(),
          );
        },
      ),
    );
  }
}

