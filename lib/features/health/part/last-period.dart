import 'package:flutter/material.dart';
import 'package:list_app/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PeriodSummaryCard extends StatelessWidget {
  final List<DocumentSnapshot> datas;
  const PeriodSummaryCard({super.key, required this.datas});

  Map<String, DateTime>? findConsecutiveRange(List<dynamic> items) {
    var filtered = items
        .where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['data']['periodLevel'] > 0; // != null;
        })
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          DateTime d = (data['date'] as Timestamp).toDate();
          return DateTime(d.year, d.month, d.day);
        })
        .toList();

    if (filtered.isEmpty) {
      // ไม่พบข้อมูลที่ตรงตามเงื่อนไข
      return null;
    }

    filtered.sort((a, b) => b.compareTo(a));
    // List<DateTime> datesOnly = filtered
    //     .map((d) => DateTime(d.year, d.month, d.day))
    //     .toList();

    DateTime firstDate = filtered.first;
    DateTime lastDate = filtered.first;

    // for (int i = 0; i < datesOnly.length - 1; i++) {
    //   DateTime current = datesOnly[i];
    //   DateTime next = datesOnly[i + 1];
    for (int i = 0; i < filtered.length - 1; i++) {
      DateTime current = filtered[i];
      DateTime next = filtered[i + 1];
      int gap = current.difference(next).inDays;

      // ถ้าห่างกัน 1 หรือ 2 วัน ให้ถือว่ายังต่อเนื่องกันอยู่
      if (gap >= 1 && gap <= 2) {
        // lastDate = filtered[i + 1];
        firstDate = next;
      }
      // ถ้าเป็น 0 แปลว่าเป็นข้อมูลวันเดียวกัน ให้ข้ามไปเช็คตัวถัดไป
      else if (gap == 0) {
        continue;
      }
      // ถ้าห่างกันตั้งแต่ 3 วันขึ้นไป ถือว่าขาดช่วง (Break)
      else {
        break;
      }
    }

    // print("ช่วงวันที่ต่อเนื่องล่าสุดคือ: $firstDate ถึง $lastDate");
    return {'first': firstDate, 'last': lastDate};
  }

  @override
  Widget build(BuildContext context) {
   var range = findConsecutiveRange(datas);
    // print(results);
    DateFormat formatter = DateFormat('dd MMM yyyy');
    final DateTime? start = range?['first'];
final DateTime? end = range?['last'];
    int days = end!.difference(start!).inDays + 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          const BoxShadow(
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
           Text(
             "${formatter.format(start)}  - ${formatter.format(end)} ($daysวัน)",
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
