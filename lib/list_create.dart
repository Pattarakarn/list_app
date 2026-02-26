import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// class CreateListPage extends StatelessWidget {
class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}
  // @override
  // Widget build(BuildContext context) {
  class _CreateListPageState extends State<CreateListPage> {
    final TextEditingController _controller = TextEditingController();
    bool _isLoading = false;
    final TextEditingController _nameController = TextEditingController();

//  ฟังก์ชันส่งข้อมูลไป Firebase Stateful
  Future<void> _createList() async {
    if (_nameController.text.isEmpty) return; // ถ้าไม่กรอกชื่อ ไม่ต้องทำต่อ

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('lists').add({
        'name': _nameController.text,
        'createdAt': FieldValue.serverTimestamp(), // เก็บเวลาที่สร้างด้วย
      });

      // เมื่อสำเร็จ ให้ล้างช่องกรอกและปิดหน้าต่าง (ถ้าเป็น Dialog)
      _nameController.clear();
      if (mounted) Navigator.pop(context); 
      
       Navigator.pop(context, _controller.text);
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

// Future<void> _createList(BuildContext context) async {
//   await FirebaseFirestore.instance.collection('lists').add({
//     'name': _nameController.text,
//   });

//   // ใช้ Navigator ผ่าน context ที่รับมา (แต่จะเช็ก mounted ลำบากกว่า)
//   Navigator.pop(context); 
// }
// 3. ฟังก์ชันสร้างหน้าจอ (ต้องมี @override Widget build เสมอ!)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างลิสต์')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
             controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
           _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: _createList,
              // onPressed: () {
              //   if (_controller.text.isNotEmpty) {
              //     // เมื่อสร้างเสร็จ ให้ย้อนกลับพร้อมส่งชื่อโปรเจกต์ไป
              //     _createList
              //     Navigator.pop(context, _controller.text);
              //   }
              // },
              child: const Text('บันทึกและเริ่มเขียนตาราง'),
            ),
          ],
        ),
      ),
    );
  }
  }