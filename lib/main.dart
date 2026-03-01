import 'package:flutter/material.dart';
import 'profile.dart';
import 'lists.dart';
import 'app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Notes.dart';
import 'homepage.dart';
import 'random.dart';
// import 'health.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase เชื่อมต่อไม่สำเร็จ: $e");
  }

  // runApp(const MyApp());
  runApp(MaterialApp(home: HomeScreen())); // กำหนดหน้าหลัก
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
  //         // --- 1. Background / Content Area ---
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
  //               _buildNoteCard("ประชุมเช้า", "คุยเรื่องดีไซน์แอปใหม่กับทีม..."),
  //               _buildNoteCard("ของต้องซื้อ", "ไข่ไก่, ขนมปัง, กาแฟ..."),
  //               _buildNoteCard("ไอเดีย", "อยากลองหัดเขียน Flutter ให้เก่งๆ"),
  //               _buildNoteCard("งานด่วน", "ส่งรีพอร์ตภายในเย็นวันนี้"),
  //             ],
  //           ),
  //         ),

  //         // --- 2. Top Header (ไม่มีไอคอน Logout ให้รกสายตา) ---
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

  //         // --- 3. Floating Bottom Navigation (ลอยด้านล่าง) ---
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
  //                 _navItem(
  //                   Icons.list_alt_rounded,
  //                   "ลิสต์",
  //                   AppColors.primary,
  //                   () {
  //                     setState(() => _selectedIndex = 1);
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //                 _navItem(
  //                   Icons.description_rounded,
  //                   "โน้ต",
  //                   AppColors.note,
  //                   () {},
  //                 ),
  //                 _navItem(
  //                   Icons.auto_awesome_rounded,
  //                   "random",
  //                   AppColors.rand,
  //                   () => {},
  //                 ),
  //                 _navItem(Icons.health_and_safety, "health", [
  //                   Color(0xFFF06292), // ชมพู
  //                   Color(0xFFBA68C8), // ม่วงชมพู
  //                 ], () => {}),
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
    const LoginPage(),
    const MyListsPage(),
    const NotesPage(),
    const RandomP(),
    // const HealthPage(),
  ];
  bool _isExpanded = true;

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        // margin: const EdgeInsets.only(bottom: 100),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ออกจากระบบ?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                // ใส่คำสั่ง Logout จริงๆ ตรงนี้
                Navigator.pop(context);
              },
              child: const Text("ยืนยันการออกจากระบบ"),
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
              // --- ส่วนที่ 2: ข้อความ (อยู่นอก ShaderMask เสมอ) ---
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
    // ข้อมูลเมนู (ดัดแปลงตามของคุณ)
    final List<Map<String, dynamic>> menuItems = [
      // {'icon': Icons.home, 'label': 'หลัก', 'color': Colors.blue, 'index': 0},
      {
        'icon': Icons.list,
        'label': 'ลิสต์',
        'color': AppColors.primary,
        'index': 1,
      },
      // list_alt_rounded
      {
        'icon': Icons.note,
        'label': 'โน้ต',
        'color': AppColors.note,
        'index': 2,
      },
      // description_rounded
      {
        'icon': Icons.auto_awesome,
        'label': 'random',
        'color': [Color(0xFF00E5FF), Color(0xFF2979FF)],
        'index': 3,
      },
    ];

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
      // appBar: AppBar(title: const Text('LisT app')),
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

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              // padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF3F7F9),
                    const Color(0xFFF3F7F9).withOpacity(0.0),
                  ],
                ),
              ),
              child: GestureDetector(
                // onTap: () => _showLogoutDialog(context),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, color: AppColors.blue),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "คุณ ✨",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
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
          //         _navItem(
          //           Icons.list_alt_rounded,
          //           "ลิสต์",
          //           AppColors.primary,
          //           () {
          //             setState(() => _selectedIndex = 1);
          //           },
          //         ),
          //         _navItem(
          //           Icons.description_rounded,
          //           "โน้ต",
          //           AppColors.note,
          //           () {setState(() => _selectedIndex = 2);},
          //         ),
          //         _navItem(
          //           Icons.auto_awesome_rounded,
          //           "random",
          //           AppColors.rand,
          //           () => {setState(() => _selectedIndex = 3)},
          //         ),
          //         _navItem(Icons.health_and_safety, "health", [
          //           Color(0xFFF06292), // ชมพู
          //           Color(0xFFBA68C8), // ม่วงชมพู
          //         ], () => {setState(() => _selectedIndex = 4)}),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LisT',
      // theme: ThemeData(
      //   // This is the theme of your application.
      //   //
      //   // TRY THIS: Try running your application with "flutter run". You'll see
      //   // the application has a purple toolbar. Then, without quitting the app,
      //   // try changing the seedColor in the colorScheme below to Colors.green
      //   // and then invoke "hot reload" (save your changes or press the "hot
      //   // reload" button in a Flutter-supported IDE, or press "r" if you used
      //   // the command line to start the app).
      //   //
      //   // Notice that the counter didn't reset back to zero; the application
      //   // state is not lost during the reload. To reset the state, use hot
      //   // restart instead.
      //   //
      //   // This works for code too, not just values: Most code changes can be
      //   // tested with just a hot reload.
      //   colorScheme: .fromSeed(seedColor: Colors.orange),
      //   // colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      // ),
      // home: const MyHomePage(title: 'Demo Home Page'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          primary: const Color(0xFFFF6B00),
          seedColor: const Color(0xFFFF6B00),
          //  seedColor: const Color(0xFFFF9E00),
        ),
        hoverColor: Colors.orange.withOpacity(0.1),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // รายการหน้าต่างๆ
  final List<Widget> _pages = [
    const ProfilePage(),
    const MyListsPage(),
    const NotesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LisT app')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Text(
                'เมนู',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('โปรไฟล์'),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context); // ปิดเมนูข้าง
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('ลิสต์'),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('โน้ต'),
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

extension ThemeGetter on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
}
