import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:list_app/app_colors.dart';
import 'dart:ui';
import '../features/fuel/create.dart';
import 'package:firebase_auth/firebase_auth.dart';

// class FuelScreen extends StatelessWidget {
//   const FuelScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  bool _isExpanded = false; // สถานะ เปิด/ปิด การซ้อน
  final user = FirebaseAuth.instance.currentUser;

  // ตัวแปร State ที่ต้องมีในไฟล์หลัก (หรือในตัว Widget เอง)
  String _selectedPeriod = '30 วัน'; // ค่าเริ่มต้น
  bool _showGraph = false; // สถานะการแสดงกราฟ
  Widget _buildDetailCard({required Map<String, dynamic> data}) {
  //   double totalMile = (data['last_mileage'] ?? 0).toDouble();
  // double totalLite = (data['allLites'] ?? 0).toDouble();
  String consumption = '4323'; //(totalLite > 0) 
      // ? (totalMile / totalLite).toStringAsFixed(2) 
      // : "-";
  
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // ปรับเป็นสีขาวตามสั่ง
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "สถิติ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateListFuel(data: data),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  "เพิ่มข้อมูล",
                  style: TextStyle(
                    // color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                // style: TextButton.styleFrom(
                //   backgroundColor: Colors.blueAccent.withOpacity(0.1), // ใส่พื้นหลังจางๆ ให้ดูเป็นปุ่ม
                //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                // ),
              ),
            ],
          ),
          const Divider(height: 10),

          // --- ส่วนเลือกช่วงเวลา (30วัน / เดือน / ปี) ---
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: ['30 วัน', 'รายเดือน', 'รายปี'].map((period) {
          //     bool isSelected = _selectedPeriod == period;
          //     return ChoiceChip(
          //       label: Text(period, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
          //       selected: isSelected,
          //       selectedColor: Colors.blueAccent,
          //       backgroundColor: Colors.grey[100],
          //       onSelected: (bool selected) {
          //         setState(() {
          //           _selectedPeriod = period;
          //           // TODO: ดึงข้อมูลใหม่ตามช่วงเวลาที่เลือก
          //         });
          //       },
          //     );
          //   }).toList(),
          // ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                "km/l",
                consumption,
              ),
              _buildStatItem("รวมจ่าย", data['total_spent'].toString()),
              // _buildStatItem("ระยะทาง", "1,720 km"),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showGraph = !_showGraph;
                });
              },
              icon: Icon(_showGraph ? Icons.close : Icons.bar_chart),
              label: Text(_showGraph ? "ปิดกราฟ" : "แสดงกราฟแนวโน้ม"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                side: const BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // --- ส่วนแสดงกราฟ (จะโผล่มาเมื่อ _showGraph เป็น true) ---
          if (_showGraph)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 100, // กำหนดความสูงกราฟคร่าวๆ
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(child: Text("📊 [ กราฟเส้นแสดงที่นี่ ]")),
            ),
        ],
      ),
    );
  }

  // Helper สร้าง Text สถิติ
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Vehicles",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(
        //       right: 12.0,
        //     ), // ขยับให้ห่างจากขอบจอเล็กน้อย
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(100),
        //       child: BackdropFilter(
        //         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: Colors.white.withOpacity(0.1), // กระจกใสๆ
        //             borderRadius: BorderRadius.circular(12),
        //             border: Border.all(color: Colors.white.withOpacity(0.2)),
        //           ),
        //           child: IconButton(
        //             icon: const Icon(
        //               Icons.add_rounded,
        //               color: Colors.white,
        //               size: 28,
        //             ),
        //             onPressed: () {
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                   builder: (context) => const CreateListFuel(),
        //                 ),
        //               );
        //             },
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          // ดึงข้อมูลเรียงตามเวลาล่าสุดขึ้นก่อน
          stream: FirebaseFirestore.instance
              .collection('cars')
              // .doc('Dq7txchVkbdl71PtqVaG')
              // .collection('fill-ups')
              // .orderBy('timestamp', descending: true)
              .where('authorId', isEqualTo: user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return const Center(
                child: Text(
                  "เกิดข้อผิดพลาด",
                  style: TextStyle(color: Colors.white),
                ),
              );
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!.docs;
            // var doc = snapshot.data!.docs.first;
            //             Map<String, dynamic> carData = doc.data() as Map<String, dynamic>;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(15, 100, 15, 20),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                data['id'] = docs[index].id;
                print(data);
                
                //     // --- ส่วนการคำนวณ ---
                //     double kml = 0;
                //     if (index < docs.length - 1) {
                //       final prevData =
                //           docs[index + 1].data() as Map<String, dynamic>;
                //       double dist = (data['odometer'] - prevData['odometer'])
                //           .toDouble();
                //       double liters = data['liters'].toDouble();
                //       kml =
                //           dist /
                //           liters; // สูตร: (ไมล์ใหม่ - ไมล์เก่า) / ลิตรที่เติม
                //     }
                //     return _buildHistoryCard(data, kml);
                return GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // --- Card 3: Graph (อยู่หลังสุด) ---
                          // _buildSubCard(
                          //   index: 2,
                          //   isExpanded: _isExpanded,
                          //   child: _buildGraphContent(),
                          //   color: Colors.white.withOpacity(0.6),
                          //   context: context,
                          // ),
                          // // --- Card 2: Summary (อยู่กลาง) ---
                          // _buildSubCard(
                          //   index: 1,
                          //   isExpanded: _isExpanded,
                          //   child: _buildSummaryContent(),
                          //   color: Colors.white.withOpacity(0.9),
                          //   context: context,
                          // ),

                          _buildSubCard(
                            index: 1,
                            isExpanded: _isExpanded,
                            child: _buildDetailCard(data: data),
                            // color: Colors.white.withOpacity(0.9),
                            context: context,
                          ),
                          // --- Card 1: Main Car Info (อยู่หน้าสุด) ---
                          Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: _isExpanded
                                          ? AppColors.secondary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: _buildMainCarHeader(data: data),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

//   Widget _buildHistoryCard(Map<String, dynamic> data, double kml) {
//     bool _isExpanded = false;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Container(
//             padding: const EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white.withOpacity(0.2)),
//             ),
//             child: Row(
//               children: [
//                 // ฝั่งซ้าย: แสดงประเภทน้ำมันและปั๊ม
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         data['name'] ,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         "${data['station']} | ${data['location']}",
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 13,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "เลขไมล์: ${data['odometer']} กม.",
//                         style: const TextStyle(
//                           color: Colors.blueAccent,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // ฝั่งขวา: แสดงผลการคำนวณ กม./ลิตร
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       "${data['amount']} ฿",
//                       style: const TextStyle(
//                         color: Colors.greenAccent,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       "${data['liters']} ลิตร",
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 13,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     // แสดง badge กม./ลิตร
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: kml > 0 ? Colors.orangeAccent : Colors.grey,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         kml > 0
//                             ? "${kml.toStringAsFixed(2)} กม./ลิตร"
//                             : "ข้อมูลไม่พอคำนวณ",
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

Widget _buildSubCard({
  required int index,
  required bool isExpanded,
  required Widget child,
  Color? color,
  required BuildContext context,
}) {
  // คำนวณระยะการ "คลี่" ออกมา
  double topMargin = isExpanded ? (index * 150.0) : (index * 10.0);
  double scale = isExpanded ? 1.0 : (1.0 - (index * 0.05));

  return AnimatedContainer(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeOutBack, //Curves.backOut,
    margin: EdgeInsets.only(top: topMargin),
    transform: Matrix4.identity()..scale(scale),
    width: MediaQuery.of(context).size.width * 0.9,
    height: 140,
    decoration: BoxDecoration(
      color: isExpanded ? color : Colors.white,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    ),
    child: isExpanded ? child : const SizedBox(), // โชว์เนื้อหาเฉพาะตอนกางออก
  );
}

Widget _buildMainCarHeader({required Map<String, dynamic> data}) {
  print(data);
  return Row(
    children: [
      CircleAvatar(
        radius: 25,
        backgroundColor: data['color'] ?? AppColors.secondary,
        child: Icon(Icons.directions_car, color: Colors.white),
      ),
      const SizedBox(width: 15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['car_name'] ?? '. . .',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),

      Text(
        "${data['last_mileage'] ?? '-'} km",
        style: const TextStyle(color: AppColors.secondary),
      ),
    ],
  );
}

Widget _buildSummaryContent() {
  return const Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("สรุปการใช้งาน", style: TextStyle(fontWeight: FontWeight.bold)),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("เติมล่าสุด: 1,200.-"),
            Text("เฉลี่ย: 2.5 ฿/km", style: TextStyle(color: Colors.green)),
          ],
        ),
      ],
    ),
  );
}

Widget _buildGraphContent() {
  return const Center(child: Text("📊 กราฟจะแสดงตรงนี้"));
}
