import 'package:flutter/material.dart';

class CreateListPage extends StatelessWidget {
  const CreateListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('สร้างรายการใหม่')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'ชื่อโปรเจกต์ / ชื่อรายการ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  // เมื่อสร้างเสร็จ ให้ย้อนกลับพร้อมส่งชื่อโปรเจกต์ไป
                  Navigator.pop(context, _controller.text);
                }
              },
              child: const Text('บันทึกและเริ่มเขียนตาราง'),
            ),
          ],
        ),
      ),
    );
  }
}