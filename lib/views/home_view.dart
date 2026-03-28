import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sebastian_diaz_supabase/viewmodel/auth_view_model.dart';
import 'package:sebastian_diaz_supabase/views/add_book_view.dart';
import 'package:sebastian_diaz_supabase/views/all_books_view.dart'; // <--- Assicurati di averla creata
import 'package:sebastian_diaz_supabase/views/auth/login_view.dart';
import 'package:sebastian_diaz_supabase/views/widgets/bottom_nav_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home View"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await vm.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllBooksView()),
                );
              },
              icon: const Icon(Icons.explore),
              label: const Text("Esplora tutti i libri"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
            
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddBookView()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Aggiungi un libro"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}