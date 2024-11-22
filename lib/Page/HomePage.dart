import 'package:flutter/material.dart'; // 导入 Flutter 的 Material Design 库，包含了我们需要的 UI 组件
import '../Tool/HomeDownButton.dart'; // 引入 HomeDownButton 组件（底部按钮）
import '../Tool/HomeUpButton.dart'; // 引入 HomeUpButton 组件（顶部按钮）
import '../Tool/CalendarWidget/Calendar.dart';   // 引入 CalendarWidget（这是你的日历组件）

// 定义 MyHomePage 组件，这个组件将会作为主页显示
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold 是一个 Material Design 结构的页面骨架，它提供了常見的布局结构（如 AppBar、Body、BottomNavigationBar 等）
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),  // 设置 AppBar 的高度為 90 像素
        child: AppBar(
          title: null,  // 设置 AppBar 的标题为空（不显示标题）
          leading: null,  // 不顯示上一頁（返回）按鈕
          automaticallyImplyLeading: false, // 禁用自動顯示上一頁按鈕
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 45), // 设置顶部按钮的位置，使其與顶部有 45 像素的间隔
            child: HomeUpButton(),  // 使用 HomeUpButton 组件，它是你定义的上部按钮，具体功能由该组件内部实现
          ),
        ),
      ),
      body: Column(
        // Column 用于垂直排列子组件
        children: [
          // 这里使用 Expanded 确保日历占据剩余空间
          Expanded(
            // Expanded 组件会使其子组件占据尽可能多的剩余空间
            child: CalendarWidget(),  // 引入并显示 CalendarWidget 组件，显示日历
          ),
        ],
      ),
      bottomNavigationBar: HomeDownButton(),  // 使用 HomeDownButton 组件，显示底部的按钮
    );
  }
}
