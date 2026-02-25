import 'package:flutter/material.dart';
import 'list_detail.dart';
import 'list_create.dart';

// class MyListsPage extends StatelessWidget {
class MyListsPage extends StatefulWidget { //เพื่อให้อัพเดททันที
  const MyListsPage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: ListView.builder(
  //       itemCount: 5,
  //       itemBuilder: (context, index) {
  //         return ListTile(
  //           leading: const Icon(Icons.assignment),
  //           title: Text('รายการที่ ${index + 1}'),
  //           onTap: () {
  //             Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailPage()));
  //           },
  //         );
  //       },
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: () {},
  //       child: const Icon(Icons.add),
  //     ),
  //   );
  // }
@override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {
  // สร้างตัวแปรเก็บรายชื่อลิสต์ (เริ่มต้นด้วยลิสต์ว่าง)
  final List<String> _items = ["โปรเจกต์ที่ 1"];

  // ฟังก์ชันสำหรับเปิดหน้าต่างกรอกชื่อลิสต์ใหม่
  void _showAddDialog() {
    String inputText = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สร้างรายการใหม่'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "กรอกชื่อลิสต์ที่นี่..."),
          onChanged: (value) => inputText = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (inputText.isNotEmpty) {
                setState(() {
                  _items.add(inputText); // เพิ่มข้อมูลลงในตัวแปร
                });
                Navigator.pop(context);
              }
            },
            child: const Text('สร้าง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ส่วนเนื้อหาหลัก
      body: _items.isEmpty
          ? const Center(child: Text('ยังไม่มีรายการ กดปุ่ม + เพื่อเพิ่ม'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    // leading: const CircleAvatar(child: Text('${index + 1}')),
                    title: Text(_items[index]),
                    subtitle: const Text('กดเพื่อดูรายละเอียดตาราง'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  DetailPage(title: '${_items[index]}')),
                      );
                    },
                  ),
                );
              },
            ),
            
      // ปุ่มบวกมุมขวาบน (ของพื้นที่ Body) หรือ มุมขวาล่าง
      // ใน Flutter นิยมใช้ FloatingActionButton วางไว้มุมขวาล่างครับ
      floatingActionButton: FloatingActionButton(
        // onPressed: _showAddDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
    // 1. ไปหน้าสร้าง
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateListPage()),
    );

    // 2. ถ้าได้ชื่อกลับมา ให้เพิ่มลงในลิสต์
    if (result != null && result is String) {
      setState(() {
        _items.add(result);
      });
    }
  },
      ),
    );
  }
}