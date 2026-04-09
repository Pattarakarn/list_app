import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:list_app/app_colors.dart'; //
import 'package:intl/intl.dart';
// import 'package:list_app/utils/constant.dart';

class SymptomHistoryList extends StatelessWidget {
  final List<DocumentSnapshot> datas;
  const SymptomHistoryList({super.key, required this.datas});

  void _showEditSheet(BuildContext context, Map<String, dynamic> data) {
    List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.lightGreen,
      Colors.green,
      Colors.grey,
    ];
    // String type = _type;
    // bool hideEmpty = _isHideBox;
    // bool requireDate = _requireDate;
    String formattedDate = DateFormat(
      'dd MMMM yyyy',
    ).format(data['date'].toDate());
    Map<String, dynamic> record = data['data'];
    print(data);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true, //
      backgroundColor: AppColors.gray,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.90,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Edit $formattedDate",
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
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

                      bool isSel = record['mental_level'] == (index);
                      return IconButton(
                        icon: Icon(icons[index]),
                        iconSize: 40,
                        color: isSel ? colors[index] : Colors.grey.shade300,
                        onPressed: () =>
                            setModalState(() => record['mental_level'] = index),
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
                        setModalState(() => record['symptoms'] = val),
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
                          onChanged: (val) => setModalState(
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
                        onPressed: () => setModalState(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              setModalState(() {
                                record['periodLevel'] = level;
                              });
                            },
                            onHorizontalDragUpdate: (details) {
                              double position = details.localPosition.dx;

                              setModalState(() {
                                record['periodLevel'] = (position / iconSize)
                                    .clamp(0, 5)
                                    .toDouble();
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
                                      )
                                    : Colors.grey.shade300,
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
                      // const Spacer(),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('health')
                                .doc(data['id'])
                                .update({
                                  // 'date': 
                                  'data': record,
                                  'updateddAt': FieldValue.serverTimestamp(),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    datas.sort((a, b) {
      Timestamp dateA = a['date'];
      Timestamp dateB = b['date'];
      return dateB.compareTo(dateA);
    });
    //   return SizedBox(
    // height: MediaQuery.of(context).size.height * 0.8,
    //   // FractionallySizedBox(heightFactor: 0.8, // 80%
    // child:
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "อาการล่าสุด", //ช่องแล้วก็แสดงวันตามที่ปฏิทินโชว์
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (datas.isNotEmpty)
          // Expanded( child:
          ListView.builder(
            shrinkWrap: true, // สำคัญ! เพื่อให้อยู่ใน SingleChildScrollView ได้
            physics: const NeverScrollableScrollPhysics(),
            itemCount: datas.length,
            itemBuilder: (context, index) {
              final data = (datas[index].data()) as Map<String, dynamic>;
              data['id'] = datas[index].id;

              final mentallevel = data['data']['mental_level'] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(
                    color: AppColors.blue, // สีขอบ
                  ),
                ),
                color: isLightMode ? Colors.white : Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    15,
                  ), // ปรับให้โค้งเท่ากับ Card
                  onTap: () {
                    _showEditSheet(context, data);
                  },
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
                    title: Text(
                      data['data']['symptoms'].split('\n').first ?? 'บันทึก',
                    ),
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
                              color: const Color(
                                0xFFF06292,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${data['data']['pain_level']}/10",
                              style: const TextStyle(
                                color: Color(0xFFF06292),
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
                          const Icon(
                            Icons.medical_services,
                            color: Color(0xFFBA68C8),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
            // ),
          ),
      ],
      // ),
    );
  }
}
