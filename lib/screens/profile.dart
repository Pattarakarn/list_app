import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

    @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
      String? _selectedGender;

    Future<void> updateProfile(
      String firstName,
      String lastName,
      String gender,
    ) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'first_name': firstName,
            'last_name': lastName,
            'gender': gender,
            'updated_at': DateTime.now(),
          },
          SetOptions(merge: true),
        ); // merge: true คือการอัปเดตเฉพาะฟิลด์ที่ส่งไป ไม่ลบอันเก่า
      }
    }

    void _showEditNameDialog(String? currentName) {
      final controller = TextEditingController(text: currentName);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('แก้ไข'),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            // กันหน้าจอล้น
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // ให้ Column สูงเท่ากับเนื้อหาข้างใน
              children: [
                TextField(
                  controller: controller,
                  decoration:  InputDecoration(hintText: "กรอกชื่อใหม่",
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
                // Gap(10), //flutter pub add gap
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .set({'displayName': controller.text, 'sex': _selectedGender});
                Navigator.pop(context);
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      );
    }

    if (user == null) return Center(child: Text("กรุณาล็อกอินใหม่"));
    return Scaffold(
      body: Column(
        mainAxisSize:
            MainAxisSize.min, // สำคัญ! บอกให้ Column สูงแค่เท่าที่จำเป็น
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    // color:  (user?.isEmailVerified )? AppColors.pink : AppColors.blue,
                  ),
                  backgroundImage: NetworkImage(user.photoURL ?? ''),
                ),

                const SizedBox(width: 20),
                // 2. ข้อมูลด้านขวา (ใช้ Expanded เพื่อให้กินพื้นที่ที่เหลือและไม่ดันจอ)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.displayName ?? '✨',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              _showEditNameDialog(user.displayName);
                            },
                          ),
                        ],
                      ),

                      Text(
                        user.email as String,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      // Text(userData?['displayName'] ?? ''),
                      // Text(userData?['email']),
                      // isEmailVerified
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // // ต้องทำอันนี้ก่อน
    // // if (user != null) {
    // //     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    // //       'first_name': firstName,
    // //       'last_name': lastName,
    // //       'gender': gender,
    // //       'updated_at': DateTime.now(),
    // //     }, SetOptions(merge: true)); // merge: true คือการอัปเดตเฉพาะฟิลด์ที่ส่งไป ไม่ลบอันเก่า
    // //   }
    //     return StreamBuilder<DocumentSnapshot>(
    //       stream: FirebaseFirestore.instance
    //           .collection('users')
    //           .doc(user?.uid)
    //           .snapshots(),
    //       builder: (context, snapshot) {
    //         if (snapshot.hasData) {
    //           var data = snapshot.data!.data() as Map<String, dynamic>?;
    //           // เติม ? หลัง Map เพื่อบอกว่ามันอาจจะเป็น null ได้
    //           final userData = data ?? {'displayName': '', 'email': 'example.com'};
    //           print(user?.uid);

    //           // Padding(padding: const EdgeInsets.symmetric(vertical: 20.0),
    //           return Column(
    //             mainAxisSize:  MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               // --- ส่วน Header Profile ---
    //               Container(
    //                 padding: const EdgeInsets.all(
    //                   16,
    //                 ),
    //                 decoration: BoxDecoration(
    //                   // color: Colors.white,
    //                   boxShadow: [
    //                     BoxShadow(
    //                       color: Colors.black.withOpacity(0.05),
    //                       blurRadius: 10,
    //                     ),
    //                   ],
    //                 ),
    //                 child: Row(
    //                   children: [
    //                     CircleAvatar(
    //                       radius: 40,
    //                       backgroundColor: Colors.white,
    //                       child: const Icon(
    //                         Icons.person,
    //                         size: 50,
    //                         color: Colors.purple,
    //                       ),
    //                       // backgroundImage: NetworkImage(userData?['photoURL'] ?? ''),
    //                     ),
    //                     const SizedBox(width: 20),
    //                     Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Row(
    //                             children: [
    //                               Text(
    //                                 userData?['displayName'] ?? 'ยังไม่ได้ตั้งชื่อ',
    //                                 style: const TextStyle(
    //                                   fontSize: 20,
    //                                   fontWeight: FontWeight.bold,
    //                                 ),
    //                               ),
    //                               IconButton(
    //                                 icon: const Icon(Icons.edit, size: 20),
    //                                 onPressed: () {
    //                                   _showEditNameDialog(userData['displayName']);
    //                                 },
    //                               ),
    //                             ],
    //                           ),
    //                           // Text("ชื่อ: ${userData?['first_name']}"),
    //                           // Text("นามสกุล: ${userData?['last_name']}"),
    //                           // Text("เพศ: ${userData?['gender']}"),
    //                           Text(
    //                             userData?['email'],
    //                             style: TextStyle(
    //                               color: Colors.grey[600],
    //                               fontSize: 14,
    //                             ),
    //                           ),
    //                           // Text(userData?['displayName'] ?? ''),
    //                           // Text(userData?['email']),
    //                           // isEmailVerified
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           );
    //         }
    //         return CircularProgressIndicator();
    //       },
    //     );
  }
  }

