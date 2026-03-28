import 'package:flutter/material.dart';

class SymptomHistoryList extends StatelessWidget {
  const SymptomHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "อาการล่าสุด",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true, // สำคัญ! เพื่อให้อยู่ใน SingleChildScrollView ได้
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3, // สมมติ 3 รายการล่าสุด
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.warning_amber_rounded, color: Colors.white),
                ),
                title: const Text("ปวดท้องเมน"),
                subtitle: const Text("28 มี.ค. 2026"),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        ),
      ],
    );
  }
}
