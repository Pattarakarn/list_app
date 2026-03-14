import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  final user = FirebaseAuth.instance.currentUser;
  // if (user == null) {
  //   return const Text("กรุณาล็อกอินใหม่");
  // }

  final TextEditingController _selectController = TextEditingController(
    text: "Table",
  );
  final TextEditingController _checkController = TextEditingController(
    text: "false",
  );

  Future<void> _createList() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    print(_checkController.text);
    print(_selectController.text);
    // try {
    //   await FirebaseFirestore.instance.collection('lists').add({
    //     'name': _nameController.text,
    //     'createdAt': FieldValue.serverTimestamp(),
    //     'authorId': user?.uid,
    //     // type:
    //     //required_date:
    //   });

    //   // เมื่อสำเร็จ ให้ล้างช่องกรอกและปิดหน้าต่าง (ถ้าเป็น Dialog)
    //   _nameController.clear();
    //   if (mounted) Navigator.pop(context, _nameController.text);
    // } catch (e) {
    //   print("Error: $e");
    // } finally {
    //   setState(() => _isLoading = false);
    // }
  }

  // Future<void> _createList(BuildContext context) async {
  //   await FirebaseFirestore.instance.collection('lists').add({
  //     'name': _nameController.text,
  //   });
  //   // ใช้ Navigator ผ่าน context ที่รับมา (แต่จะเช็ก mounted ลำบากกว่า)
  //   Navigator.pop(context);
  // }

  final List<Map<String, String>> optionType = [
    {"label": "ตาราง", "value": "Table"},
    {"label": "checklist", "value": "Checklist"},
  ];
  // 3. ฟังก์ชันสร้างหน้าจอ (ต้องมี @override Widget build เสมอ!)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างลิสต์')),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                // ใช้ Expanded เพื่อให้ Dropdown กินพื้นที่ส่วนใหญ่ที่เหลือ
                Expanded(
                  flex:
                      2, // ปรับสัดส่วนความกว้าง (ถ้าต้องการให้กว้างกว่า checkbox)
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectController.text,
                    items: optionType.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['value'],
                        child: Text(item['label']!),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectController.text =
                            newValue!; // อัปเดตค่าเข้า Controller
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: CheckboxListTile(
                    title: const Text("Required Date"),
                    value: _checkController.text == "true",
                    onChanged: (bool? value) {
                      setState(() {
                        _checkController.text = value.toString();
                      });
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, // เอาติ๊กถูกไว้ด้านหน้า
                    contentPadding: EdgeInsets.zero, // ลดพื้นที่ว่างด้านข้าง
                  ),
                ),
              ],
            ),
            const Spacer(), // const SizedBox(height: 15),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _createList,
                    child: const Text('Save New'),
                  ),
          ],
        ),
      ),
    );
  }
}
