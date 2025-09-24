// 临时测试文件 - 用于验证assets是否正确配置
import 'package:flutter/material.dart';

class AssetsTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assets Test')),
      body: Column(
        children: [
          Text('Testing fitness_app assets:'),
          Image.asset('fitness_app/tab_1.png', width: 50, height: 50),
          Image.asset('fitness_app/tab_1s.png', width: 50, height: 50),
          Image.asset('fitness_app/tab_2.png', width: 50, height: 50),
          Image.asset('fitness_app/tab_2s.png', width: 50, height: 50),
          Image.asset('fitness_app/tab_3.png', width: 50, height: 50),
          Image.asset('fitness_app/tab_3s.png', width: 50, height: 50),
          Image.asset('fitness_app/tab_4.png', width: 50, height: 50),
          Image.asset('fitness_app/tab_4s.png', width: 50, height: 50),
        ],
      ),
    );
  }
}
