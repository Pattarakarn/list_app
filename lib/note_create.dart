import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_colors.dart';

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

  Future<void> _createList() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('notes').add({
        'name': _nameController.text,
        'content': _contentController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'lock': false,
      });

      if (mounted) Navigator.pop(context);

      Navigator.pop(context, _controller.text);
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
                        backgroundColor: AppColors.primary,
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
