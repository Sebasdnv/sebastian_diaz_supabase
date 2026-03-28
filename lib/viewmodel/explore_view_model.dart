import 'package:flutter/material.dart';
import 'package:sebastian_diaz_supabase/core/book_service.dart';
import 'package:sebastian_diaz_supabase/models/book_model.dart';

class ExploreViewModel extends ChangeNotifier {
  final BookService _bookService = BookService();
  
  List<Book> allBooks = [];
  bool isLoading = false;

  Future<void> fetchAllBooks() async {
    isLoading = true;
    notifyListeners();

    try {
      allBooks = await _bookService.fetchBooks();
    } catch (e) {
      print("Errore nel caricamento globale: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}