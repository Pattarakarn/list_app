import 'package:flutter/material.dart';
import 'package:list_app/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';

class MoodCalendarWidget extends StatefulWidget {
  //  final Map<String, dynamic> data;
  final List<DocumentSnapshot> data; //array
  final DateTime firstDayC;
  final DateTime lastDayC;
  final Function(DateTime, DateTime) setDates;
  // final Map<DateTime, Map<String, dynamic>> data;
  const MoodCalendarWidget({
    super.key,
    required this.data,
    required this.firstDayC,
    required this.lastDayC,
    required this.setDates,
  });

  @override
  State<MoodCalendarWidget> createState() => _MoodCalendarWidgetState();
}

class _MoodCalendarWidgetState extends State<MoodCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  final user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot>? myDrugs;
  late Map<String, bool> medTimes = {
    'morning': false,
    'noon': false,
    'evening': false,
    'bedtime': false,
  };

  @override
  void initState() {
    super.initState();

    //   if (isLoading && dialogDrugList.isEmpty) {
    //   FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(user?.uid)
    //       .collection('drugs')
    //       .where('amount', isGreaterThan: 0)
    //       .get()
    //       .then((snapshot) {
    //     // ⚠️ ต้องใช้ setDialogState ตรงนี้ หน้าจอ Dialog ถึงจะอัปเดตเลข/ข้อมูลใหม่
    //     setDialogState(() {
    //       dialogDrugList = snapshot.docs;
    //       isLoading = false;
    //     });
    //   });
    // }
  }

  @override
void didUpdateWidget(covariant MoodCalendarWidget oldWidget) {
  // super.didUpdateWidget(oldWidget);
  // // ถ้าหน้าหลักส่งค่าวันใหม่มา ไม่เท่ากับค่าเดิม
  // if (widget.firstDayC != oldWidget.firstDayC) {
  //   setState(() {
  //     // เอาตัวแปรภายในปฏิทินของคุณ (สมมติว่าชื่อ _selectedDay) มาเท่ากับค่าใหม่ที่ส่งมา
  //     // _focusedDay = widget.firstDayC; 
  //     // _selectedDay = widget.lastDayC; 
  //   });
  // }
}

  List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow.shade700,
    Colors.lightGreen,
    Colors.green,
    Colors.grey,
  ];
  // FirebaseFirestore.instance
  //   .collection('users')
  //   .doc(userId)
  //   .collection('drugs')
  //   .get() // ดึงข้อมูลทั้งหมดใน sub-collection ของคนนี้
  //   .then((querySnapshot) {
  //     for (var doc in querySnapshot.docs) {
  //       print(doc.data());
  //     }
  //   });

  // Widget _buildMedicationTile(String label, IconData icon, String key) {
  //   // bool isSelected = selectedTimes[key] ?? false;

  //   return Tooltip(
  //     message: label,
  //     child: IconButton(
  //       icon: Icon(icon),
  //       // ถ้าเลือกอยู่ให้เป็นสีหลัก (เช่น สีน้ำเงิน/ส้ม) ถ้าไม่เลือกให้เป็นสีเทา
  //       color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400],
  //       iconSize: 22,
  //       constraints:
  //           const BoxConstraints(), // ช่วยให้ปุ่มไม่กินพื้นที่กว้างเกินไป
  //       padding: const EdgeInsets.symmetric(horizontal: 4),
  //       onPressed: () {
  //         setState(() {
  //           selectedTimes[key] = !isSelected;
  //         });
  //         // ส่งค่า Map ชุดใหม่กลับไปให้ Widget หลักเพื่อเตรียมบันทึกลง Firestore
  //         // widget.onTimeChanged(selectedTimes);
  //       },
  //     ),
  //   );
  // }

  void _showEditDialog(date) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('drugs')
        .where('isDelete', isNotEqualTo: true)
        // .where('amount', isGreaterThanOrEqualTo: 0)
        .get();

    List<DocumentSnapshot> dataDrug = snapshot.docs;
    print(dataDrug);
    Map<String, dynamic> record = {
      "symptoms": "",
      "pain_level": 0,
      "medications": [
        // {
        //   "name": "",
        //   "morning": false,
        //   "noon": false,
        //   "evening": false,
        //   "night": false,
        // },
      ],
      "periodLevel": 0,
      "minExercise": 10,
      "typeEx": "",
    };
    final TextEditingController _amountController = TextEditingController(
      text: record['minExercise'].toString(),
    );
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          String formattedDate = DateFormat('dd/MM/yyyy').format(date);
          return AlertDialog(
            title: Text(
              "เพิ่มข้อมูล - $formattedDate",
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            //  scrollable: true,
            content:
                // Row(  children:
                SizedBox(
                  width: double
                      .maxFinite, // กำหนดขนาดกว้างเพื่อไม่ให้ ListView พัง
                  // height: MediaQuery.of(context).size.height * 0.5,
                  child: SingleChildScrollView(
                    child: FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .collection('drugs')
                          .where('amount', isGreaterThan: 0)
                          .get(),
                      // child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      //   stream: FirebaseFirestore.instance
                      //       .collection('users')
                      //       .doc(user?.uid)
                      //       .collection('drugs')
                      //       .doc('8qvmRslHfE68HCwFxeo2')
                      //       .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        // if (snapshot.hasError) {
                        //   return Center(
                        //     child: Text(
                        //       'Firebase ฟ้องว่า: ${snapshot.error}',
                        //       style: TextStyle(color: Colors.red, fontSize: 16),
                        //     ),
                        //   );
                        // }
                        // if (snapshot.connectionState == ConnectionState.waiting) {
                        //   // print(user?.uid);
                        //   return const Center(child: CircularProgressIndicator());
                        // }
                        // // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        // if (!snapshot.hasData) {
                        //   return const Center(child: Text('ไม่มีข้อมูลยา'));
                        // }

                        // // final docs = snapshot.data!.docs;
                        // var doc = snapshot.data!.docs;
                        // // print(doc);
                        // // Map<String, dynamic> data =  snapshot.data!.data() as Map<String, dynamic>;
                        // Map<String, dynamic> data =  doc!.data() as Map<String, dynamic>;
                        // print(data);
                        // print('. . . .');
                        return SizedBox(
                          width: double
                              .maxFinite, // ให้กว้างเท่าที่ Dialog จะยอมให้กว้างได้
                          child: Column(
                            mainAxisSize: MainAxisSize
                                .min, // สำคัญ! เพื่อให้ Dialog ไม่สูงเต็มจอ
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(5, (index) {
                                  List<IconData> icons = [
                                    Icons.sentiment_very_dissatisfied,
                                    Icons.sentiment_dissatisfied,
                                    Icons.sentiment_neutral,
                                    Icons.sentiment_satisfied,
                                    Icons.sentiment_very_satisfied,
                                  ];

                                  bool isSel =
                                      record['mental_level'] == (index);
                                  return IconButton(
                                    icon: Icon(icons[index]),
                                    iconSize: 40,
                                    color: isSel
                                        ? colors[index]
                                        : Colors.grey.shade300,
                                    onPressed: () => setDialogState(
                                      () => record['mental_level'] = index,
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: "Symptom . . .",
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                onChanged: (val) => setDialogState(
                                  () => record['symptoms'] = val,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text(
                                    "Level of discomfort:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: record['pain_level'].toDouble(),
                                      min: 0,
                                      max: 10,
                                      divisions: 10,
                                      label: record['pain_level'].toString(),
                                      onChanged: (val) => setDialogState(
                                        () =>
                                            record['pain_level'] = val.toInt(),
                                      ),
                                      // activeColor: Color(0xFFF06292), // AppColors.pink,
                                      activeColor: Color.lerp(
                                        AppColors.pink,
                                        const Color(0xFFF06292),
                                        record['pain_level'].toDouble() / 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Column(
                                children: [
                                  // Expanded( child:
                                  // StreamBuilder<QuerySnapshot>(
                                  //   stream: myDrugs,
                                  //   builder: (context, snapshot) {
                                  //     print('snapshot');
                                  //     if (snapshot.hasError) {
                                  //       print(snapshot);
                                  //       return const Center(
                                  //         child: Text(
                                  //           'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                                  //         ),
                                  //       );
                                  //     }

                                  //     if (snapshot.connectionState ==
                                  //         ConnectionState.waiting) {
                                  //       return const Center(
                                  //         child: CircularProgressIndicator(),
                                  //       );
                                  //     }

                                  //     final List<DocumentSnapshot> documents =
                                  //         snapshot.data!.docs; //array
                                  //     print('documents');
                                  //     print(documents);
                                  //     return const Text('null');
                                  //     // return ListView.builder(
                                  //     //   // ข้างในเป็น ListView ได้ตามปกติแล้ว
                                  //     //   itemCount: documents.length,
                                  //     //   itemBuilder: (context, index) => ListTile(),
                                  //     // );
                                  //   },
                                  // ),

                                  // ),
                                  ...record['medications'].asMap().entries.map((
                                    entry,
                                  ) {
                                    int idx = entry.key;
                                    var med = entry.value;
                                    return Row(
                                      children: [
                                        // Expanded(child: DropdownButton( /* เลือกยาจาก Firebase Master */ )),
                                        // // ไอคอน เช้า กลางวัน เย็น ก่อนนอน (ใช้ IconButton หรือ FilterChip)
                                        // _buildTimeChip(idx, 'morning', Icons.wb_sunny_outlined),
                                        // _buildTimeChip(idx, 'noon', Icons.wb_sunny),
                                        // _buildTimeChip(idx, 'evening', Icons.dark_mode_outlined),
                                        // _buildTimeChip(idx, 'night', Icons.bedtime),
                                      ],
                                    );
                                  }),
                                  Row(
                                    children: [
                                      // TextField(
                                      //   controller: TextEditingController(text: data['amount']?.toString() ?? ''),
                                      //   decoration: InputDecoration(
                                      //     // labelText: "${data['amount']}",
                                      //     border: OutlineInputBorder(),
                                      //   ),
                                      //   onChanged: (val) => setDialogState(
                                      //     () => record['amount'] = data['amount'] - val,
                                      //   ),
                                      // ),

                                      // TextButton.icon(
                                      //   onPressed: () => setDialogState(
                                      //     () => record['medications'].add({
                                      //       "name": "",
                                      //       "morning": false,
                                      //       "noon": false,
                                      //       "evening": false,
                                      //       "night": false,
                                      //     }),
                                      //   ),
                                      //   icon: const Icon(Icons.add),
                                      //   label: const Text("เพิ่มยา"),
                                      //   style: OutlinedButton.styleFrom(
                                      //     foregroundColor: const Color(
                                      //       0xFFBA68C8,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: dataDrug.length,
                                itemBuilder: (context, index) {
                                  // var doc = snapshot.data!.docs[index];
                                  var doc = dataDrug[index];
                                  Map<String, dynamic> data =
                                      doc.data() as Map<String, dynamic>;
                                  String docId = doc.id;

                                  List<String> activeTimes = [];
                                  data['schedule'].forEach((
                                    timeName,
                                    isActive,
                                  ) {
                                    if (isActive == true) {
                                      activeTimes.add(
                                        timeName,
                                      ); // ถ้าอันไหนเป็น true จะเก็บชื่อช่วงเวลานั้นไว้
                                    }
                                  });

                                  return Column(
                                    children: activeTimes.map((timeLabel) {
                                      return Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        runSpacing: 8,
                                        children: [
                                          ListTile(
                                            leading: Icon(
                                              timeLabel == 'เช้า'
                                                  ? Icons.wb_sunny_outlined
                                                  : timeLabel == 'กลางวัน'
                                                  ? Icons.wb_sunny
                                                  : timeLabel == 'เย็น'
                                                  ? Icons.dark_mode_outlined
                                                  : Icons.bedtime,
                                            ),
                                            // color: isSelected
                                            //     ? Colors.orange
                                            //     : Colors.grey.shade400, // ส้มถ้าเลือก เทาถ้าไม่เลือก
                                            // onPressed: () {
                                            //   // setState(() {
                                            //   //   // สลับค่า true/false ใน List ของยาตาม index
                                            //   //   record['medications'][index][timeKey] = !isSelected;
                                            //   // });
                                            // },
                                            // tooltip: timeLabel,
                                            title: Text(data['name']),
                                            subtitle: Text(data['desc']),
                                          ),
                                          // trailing:
                                          Row(
                                            mainAxisSize: MainAxisSize
                                                .min, // จำกัดขนาดของ Row ไม่ให้ยาวดึงพื้นที่ ListTile
                                            children: [
                                              const Text('จำนวนที่เหลือ'),
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                width: 80,
                                                // TextFormField(  initialValue:
                                                child: TextField(
                                                  // controller: TextEditingController(
                                                  //   text:
                                                  //       data['amount']
                                                  //           ?.toString() ??
                                                  //       '',
                                                  // ),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        (data['amount'] ?? '')
                                                            .toString(),
                                                    // labelText: "${data['amount']}",
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  onChanged: (val) => {
                                                    setDialogState(() {
                                                      List<dynamic>
                                                      currentList = List.from(
                                                        record['medications'] ??
                                                            [],
                                                      );

                                                      int targetIndex = 3;

                                                      while (currentList
                                                              .length <=
                                                          index) {
                                                        currentList.add(null);
                                                      }

                                                      currentList[index] = {
                                                        'id': docId,
                                                        'name': data['name'],
                                                        'amount':
                                                            data['amount'] -
                                                            int.parse((val)),
                                                        'skip': false,
                                                      };

                                                      record['medications'] =
                                                          currentList;

                                                      //  record['medications'][index] = data;
                                                      // record['medications'] = [
                                                      //   ...record['medications'],
                                                      //   {
                                                      //     'id': data['id'],
                                                      //     'name': data['name'],
                                                      //     'amount':
                                                      //         data['amount'] -
                                                      //         int.parse((val)),
                                                      //   },
                                                      // ];
                                                      // List<dynamic> currentList =
                                                      //     List.from(
                                                      //       record['medication'],
                                                      //     );

                                                      // currentList.add({
                                                      //   'name': data['name'],
                                                      //   'id': data['id'],
                                                      //   'amount':
                                                      //       data['amount'] - val,
                                                      //   'label': timeLabel,
                                                      // });

                                                      // record['medication'] =
                                                      //     currentList;
                                                    }),
                                                    //                              if (value.isNotEmpty) {
                                                    //   setState(() {
                                                    //     isSkipSelected = false; // ✨ ถ้าเริ่มพิมพ์ตัวเลข ให้ปลดสีปุ่ม Skip ออก
                                                    //   });
                                                    //   _saveData(); // อัปเดตค่าเข้า List ทันทีเมื่อพิมพ์
                                                    // }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  // backgroundColor: isSkipSelected
                                                  //     ? primaryColor
                                                  //     : Colors.grey[300],
                                                  foregroundColor:
                                                      (record['medications']
                                                              .isNotEmpty &&
                                                          record['medications'][index]['skip'] ==
                                                              true)
                                                      ? AppColors.danger
                                                      : Color(0xFFBA68C8),
                                                ),
                                                onPressed: () {
                                                  // setState(() {
                                                  //   isSkipSelected = true;
                                                  //   _amountController
                                                  //       .clear(); // กด Skip แล้วให้ล้างค่าใน Input ออก
                                                  // });
                                                  setDialogState(() {
                                                    List<dynamic>
                                                    currentList = List.from(
                                                      record['medications'] ??
                                                          [],
                                                    );

                                                    while (currentList.length <=
                                                        index) {
                                                      currentList.add(null);
                                                    }

                                                    currentList[index] = {
                                                      'id': docId,
                                                      'name': data['name'],
                                                      'amount': data['amount'],
                                                      'skip': true,
                                                    };

                                                    record['medications'] =
                                                        currentList;
                                                  });
                                                },
                                                child: const Text('Skip'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                              const Divider(height: 20),
                              // if (isFemale)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // ให้ชื่อ "ประจำเดือน" ชิดซ้าย
                                children: [
                                  const Text(
                                    "Period:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      int level = index + 1;
                                      bool isSelected =
                                          record['periodLevel'] >= level;

                                      double iconSize = 20.0 + (index * 5);

                                      return GestureDetector(
                                        onTap: () {
                                          // อย่าลืมใช้ setDialogState หากอยู่ใน AlertDialog
                                          setDialogState(() {
                                            record['periodLevel'] = level;
                                          });
                                        },
                                        onHorizontalDragUpdate: (details) {
                                          // double renderBoxWidth = _iconSize * 5;
                                          double position =
                                              details.localPosition.dx;

                                          setDialogState(() {
                                            // ปรับค่าให้อยู่ในช่วง 1-5 และปัดเศษขึ้น
                                            record['periodLevel'] =
                                                (position / iconSize)
                                                    .clamp(0, 5)
                                                    .toDouble();
                                            // ถ้าอยากให้เป็นเลขเต็ม 1, 2, 3, 4, 5 ให้ใช้ .ceilToDouble()
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Icon(
                                            Icons.water_drop, // รูปหยดเลือด
                                            size: iconSize,
                                            color: isSelected
                                                ? Color.lerp(
                                                    Colors.red.shade500,
                                                    Colors.red.shade900,
                                                    index / 4,
                                                  ) // ไล่สีแดงอ่อนไปเข้ม
                                                : Colors
                                                      .grey
                                                      .shade300, // ถ้าไม่เลือกเป็นสีเทา
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              const Divider(),
                              Column(
                                children: [
                                  SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Excercise:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 120, // จำกัดความกว้างช่องกรอก
                                        child: TextField(
                                          // controller: _amountController,
                                          controller: TextEditingController(
                                            text: record['typeEx']?.toString(),
                                          ),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),

                                          onChanged: (value) {
                                            record['typeEx'] = value;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          if (record['minExercise'] > 0) {
                                            setDialogState(() {
                                              record['minExercise'] =
                                                  (record['minExercise'] - 1);
                                            });
                                          }
                                        },
                                      ),

                                      SizedBox(
                                        width: 80, // จำกัดความกว้างช่องกรอก
                                        child: TextField(
                                          // controller: _amountController,
                                          controller: TextEditingController(
                                            text: record['minExercise']
                                                ?.toString(),
                                          ),
                                          keyboardType: TextInputType
                                              .number, // บังคับให้คีย์บอร์ดขึ้นเฉพาะตัวเลข
                                          textAlign: TextAlign
                                              .center, // จัดตัวเลขให้อยู่ตรงกลางช่อง
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),

                                          onChanged: (value) {
                                            record['minExercise'] = int.parse(
                                              value,
                                            );
                                          },
                                        ),
                                      ),

                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          int currentValue =
                                              int.tryParse(
                                                _amountController.text,
                                              ) ??
                                              10;
                                          // int currentValue = record['minExercise'];
                                          setDialogState(() {
                                            // _amountController.text =
                                            //     (currentValue + 1).toString();
                                            record['minExercise'] =
                                                record['minExercise'] + 1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  // _buildCircleButton(icon: Icons.add, onPressed: () {}),
                                ],
                              ),

                              const SizedBox(height: 30),
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
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () async {
                                        FirebaseFirestore.instance
                                            .collection('health')
                                            .add({
                                              'date': date,
                                              'data': record,
                                              'authorId': user
                                                  ?.uid, //auth.currentUser?.uid,
                                              'createdAt':
                                                  FieldValue.serverTimestamp(),
                                            });

                                        CollectionReference medicationRef =
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user?.uid)
                                                .collection('drugs');
                                        try {
                                          for (Map<String, dynamic> data
                                              in record['medications']) {
                                            print(data);
                                            if (data['skip'])
                                              continue; //skip: true จะข้ามข้างล่าง
                                            await medicationRef
                                                .doc(data['id'])
                                                .update({
                                                  'amount': data['amount'],
                                                  'updatedAt':
                                                      FieldValue.serverTimestamp(),
                                                });
                                          }
                                        } catch (e) {
                                          print("❌ อัปเดตล้มเหลว: $e");
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: const Text('บันทึก'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            // actions: [
            // ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime lastDayOfWeek = now.add(Duration(days: 6 - now.weekday));
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                // lastDay: _calendarFormat == CalendarFormat.week
                //     ? lastDayOfWeek
                lastDay: lastDayOfMonth,
                focusedDay: _focusedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  // setState(() {
                  //   _focusedDay =
                  //       focusedDay; // อัปเดตหน้าปฏิทินให้เลื่อนตาม (ถ้าจำเป็น)
                  // });
                  var filt = widget.data
                      .map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        DateTime d = (data['date'] as Timestamp).toDate();
                        return DateTime(d.year, d.month, d.day);
                      })
                      .where((d) {
                        return d ==
                            DateTime(
                              selectedDay.year,
                              selectedDay.month,
                              selectedDay.day,
                            );
                      })
                      .toList();
               if(filt.isEmpty)   _showEditDialog(selectedDay);
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    // _firstDayC = DateTime(focusedDay.year, focusedDay.month, 1);
                    // _lastDayC = DateTime(
                    //   focusedDay.year,
                    //   focusedDay.month + 2,
                    //   0,
                    // );
                  });
                  widget.setDates(
                    DateTime(focusedDay.year, focusedDay.month, 1),
                    DateTime(focusedDay.year, focusedDay.month + 2, 0),
                  );
                },
                // selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onHeaderTapped: (focusedDay) {
                  setState(() {
                    _focusedDay =
                        DateTime.now(); // สั่งให้โฟกัสกลับมาที่ "วันนี้"
                  });
                },
                calendarFormat: _calendarFormat,
                rowHeight: _calendarFormat == CalendarFormat.week
                    ? 85
                    : 52, // ขยายความสูงถ้าเป็นรายสัปดาห์
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false, //มีปุ่ม 2 weeks
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Color(0xFFBA68C8),
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Color(0xFFBA68C8),
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  dowTextFormatter: (date, locale) =>
                      DateFormat.E(locale).format(date),
                  weekdayStyle: const TextStyle(fontWeight: FontWeight.bold),
                  weekendStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // --- ส่วนการตกแต่งแต่ละช่องวันที่ ---
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    if (day.weekday == DateTime.sunday) {
                      return Center(
                        child: Text(
                          DateFormat.E().format(day),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            //  decoration: TextDecoration.underline,
                            // decorationColor: Color(0xFFFF758C),
                            // decorationThickness: 2,
                          ),
                        ),
                      );
                    }
                    return null; // วันอื่นใช้ค่าจาก daysOfWeekStyle ปกติ
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF06292),
                        ),
                      ),
                    );
                  },

                  markerBuilder: (context, date, events) {
                    DateTime dayOnly = DateTime.utc(
                      date.year,
                      date.month,
                      date.day,
                    );
                    // DocumentSnapshot? result;
                    // try {
                    //   result = widget.data.firstWhere((doc) => doc.data()?['isA'] == true);
                    // } catch (e) {
                    //   result = null; // ถ้า Error (หาไม่เจอ) ให้เป็น null
                    // }
                    var found = widget.data
                        .cast<
                          DocumentSnapshot?
                        >() // แปลง List ให้ยอมรับ null ได้
                        .firstWhere((doc) {
                          DateTime itemDate = (doc?['date'] as Timestamp)
                              .toDate();
                          return itemDate.year == dayOnly.year &&
                              itemDate.month == dayOnly.month &&
                              itemDate.day == dayOnly.day;
                        }, orElse: () => null);

                    var data = (found != null && found.exists)
                        ? found.data() as Map<String, dynamic>
                        : null;

                    if (_calendarFormat == CalendarFormat.week) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 50,
                          ), // ขยับลงมาใต้ตัวเลขวันที่
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sentiment_satisfied,
                                // color: data ? colors[data['data']['mental_level']] : colors[5],
                                color:
                                    colors[data?['data']['mental_level'] ?? 5],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      if (data == null) return const SizedBox();
                      return Positioned(
                        bottom: 8,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            // color: colors[data?['mental_level'] ?? 5],
                            color: colors[data['data']['mental_level'] ?? 5],
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                  },
                ),

                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
              ),

              // --- ปุ่มกดสลับโหมด (สามเหลี่ยมทึบลง) ---
              GestureDetector(
                onTap: () {
                  setState(() {
                    _calendarFormat = (_calendarFormat == CalendarFormat.week)
                        ? CalendarFormat.month
                        : CalendarFormat.week;
                  });
                },
                child: Container(
                  width: double.infinity, // แถบยาวเต็มการ์ดด้านล่าง
                  height: 30,
                  decoration: const BoxDecoration(
                    // color: Colors.grey[50],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _calendarFormat == CalendarFormat.week
                            ? Icons.arrow_drop_down_rounded
                            : Icons.arrow_drop_up_rounded,
                        color: Colors.grey[400],
                        size: 35,
                      ),
                      // Text(_calendarFormat == CalendarFormat.week ? " View Month " : " View Week ")
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildTimeChip(int index, String timeKey, IconData iconData) {
  // bool isSelected = record['medications'][index][timeKey];
  return IconButton(
    icon: Icon(iconData),
    // color: isSelected
    //     ? Colors.orange
    //     : Colors.grey.shade400, // ส้มถ้าเลือก เทาถ้าไม่เลือก
    onPressed: () {
      // setState(() {
      //   // สลับค่า true/false ใน List ของยาตาม index
      //   record['medications'][index][timeKey] = !isSelected;
      // });
    },
    tooltip: timeKey,
  );
}
