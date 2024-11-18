import 'package:flutter/material.dart'; // 导入 Flutter 的 Material Design 库，包含了需要的 UI 组件
import 'CalendarUtils.dart';  // 导入用于日期计算的工具函数（例如：计算每月的天数和第一天的偏移量）

// CalendarGrid 组件，负责渲染日历的网格视图
class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;  // 当前显示的月份
  final DateTime today;  // 当前日期（今天）
  final Function(int) onDateSelected;  // 选择日期时的回调函数，参数为选中的日期

  // 构造函数，通过参数传递当前月份、今天的日期和日期选择的回调函数
  CalendarGrid({
    required this.currentMonth,  // 当前月份
    required this.onDateSelected,  // 日期选择回调
    required this.today,  // 今天的日期
  });

  @override
  Widget build(BuildContext context) {
    // 获取当前月份的第一天偏移量（即星期几）
    int firstDayOffset = getFirstDayOffset(currentMonth);
    // 获取当前月份的天数
    int totalDaysInMonth = getDaysInMonth(currentMonth);

    return Column(
      children: [
        // 创建一行显示星期的标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),  // 添加水平内边距
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 在行内元素之间添加间隔
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'] // 星期的名称
                .map((weekday) {
              // 为每个星期几生成一个文本组件
              return Expanded(
                child: Center(
                  child: Text(
                    weekday,  // 显示星期几
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),  // 设置字体样式
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // 使用 GridView 来显示日期
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,  // 设置为 true，避免占用更多空间
            physics: NeverScrollableScrollPhysics(),  // 禁用 GridView 的滚动效果
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,  // 每行显示 7 个元素（星期天到星期六）
              childAspectRatio: 0.6,  // 设置每个格子的宽高比
            ),
            itemCount: totalDaysInMonth + firstDayOffset,  // 网格项数是总天数加上第一天的偏移量
            itemBuilder: (context, index) {
              int day = index - firstDayOffset + 1;  // 计算出当前网格项对应的日期
              if (index < firstDayOffset) {
                // 如果索引小于第一天的偏移量，说明这个位置是空白的，返回一个空容器
                return Container();
              } else if (day <= totalDaysInMonth) {
                // 如果计算出来的日期小于等于本月总天数，显示日期
                bool isToday = today.year == currentMonth.year &&
                    today.month == currentMonth.month &&
                    today.day == day;  // 判断当前日期是否是今天

                return Container(
                  margin: EdgeInsets.all(0),  // 设置每个日期单元格的边距为 0
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),  // 设置边框样式
                    color: isToday ? Colors.green : Colors.transparent,  // 如果是今天则用绿色背景，否则透明
                  ),
                  child: TextButton(
                    onPressed: () => onDateSelected(day),  // 按钮点击事件，触发日期选择的回调
                    child: Center(
                      child: Text(
                        day.toString(),  // 显示当前日期
                        style: TextStyle(
                          fontSize: 16,  // 设置字体大小
                          color: isToday ? Colors.white : Colors.black,  // 如果是今天则字体为白色，否则为黑色
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // 如果日期大于本月总天数，返回一个空容器
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}