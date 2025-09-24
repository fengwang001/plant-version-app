import 'package:flutter/material.dart';
// import '../widgets/bottom_navigation_widget.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发现')),
      body: const Center(child: Text('作品流与探索')),
      // bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2),
    );
  }
}



