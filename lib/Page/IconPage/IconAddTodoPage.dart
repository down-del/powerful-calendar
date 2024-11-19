import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入 intl 包用于格式化日期和时间
import 'package:project2/Page/HomePage.dart';
import 'package:project2/Page/IconPage/IconCheckBoxPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Tool/HomeDownButton.dart'; // 引入 HomeDownButton 组件（底部按钮）
import 'dart:convert'; // 引入 json 库用于序列化和反序列化数据

class EventStorage {
  // 存储多个事件数据的方法
  Future<void> saveEvent({
    required int year, // 事件的年份
    required int month, // 事件的月份
    required int day, // 事件的日期
    required int hour, // 事件的小时
    required int minute, // 事件的分钟
    required String eventDescription, // 事件的描述
    required String repeatOption, // 事件的重复选项
  }) async {
    final prefs = await SharedPreferences
        .getInstance(); // 获取 SharedPreferences 实例，用于持久化存储
    List<Map<String, dynamic>> events =
        await loadEvents(); // 获取当前已保存的事件列表，如果没有则返回空列表

    // 创建一个新的事件数据，使用 Map 结构，新增 completed 字段并默认设置为 false
    Map<String, dynamic> newEvent = {
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'event_description': eventDescription,
      'repeat_option': repeatOption,
      'completed': false, // 新增字段，默认值为 false
    };

    // 将新的事件添加到现有的事件列表中
    events.add(newEvent);

    // 对事件列表按照时间顺序进行排序
    events.sort((a, b) {
      DateTime timeA =
          DateTime(a['year'], a['month'], a['day'], a['hour'], a['minute']);
      DateTime timeB =
          DateTime(b['year'], b['month'], b['day'], b['hour'], b['minute']);
      return timeA.compareTo(timeB); // 升序排列
    });

    // 将事件列表转化为 JSON 字符串，方便存储
    String jsonEvents = jsonEncode(events);

    // 将 JSON 字符串存储到 SharedPreferences 中
    await prefs.setString('events', jsonEvents);
  }

  // 从 SharedPreferences 加载所有事件数据
  Future<List<Map<String, dynamic>>> loadEvents() async {
    final prefs =
        await SharedPreferences.getInstance(); // 获取 SharedPreferences 实例
    String? jsonEvents = prefs.getString('events'); // 获取存储的事件列表 JSON 字符串

    if (jsonEvents == null) {
      return []; // 如果没有保存任何事件，返回空列表
    }

    // 将 JSON 字符串反序列化为 List<Map<String, dynamic>> 类型
    List<dynamic> decodedList = jsonDecode(jsonEvents);

    // 将解码后的 List<dynamic> 转换为 List<Map<String, dynamic>>
    // 并确保数据类型正确
    return decodedList
        .map((event) => Map<String, dynamic>.from(event))
        .toList();
  }
}

// 这是一个 StatefulWidget，表示可以修改状态的页面
class IconAddTodo extends StatefulWidget {
  @override
  _IconAddTodoState createState() => _IconAddTodoState(); // 创建与此页面相关联的状态
}

class _IconAddTodoState extends State<IconAddTodo> {
  // 初始化年、月、日、时、分，默认值是当前时间
  int year = DateTime.now().year; // 获取当前年份
  int month = DateTime.now().month; // 获取当前月份
  int day = DateTime.now().day; // 获取当前日期
  int hour = DateTime.now().hour; // 获取当前小时
  int minute = DateTime.now().minute; // 获取当前分钟

  final TextEditingController _eventController =
      TextEditingController(); // 控制事件描述输入框的控制器

  String repeatOption = '一天一次'; // 默认的重复选项，表示事件每一天重复一次

  final EventStorage _eventStorage =
      EventStorage(); // 创建 EventStorage 实例，用于保存和加载事件数据

  // 初始化时，调用 _loadEvents 方法从 EventStorage 中读取已保存的数据
  @override
  void initState() {
    super.initState();
    _loadEvents(); // 加载先前保存的事件数据
  }

  // 异步加载已保存的事件
  Future<void> _loadEvents() async {
    List<Map<String, dynamic>> events =
        await _eventStorage.loadEvents(); // 获取已保存的事件数据
    print('加載的事件: $events'); // 输出事件列表，便于调试
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HomeDownButton(), // 页面底部按钮，使用自定义组件
      appBar: AppBar(
        title: Text('新增待辦事項'), // 显示在 AppBar 上的标题
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // 设置内边距，使内容更整齐
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 设置内容对齐方式为左对齐
          children: [
            // 显示选择日期的按钮，点击后会触发日期选择的功能
            GestureDetector(
              onTap: () => _selectDate(context), // 点击后触发 _selectDate 函数，选择日期
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 30.0), // 设置按钮内部的边距
                decoration: BoxDecoration(
                  color: Colors.blueAccent, // 设置背景颜色为蓝色
                  borderRadius: BorderRadius.circular(12), // 设置圆角
                ),
                child: Text(
                  '選擇日期: $formattedDate', // 显示选择的日期，使用 formattedDate 来格式化日期
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white), // 设置文字样式
                ),
              ),
            ),
            SizedBox(height: 20), // 设置日期与时间区块之间的间距

            // 显示选择时间的文字，显示当前选择的时间
            Text('選擇時間: $formattedTime',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20), // 设置时间与事件描述区块之间的间距

            // 时间选择的组件，使用 CupertinoPicker 实现上下滑动选择
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 水平居中
              children: [
                // 选择小时
                Container(
                  height: 200,
                  width: 80,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: hour), // 初始值为当前小时
                    itemExtent: 32, // 每一项的高度
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        hour = index; // 更新选择的小时
                      });
                    },
                    children: List<Widget>.generate(
                      24,
                      (int index) =>
                          Center(child: Text('$index')), // 生成 0 到 23 小时
                    ),
                  ),
                ),
                // 选择分钟
                Container(
                  height: 200,
                  width: 80,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: minute), // 初始值为当前分钟
                    itemExtent: 32, // 每一项的高度
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        minute = index; // 更新选择的分钟
                      });
                    },
                    children: List<Widget>.generate(
                      60,
                      (int index) =>
                          Center(child: Text('$index')), // 生成 0 到 59 分钟
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 设置选择时间区块与事件描述输入框之间的间距

            // 事件描述输入框
            TextField(
              controller: _eventController, // 与事件描述的控制器绑定
              decoration: InputDecoration(
                  labelText: '事件描述',
                  border: OutlineInputBorder()), // 设置输入框的标签和边框
            ),
            SizedBox(height: 20), // 设置输入框与重复选项之间的间距

            // 显示重复选项的标题
            Text('重複選項:(尚未實裝)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            // 重复选项的下拉菜单
            DropdownButton<String>(
              value: repeatOption, // 显示当前选择的重复选项
              items: [
                '一天一次',
                '两天一次',
                '三天一次',
                '每周一次',
                '每月一次',
              ].map((String option) {
                return DropdownMenuItem<String>(
                  value: option, // 每个菜单项对应一个重复选项
                  child: Text(option), // 显示菜单项的文本
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  repeatOption = newValue ?? '一天一次'; // 更新选择的重复选项
                });
              },
            ),
            SizedBox(height: 20), // 设置重复选项与保存按钮之间的间距

            // 保存事件的按钮
            ElevatedButton(
              onPressed: () {
                _saveEvent(); // 点击时调用 _saveEvent 函数保存事件
                Navigator.push(
                  context, // 當前的上下文
                  MaterialPageRoute(
                    // 使用 MaterialPageRoute 來跳轉的頁面
                    builder: (context) =>
                        MyHomePage(), // 當新的頁面需要顯示時，構建 MyHomePage()
                  ),
                );
              },
              child: Text('新增s事件'),
            ),
          ],
        ),
      ),
    );
  }

  // 显示日期选择器并更新选择的日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(year, month, day), // 初始日期为当前日期
      firstDate: DateTime(2000), // 最早可选日期
      lastDate: DateTime(2101), // 最晚可选日期
    );

    // 如果选择了日期，更新相关的年、月、日值
    if (selectedDate != null && selectedDate != DateTime(year, month, day)) {
      setState(() {
        year = selectedDate.year;
        month = selectedDate.month;
        day = selectedDate.day;
      });
    }
  }

  // 获取格式化后的日期
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(DateTime(year, month, day));
  }

  // 获取格式化后的时间
  String get formattedTime {
    return DateFormat('HH:mm').format(DateTime(year, month, day, hour, minute));
  }

  // 保存事件
  Future<void> _saveEvent() async {
    String eventDescription = _eventController.text;
    await _eventStorage.saveEvent(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      eventDescription: eventDescription,
      repeatOption: repeatOption,
    );
  }
}
