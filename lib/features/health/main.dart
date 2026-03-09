import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  DateTime selectedDate = DateTime.now();
  int? selectedLevel; // 0: น้อยมาก, 1: น้อย, 2: ปานกลาง, 3: มาก
  
  // สีตามระดับความมากน้อย (4 ระดับ)
  final List<Color> flowColors = [
    Colors.pink[100]!,
    Colors.pink[300]!,
    Colors.red[400]!,
    Colors.red[900]!,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("บันทึกรอบเดือน"), backgroundColor: Colors.pink[50]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ส่วนแสดงประจำเดือนล่าสุด
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // เอาวันนี้อยู่ตรงกลาง ใส่ไอคอนรูปยิ้มดีกว่า ส่วนbloodเป็นอันเล็ก
            const Text("สัปดาห์นี้", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildWeeklyBloodSelector(),
            const SizedBox(height: 24),

            // 3. ส่วนเลือกวันที่ต้องการดูข้อมูล
            _buildDatePickerSection(),
            const SizedBox(height: 24),

            // 4. รายการอาการล่าสุด
            const Text("อาการล่าสุด", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildSymptomList(),
          ],
        ),
      ),
      
      // 5. ปุ่มเพิ่มอาการ
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSymptomPopup(),
        label: const Text("เพิ่มอาการ"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  // --- Widget ย่อยๆ ---
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text("ประจำเดือนล่าสุดมาเมื่อ", style: TextStyle(color: Colors.pink)),
          Text(
            "12 กุมภาพันธ์ 2026 (กี่วัน)", 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[900]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBloodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        bool isSelected = selectedLevel != null && index == 3; // สมมติลองเลือกอันนึง
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedLevel = (selectedLevel ?? 0 + 1) % 4; // คลิ๊กเพื่อเปลี่ยนระดับสี (Demo)
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
                color: index == 3 ? flowColors[selectedLevel ?? 0] : Colors.grey[300],
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
      title: const Text("ดูข้อมูลย้อนหลัง"),
      subtitle: Text(DateFormat('dd MMMM yyyy').format(selectedDate)),
      trailing: const Icon(Icons.calendar_month, color: Colors.pink),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => selectedDate = date);
      },
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
            leading: const Icon(Icons.sentiment_dissatisfied, color: Colors.orange),
            title: Text(index == 0 ? "ปวดท้องน้อย" : "คัดหน้าอก"),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("เลือกระดับปริมาณเลือด", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            TextField(decoration: InputDecoration(labelText: "รายละเอียดเพิ่มเติม")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }
    // TableCalendar(
    //           firstDay: DateTime.utc(2024, 1, 1),
    //           lastDay: DateTime.utc(2030, 12, 31),
    //           focusedDay: _focusedDay,
    //           selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
    //           eventLoader: (day) => _events[DateTime.utc(day.year, day.month, day.day)] ?? [],
    //           onDaySelected: (selectedDay, focusedDay) {
    //             setState(() {
    //               _selectedDay = selectedDay;
    //               _focusedDay = focusedDay;
    //             });
    //           },
    //           calendarStyle: const CalendarStyle(
    //             markerDecoration: BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
    //             selectedDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
    //             todayDecoration: BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle),
    //           ),
    //         ),
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
            const TextField(decoration: InputDecoration(labelText: "รายละเอียดอื่นๆ")),
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