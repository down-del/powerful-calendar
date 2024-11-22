import 'package:flutter/material.dart';
import '../../Tool/HomeDownButton.dart'; // 引入 HomeDownButton 组件（底部按钮）

class IconSettings extends StatelessWidget {
  const IconSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "尚未開發",
          style: TextStyle(
            fontSize: 80,
            color: Colors.red,
          ),
        ),
      ),
      bottomNavigationBar: HomeDownButton(), 
    );
  }
}