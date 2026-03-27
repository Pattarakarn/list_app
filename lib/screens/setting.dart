import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../app_colors.dart';
import 'welcome.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return const Text("กรุณาล็อกอินใหม่");
    }
    return Scaffold(
      appBar: AppBar(title: const Text("ตั้งค่า"), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 20),
              //     child: Align(
              //       alignment: Alignment.centerLeft,
              //       child: const Text(
              //         'profile',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    // color: Theme.of(context).brightness == Brightness.dark
                    //     ? const Color(0xFF334155).withOpacity(0.7)
                    //     : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text("Hide displayname"),
                        value: true, //_isVisible,
                        onChanged: (bool? value) {
                          // setState(() {
                          //   _isVisible = value ?? false; // อัปเดตสถานะเมื่อกด
                          // });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // เอาติ๊กถูกไว้ด้านหน้า
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text("Edit Profile"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),

              // ListTile(
              //   leading: const Icon(Icons.notifications_none),
              //   title: const Text("การแจ้งเตือน"),
              //   trailing: const Icon(Icons.chevron_right),
              //   onTap: () {},
              // ),
              // ListTile(
              //   leading: const Icon(Icons.lock_outline),
              //   title: const Text("ความเป็นส่วนตัว"),
              //   trailing: const Icon(Icons.chevron_right),
              //   onTap: () {},
              // ),
              const Spacer(), // !ดัน ทุกอย่างที่อยู่ข้างล่างมันให้ลงไปล่างสุด

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gray,
                  foregroundColor: Colors.blue,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  //                 final prefs = await SharedPreferences.getInstance();
                  // await prefs.setString('user_token', 'ค่า_token_ที่ได้จาก_backend');
                  // await prefs.remove('user_token');
                  // แล้วสั่ง Navigator.pushReplacement ไปหน้า Login
                },
                child: const Text("ออกจากระบบ"),
              ),
              const SizedBox(height: 10), // เว้นระยะจากขอบล่างสุดเล็กน้อย
            ],
          ),
        ),
      ),
    );
  }
}
