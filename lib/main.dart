import 'package:flutter/material.dart';
import 'screens/profile.dart';
import 'features/list/main.dart';
import 'app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/note/main.dart';
import 'screens/welcome.dart';
import 'features/random/main.dart';
// import 'features/health/main.dart';
import '../utils/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          primary: const Color(0xFFFF6B00),
          seedColor: const Color(0xFFFF6B00),
          secondary: const Color(0xFFFF9E00),
        ),
        hoverColor: Colors.orange.withOpacity(0.1),
      ),

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
  // const MainNavigation({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFFF3F7F9),
  //     // ใช้ Stack เพื่อจัดวางเลเยอร์
  //     body: Stack(
  //       children: [
  //         // ส่วนนี้จะปล่อยให้ Scroll ได้เต็มจอ
  //         Positioned.fill(
  //           child: ListView(
  //             padding: const EdgeInsets.fromLTRB(
  //               24,
  //               120,
  //               24,
  //               120,
  //             ), // เผื่อที่ให้ Header และ Nav
  //             children: [
  //               const Text(
  //                 "โน้ตล่าสุด",
  //                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 20),
  //               _buildNoteCard("ไอเดีย", "อยากลองหัดเขียน Flutter ให้เก่งๆ"),
  //             ],
  //           ),
  //         ),

  //         Positioned(
  //           top: 0,
  //           left: 0,
  //           right: 0,
  //           child: Container(
  //             padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //                 colors: [
  //                   const Color(0xFFF3F7F9),
  //                   const Color(0xFFF3F7F9).withOpacity(0.0),
  //                 ],
  //               ),
  //             ),
  //             child: GestureDetector(
  //               // onTap: () => _showLogoutDialog(context),
  //               child: Row(
  //                 children: [
  //                   CircleAvatar(
  //                     radius: 22,
  //                     backgroundColor: Colors.white,
  //                     child: Icon(Icons.person_rounded, color: AppColors.blue),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   const Text(
  //                     "คุณ ✨",
  //                     style: TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const Spacer(),
  //                   IconButton(
  //                     icon: const Icon(
  //                       Icons.more_vert_rounded,
  //                       color: Colors.black54,
  //                     ),
  //                     onPressed: () {
  //                       _showLogoutDialog(context);
  //                     },
  //                   ),
  //                   // PopupMenuButton<String>(
  //                   //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //                   //   icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
  //                   //   onSelected: (value) {
  //                   //     if (value == 'logout') {

  //                   //     }
  //                   //   },
  //                   //   itemBuilder: (context) => [
  //                   //     const PopupMenuItem(
  //                   //       value: 'logout',
  //                   //       child: Row(
  //                   //         children: [
  //                   //           Icon(Icons.logout_rounded, color: Colors.red, size: 20),
  //                   //           SizedBox(width: 10),
  //                   //           Text("ออกจากระบบ", style: TextStyle(color: Colors.red)),
  //                   //         ],
  //                   //       ),
  //                   //     ),
  //                   //   ],
  //                   // ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),

  //         Positioned(
  //           bottom: 30,
  //           left: 20,
  //           right: 20,
  //           child: Container(
  //             height: 70,
  //             decoration: BoxDecoration(
  //               // color: Colors.white.withOpacity(0.95),
  //               color: AppColors.primary.withOpacity(0.05),
  //               borderRadius: BorderRadius.circular(35),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 20,
  //                   offset: const Offset(0, 10),
  //                 ),
  //               ],
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _navItem(IconData icon, String label, Color color) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Icon(icon, color: color, size: 26),
  //       Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
  //     ],
  //   );
  // }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const ProfilePage(),
    const MyListsPage(),
    const NotesPage(),
    const RandomP(),
    const RandomP(),
    // const HealthPage(),
  ];
  bool _isExpanded = true;
  final user = FirebaseAuth.instance.currentUser;

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        // margin: const EdgeInsets.only(bottom: 100),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ตั้งค่า",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
                Navigator.pop(context);
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
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    dynamic color,
    // VoidCallback onTap,
    int index,
  ) {
    bool _isHovered = false;
    Color baseColor = color is List<Color> ? color[0] : color;
    return InkWell(
      // onTap: onTap,
      onTap: () {
        _isExpanded = false;
        setState(() => _selectedIndex = index);
      },
      onHover: (hovering) {
        /* จัดการตอน hover */
      },
      borderRadius: BorderRadius.circular(15), // ให้ขอบสีอ่อนโค้งมนสวยๆ
      child: Padding(
        // เพิ่ม Padding หน่อยเพื่อให้พื้นที่กดไม่ติดไอคอนเกินไป
        padding: const EdgeInsets.all(8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            // ✅ ถ้า Hover ให้เป็นสีอ่อนของไอคอน (Opacity 10-15%) ถ้าไม่ Hover ให้เป็นสีใส
            color: _isHovered
                ? baseColor.withOpacity(0.15)
                : Colors.transparent,
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

  Widget _buildNoteCard(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingItems() {
    final List<Map<String, dynamic>> menuItems = AppMenus.mainNavItems;

    // กรณีที่เลือกหน้า 1 ขึ้นไป และยังไม่ได้กดขยาย
    if (_selectedIndex >= 1 && !_isExpanded) {
      var current = menuItems[_selectedIndex - 1];
      return [
        _navItem(
          current['icon'],
          current['label'],
          current['color'],
          current['index'],
        ),
        // ปุ่มลูกศรสำหรับกดขยาย
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
        (item) =>
            _navItem(item['icon'], item['label'], item['color'], item['index']),
      ),
      // if (_isExpanded) // ถ้าขยายอยู่ ให้มีปุ่มกดหดกลับ
      //   IconButton(
      //     icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
      //     onPressed: () => setState(() => _isExpanded = false),
      //   ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F9),

      body: Stack(
        children: [
          Positioned.fill(
            top: 50,
            // bottom: 78,
            child: SafeArea(
              // ใช้ SafeArea เพื่อไม่ให้เนื้อหาไปทับแถบสถานะด้านบน
              child: _pages[_selectedIndex],
            ),
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
                // decoration: BoxDecoration(
                //   gradient: LinearGradient(
                //     begin: Alignment.topCenter,
                //     end: Alignment.bottomCenter,
                //     colors: [
                //       const Color(0xFFF3F7F9),
                //       const Color(0xFFF3F7F9).withOpacity(0.0),
                //     ],
                //   ),
                // ),
                child: GestureDetector(
                  onTap: () => {
                    setState(() => _selectedIndex = 0),
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const ProfilePage(),
                    //   ),
                    // ),
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_rounded,
                          // color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        (((user?.email?.length ?? 0) > 4
                                    ? user?.email?.substring(0, 4)
                                    : user?.email) ??
                                '') +
                            "@",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          // Icons.settings,//_suggest,
                          // Icons.manage_accounts,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                      ),
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
            bottom: 20, // ให้ลอยจากขอบล่าง 20
            left: 20,
            right: 20,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),

                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: _isExpanded
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    children: _buildFloatingItems(),
                  ),
                ),
              ),
            ),
          ),
          // Positioned(
          //   bottom: 20,
          //   left: 20,
          //   right: 20,
          //   child: Container(
          //     height: 70,
          //     decoration: BoxDecoration(
          //       // color: Colors.white.withOpacity(0.95),
          //       color: AppColors.primary.withOpacity(0.05),
          //       borderRadius: BorderRadius.circular(35),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.05),
          //           blurRadius: 20,
          //           offset: const Offset(0, 10),
          //         ),
          //       ],
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'LisT',
//       // home: const MyHomePage(title: 'Demo Home Page'),
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           primary: const Color(0xFFFF6B00),
//           seedColor: const Color(0xFFFF6B00),
//           //  seedColor: const Color(0xFFFF9E00),
//         ),
//         hoverColor: Colors.orange.withOpacity(0.1),
//       ),
//       home: const MainNavigation(),
//     );
//   }
// }

// class MainNavigation extends StatefulWidget {
//   const MainNavigation({super.key});
//   @override
//   State<MainNavigation> createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const ProfilePage(),
//     const MyListsPage(),
//     const NotesPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('LisT app')),
//       drawer: Drawer(
//         child: ListView(
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(color: AppColors.primary),
//               child: Text(
//                 'เมนู',
//                 style: TextStyle(color: Colors.white, fontSize: 24),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('โปรไฟล์'),
//               onTap: () {
//                 setState(() => _selectedIndex = 0);
//                 Navigator.pop(context); // ปิดเมนูข้าง
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.list),
//               title: const Text('ลิสต์'),
//               onTap: () {
//                 setState(() => _selectedIndex = 1);
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.note),
//               title: const Text('โน้ต'),
//               onTap: () {
//                 setState(() => _selectedIndex = 2);
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: _pages[_selectedIndex],
//     );
//   }
// }

extension ThemeGetter on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
}
