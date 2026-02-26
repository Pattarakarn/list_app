import 'package:flutter/material.dart';
import 'list_detail.dart';
import 'list_create.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:list_app/list_detail.dart'; // <--- ต้องมีบรรทัดนี้
import 'package:list_app/main.dart';

// class MyListsPage extends StatelessWidget {
class MyListsPage extends StatefulWidget {
  //เพื่อให้อัพเดททันที
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
      // body: _items.isEmpty
      //     ? const Center(child: Text('ยังไม่มีรายการ กดปุ่ม + เพื่อเพิ่ม'))
      //     : ListView.builder(
      //         itemCount: _items.length,
      //         itemBuilder: (context, index) {
      //           return Card(
      //             margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      //             child: ListTile(
      //               // leading: const CircleAvatar(child: Text('${index + 1}')),
      //               title: Text(_items[index]),
      //               subtitle: const Text('กดเพื่อดูรายละเอียดตาราง'),
      //               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      //               onTap: () {
      //                 Navigator.push(
      //                   context,
      //                   MaterialPageRoute(builder: (context) =>  DetailPage(title: '${_items[index]}')),
      //                 );
      //               },
      //             ),
      //           );
      //         },
      //       ),
      body: StreamBuilder<QuerySnapshot>(
        // เชื่อมต่อท่อข้อมูลกับ Cloud Firestore
        stream: FirebaseFirestore.instance
            .collection('lists')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('ยังไม่มีรายการ... ลองกดปุ่ม + ดูนะ'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // ดึงข้อมูลในแต่ละแถวออกมา
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              print(docId);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  // leading: const CircleAvatar(child: Icon(Icons.assignment)),
                  leading: Icon(
                    Icons.assignment,
                    //size: 24,
                    color: context.primaryColor,
                  ),
                  title: Text(data['name'] ?? 'ว่าง'),
                  subtitle: Text(
                    data['createdAt'] != null
                        // ? (data['createdAt'] as Timestamp).toDate().toString()
                        ? DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format((data['createdAt'] as Timestamp).toDate())
                        : '',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    String itemName = data['name'] ?? 'Unnamed';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPage(title: itemName, docId: docId),
                      ),
                    );
                  },
                  // // เพิ่มปุ่มลบ (แถมให้ครับ)
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.delete, color: Colors.red),
                  //   onPressed: () => _deleteItem(docId),
                  // ),
                ),
              );
            },
          );
        },
      ),
      // ปุ่มบวกมุมขวาบน (ของพื้นที่ Body) หรือ มุมขวาล่าง
      // ใน Flutter นิยมใช้ FloatingActionButton วางไว้มุมขวาล่างครับ
      floatingActionButton: FloatingActionButton(
        // onPressed: _showAddDialog,
        backgroundColor: context.primaryColor,
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
