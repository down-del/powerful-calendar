import 'package:flutter/material.dart'; // Flutter 的核心包，用於構建 UI
import 'package:shared_preferences/shared_preferences.dart'; // 引入 SharedPreferences，用於本地數據持久化存儲

// 定義一個有狀態的組件 HomeUpButton（StatefulWidget）
// 有狀態的組件能夠保存用戶交互過程中的數據變化
class HomeUpButton extends StatefulWidget {
  @override
  _HomeUpButtonState createState() => _HomeUpButtonState();
  // createState 方法會創建一個對應的狀態類 _HomeUpButtonState
  // _HomeUpButtonState 負責持有當前狀態和邏輯
}

// 定義 HomeUpButton 的狀態類
class _HomeUpButtonState extends State<HomeUpButton> {
  // 定義一個變量 name，表示按鈕上顯示的名字
  // 默認值為 "點擊修改名字"，如果本地有保存的名字會加載並覆蓋此值
  String name = "點擊修改名字";

  // Flutter 組件的生命周期方法之一
  // initState 方法在組件被插入 widget 樹時執行一次
  @override
  void initState() {
    super.initState(); // 調用父類的 initState，執行父類相關初始化邏輯
    _loadName(); // 調用自定義方法 _loadName 從本地存儲加載名字
  }

  // 自定義方法：從本地存儲中加載名字
  Future<void> _loadName() async {
    try {
      // SharedPreferences 是一個輕量級的鍵值存儲工具
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // 使用 getString 方法嘗試加載鍵為 'name' 的值
      // 如果本地存儲中沒有值，則返回默認值 "點擊修改名字"
      setState(() {
        name = prefs.getString('name') ?? "點擊修改名字";
      });
    } catch (e) {
      print("加載名字時發生錯誤：$e"); // 輸出錯誤日誌，方便調試
    }
  }

  // 自定義方法：將新名字保存到本地存儲
  Future<void> _saveName(String newName) async {
    try {
      // 獲取 SharedPreferences 的實例
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // 使用 setString 方法保存名字到鍵 'name'
      await prefs.setString('name', newName);
      print("名字已保存：$newName"); // 在控制台打印確認信息
    } catch (e) {
      print("保存名字時發生錯誤：$e"); // 輸出錯誤日誌，方便調試
    }
  }

  // 自定義方法：顯示一個對話框，允許用戶修改名字
  void _editName(BuildContext context) {
    // 創建一個 TextEditingController，用於控制文本框的內容
    // 初始值設置為當前的名字
    TextEditingController controller = TextEditingController(text: name);

    // 調用 showDialog 顯示對話框
    showDialog(
      context: context, // 傳入當前的 BuildContext
      builder: (BuildContext context) {
        // 返回一個 AlertDialog，表示彈出的對話框
        return AlertDialog(
          title: Text("修改名字"), // 對話框的標題
          content: TextField(
            controller: controller, // 將文本框綁定到 controller
            decoration: InputDecoration(labelText: "新名字"), // 提示用戶輸入新名字
          ),
          actions: [
            // 定義 "取消" 按鈕
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 點擊 "取消" 時關閉對話框
              },
              child: Text("取消"), // 按鈕顯示的文字
            ),
            // 定義 "保存" 按鈕
            TextButton(
              onPressed: () {
                // 檢查輸入框是否有內容
                if (controller.text.isNotEmpty) {
                  // 更新狀態
                  setState(() {
                    name = controller.text; // 更新 name 為新輸入的值
                  });
                  _saveName(controller.text); // 調用 _saveName 將新名字保存到本地
                }
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: Text("保存"), // 按鈕顯示的文字
            ),
          ],
        );
      },
    );
  }

  // build 方法定義組件的界面結構
  @override
  Widget build(BuildContext context) {
    // 使用 Row 將兩個按鈕水平排列
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // 將按鈕居中排列
      children: [
        // 第一個按鈕：用於顯示和修改名字
        Flexible(
          flex: 5, // 設置按鈕所佔的彈性比例
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6), // 設置內邊距
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2), // 設置邊框樣式
              borderRadius: BorderRadius.circular(8), // 設置圓角
            ),
            child: TextButton(
              onPressed: () {
                _editName(context); // 點擊按鈕時調用 _editName 方法
              },
              child: Text(
                name, // 按鈕上顯示當前名字
                style: TextStyle(color: Colors.black, fontSize: 16), // 設置文字樣式
              ),
            ),
          ),
        ),
        SizedBox(width: 21.0), // 設置按鈕之間的間距
        // 第二個按鈕：顯示固定的文本
        Flexible(
          flex: 5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                print('你點擊了按鈕2'); // 點擊時輸出日誌
              },
              child: Text(
                '錢:0000000', // 按鈕上顯示固定文字
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
