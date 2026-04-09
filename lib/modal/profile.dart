import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModalProfile extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ModalProfile({super.key, required this.userData});
  @override
  _ModalProfileState createState() => _ModalProfileState();
}

class _ModalProfileState extends State<ModalProfile> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final controller = TextEditingController(text: widget.userData['displayName'] ?? '');
    String? _selectedGender = widget.userData['sex'] ?? 'ชาย';

    return AlertDialog(
      title: const Text('แก้ไข'),
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        // กันหน้าจอล้น
        child: Column(
          mainAxisSize: MainAxisSize.min, // ให้ สูงเท่ากับเนื้อหาข้างใน
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "กรอกชื่อใหม่",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // ปรับความโค้งของมน
                ),
                // focusedBorder: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(12),
                //   borderSide: const BorderSide(color: Colors.blue, width: 2),
                // ),
                // enabledBorder: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(12),
                //   borderSide: BorderSide(color: Colors.grey.shade400),
                // ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'เพศ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                // prefixIcon: const Icon(Icons.people),
              ),
              hint: const Text('เลือกหรือไม่เลือกก็ได้'),
              items: const [
                DropdownMenuItem(value: 'ชาย', child: Text('ชาย')),
                DropdownMenuItem(value: 'หญิง', child: Text('หญิง')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'กรุณาเลือกเพศก่อนบันทึก' : null,
            ),
          ],
        ),
      ),
      actions: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .set({
                    'displayName': controller.text,
                    'sex': _selectedGender,
                  });
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ),
      ],
    );
  }
}


// class Widget {
  // static void ex(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('หัวข้อแจ้งเตือน'),
  //         content: const Text('นี่คือ Dialog ที่แยกออกมาจากไฟล์หลัก'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('ปิด'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }