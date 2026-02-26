import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // สำหรับจัดการวันที่
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String docId;

  const DetailPage({super.key, required this.title, required this.docId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isInitialized = false;
  String name = '';
  String content = '';

  void _updateData() async {
    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.docId)
          .update({'name': name, 'content': content, 'lock': true});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกข้อมูลสำเร็จ!'),
          backgroundColor: Colors.green,
          behavior:
              SnackBarBehavior.floating, // ต้องใส่ตัวนี้ถึงจะกำหนด width ได้
          width: MediaQuery.of(context).size.width * 0.5,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(10),
          // ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .doc(widget.docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('เกิดข้อผิดพลาด'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!isInitialized) {
            // var docData = snapshot.data?.data() as Map<String, String>?;
            var docData = snapshot.data!.data() as Map<String, dynamic>?;
            print(docData);
            if (docData != null) {
              name = docData['name'];
              content = docData['content'];
            }
            isInitialized = true;
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: name),
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
                  controller: TextEditingController(text: content),
                ),
                // RichText(
                //   text: TextSpan(
                //     style: TextStyle(color: Colors.black, fontSize: 18), // สไตล์หลัก
                //     children: [
                //       TextSpan(text: 'Hello '),
                //       TextSpan(
                //         text: 'Flutter',
                //         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                //       ),
                //       TextSpan(text: ' Developer!'),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: FloatingActionButton.extended(
          onPressed: _updateData,
          // icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ),
    );
  }
}
