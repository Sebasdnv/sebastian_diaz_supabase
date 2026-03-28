import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sebastian_diaz_supabase/core/book_image_service.dart';
import 'package:sebastian_diaz_supabase/core/storage_service.dart';
import 'package:sebastian_diaz_supabase/models/book_image.dart';
import 'package:sebastian_diaz_supabase/models/book_model.dart';
import 'package:sebastian_diaz_supabase/viewmodel/book_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

String _statusLabel(BookStatus status) {
  switch (status) {
    case BookStatus.nonLetto:
      return 'non letto';
    case BookStatus.inLettura:
      return 'in lettura';
    case BookStatus.daLeggere:
      return 'da leggere';
    case BookStatus.lasciato:
      return 'lasciato';
    case BookStatus.nonInteressa:
      return 'non interessa';
  }
}

class AddBookView extends StatefulWidget {
  const AddBookView({super.key});

  @override
  State<AddBookView> createState() => _AddBookViewState();
}

class _AddBookViewState extends State<AddBookView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _pagesController = TextEditingController();
  BookStatus? _selectedStatus;
  double _rating = 3.0;
  final _commentController = TextEditingController();
  List<File> _selectedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedStatus != null) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Utente non autenticato')));
        return;
      }

      final newBook = Book(
        id: const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        genre: _genreController.text.trim(),
        author: _authorController.text.trim(),
        pages: int.tryParse(_pagesController.text.trim()) ?? 0,
        rating: _rating.toInt(),
        comment: _commentController.text.trim(),
        status: _selectedStatus!,
        createdAt: DateTime.now(),
      );

      try {
        await Provider.of<BookViewModel>(
          context,
          listen: false,
        ).addBook(newBook);

        if (_selectedImages.isNotEmpty) {
          final storageService = StorageService();
          final imageService = BookImageService();
          for (final imageFile in _selectedImages) {
            final imageUrl = await storageService.uploadImage(
              imageFile,
              newBook.id,
            );

            final bookImage = BookImage(
              id: const Uuid().v4(),
              bookId: newBook.id,
              imageUrl: imageUrl,
            );

            await imageService.createBookImage(bookImage);
          }
        }

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Dati validi possiamo andare avanti")),
          );
        }
      } catch (e) {
        print("Errore nel salvataggio del libro: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore nel salvataggio del libro")),
        );
      }
    }
  }

  //* metodo caricamento immagini
  Future<void> _pickMultipleImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedImages = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form ins Libro"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titolo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Campo obbligatorio'
                      : null,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _authorController,
                  decoration: InputDecoration(
                    labelText: 'Nome autore',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Campo obbligatorio'
                      : null,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _genreController,
                  decoration: InputDecoration(
                    labelText: 'Genere',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _pagesController,
                  decoration: InputDecoration(
                    labelText: 'Numero di pagine',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final pages = int.tryParse(value);
                    if (pages == null || pages <= 0)
                      return 'inserisci numero valido';
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Stato di lettura',
                    border: OutlineInputBorder(),
                  ),
                  items: BookStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_statusLabel(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Seleziona uno stato di lettura' : null,
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valutazione',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          min: 1,
                          max: 5,
                          divisions: 4,
                          value: _rating,
                          onChanged: (value) {
                            setState(() {
                              _rating = value;
                            });
                          },
                        ),
                      ),
                      Text("${_rating.toStringAsFixed(0)} ⭐"),
                    ],
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: "inserisci il commento",
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
              ),

              ElevatedButton.icon(
                onPressed: _pickMultipleImages,
                label: Text("Scegli le immagini"),
                icon: Icon(Icons.photo_library),
              ),
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages.map((img) {
                    return Image.file(
                      img,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),

              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: Icon(Icons.arrow_forward),
                label: Text("Continua"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
