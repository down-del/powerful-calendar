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

    //按照是否完成、時間排序
    decodedList.sort((a, b) {
      int completedComparison = (a['completed'] == true ? 1 : 0).compareTo(b['completed']==true?1:0);
      if (completedComparison != 0) {
        return completedComparison;
      }
      DateTime timeA =
          DateTime(a['year'], a['month'], a['day'], a['hour'], a['minute']);
      DateTime timeB =
          DateTime(b['year'], b['month'], b['day'], b['hour'], b['minute']);
      return timeA.compareTo(timeB);
    });

    return decodedList
        .map((event) => Map<String, dynamic>.from(event))
        .toList();
  }

// 事件儲存到本地
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
// 延遲初始化的 Future，將用於保存事件數據列表。
// List<Map<String, dynamic>> 是事件數據的結構：每個事件是一個 Map。
  late Future<List<Map<String, dynamic>>> _events;

// 定義一個事件存儲類（EventStorage）的實例，用於處理事件的加載和存儲。
// 通過該實例調用方法來實現事件的加載。
  final EventStorage _eventStorage = EventStorage();

// 用於控制是否進入多選模式的布爾變數。
// 默認為 false，表示未進入多選模式。
  bool _isSelectionMode = false;

// 用於保存多選模式下被選中的項目的索引集合。
// 使用 Set<int> 可以確保索引不重複且方便進行添加和移除操作。
  Set<int> _selectedItems = {};

  @override
  void initState() {
    super.initState(); // 繼承自父類的初始化方法，保證基礎設置正確執行。

    // 調用 _loadEvents 方法，初始化事件數據。
    // 這通常是在頁面加載時執行，以確保數據在界面構建前準備好。
    _loadEvents();
  }

// 加載事件數據的方法，將 Future 賦值給 _events。
// 使用 _eventStorage 實例的 loadEvents 方法來獲取事件數據，通常是異步操作。
  void _loadEvents() {
    _events = _eventStorage.loadEvents();
  }

// 切換多選模式的方法。
// 進入或退出多選模式的切換由 _isSelectionMode 控制。
  void _toggleSelectionMode() {
    setState(() {
      // 切換 _isSelectionMode 的布爾值（從 true 變為 false，或從 false 變為 true）。
      _isSelectionMode = !_isSelectionMode;

      // 當進入或退出多選模式時，清空已選中的項目集合，避免干擾。
      _selectedItems.clear();
    });
  }

  // 刪除選定項目
  Future<void> _deleteSelectedItems() async {
    // 檢查是否處於多選模式
    if (_isSelectionMode) {
      // 使用 await 獲取 _events 中的數據
      // 這裡 _events 是一個 Future，resolve 後得到 List<Map<String, dynamic>>。
      List<Map<String, dynamic>> events = await _events;

      // 從 events 中刪除所有被選中的項目。
      // 使用 hashCode 確認哪些項目在 _selectedItems 中，並移除它們。
      events.removeWhere((item) => _selectedItems.contains(item.hashCode));

      // 將更新後的 events 保存到存儲中。
      await _eventStorage.saveEvents(events);

      // 更新 UI 狀態
      setState(() {
        // 清空已選中的項目，因為這些項目已被刪除。
        _selectedItems.clear();

        // 退出選取模式，將 _isSelectionMode 設為 false。
        _isSelectionMode = false;
      });

      // 重新加載事件數據，以便刷新界面並顯示最新數據。
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 判斷當前主題模式
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      bottomNavigationBar: HomeDownButton(),
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 39, 39, 39)
          : const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: isDarkMode // 設置 AppBar 的背景顏色
            ? const Color.fromARGB(255, 39, 39, 39)
            : const Color.fromARGB(255, 255, 255, 255),
        title: Text('事件列表',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        actions: [
          // 切換選取模式的按鈕
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.check : Icons.delete,
                color: isDarkMode ? Colors.white : Colors.black),
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
            return Center(
                child: Text(
              '加載失敗: ${snapshot.error}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              '沒有事件',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ));
          }

          List<Map<String, dynamic>> eventsList = snapshot.data!;
          // 顯示事件列表
          return ListView.builder(
            itemCount: eventsList.length,
            itemBuilder: (context, index) {
              var event = eventsList[index];
              bool isSelected = _selectedItems.contains(event.hashCode);

              // 顯示事件列表的每一項
              return ListTile(
                leading: Icon(
                  event['completed'] == true
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                title: Text(
                  event['event_description'],
                  style: TextStyle(
                    decoration: event['completed'] == true
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: isDarkMode ? Colors.white : Colors.black,
                    decorationThickness: 2.50,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  '${event['year']}年${event['month']}月${event['day']}日',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
                tileColor:
                    isSelected ? const Color.fromARGB(255, 165, 79, 79) : null,
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

                      //按照是否完成、時間排序
                      eventsList.sort((a, b) {
                        int completedComparison =
                            (a['completed'] == true ? 1 : 0).compareTo(b['completed']==true?1:0);
                        if (completedComparison != 0) {
                          return completedComparison;
                        }
                        DateTime timeA = DateTime(a['year'], a['month'],
                            a['day'], a['hour'], a['minute']);
                        DateTime timeB = DateTime(b['year'], b['month'],
                            b['day'], b['hour'], b['minute']);
                        return timeA.compareTo(timeB);
                      });

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
