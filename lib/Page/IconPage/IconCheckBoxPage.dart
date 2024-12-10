import 'package:calender/Tool/HomeDownButton.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 事件存儲管理類
class EventStorage {
  Future<List<Map<String, dynamic>>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonEvents = prefs.getString('events');
    if (jsonEvents == null) return [];
    List<dynamic> decodedList = jsonDecode(jsonEvents);
    return decodedList
        .map((event) => Map<String, dynamic>.from(event))
        .toList();
  }

  Future<void> saveEvents(List<Map<String, dynamic>> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('events', jsonEncode(events));
  }
}

class IconCheakBox extends StatefulWidget {
  @override
  _IconCheakBoxState createState() => _IconCheakBoxState();
}

class _IconCheakBoxState extends State<IconCheakBox> {
  late Future<List<Map<String, dynamic>>> _events;
  final EventStorage _eventStorage = EventStorage();
  bool _isSelectionMode = false; // 是否進入多選模式
  Set<int> _selectedItems = {}; // 存儲被選中的項目

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    _events = _eventStorage.loadEvents();
  }

  // 進入或退出選取模式
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear(); // 清空選中項目
    });
  }

  // 刪除選定項目
  Future<void> _deleteSelectedItems() async {
    if (_isSelectionMode) {
      List<Map<String, dynamic>> events = await _events;
      events.removeWhere((item) => _selectedItems.contains(item.hashCode));
      await _eventStorage.saveEvents(events);

      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false; // 退出選取模式
      });

      _loadEvents(); // 更新數據
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HomeDownButton(), 
      appBar: AppBar(
        title: Text('事件列表'),
        actions: [
          // 切換選取模式的按鈕
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.check : Icons.delete),
            onPressed: _toggleSelectionMode,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加載失敗: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('沒有事件'));
          }

          List<Map<String, dynamic>> eventsList = snapshot.data!;

          return ListView.builder(
            itemCount: eventsList.length,
            itemBuilder: (context, index) {
              var event = eventsList[index];
              bool isSelected = _selectedItems.contains(event.hashCode);

              return ListTile(
                leading: Icon(
                  event['completed'] == true
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                title: Text(
                  event['event_description'],
                  style: TextStyle(
                    decoration: event['completed'] == true
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle:
                    Text('${event['year']}年${event['month']}月${event['day']}日'),
                tileColor: isSelected ? Colors.red[300] : null,
                // trailing: _isSelectionMode
                //     ? Icon(Icons.check, color: isSelected ? Colors.green : null) // 在選擇模式下顯示勾選框
                //     : null,
                onTap: () {
                  setState(() {
                    if (_isSelectionMode) {
                      if (isSelected) {
                        _selectedItems.remove(event.hashCode);
                      } else {
                        _selectedItems.add(event.hashCode);
                      }
                    } else {
                      // 切換事件狀態的邏輯
                      event['completed'] = !(event['completed'] ?? false);
                      _eventStorage.saveEvents(eventsList);
                    }
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: _isSelectionMode
          ? FloatingActionButton(
              onPressed: _deleteSelectedItems,
              child: Icon(Icons.delete),
              backgroundColor: Colors.red,
            )
          : null,
    );
  }
}
