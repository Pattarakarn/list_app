import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  // บรรทัดที่5กับ6 ชื่อต้องตรงกัน
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Future<void> signInWithGoogle() async {
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // เรียกใช้ผ่านตัวแปรที่เราสร้างไว้
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print(googleUser);

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'ยินดีต้อนรับ!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // const Text('เลือกเมนูด้านซ้ายเพื่อเริ่มต้นใช้งาน'),
          ElevatedButton(
            child: Text("Login with Google"),
            onPressed: () async {
              UserCredential? user = await signInWithGoogle();
              if (user != null) {
                print("Login สำเร็จ: ${user.user?.displayName}");
                // เมื่อ authen แล้ว ข้อมูลนี้จะถูกส่งไปพร้อมสิทธิ์ของ user คนนั้นทันที
                // FirebaseFirestore.instance.collection('users').doc(uid).update({
                //   'last_login': DateTime.now(),
                // });
                // เปลี่ยนหน้าไป Home
              }
            },
          ),
        ],
      ),
    );
  }
}
