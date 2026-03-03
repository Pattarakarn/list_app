import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
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

  String email = "";
  String password = "";
  Future<void> _Login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(credential);
    } on FirebaseAuthException catch (e) {
      print("เกิดข้อผิดพลาด: ${e.message}");
    }
  }

  Future<void> _Signup() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      print(credential);
    } on FirebaseAuthException catch (e) {
      print("เกิดข้อผิดพลาด: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ต้องเริ่มด้วย Scaffold เสมอ
      // appBar: AppBar(title: const Text('เข้าสู่ระบบ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Icon(Icons.auto_awesome, size: 100, color: Colors.blue),
            // const SizedBox(height: 20),
            const Text(
              'ยินดีต้อนรับ!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (val) => email = val,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => password = val,
              ),
            ),

            ElevatedButton(
              onPressed: () {
                _Login();
              },
              child: Text('Login to LisT'),
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: Divider(thickness: 1)), // เส้นซ้าย
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("หรือ"),
                ),
                Expanded(child: Divider(thickness: 1)), // เส้นขวา
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0), // ห่างทุกด้าน
              child: OutlinedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
