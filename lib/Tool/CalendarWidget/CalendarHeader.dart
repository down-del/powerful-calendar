import 'package:flutter/material.dart';  // 引入 Flutter 的 Material Design 库，包含 UI 组件
import 'package:intl/intl.dart';  // 用于日期格式化，方便显示月份和年份

// CalendarHeader 组件，用于显示日历头部，包含月份、年份以及切换月份的按钮
class CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;  // 当前显示的月份
  final VoidCallback previousMonth;  // 切换到上个月的回调函数
  final VoidCallback nextMonth;  // 切换到下个月的回调函数

  // 构造函数，初始化当前月份和切换月份的回调函数
  CalendarHeader({
    required this.currentMonth,  // 当前月份
    required this.previousMonth,  // 上个月切换回调
    required this.nextMonth,  // 下个月切换回调
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,  // 水平居中排列
      children: [
        // 左箭头按钮，用于切换到上个月
        IconButton(
          icon: Icon(Icons.arrow_left),  // 使用左箭头图标
          onPressed: previousMonth,  // 按钮点击时执行 previousMonth 回调
        ),
        // 显示当前月份和年份的文本
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),  // 设置左右间距
          child: Text(
            DateFormat.yMMM().format(currentMonth),  // 使用 DateFormat 格式化当前月份为 "yyyy MMM" 格式（如：2024 Nov）
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  // 设置字体样式，字号为 24，粗体
          ),
        ),
        // 右箭头按钮，用于切换到下个月
        IconButton(
          icon: Icon(Icons.arrow_right),  // 使用右箭头图标
          onPressed: nextMonth,  // 按钮点击时执行 nextMonth 回调
        ),
      ],
    );
  }
}
