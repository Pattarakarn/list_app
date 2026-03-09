import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import '../../app_colors.dart';
import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

    StreamSubscription? _internetSubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    // 2. เริ่มฟังทันทีที่เปิดหน้านี้
    _internetSubscription = InternetConnection().onStatusChange.listen((
      status,
    ) {
      if (status == InternetStatus.connected) {
        setState(() => _isConnected = true);
        _showSnackBar("เชื่อมต่ออินเทอร์เน็ตแล้ว", Colors.green);
      } else {
        setState(() => _isConnected = false);
        _showSnackBar("ไม่มีการเชื่อมต่ออินเทอร์เน็ต!", Colors.red);
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).clearSnackBars(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    super.dispose();
  }

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
  String? _errorMessage ;
  Future<void> _Login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      print(credential);
     setState(() {
    _errorMessage = null; 
  });
    } on FirebaseAuthException catch (e) {
     setState(() {
    _errorMessage = 'ข้อมูลไม่ถูกต้อง'; 
  });
      print("เกิดข้อผิดพลาด: ${e.message}");
    }
  }

  Future<void> _Signup() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email.trim().toLowerCase(), password: password);
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
      backgroundColor: Colors.black87,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ), // เว้นขอบข้าง 16
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
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
                  decoration: InputDecoration(labelText: 'Email',
                  errorText:(_errorMessage?.isEmpty ?? true) ? null : ''),
                  onChanged: (val) => email = val,
                  style: TextStyle(color: Colors.white),
        //           validator: (value) {
        //   if (value == null || value.isEmpty) {
        //     return 'กรุณากรอกอีเมล';
        //   }
        //   if (!value.contains('@')) {
        //     return 'รูปแบบอีเมลไม่ถูกต้อง';
        //   }
        //   return null; // ผ่าน!
        // },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Password',
                    errorText: _errorMessage,),
                    obscureText: true,
                    onChanged: (val) => password = val,
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    _Login();
                  },
                  child: Text('Login to LisT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFFF6B00,
                    ), //AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)), // เส้นซ้าย
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "หรือ",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1)), // เส้นขวา
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0), // ห่างทุกด้าน
                  // child: OutlinedButton(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    // child: ShaderMask(
                    // shaderCallback: (bounds) => const LinearGradient(
                    //   colors: [
                    //     Color(0xFF4285F4), // Blue
                    //     Color(0xFFEA4335), // Red
                    //     Color(0xFFFBBC05), // Yellow
                    //     Color(0xFF34A853), // Green
                    //   ],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ).createShader(bounds),
                    child: Text("Login with Google"),
                    // ),
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
        ),
      ),
    );
  }
}
