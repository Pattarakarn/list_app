import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app_colors.dart';
import 'calculator.dart';
import 'setting.dart';
import 'fuel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // String? _selectedGender;
    if (user == null) return Center(child: Text("กรุณาล็อกอินใหม่"));
    Map<String, dynamic> userData = {};

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final doc = snapshot.data;

        if (snapshot.hasError)
          return const Center(child: Text('เกิดข้อผิดพลาด'));
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        //       if (doc == null || !doc.exists) {
        //   return const Text("Document does not exist");
        // }
        if (snapshot.hasData) {
          // var data = snapshot.data!.data() as Map<String, dynamic>?;
          // เติม ? หลัง Map เพื่อบอกว่ามันอาจจะเป็น null ได้
          // final userData = data ?? {'displayName': '', 'email': 'example.com'};
          userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        }

        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F172A)
              : Colors.white,
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.manage_accounts),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingPage( userData)),
                  );
                },
              ),
              const SizedBox(width: 8), // เว้นระยะห่างจากขอบขวาเล็กน้อย
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              // !ป้องกันจอเล็กแล้วเลื่อนไม่ได้
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 46, // ขนาดรวมเส้นขอบ (รัศมีรูป 50 + ขอบ 4)
                          backgroundColor: (userData['sex'] == "หญิง")
                              ? AppColors.pink
                              : AppColors.blue,
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                              // color:  (user?.isEmailVerified )? AppColors.pink : AppColors.blue,
                            ),
                            backgroundImage: NetworkImage(user.photoURL ?? ''),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData['displayName'] ?? '✨',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email as String,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Personal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // // สมุดเบาใจ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF334155).withOpacity(0.7)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.favorite,
                              color: Colors.pink,
                            ),
                            title: const Text('Last will'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalculatorPage(),
                                ),
                              );
                            },
                          ),
                          // const Divider(height: 1),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Tools',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // --- รายการเครื่องมือ (List Items) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF334155).withOpacity(0.7)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.calculate,
                              color: Colors.orange,
                            ),
                            title: const Text('คำนวณ'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalculatorPage(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.local_gas_station,
                              color: Colors.blue,
                            ),
                            title: const Text('อัตราสิ้นเปลือง'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FuelScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        // return Scaffold(
        //   body:  Column(
        //     mainAxisSize:MainAxisSize.min, // ! Columnสูงแค่เท่าที่จำเป็น
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.all(16),
        //         decoration: BoxDecoration(
        //           boxShadow: [
        //             BoxShadow(
        //               color: Colors.black.withOpacity(0.05),
        //               blurRadius: 10,
        //             ),
        //           ],
        //         ),
        //         child: Row(
        //           children: [
        //             CircleAvatar(
        //               radius: 40,
        //               backgroundColor: Colors.white,
        //               child: Icon(
        //                 Icons.person,
        //                 size: 50,
        //                 // color:  (user?.isEmailVerified )? AppColors.pink : AppColors.blue,
        //                 color: (userData['sex'] == "หญิง")
        //                     ? AppColors.pink
        //                     : AppColors.blue,
        //               ),
        //               backgroundImage: NetworkImage(user.photoURL ?? ''),
        //             ),

        //             const SizedBox(width: 20),
        //             // 2. ข้อมูลด้านขวา (ใช้ Expanded เพื่อให้กินพื้นที่ที่เหลือและไม่ดันจอ)
        //             Expanded(
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Row(
        //                     children: [
        //                       Text(
        //                         userData['displayName'] ?? '✨',
        //                         style: const TextStyle(
        //                           fontSize: 20,
        //                           fontWeight: FontWeight.bold,
        //                         ),
        //                       ),
        //                       IconButton(
        //                         icon: const Icon(Icons.edit, size: 20),
        //                         onPressed: () {
        //                           _showEditNameDialog();
        //                         },
        //                       ),
        //                     ],
        //                   ),

        //                   Text(
        //                     user.email as String,
        //                     style: TextStyle(
        //                       color: Colors.grey[600],
        //                       fontSize: 14,
        //                     ),
        //                   ),
        //                   // Text(userData?['displayName'] ?? ''),
        //                   // Text(userData?['email']),
        //                   // isEmailVerified
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // );
      },
    );
  }
}
