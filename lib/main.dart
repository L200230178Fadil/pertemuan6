import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(primarySwatch: Colors.blue),
    home: BookListScreen(),
  ));
}

class BookListScreen extends StatelessWidget {
  // 1. Menambahkan jumlah buku menjadi 10
  final List<Map<String, String>> books = [
    {'title': 'Algorithms to Live By', 'author': 'Brian Christian', 'description': 'The computer science of human decisions.', 'pdfPath': 'assets/pdf/algo.pdf'},
    {'title': 'Beginning Programming', 'author': 'Wallace Wang', 'description': 'All-in-One Desk Reference for Dummies.', 'pdfPath': 'assets/pdf/prog.pdf'},
    {'title': 'Streamlit for Data Science', 'author': 'Tyler Richards', 'description': 'Create interactive data apps in Python.', 'pdfPath': 'assets/pdf/streamlit.pdf'},
    {'title': 'Clean Code', 'author': 'Robert C. Martin', 'description': 'A Handbook of Agile Software Craftsmanship.', 'pdfPath': 'assets/pdf/clean_code.pdf'},
    {'title': 'The Pragmatic Programmer', 'author': 'Andrew Hunt', 'description': 'Your journey to mastery.', 'pdfPath': 'assets/pdf/pragmatic.pdf'},
    {'title': 'You Don\'t Know JS', 'author': 'Kyle Simpson', 'description': 'Deep dive into JavaScript.', 'pdfPath': 'assets/pdf/js.pdf'},
    {'title': 'Dart in Action', 'author': 'Chris Buckett', 'description': 'Master the Dart language.', 'pdfPath': 'assets/pdf/dart.pdf'},
    {'title': 'Flutter Cookbook', 'author': 'Alberto Miola', 'description': 'Practical recipes for Flutter.', 'pdfPath': 'assets/pdf/flutter.pdf'},
    {'title': 'Atomic Habits', 'author': 'James Clear', 'description': 'An easy way to build good habits.', 'pdfPath': 'assets/pdf/habits.pdf'},
    {'title': 'Deep Work', 'author': 'Cal Newport', 'description': 'Rules for focused success.', 'pdfPath': 'assets/pdf/deepwork.pdf'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Digital Library')),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(books[index]['title']!),
            subtitle: Text(books[index]['author']!),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(
                    title: books[index]['title']!,
                    author: books[index]['author']!,
                    description: books[index]['description']!,
                    pdfPath: books[index]['pdfPath']!,
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
  final String title, author, description, pdfPath;

  BookDetailScreen({required this.title, required this.author, required this.description, required this.pdfPath});

  // Fungsi pembantu untuk menyalin file asset ke penyimpanan lokal agar bisa dibaca PDFView
  Future<String> fromAsset(String assetPath, String filename) async {
    try {
      var data = await rootBundle.load(assetPath);
      var bytes = data.buffer.asUint8List();
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('By $author', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey[700])),
            Divider(height: 30),
            Text('Description:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 16)),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 2. Fungsi Navigasi ke Halaman PDF
                      fromAsset(pdfPath, 'temp_book.pdf').then((path) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadingBookFile(path: path, title: title),
                          ),
                        );
                      });
                    },
                    child: Text('Read the book'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Implementasi PDF View
class ReadingBookFile extends StatelessWidget {
  final String? path;
  final String title;

  ReadingBookFile({this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: path != null
          ? PDFView(filePath: path)
          : Center(child: CircularProgressIndicator()),
    );
  }
}