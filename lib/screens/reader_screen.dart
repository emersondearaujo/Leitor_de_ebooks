import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocsy_epub_viewer/vocsy_epub_viewer.dart';
import '../models/book.dart';

class ReaderScreen extends StatelessWidget {
  final Book book;

  const ReaderScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reader - ${book.title}'),
      ),
      body: FutureBuilder<EpubBook>(
        future: _loadBook(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            EpubBook epubBook = snapshot.data!;
            return vocsy_epub_viewer(epubBook: epubBook);
          }
        },
      ),
    );
  }

  Future<EpubBook> _loadBook() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/${book.title}.epub';
    var bytes = await File(filePath).readAsBytes();
    return EpubReader.readBook(bytes);
  }
}

class EpubReader {
  static Future<EpubBook> readBook(Uint8List bytes) {}
}

class EpubBook {}
