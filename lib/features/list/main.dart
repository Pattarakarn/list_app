import 'package:flutter/material.dart';
import 'list_detail.dart';
import 'list_create.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:list_app/features/list/list_detail.dart'; // <--- ต้องมีบรรทัดนี้
import 'package:list_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';

class MyListsPage extends StatefulWidget {
  const MyListsPage({super.key});

  @override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {

  void confirmArchive(BuildContext context, docId, name) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text("Are you sure you want to delete '$name'?"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('lists')
                  .doc(docId)
                  .update({'isArchived': true});
              Navigator.pop(context);
            },
            child: const Text('ลบข้อมูล'),
            isDestructiveAction: true,
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true, // ทำให้ตัวหนา
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก', style: TextStyle(color: Colors.blue)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text("กรุณาล็อกอินใหม่");
    }
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lists')
            .where('authorId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('ยังไม่มีรายการ'));
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 85),
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final docId = docs[index].id;
                // if (index == docs.length) {
                //   return const SizedBox(height: 100.0);
                // }
                return InkWell(
                  onLongPress: () async {
                    confirmArchive(context, docId, data['name']);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    color: Theme.of(
                      context,
                    ).scaffoldBackgroundColor, //cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: data['type'] == 'Checklist'
                            ? context.primaryColor
                            : Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading: data['type'] == 'Table'
                          ? Icon(Icons.table_chart, color: context.primaryColor)
                          : Icon(
                              Icons.checklist,
                              color: Theme.of(context).colorScheme.secondary,
                            ),

                      // leading: SvgPicture.asset(
                      //   'assets/icons/table.svg',
                      //   width: 24,
                      //   height: 24,
                      //   // colorFilter: ColorFilter.mode(Colors.blue, BoxType.srcIn), // เปลี่ยนสีได้ด้วย!
                      // ),
                      title: Text(data['name'] ?? 'ว่าง'),
                      subtitle: Text(
                        data['createdAt'] != null
                            // ? (data['createdAt'] as Timestamp).toDate().toString()
                            ? DateFormat('dd/MM/yyyy HH:mm').format(
                                (data['createdAt'] as Timestamp).toDate(),
                              )
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
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: context.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateListPage()),
          );
          // 2. ถ้าได้ชื่อกลับมา ให้เพิ่มลงในลิสต์
          if (result != null && result is String) {
            // setState(() {
            //   _items.add(result);
            // });
          }
        },
      ),
    );
  }
}
