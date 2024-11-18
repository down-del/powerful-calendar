import 'package:flutter/material.dart';
import '../../Tool/HomeDownButton.dart'; // 引入 HomeDownButton 组件（底部按钮）

class IconAddIncome extends StatelessWidget {
  const IconAddIncome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HomeDownButton(), 
    );
  }
}