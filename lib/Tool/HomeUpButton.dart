import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Page/IconPage/IconWalletPage.dart';

class HomeUpButton extends StatefulWidget {
  @override
  _HomeUpButtonState createState() => _HomeUpButtonState();
}

class _HomeUpButtonState extends State<HomeUpButton> {
  String name = "點擊修改名字";

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

  void _editName(BuildContext context) {
    TextEditingController controller = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("修改名字"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "新名字"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _saveName(controller.text);
                }
                Navigator.of(context).pop();
              },
              child: Text("保存"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                _editName(context);
              },
              child: Text(
                name,
                style: TextStyle(color: Colors.black, fontSize: 15.5),
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
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                print('你點擊了按鈕2');
              },
              child: Text(
                '本月餘額:\$${Global.historicalBalance.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.black, fontSize: 15.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
