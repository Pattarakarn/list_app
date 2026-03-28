import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app_colors.dart';
import 'package:flutter/cupertino.dart'; // 👈 เพิ่มบรรทัดนี้
import 'package:firebase_auth/firebase_auth.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _contentController = TextEditingController();
  bool isLock = false;
  final user = FirebaseAuth.instance.currentUser;
  // final LocalAuthentication auth = LocalAuthentication();

  // // เช็กว่า Browser หรืออุปกรณ์นี้รองรับไหม
  // final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  // final bool isSupported = await auth.isDeviceSupported();

  // if (canAuthenticateWithBiometrics || isSupported) {
  //    // ทำการยืนยันตัวตน
  // } else {
  //    // กรณีรันบน Web แล้วเครื่องไม่มีที่สแกนนิ้ว/FaceID
  //    ScaffoldMessenger.of(context).showSnackBar(
  //      const SnackBar(content: Text('อุปกรณ์นี้ไม่รองรับการยืนยันตัวตน')),
  //    );
  // }

  Future<void> _createList() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('notes').add({
        'name': _nameController.text,
        'content': _contentController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'lock': isLock,
        'authorId': user?.uid,
      });

      if (mounted) Navigator.pop(context);
      // Navigator.pop(context, _nameController.text);
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. ฟังก์ชันสร้างหน้าจอ (ต้องมี @override Widget build เสมอ!)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างโน้ต')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Switch(
            //   value: isLock,
            //   activeColor: Colors.green, // สีตอนเปิด
            //   onChanged: (bool value) {
            //     setState(() {
            //       isLock = value; // อัปเดตสถานะ
            //     });
            //   },
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Lock '),
                CupertinoSwitch(
                  value: isLock,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      isLock = value;
                    });
                  },
                ),
              ],
            ),
            //  CupertinoListTile(
            //   title: const Text("สถานะการล็อก"),
            //   trailing: CupertinoSwitch(
            //     value: isLock,
            //     onChanged: (value) => setState(() => isLock = value),
            //   ),
            // )
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // textarea
            TextField(
              maxLines: 5,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Note here',
                border: OutlineInputBorder(),
              ),
              controller: _contentController,
            ),
            //ลงเพิ่ม flutter_quill
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width:
                        MediaQuery.of(context).size.width * 0.5, // ครึ่งจอพอดี
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColors.note,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      onPressed: _createList,
                      child: const Text('บันทึก'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
