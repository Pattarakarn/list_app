import 'package:flutter/material.dart';

class PeriodSummaryCard extends StatelessWidget {
  const PeriodSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // Row(
          //   children: [
          //     Icon(Icons.water_drop, color: Colors.redAccent[100]),
          //     const SizedBox(width: 8),
          //     const Text("Period Tracker", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          //   ],
          // ),
          const Text("รอบเดือนล่าสุด"),
          const Text("x - x (กี่วัน)"),
          // const SizedBox(height: 15),
          // const Text("เหลืออีก 5 วัน", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          // const Text("รอบเดือนถัดไปจะมาวันที่ 2 เม.ย.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
