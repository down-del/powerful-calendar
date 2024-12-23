import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Page/IconPage/IconWalletPage.dart';

class HomeUpButton extends StatefulWidget {
  @override
  _HomeUpButtonState createState() => _HomeUpButtonState();
}

class _HomeUpButtonState extends State<HomeUpButton> {
  String name = "點擊修改名字";

  bool isDarkMode = false; // Add this line to define isDarkMode

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        name = prefs.getString('name') ?? "點擊修改名字";
      });
    } catch (e) {
      print("加載名字時發生錯誤：$e");
    }
  }

  Future<void> _saveName(String newName) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', newName);
      setState(() {
        name = newName; // 更新狀態後再儲存
      });
      print("名字已保存：$newName");
    } catch (e) {
      print("保存名字時發生錯誤：$e");
    }
  }

  //按鈕功能、文字(名字的那個按鈕)
  void _editName(BuildContext context) {
    TextEditingController controller = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        var brightness = MediaQuery.of(context).platformBrightness;
        bool isDarkMode = brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkMode
              ? const Color.fromARGB(255, 4, 4, 4)
              : const Color.fromARGB(255, 255, 255, 255),
          title: Text(
            "修改名字",
            style: TextStyle(
              color: isDarkMode
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : Colors.black,
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color: isDarkMode
                  ? const Color.fromARGB(255, 255, 255, 255) // 暗模式下的文字顏色
                  : Colors.black, // 亮模式下的文字顏色
            ),
            decoration: InputDecoration(
              labelText: "新名字",
              labelStyle: TextStyle(
                color: isDarkMode
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : Colors.black,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: Text(
                "取消",
                style: TextStyle(
                  color: isDarkMode
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _saveName(controller.text);
                }
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: Text(
                "保存",
                style: TextStyle(
                  color: isDarkMode
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //按鈕本體
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                    color: isDarkMode
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : const Color.fromARGB(255, 0, 0, 0),
                  width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                _editName(context);
              },
              child: Text(
                name,
                style: TextStyle(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 15.5),
              ),
            ),
          ),
        ),
        SizedBox(width: 21.0),
        Flexible(
          flex: 7,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isDarkMode
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromARGB(255, 0, 0, 0),
                  width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                print('你點擊了按鈕2');
              },
              child: Text(
                '本月餘額:\$${Global.historicalBalance.toStringAsFixed(0)}',
                style: TextStyle(
                    color: isDarkMode
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 15.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
