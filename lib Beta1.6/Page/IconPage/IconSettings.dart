import 'package:flutter/material.dart';
import '../../Tool/HomeDownButton.dart';

class IconSettings extends StatelessWidget {
  const IconSettings({super.key});

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 39, 39, 39)
          : const Color.fromARGB(255, 255, 255, 255),
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
