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
  // final Map<DateTime, Map<String, dynamic>> data;
  const MoodCalendarWidget({super.key, required this.data});

  @override
  State<MoodCalendarWidget> createState() => _MoodCalendarWidgetState();
}

class _MoodCalendarWidgetState extends State<MoodCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  final user = FirebaseAuth.instance.currentUser;
  late DateTime _firstDayC = DateTime(_focusedDay.year, _focusedDay.month, 1);
  late DateTime _lastDayC = DateTime(
    _focusedDay.year,
    _focusedDay.month + 1,
    0,
  );
  // List<Color> colors = Color.Mental;
  List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow.shade700,
    Colors.lightGreen,
    Colors.green,
    Colors.grey,
  ];

  void _showEditDialog(date) {
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
    };
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
            content:
                // Row(  children:
                SizedBox(
                  width: double
                      .maxFinite, // ให้กว้างเท่าที่ Dialog จะยอมให้กว้างได้
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // สำคัญ! เพื่อให้ Dialog ไม่สูงเต็มจอ
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          List<IconData> icons = [
                            Icons.sentiment_very_dissatisfied,
                            Icons.sentiment_dissatisfied,
                            Icons.sentiment_neutral,
                            Icons.sentiment_satisfied,
                            Icons.sentiment_very_satisfied,
                          ];

                          bool isSel = record['mental_level'] == (index );
                          return IconButton(
                            icon: Icon(icons[index]),
                            iconSize: 40,
                            color: isSel ? colors[index] : Colors.grey.shade300,
                            onPressed: () => setDialogState(
                              () => record['mental_level'] = index ,
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
                        onChanged: (val) =>
                            setDialogState(() => record['symptoms'] = val),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            "Level of discomfort:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Slider(
                              value: record['pain_level'].toDouble(),
                              min: 0,
                              max: 10,
                              divisions: 10,
                              label: record['pain_level'].toString(),
                              onChanged: (val) => setDialogState(
                                () => record['pain_level'] = val.toInt(),
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
                          ...record['medications'].asMap().entries.map((entry) {
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
                          TextButton.icon(
                            onPressed: () => setDialogState(
                              () => record['medications'].add({
                                "name": "",
                                "morning": false,
                                "noon": false,
                                "evening": false,
                                "night": false,
                              }),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text("เพิ่มยา"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFBA68C8),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      // if (isFemale)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // ให้ชื่อ "ประจำเดือน" ชิดซ้าย
                        children: [
                          const Text(
                            "Period:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              int level = index + 1;
                              bool isSelected = record['periodLevel'] >= level;

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
                                  double position = details.localPosition.dx;

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

                      // Text(
                      //     "Excercise:",
                      //     style: TextStyle(fontWeight: FontWeight.bold),
                      //   ),
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
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('health')
                                    .add({
                                      'date': date,
                                      'data': record,
                                      'authorId':
                                          user?.uid, //auth.currentUser?.uid,
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });
                                Navigator.pop(context);
                              },
                              child: const Text('บันทึก'),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                lastDay: _calendarFormat == CalendarFormat.week
                    ? lastDayOfWeek
                    : lastDayOfMonth,
                focusedDay: _focusedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  // setState(() {
                  //   _focusedDay =
                  //       focusedDay; // อัปเดตหน้าปฏิทินให้เลื่อนตาม (ถ้าจำเป็น)
                  // });
                  _showEditDialog(selectedDay);
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    // คำนวณวันแรกและวันสุดท้ายของเดือนที่แสดงอยู่ใหม่
                    _firstDayC = DateTime(focusedDay.year, focusedDay.month, 1);
                    _lastDayC = DateTime(
                      focusedDay.year,
                      focusedDay.month + 1,
                      0,
                    );
                  });

                  print("ปฏิทินเปลี่ยนหน้ามาที่เดือน: ${focusedDay.month}");
                  print("เริ่มที่: $_firstDayC ถึง: $_lastDayC");
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
