import 'package:flutter/material.dart';
// import '../widgets/bottom_navigation_widget.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图鉴')),
      body: const Center(child: Text('植物图鉴与知识库')),
      // bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }
}
