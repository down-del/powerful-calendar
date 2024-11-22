// calendar_utils.dart

import 'package:intl/intl.dart';  // 用于格式化日期

// 计算指定月份的天数
int getDaysInMonth(DateTime month) {
  int nextMonth = month.month % 12 + 1;
  int year = month.month == 12 ? month.year + 1 : month.year;
  return DateTime(year, nextMonth, 1).subtract(Duration(days: 1)).day;
}

// 计算当月第一天是星期几，返回一个偏移量（星期日为0，星期一为1，以此类推）
int getFirstDayOffset(DateTime month) {
  DateTime firstDay = DateTime(month.year, month.month, 1);
  return firstDay.weekday % 7;  // 将星期几转换为0-6的数字
}

// 获取月份的名称
String getMonthName(DateTime month) {
  return DateFormat.yMMM().format(month);  // 格式化为 "Year Month" 格式
}