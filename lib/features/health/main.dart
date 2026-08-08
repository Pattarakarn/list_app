import 'package:flutter/material.dart';
import '../../app_colors.dart';
import 'part/lists.dart';
import 'part/calendar.dart';
import 'part/last-period.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  DateTime selectedDate = DateTime.now();
  int? selectedLevel; // 0: น้อยมาก, 1: น้อย, 2: ปานกลาง, 3: มาก
  final user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot>? _healthRecord;
  //calendar
  DateTime _focusedDay = DateTime.now();
  late DateTime _firstDayC = DateTime(
    DateTime.now().year,
    DateTime.now().month-1,
    1,
  );
  late DateTime _lastDayC = DateTime(
    DateTime.now().year,
    DateTime.now().month + 2,
    0,
  );

  @override
  void initState() {
    super.initState();
    // สร้าง Stream ครั้งเดียวตอนโหลดหน้า เพื่อลดภาระเครื่องและป้องกัน Error
    // _healthRecord = FirebaseFirestore.instance
    //     .collection('health')
    //     .where('authorId', isEqualTo: user?.uid)
    //     .limit(69)
    //     .snapshots();
  }

  Stream<QuerySnapshot> fetchFirestoreData(DateTime selectedDay) {
    // void fetchFirestoreData() {
    return FirebaseFirestore.instance
        .collection('health')
        .where('authorId', isEqualTo: user?.uid)
        // .orderBy('date', descending: true)
        .where('date', isGreaterThanOrEqualTo: _firstDayC)
        .where('date', isLessThanOrEqualTo: _lastDayC)
        .snapshots();

    // .get()
    // .then((querySnapshot) {
    //   setState(() {
    //     _healthRecord = querySnapshot.docs;
    //   });
    // });
  }

  final List<Color> flowColors = [
    Colors.pink[100]!,
    Colors.pink[300]!,
    Colors.red[400]!,
    Colors.red[900]!,
  ];


  Color _getDayColor(int weekday) {
    switch (weekday) {
      case 1:
        return Colors.yellow[700]!; // จันทร์
      case 2:
        return Colors.pinkAccent; // อังคาร
      case 3:
        return Colors.green; // พุธ
      case 4:
        return Colors.orange; // พฤหัสบดี
      case 5:
        return Colors.blue; // ศุกร์
      case 6:
        return Colors.purple; // เสาร์
      case 7:
        return Colors.red; // อาทิตย์
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = MediaQuery.of(context).size.height * 0.31; // 30vh

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body:
          // _healthRecord == null
          //     ? const Center(
          //         child: CircularProgressIndicator(),
          //       ) // ถ้ายัง null ให้หมุนรอ
          //     :
          StreamBuilder<QuerySnapshot>(
            // stream: _healthRecord,
            stream: fetchFirestoreData(_firstDayC),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
                );
              }

              final List<DocumentSnapshot> documents =
                  snapshot.data!.docs; //array
              //     if (documents.isEmpty) return Text("ไม่มีข้อมูล");
              //     Map<String, dynamic> data = documents[0].data() as Map<String, dynamic>;
              final Map<DateTime, Map<String, dynamic>> _calendar = {};

              for (var doc in documents) {
                final data = doc.data() as Map<String, dynamic>;
                //                   // DateTime dateValue = (data['date'] as Timestamp).toDate();
                //                   DateTime dateValue = (data['createdAt'] as Timestamp)
                //                       .toDate();

                //                   DateTime dayKey = DateTime.utc(
                //                     dateValue.year,
                //                     dateValue.month,
                //                     dateValue.day,
                //                   );
                // // print(dayKey);
                //                   _calendar[dayKey] = data;

                // _calendar[dayKey] = {
                //   'symptoms': data['symptoms'],
                //   'pain_level': data['painLevel'],
                //   'medications': data['medications'],
                //   'periodLevel': data['periodLevel'],
                //   'mental_level': data['mental_level'],
                //   // ใส่ข้อมูลอื่นๆ ที่คุณต้องการ
                // };
              }
              
              if (snapshot.hasData) {
                return Scaffold(
                  // backgroundColor: Colors.grey[50],
                  body: Stack(
                    children: [
                      Container(
                        height: headerHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,

                            colors: [
                              const Color(0xFFFF758C),
                              const Color(0xFFFF7EB3).withOpacity(0.5),
                              Colors
                                  .transparent, // จางหายไปเลยที่ด้านล่าง (รอยต่อ 30vh)
                            ],

                            // 2. กำหนดจุดที่สีจะเริ่มจาง (Stops)
                            stops: const [0.0, 0.6, 1.0],
                            // 0.0 คือบนสุดสีชัด | 0.6 คือเริ่มจางที่ 60% | 1.0 คือใสสนิทที่ขอบล่างพอดี
                          ),
                        ),
                      ),

                      SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 15),

                              PeriodSummaryCard(datas: documents),

                              const SizedBox(height: 10),

                              MoodCalendarWidget(
                                data: documents,
                                firstDayC: _firstDayC,
                                lastDayC: _lastDayC,
                                setDates: (firstD, lastD) {
                                  setState(() {
                                    _firstDayC = firstD;
                                    _lastDayC = lastD;
                                    // _focusedDay = lastD;
                                  });
                                  // fetchFirestoreData();
                                },
                              ),
                              const SizedBox(height: 25),

                              SymptomHistoryList(
                                datas: documents,
                                firstDayC: _firstDayC,
                                lastDayC: _lastDayC,
                              ),

                              const SizedBox(height: 100), // เผื่อระยะล่าง
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return const Center(child: Text('ไม่มีข้อมูล'));
            },
          ),
    );
  }

  // --- Widget ย่อยๆ ---

  Widget _buildWeeklyBloodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        bool isSelected =
            selectedLevel != null && index == 3; // สมมติลองเลือกอันนึง
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedLevel =
                  (selectedLevel ?? 0 + 1) %
                  4; // คลิ๊กเพื่อเปลี่ยนระดับสี (Demo)
            });
          },
          child: Column(
            children: [
              Text(["จ", "อ", "พ", "พฤ", "ศ", "ส", "อา"][index]),
              const SizedBox(height: 8),
              Icon(
                Icons.water_drop,
                size: 40,
                // เปลี่ยนสีตามระดับที่เลือก (Demo: ใช้สีตามระดับที่เราตั้งไว้)
                color: index == 3
                    ? flowColors[selectedLevel ?? 0]
                    : Colors.grey[300],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDatePickerSection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text("เลือกดู 30 วันล่าสุด / Symptom&Mind / Period"),
      // subtitle: Text(DateFormat('dd MMMM yyyy').format(selectedDate)),
      trailing: const Icon(Icons.calendar_month, color: AppColors.pink),
      // onTap: () async {
      //   final date = await showDatePicker(
      //     context: context,
      //     initialDate: selectedDate,
      //     firstDate: DateTime(2020),
      //     lastDate: DateTime.now(),
      //   );
      //   if (date != null) setState(() => selectedDate = date);
      // },
    );
  }

  Widget _buildSymptomList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.orange,
            ),
            title: Text(index == 0 ? "ปวดหัว" : "คัดหน้าอก"),
            subtitle: const Text("ระดับปานกลาง - 14:00 น."),
          ),
        );
      },
    );
  }

  // feeling good-bad
  // ไม่ได้ใส่ เป็นรูป *
  void _showBloodLevelSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "เลือกระดับปริมาณเลือด",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) {
                return InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Column(
                    children: [
                      Icon(Icons.water_drop, color: flowColors[i], size: 50),
                      Text("ระดับ ${i + 1}"),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- ส่วนปุ่มเพิ่มอาการ (เปลี่ยนเป็น Popup Dialog) ---
  void _showAddSymptomPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("บันทึกอาการ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(decoration: InputDecoration(labelText: "อาการที่พบ")),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: "รายละเอียดเพิ่มเติม"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  void _showAddSymptomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("เพิ่มรายละเอียดอาการ", style: TextStyle(fontSize: 20)),
            const TextField(decoration: InputDecoration(labelText: "อาการ")),
            const TextField(
              decoration: InputDecoration(labelText: "รายละเอียดอื่นๆ"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("บันทึก"),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
