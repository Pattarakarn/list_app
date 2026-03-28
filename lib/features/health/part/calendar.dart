import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MoodCalendarWidget extends StatefulWidget {
  const MoodCalendarWidget({super.key});

  @override
  State<MoodCalendarWidget> createState() => _MoodCalendarWidgetState();
}

class _MoodCalendarWidgetState extends State<MoodCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  // จำลองข้อมูลอารมณ์ (ในอนาคตดึงจาก Firebase)
  // วันไหนไม่มีใน Map นี้ จะถือว่าเป็นสีเทา
  final Map<DateTime, Map<String, dynamic>> _moodData = {
    DateTime.utc(2026, 3, 28): {
      "emoji": "😊",
      "label": "แฮปปี้",
      "color": Colors.orange,
    },
    DateTime.utc(2026, 3, 26): {
      "emoji": "😔",
      "label": "เพลีย",
      "color": Colors.blueGrey,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
            color: Colors.white,
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
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,

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
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
                          style: const TextStyle(color: Colors.red),
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
                          // decoration: TextDecoration.underline,
                          // decorationColor: Color(0xFFFF758C),
                          // decorationThickness: 2,
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
                    var data = _moodData[dayOnly];

                    if (_calendarFormat == CalendarFormat.week) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 35,
                          ), // ขยับลงมาใต้ตัวเลขวันที่
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ถ้าไม่มีข้อมูล ให้ใช้สีเทา (Grayscale Filter หรือสีจาง)
                              Text(
                                data?['emoji'] ?? "😶",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: data == null ? Colors.grey : null,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data?['label'] ?? "ไม่มี",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: data == null
                                      ? Colors.grey[400]
                                      : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // 2. โหมดเดือน: แสดงแค่จุด (Dot) เล็กๆ
                      if (data == null) return const SizedBox();
                      return Positioned(
                        bottom: 8,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: data['color'],
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
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: Icon(
                    _calendarFormat == CalendarFormat.week
                        ? Icons.arrow_drop_down_rounded
                        : Icons.arrow_drop_up_rounded,
                    color: Colors.grey[400],
                    size: 35,
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
