import 'package:flutter/material.dart';
import 'note_detail.dart';
import 'note_create.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:list_app/note_detail.dart';
import 'app_colors.dart';

class RandomP extends StatefulWidget {
  const RandomP({super.key});

  @override
  State<RandomP> createState() => _RandomPState();
}

class _RandomPState extends State<RandomP> {
  final List<String> _items = ["โปรเจกต์ที่ 1"];

  void _deleteItem({required String id, String? name}) {
    String inputText = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบรายการโน้ตนี้หรือไม่'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text('random');
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('random')
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
            return Text('');
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              String itemName = data['name'] ?? 'Unnamed';
              print(docId);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                clipBehavior: Clip
                    .antiAlias, // สำคัญ: เพื่อให้สี Hover ไม่ทะลุขอบมนของ Card
                child: InkWell(
                  onTap: () {}, // ต้องมี onTap เพื่อให้เอฟเฟกต์ Hover ทำงาน
                  hoverColor: AppColors.note.withOpacity(0.2),
                  child: ListTile(
                    // leading: const CircleAvatar(child: Icon(Icons.delete)),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _deleteItem(id: docId, name: itemName),
                      hoverColor: AppColors.danger,
                      highlightColor: AppColors.danger.withOpacity(0.2),
                      color: Colors.white,
                      // mouseCursor: SystemMouseCursors.click,
                      iconSize: 18,
                    ),

                    title: Text(data['name'] ?? 'ไม่มีชื่อ'),
                    subtitle: Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format((data['createdAt'] as Timestamp).toDate()),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(title: itemName, docId: docId),
                        ),
                      );
                    },
                    // trailing: IconButton(
                    //   // icon: const Icon(Icons.delete, color: Colors.red),
                    // ),
                    trailing: const Icon(Icons.lock, color: AppColors.primary),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNotePage()),
          );

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
