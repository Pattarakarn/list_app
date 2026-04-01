import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:list_app/app_colors.dart'; //
import 'package:intl/intl.dart';

class SymptomHistoryList extends StatelessWidget {
  final List<DocumentSnapshot> datas;
  const SymptomHistoryList({super.key, required this.datas});

  @override
  Widget build(BuildContext context) {
    bool isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "อาการล่าสุด", //ช่องแล้วก็แสดงวันตามที่ปฏิทินโชว์
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (datas.isNotEmpty)
          ListView.builder(
            shrinkWrap: true, // สำคัญ! เพื่อให้อยู่ใน SingleChildScrollView ได้
            physics: const NeverScrollableScrollPhysics(),
            itemCount: datas.length,
            itemBuilder: (context, index) {
              final data = (datas[index].data()) as Map<String, dynamic>;
              // print(data);
              final mentallevel = data['data']['mental_level'];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side:const BorderSide(
                    color: AppColors.blue, // สีขอบ
                  ),
                ),
                color: isLightMode ? Colors.white : Colors.transparent,
                child: ListTile(
                  leading: CircleAvatar(
                    // backgroundColor: Colors.transparent,
                    child: Icon(
                      mentallevel == 0
                          ? Icons.sentiment_very_dissatisfied
                          : mentallevel == 1
                          ? Icons.sentiment_dissatisfied
                          : mentallevel == 2
                          ? Icons.sentiment_neutral
                          : mentallevel == 3
                          ? Icons.sentiment_satisfied
                          : mentallevel == 4
                          ? Icons.sentiment_very_satisfied
                          : Icons.warning_amber_rounded,
                      color: mentallevel < 0
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(data['data']['symptoms'].split('\n').first ?? 'บันทึก'),
                  subtitle: Text(
                    DateFormat('dd MMMM yyyy').format(data['date'].toDate()),
                    // (data['date'] != null)
                    //     ? DateFormat(
                    //         'dd MMMM yyyy',
                    //       ).format(data['date'] | data['createdAt]).toString()
                    //     : "29 มี.ค. 2026",
                    style: const TextStyle(fontSize: 12),
                  ),

                  trailing: Wrap(
                    spacing: 4, // ระยะห่างระหว่างไอคอน
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      if (data['data']['pain_level'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF06292).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${data['data']['pain_level']}/10",
                            style:const TextStyle(
                              color:  Color(0xFFF06292),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (data['data']['periodLevel'] > 0)
                        Icon(
                          Icons.water_drop,
                          color: AppColors.danger,
                          size: 20.0 + (index * data['data']['periodLevel']),
                        ),
                      if (data['data']['medications'].isNotEmpty)
                       const Icon(Icons.medical_services, color: Color(0xFFBA68C8)),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
