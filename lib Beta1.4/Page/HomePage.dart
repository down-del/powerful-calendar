import 'package:flutter/material.dart'; // 導入 Flutter 的 Material Design 庫，包含了我們需要的 UI 元件
import '../Tool/HomeDownButton.dart'; // 引入 HomeDownButton 元件（底部按鈕）
import '../Tool/HomeUpButton.dart'; // 引入 HomeUpButton 元件（頂部按鈕）
import '../Tool/CalendarWidget/Calendar.dart'; // 引入 CalendarWidget（這是你的日曆元件）

// 定義 MyHomePage 元件，這個元件將會作為主頁顯示
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      // Scaffold 是一個 Material Design 結構的頁面骨架，它提供了常見的佈局結構（如 AppBar、Body、BottomNavigationBar 等）
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 39, 39, 39)
          : const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90), // 設定 AppBar 的高度為 90 像素
        child: AppBar(
          backgroundColor: isDarkMode
              ? const Color.fromARGB(255, 39, 39, 39)
              : const Color.fromARGB(255, 255, 255, 255),
          title: null, // 設定 AppBar 的標題為空（不顯示標題）
          leading: null, // 不顯示上一頁（返回）按鈕
          automaticallyImplyLeading: false, // 禁用自動顯示上一頁按鈕
          flexibleSpace: Padding(
            padding:
                const EdgeInsets.only(top: 45), // 設定頂部按鈕的位置，使其與頂部有 45 像素的間隔
            child: HomeUpButton(), // 使用 HomeUpButton 元件，它是你定義的上部按鈕，具體功能由該元件內部實現
          ),
        ),
      ),
      body: Column(
        // Column 用於垂直排列子元件
        children: [
          // 這裡使用 Expanded 確保日曆占據剩餘空間
          Expanded(
            // Expanded 元件會使其子元件占據盡可能多的剩餘空間
            child: CalendarWidget(), // 引入並顯示 CalendarWidget 元件，顯示日曆
          ),
        ],
      ),
      bottomNavigationBar: HomeDownButton(), // 使用 HomeDownButton 元件，顯示底部的按鈕
    );
  }
}
