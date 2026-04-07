import 'package:flutter/material.dart';
import 'screens/profile.dart';
import 'features/list/main.dart';
import 'app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/note/main.dart';
import 'screens/welcome.dart';
import 'features/random/main.dart';
import 'features/health/main.dart';
import '../utils/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase เชื่อมต่อไม่สำเร็จ: $e");
  }

  runApp(
    MaterialApp(
      title: 'LisT',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          primary: const Color(0xFFFF6B00),
          seedColor: const Color(0xFFFF6B00),
          secondary: const Color(0xFFFF9E00),
        ),
        hoverColor: Colors.orange.withOpacity(0.1),

        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        // colorScheme: const ColorScheme.dark(primary: Color(0xFFFF6B00)),
      ),
      themeMode: ThemeMode.system,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return HomeScreen();
          }
          print('pls');
          return const LoginPage();
        },
      ),
      //         final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('user_token');
      // if (token != null) {
      //   // พาไปหน้า Home
      // }
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const ProfilePage(),
    const MyListsPage(),
    const NotesPage(),
    const RandomP(),
    const HealthPage(),
  ];
  bool _isExpanded = true;
  final user = FirebaseAuth.instance.currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Widget _navItem(
    IconData icon,
    String label,
    dynamic color,
    int index,
    VoidCallback onTap,
  ) {
    bool _isHovered = false;
    Color baseColor = color is List<Color> ? color[0] : color;
    return InkWell(
      onTap: () {
        if (_isExpanded) {
          _isExpanded = false;
          } else {
            onTap();
        }
        setState(() => _selectedIndex = index);
      },
      onHover: (hovering) {
        /* จัดการตอน hover */
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.grey : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              color is List<Color>
                  ? ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: color,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 26,
                      ), // ขาวเพื่อรับสีรุ้ง
                    )
                  : Icon(icon, color: color, size: 26), // สีปกติ

              const SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  // ถ้าเป็น Gradient ให้เลือกสีที่เข้มที่สุดในลิสต์มาใช้กับ Text (หรือกำหนดสีเทาไปเลยก็ได้)
                  // color: color is List<Color> ? color[1] : color,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingItems() {
    final List<Map<String, dynamic>> menuItems = AppMenus.mainNavItems;

    if (_selectedIndex >= 1 && !_isExpanded) {
      var current = menuItems[_selectedIndex - 1];
      return [
        _navItem(
          current['icon'],
          current['label'],
          current['color'],
          current['index'],
          () {
            setState(() => _isExpanded = !_isExpanded);
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _isExpanded = true),
        ),
      ];
    }

    // กรณีหน้าแรก (Index 0) หรือกดขยายแล้ว ให้โชว์ทั้งหมด
    return [
      ...menuItems.map(
        (item) => _navItem(
          item['icon'],
          item['label'],
          item['color'],
          item['index'],
          () => {},
        ),
      ),
    ];
  }

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
        // _showSnackBar("เชื่อมต่ออินเทอร์เน็ตแล้ว", Colors.green);
      } else {
        setState(() => _isConnected = false);
        _showSnackBar("ไม่มีการเชื่อมต่ออินเทอร์เน็ต!", Colors.grey);
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).clearSnackBars(); // ลบอันเก่าออกก่อนเด้งอันใหม่
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
    // !ปิดการฟังเมื่อปิดหน้าจอ เพื่อไม่ให้เปลือง Memory
    _internetSubscription?.cancel();
    super.dispose();
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ออกจากแอป?"),
        content: const Text("คุณต้องการออกจากแอปใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ตกลง"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false), // ส่งค่า false (ไม่ออก)
            child: const Text("ยกเลิก"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return PopScope(
      canPop: false, // 1. สั่งห้ามไม่ให้ย้อนกลับทันที
      onPopInvokedWithResult: (didPop, result) async {
        // ถ้าการย้อนกลับเกิดขึ้นไปแล้ว (เช่น สั่ง pop จากที่อื่น) ไม่ต้องทำอะไร
        if (didPop) return;

        // 2. เรียกฟังก์ชันแสดง Dialog ถามผู้ใช้
        final shouldPop = await _showExitDialog(context);

        // 3. ถ้าผู้ใช้กด "ใช่" (true) ให้สั่งออกจากแอป/หน้าจอด้วยตัวเอง
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // backgroundColor: AppColors.gray,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                top: _selectedIndex == 0 ? 0 : 50,
                // bottom: 78,
                child: SafeArea(child: _pages[_selectedIndex]),
              ),
              // Visibility(  visible: index != 0,
              if (_selectedIndex != 0)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 5, 24, 3),
                    color: Colors.grey[200],
                    child: GestureDetector(
                      onTap: () => {setState(() => _selectedIndex = 0)},
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person_rounded,
                              // color: AppColors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(user?.displayName ?? user?.email ?? '',
                            // (((user?.email?.length ?? 0) > 4
                            //         // && user?.isAnonymous == true
                            //         ? "${user?.email?.substring(0, 4)}@"
                            //         : user?.email) ??
                            //     ''),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // IconButton(
                          //   icon: const Icon(
                          //     Icons.more_vert_rounded,
                          //     // Icons.settings,//_suggest,
                          //     // Icons.manage_accounts,
                          //     color: Colors.black54,
                          //   ),
                          //   onPressed: () {
                          //     _showLogoutDialog(context);
                          //   },
                          // ),

                          // PopupMenuButton<String>(
                          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          //   icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
                          //   onSelected: (value) {
                          //     if (value == 'logout') {

                          //     }
                          //   },
                          //   itemBuilder: (context) => [
                          //     const PopupMenuItem(
                          //       value: 'logout',
                          //       child: Row(
                          //         children: [
                          //           Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                          //           SizedBox(width: 10),
                          //           Text("ออกจากระบบ", style: TextStyle(color: Colors.red)),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),

              Positioned(
                bottom: 15, // ให้ลอยจากขอบล่าง 20
                left: 20,
                right: 20,
                child: isKeyboardOpen
                    ? const SizedBox.shrink() // ถ้าเปิดแป้นพิมพ์ ให้ซ่อน
                    : Align(
                        alignment: Alignment.bottomLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          // height: 70, BOTTOM OVERFLOW BY 9.0 PIXELS
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                              ),
                            ],
                          ),

                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: _selectedIndex == 0
                                  ? MainAxisSize.max
                                  : MainAxisSize.min,
                              children: _buildFloatingItems(),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension ThemeGetter on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
}
