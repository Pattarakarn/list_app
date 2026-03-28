import 'package:flutter/material.dart';
import 'note_detail.dart';
import 'note_create.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:list_app/features/note/note_detail.dart';
import '../../app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
// import 'package:local_auth_android/local_auth_android.dart';
// import 'package:local_auth_ios/local_auth_ios.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class AuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> authenticateUser(
    BuildContext context,
    String itemName,
    String docId,
  ) async {
    try {
      // 1. เช็กก่อนว่าเครื่องนี้รองรับการสแกนไหม และเปิดใช้งานอยู่ไหม
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        // แจ้งเตือนว่าเครื่องไม่รองรับ
        print('can t');
      }

      // 2. เริ่มการสแกน (Pop-up ของระบบจะเด้งขึ้นมาเอง)
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'กรุณาสแกนใบหน้าหรือลายนิ้วมือเพื่อเข้าดูข้อมูล',
        // authMessages:  <AuthMessages>[
        //   AndroidAuthMessages(
        //     signInTitle: 'ยืนยันตัวตน',
        //     cancelButton: 'ยกเลิก',
        //   ),
        //   IOSAuthMessages(cancelButton: 'ยกเลิก'),
        // ],
        biometricOnly:
            false, // วางไว้ตรงๆ แบบนี้เลย ไม่ต้องมี AuthenticationOptions
        // stickyAuth: true,
        // useErrorDialogs: true,
        // // options:  AuthenticationOptions(
        // options: const AuthenticationOptions(
        //   stickyAuth: true, // ให้แอปพยายามสแกนต่อถ้า User สลับแอปไปมา
        //   biometricOnly:
        //       false, // true = บังคับใช้แค่ Biometric เท่านั้น (ไม่เอา PIN)
        // ),
      );

      if (didAuthenticate) {
        // สแกนผ่านแล้ว! ทำงานที่ต้องการต่อที่นี่
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(title: itemName, docId: docId),
          ),
        );
      } else {
        // ผู้ใช้ยกเลิก หรือสแกนไม่ผ่าน
      }
    } catch (e) {
      print("เกิดข้อผิดพลาด: $e");
    }
  }
}

class _NotesPageState extends State<NotesPage> {
  final List<String> _items = ["โปรเจกต์ที่ 1"];
  final user = FirebaseAuth.instance.currentUser;
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
          // ElevatedButton(
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('notes')
                  .doc(id)
                  .delete();
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
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .where('authorId', isEqualTo: user?.uid)
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
              bool isLock = data['lock'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                clipBehavior: Clip
                    .antiAlias, // สำคัญ: เพื่อให้สี Hover ไม่ทะลุขอบมนของ Card
                child: InkWell(
                  // !ต้องมี onTap เพื่อให้เอฟเฟกต์ Hover ทำงาน
                  hoverColor: AppColors.note.withOpacity(0.1),
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
                      if (isLock) {
                        AuthService().authenticateUser(
                          context,
                          itemName,
                          docId,
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailPage(title: itemName, docId: docId),
                          ),
                        );
                      }
                    },
                    // trailing: IconButton(
                    //   // icon: const Icon(Icons.delete, color: Colors.red),
                    // ),
                    trailing: isLock
                        ? const Icon(Icons.lock, color: AppColors.primary)
                        : null,
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
