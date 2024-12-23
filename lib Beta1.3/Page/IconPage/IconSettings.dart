import 'package:flutter/material.dart';
import '../../Tool/HomeDownButton.dart'; 

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