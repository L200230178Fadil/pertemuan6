import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(primarySwatch: Colors.brown),
    home: BookListScreen(),
  ));
}

class BookListScreen extends StatelessWidget {
  // Daftar 10 buku sesuai file yang Anda unggah
  final List<Map<String, String>> books = [
    {'title': 'Jane Eyre', 'author': 'Charlotte Brontë', 'pdf': '119-2014-04-09-Jane Eyre.pdf'},
    {'title': 'Wuthering Heights', 'author': 'Emily Brontë', 'pdf': '119-2014-04-09-Wuthering Heights.pdf'},
    {'title': 'The Great Gatsby', 'author': 'F. Scott Fitzgerald', 'pdf': '2015.184960.The-Great-Gatsby.pdf'},
    {'title': 'The Adventures of Sherlock Holmes', 'author': 'Arthur Conan Doyle', 'pdf': 'advs.pdf'},
    {'title': 'Alice\'s Adventures in Wonderland', 'author': 'Lewis Carroll', 'pdf': 'Alice_in_Wonderland.pdf'},
    {'title': 'Peter Pan and Wendy', 'author': 'J.M. Barrie', 'pdf': 'Barrie_Peter_Pan_and_Wendy_1911_edition.pdf'},
    {'title': 'Frankenstein', 'author': 'Mary Shelley', 'pdf': 'frank-a5.pdf'},
    {'title': 'Gulliver\'s Travels', 'author': 'Jonathan Swift', 'pdf': 'gulliverstravels1918swif.pdf'},
    {'title': 'Pride and Prejudice', 'author': 'Jane Austen', 'pdf': 'Pride.pdf'},
    {'title': 'The Wonderful Wizard of Oz', 'author': 'L. Frank Baum', 'pdf': 'wonderfulwizardo00baumiala.pdf'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Koleksi Buku Klasik')),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.menu_book),
            title: Text(books[index]['title']!),
            subtitle: Text(books[index]['author']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(
                    title: books[index]['title']!,
                    author: books[index]['author']!,
                    pdfFileName: books[index]['pdf']!,
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

class BookDetailScreen extends StatelessWidget {
  final String title, author, pdfFileName;

  BookDetailScreen({required this.title, required this.author, required this.pdfFileName});

  // Fungsi untuk menyiapkan file dari Assets ke Local Storage
  Future<String> preparePdf() async {
    try {
      final ByteData data = await rootBundle.load("assets/pdf/$pdfFileName");
      final Directory tempDir = await getApplicationDocumentsDirectory();
      final File tempFile = File("${tempDir.path}/$pdfFileName");
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      return tempFile.path;
    } catch (e) {
      throw Exception("Gagal memuat file PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.auto_stories, size: 100, color: Colors.brown),
            SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text("Oleh $author", style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            Spacer(),
            ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Read the book"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: () async {
                String path = await preparePdf();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingBookFile(path: path, title: title),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingBookFile extends StatelessWidget {
  final String path;
  final String title;

  ReadingBookFile({required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PDFView(
        filePath: path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}