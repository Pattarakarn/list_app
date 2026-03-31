import 'package:flutter/material.dart';
import 'package:list_app/app_colors.dart'; 

class PeriodSummaryCard extends StatelessWidget {
  const PeriodSummaryCard({super.key});

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
          const Text("รอบเดือนล่าสุด",style: TextStyle(fontWeight: FontWeight.bold),),
          const Text("x - x (กี่วัน)",style: TextStyle(color: AppColors.secondary),),
          // const SizedBox(height: 15),

// Icons.add_circle_outline
          // How's Today
        ],
      ),
    );
  }
}
