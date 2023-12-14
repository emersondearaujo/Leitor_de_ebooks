import 'dart:io';
import 'package:ebook/screens/reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({Key? key}) : super(key: key);

  @override
  _BookshelfScreenState createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  late Future<List<Book>> _books;

  get http => null;

  @override
  void initState() {
    super.initState();
    _books = ApiService(apiUrl: 'https://escribo.com/books.json').fetchBooks();
  }

  Future<bool> checkIfBookDownloaded(Book book) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/${book.title}.epub';
    return File(filePath).exists();
  }

  Future<void> downloadBook(Book book) async {
    String url = book.downloadUrl;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/${book.title}.epub';
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download book');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookshelf'),
      ),
      body: FutureBuilder<List<Book>>(
        future: _books,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Book> books = snapshot.data ?? [];
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                Book book = books[index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () async {
                    bool isBookDownloaded = await checkIfBookDownloaded(book);

                    if (isBookDownloaded) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReaderScreen(book: book),
                        ),
                      );
                    } else {
                      await downloadBook(book);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReaderScreen(book: book),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
