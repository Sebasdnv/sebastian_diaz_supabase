import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sebastian_diaz_supabase/viewmodel/explore_view_model.dart';
import 'package:sebastian_diaz_supabase/views/book_detail_view.dart';

class AllBooksView extends StatefulWidget {
  const AllBooksView({super.key});

  @override
  State<AllBooksView> createState() => _AllBooksViewState();
}

class _AllBooksViewState extends State<AllBooksView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ExploreViewModel>(context, listen: false).fetchAllBooks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tutti i Libri"), centerTitle: true),
      body: Consumer<ExploreViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: vm.allBooks.length,
            itemBuilder: (context, index) {
              final book = vm.allBooks[index];
              final hasImage = book.images != null && book.images!.isNotEmpty;

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailView(book: book),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: hasImage
                            ? Image.network(
                                book.images![0].imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : const Center(child: Icon(Icons.book, size: 40)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              book.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Leggi",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}