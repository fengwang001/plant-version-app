import 'package:flutter/material.dart';
// import '../widgets/bottom_navigation_widget.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创作')),
      body: const Center(child: Text('识别与AI视频生成入口')),
      // bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2),
    );
  }
}



