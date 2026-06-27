import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../app_colors.dart';
import 'welcome.dart';
import '../modal/profile.dart';
import '../modal/drug.dart';

class SettingPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const SettingPage(this.userData, {super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Stream<QuerySnapshot>? myDrugs;
  List<TextEditingController> _controllers = [];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isVisible = bool.tryParse(user?.displayName ?? '') ?? true;

    void _showModal() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('ยืนยันการออกจากระบบ?'),

            // content: const Text(''),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'ยกเลิก',
                      ), //, style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        await GoogleSignIn().signOut();
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text('ตกลง'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    Future<void> addCar(BuildContext context) async {
      try {
        await FirebaseFirestore.instance.collection('cars').add({
          'authorId': user?.uid,
          'car_name': '',
          'color': '',
          // 'capacity': double.tryParse(capacity) ?? 0.0,
          'type': '',
          // 'station': '',
          'oil': '',
          // cc
        });
        Navigator.pop(context);
      } catch (e) {
        print("Error: $e");
      }
    }

    void _showMyCar(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // ทำให้ลากขึ้นไปสูงเต็มจอได้
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "เพิ่มรถใหม่",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildInputGroup(
                        title: "ข้อมูลพื้นฐาน",
                        children: [
                          _buildMiniField(
                            label: "ชื่อรถ",
                            icon: Icons.directions_car_rounded,
                          ),
                          const SizedBox(height: 15),
                          _buildMiniField(
                            label: "สี",
                            // icon: Icons.gradient,
                            icon: Icons.format_color_text,
                            //  icon: Icons.dashboard_customize,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              // const Text('ประเภทรถ'),
                              // const SizedBox(width: 25),
                              Expanded(child: _buildTypeSelector()),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // --- Group 2: ข้อมูลถังน้ำมัน / แบตเตอรี่ ---
                      _buildInputGroup(
                        title: "สเปกพลังงาน",
                        children: [
                          _buildMiniField(
                            label: "ความจุถัง (ลิตร/kWh)",
                            icon: Icons.ev_station_rounded,
                            isNumber: true,
                          ),
                          const SizedBox(height: 15),
                          _buildMiniField(
                            label: "ชนิดน้ำมันที่เติมประจำ",
                            icon: Icons.local_gas_station_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            addCar(context);
                          },
                          style: ElevatedButton.styleFrom(
                            // backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "บันทึกข้อมูลรถ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("ตั้งค่าผู้ใช้"), centerTitle: true),
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
                      ListTile(
                        leading: const Icon(Icons.directions_car_rounded),
                        // title: const Text("Add Car"),
                        onTap: () {
                          _showMyCar(context);
                        },
                      ),
                      const Divider(height: 1),
                      ExpansionTile(
                        title: const Text(
                          "Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // color:
                          ),
                        ),
                        textColor: AppColors.primary,
                        // subtitle: Text("คลิกที่นี่เพื่อขยาย"),
                        iconColor: AppColors.secondary,
                        // leading: Icon(Icons.person_outline),
                        tilePadding: EdgeInsets.zero,
                        children: [
                          // Container(
                          //   padding: EdgeInsets.all(16),
                          //   color: Colors.grey[100],
                          //   child: Text(
                          //     "สีเทา .. ตรงกลาง",
                          //   ),
                          // ),
                          CheckboxListTile(
                            title: Transform.translate(
                              offset: Offset(
                                -8,
                                0,
                              ), // ไม้ตายสุดท้าย: สั่งขยับ Title ไปทางซ้าย
                              child: Text("Hide displayname"),
                            ),
                            value:
                                bool.tryParse(user?.displayName ?? '') ??
                                false, //_isVisible,
                            onChanged: (bool? value) async {
                              bool isChecked = value ?? false;
                              String name = isChecked
                                  ? "${user?.email?.substring(0, 4)}@"
                                  : "";
                              await user?.updateDisplayName(name);
                              // ก็ยังไม่ค่อยอัพเดท
                              await user?.reload();
                              // setState(() {
                              //   _isVisible = value ?? false; // อัปเดตสถานะเมื่อกด
                              // });
                            },
                            activeColor: Colors.blueAccent,
                            controlAffinity: ListTileControlAffinity
                                .leading, // เอาติ๊กถูกไว้ด้านหน้า
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 0.0,
                            ),
                            //  visualDensity:  VisualDensity(horizontal: -4.0, vertical: 0),
                          ),
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text("Edit "),
                            // trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              // Modal.showProfile(context, user);
                              await showDialog(
                                context: context,
                                builder: (context) =>
                                    ModalProfile(userData: widget.userData),
                              );
                            },
                          ),
                        ],
                      ),

                      const Divider(height: 1),
                      // ListTile(
                      //   leading: const Icon(Icons.contrast_rounded),
                      //   title: const Text("Theme"),
                      //   onTap: () {},
                      // ),
                      ExpansionTile(
                        title: const Text(
                          "ยาประจำตัว",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        textColor: AppColors.primary,
                        iconColor: AppColors.secondary,
                        tilePadding: EdgeInsets.zero,
                        onExpansionChanged: (bool isExpanded) {
                          if (isExpanded) {
                            setState(() {
                              myDrugs = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .collection('drugs')
                                  .snapshots();
                            });
                          }
                        },
                        children: [
                          // เอา StreamBuilder มาครอบครอบท่อน้ำ (myD)
                          StreamBuilder<QuerySnapshot>(
                            stream: myDrugs, // ตัวแปร myD ที่เป็น Stream ของคุณ
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final docs = snapshot.data!.docs;
                              print(docs);
                              // ตั้งค่าเตรียมความพร้อมให้ Controller
                              // if (_controllers.length != docs.length) {
                              //   _controllers = List.generate(
                              //     docs.length,
                              //     (_) => TextEditingController(),
                              //   );
                              // }

                              // วาด Column และทำการ .map() ข้อมูล

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Column(
                                  // แปลง docs จากตัวแปร myD ของคุณมาเป็นลิสต์ของ Widget
                                  children: () {
                                    // final docs = myDrugs.docs;

                                    // ใช้ .asMap().entries.map() เพื่อให้ได้ทั้งตัวข้อมูล (doc) และลำดับแถว (index)
                                    return docs.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      var doc = entry.value;

                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final String medicineName =
                                          data['name'] ?? '. . .';

                                      // ตรวจสอบและเตรียมจำนวน Controller ให้เท่ากับจำนวนข้อมูลที่ดึงมาได้
                                      // if (_controllers.length != docs.length) {
                                      //   _controllers = List.generate(
                                      //     docs.length,
                                      //     (_) => TextEditingController(
                                      //       text: data['amount'].toString(),
                                      //     ),
                                      //   );
                                      // }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 6.0,
                                        ),
                                        child: Row(
                                          children: [
                                            // ด้านซ้าย: ชื่อยา
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                medicineName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),

                                            // const SizedBox(width: 10),

                                            // // ด้านขวา: ช่อง Input สำหรับกรอกข้อมูล
                                            // Expanded(
                                            //   flex: 2,
                                            //   child: SizedBox(
                                            //     height: 20,
                                            //     child: TextField(
                                            //       // 👈 ผูกเข้ากับ Controller ประจำแถว (ดึงตาม index)
                                            //       controller:
                                            //           _controllers[index],
                                            //       decoration: InputDecoration(
                                            //         hintText: 'จำนวน',
                                            //         contentPadding:
                                            //             const EdgeInsets.symmetric(
                                            //               horizontal: 10,
                                            //             ),
                                            //         border: OutlineInputBorder(
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                 8,
                                            //               ),
                                            //         ),
                                            //       ),
                                            //       keyboardType:
                                            //           TextInputType.number,
                                            //     ),
                                            //   ),
                                            // ),
                                            const SizedBox(width: 8),

                                            IconButton(
                                              icon: const Icon(
                                                Icons
                                                    .edit, 
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                       AddDrugDialog(data: data, docId: doc.id),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(); // แปลงผลลัพธ์กลับเป็น List<Widget> ส่งให้ Column
                                  }(), // 👈 เติม () เพื่อสั่งให้ฟังก์ชันนี้ทำงานทันทีในช่อง children
                                ),
                              );
                            },
                          ),

                          ListTile(
                            leading: const Icon(Icons.medical_services),
                            title: const Text("เพิ่ม "),
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => const AddDrugDialog(),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                      ExpansionTile(
                        title: const Text(
                          "Export",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        textColor: AppColors.primary,
                        iconColor: AppColors.secondary,
                        tilePadding: EdgeInsets.zero,
                        children: [
                          ListTile(
                            // leading: const Icon(Icons.edit),
                            title: const Text("Car "),
                            onTap: () async {},
                          ),
                          ListTile(
                            // leading: const Icon(Icons.edit),
                            title: const Text("Health "),
                            onTap: () async {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // การแจ้งเตือน .notifications_none
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
                  _showModal();
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

Widget _buildInputGroup({
  required String title,
  required List<Widget> children,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(children: children),
      ),
    ],
  );
}

Widget _buildTypeSelector() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _typeButton(
        "น้ำมัน",
        Icons.local_gas_station,
        AppColors.secondary,
        isSelected: !true,
      ),
      _typeButton(
        "HEV",
        Icons.electric_car_outlined,
        Colors.red,
        isSelected: !true,
      ),
      _typeButton(
        "EV",
        Icons.battery_charging_full_rounded,
        Colors.green,
        isSelected: !true,
      ),
    ],
  );
}

Widget _typeButton(
  String label,
  IconData icon,
  Color color, {
  bool isSelected = false,
}) {
  return Row(
    children: [
      CircleAvatar(
        radius: 25,
        backgroundColor: isSelected ? color : Colors.white12,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(width: 20),
    ],
  );
}

Widget _buildMiniField({
  required String label,
  required IconData icon,
  bool isNumber = false,
  TextEditingController? controller,
}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: Icon(
        icon,
        color: Colors.blueAccent.withOpacity(0.7),
        size: 20,
      ),

      // การตกแต่งพื้นหลังช่องกรอก
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),

      // เส้นขอบตอนปกติ
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white10),
      ),

      // เส้นขอบตอนกดพิมพ์ (Focus)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
