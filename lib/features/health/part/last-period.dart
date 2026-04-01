import 'package:flutter/material.dart';
import 'package:list_app/app_colors.dart';

class PeriodSummaryCard extends StatelessWidget {
  const PeriodSummaryCard({super.key});

  // void findConsecutiveRange(List<Map<String, dynamic>> items) {
  //   // 1. กรองเฉพาะ isA: true และแปลง Date ให้เป็น DateTime ที่คำนวณได้
  //   var filtered = items
  //       .where((item) => item['isA'] == true)
  //       .map(
  //         (item) => (item['date'] as Timestamp).toDate(),
  //       ) // หรือแปลงจาก String/Date ปกติ
  //       .toList();

  //   if (filtered.isEmpty) return;

  //   // 2. เรียงจากใหม่ไปเก่า (Descending)
  //   filtered.sort((a, b) => b.compareTo(a));

  //   DateTime firstDate = filtered.first; // วันที่ล่าสุด (วันเริ่มส่อง)
  //   DateTime lastDate = filtered.first; // จะใช้วิ่งถอยหลังไปเรื่อยๆ

  //   // 3. วนลูปถอยหลังเช็ค -1 วัน
  //   for (int i = 0; i < filtered.length - 1; i++) {
  //     DateTime current = filtered[i];
  //     DateTime next = filtered[i + 1];

  //     // เช็คว่าห่างกันแค่ 1 วันพอดีไหม (เอาเวลาออกด้วย .year, .month, .day)
  //     DateTime currentOnlyDate = DateTime(
  //       current.year,
  //       current.month,
  //       current.day,
  //     );
  //     DateTime nextOnlyDate = DateTime(next.year, next.month, next.day);

  //     if (currentOnlyDate.difference(nextOnlyDate).inDays == 1) {
  //       lastDate =
  //           next; // ถ้าห่างกัน 1 วันพอดี ให้ขยับวันสุดท้ายของช่วงถอยไปอีก
  //     } else {
  //       break; // ถ้าเริ่มแหว่ง (ห่างเกิน 1 วัน) ให้หยุดทันที
  //     }
  //   }

  //   print("ช่วงวันที่ต่อเนื่องกันคือ: $firstDate ถึง $lastDate");
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Row(
          //   children: [
          //     Icon(Icons.water_drop, color: Colors.redAccent[100]),
          //     const SizedBox(width: 8),
          //     const Text("Period Tracker", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          //   ],
          // ),
          const Text(
            "รอบเดือนล่าสุด",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            "x - x (กี่วัน)",
            style: TextStyle(color: AppColors.secondary),
          ),
          // const SizedBox(height: 15),

          // Icons.add_circle_outline
          // How's Today
        ],
      ),
    );
  }
}
