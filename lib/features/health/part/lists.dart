import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:list_app/app_colors.dart'; //
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SymptomHistoryList extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  final List<DocumentSnapshot> datas;
  final DateTime firstDayC;
  final DateTime lastDayC;
  SymptomHistoryList({
    super.key,
    required this.datas,
    required this.firstDayC,
    required this.lastDayC,
  });
  void _showEditSheet(BuildContext context, Map<String, dynamic> data) async {
    List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.lightGreen,
      Colors.green,
      Colors.grey,
    ];

    String formattedDate = DateFormat(
      'dd MMMM yyyy',
    ).format(data['date'].toDate());
    Map<String, dynamic> record = data['data'];

    final TextEditingController _controller = TextEditingController();
    final TextEditingController _amountController = TextEditingController(
      text: record['minExercise']?.toString() ?? '',
    );
    final TextEditingController _typeExController = TextEditingController(
      text: record['typeEx']?.toString() ?? '',
    );

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('drugs')
        .where('isDelete', isNotEqualTo: true)
        .get();
    List<DocumentSnapshot> dataDrug = snapshot.docs;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true, //
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.90,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                // เอา Expanded ครอบ SingleChildScrollView ตรงนี้
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
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
                                color: isSel
                                    ? colors[index]
                                    : Colors.grey.shade300,
                                onPressed: () => setModalState(
                                  () => record['mental_level'] = index,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          // TextField(
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Symptom . . .",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            onChanged: (val) =>
                                setModalState(() => record['symptoms'] = val),
                            // controller: TextEditingController(text: record['symptoms']),
                            initialValue: record['symptoms'],
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
                              ...record['medications'].asMap().entries.map((
                                entry,
                              ) {
                                int idx = entry.key;
                                var med = entry.value;

                                return ListTile(
                                  // leading: Icon(
                                  //   med.label == 'เช้า'
                                  //       ? Icons.wb_sunny_outlined
                                  //       : med.label == 'กลางวัน'
                                  //       ? Icons.wb_sunny
                                  //       : med.label == 'เย็น'
                                  //       ? Icons.dark_mode_outlined
                                  //       : Icons.bedtime,
                                  // ),
                                  title: Text(med['name']),

                                  // subtitle: Text(data['desc']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('จำนวนที่เหลือ'),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 80,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: (med['amount'] ?? '')
                                                .toString(),
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (val) => {
                                            setModalState(() {
                                              List<dynamic> currentList =
                                                  List.from(
                                                    record['medications'] ?? [],
                                                  );

                                              while (currentList.length <=
                                                  idx) {
                                                currentList.add(null);
                                              }

                                              currentList[idx] = {
                                                'id': med['id'],
                                                'name': med['name'],
                                                'amount': int.parse((val)),
                                                'skip': false,
                                              };

                                              record['medications'] =
                                                  currentList;
                                            }),
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: med['skip']
                                              ? Colors.grey
                                              : const Color(0xFFBA68C8),
                                        ),
                                        onPressed: () {
                                          setModalState(() {
                                            List<dynamic> currentList =
                                                List.from(
                                                  record['medications'] ?? [],
                                                );

                                            while (currentList.length <= idx) {
                                              currentList.add(null);
                                            }

                                            currentList[idx] = {
                                              'id': med['id'],
                                              'name': med['name'],
                                              'amount': med['amount'],
                                              'skip': true,
                                            };

                                            record['medications'] = currentList;
                                          });
                                        },
                                        child: const Text('Skip'),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              // TextButton.icon(
                              //   onPressed: () => setModalState(
                              //     () => record['medications'].add({
                              //       "name": "",
                              //       "morning": false,
                              //       "noon": false,
                              //       "evening": false,
                              //       "night": false,
                              //     }),
                              //   ),
                              //   icon: const Icon(Icons.add),
                              //   label: const Text("เพิ่มยา"),
                              //   style: OutlinedButton.styleFrom(
                              //     foregroundColor: const Color(0xFFBA68C8),
                              //   ),
                              // ),
                            ],
                          ),

                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: dataDrug.length,
                            itemBuilder: (context, index) {

                              var doc = dataDrug[index];
                              Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;
                              String docId = doc.id;

                              List<String> activeTimes = [];
                              bool hasActiveItem = false;
                              if(record['medications'].any((item) => item['id'] == doc.id)) return null;
                              data['schedule'].forEach((timeName, isActive) {
                                if (isActive == true) {
                                  activeTimes.add(timeName);
                                  hasActiveItem = true;
                                }
                              });
                              if (!hasActiveItem) {
                                activeTimes.add('');
                              }

                              return Column(
                                children: activeTimes.map((timeLabel) {
                                  return Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    runSpacing: 8,
                                    children: [
                                      ListTile(
                                        leading: Icon(
                                          timeLabel == 'เช้า'
                                              ? Icons.wb_sunny_outlined
                                              : timeLabel == 'กลางวัน'
                                              ? Icons.wb_sunny
                                              : timeLabel == 'เย็น'
                                              ? Icons.dark_mode_outlined
                                              : timeLabel == 'ก่อนนอน'
                                              ? Icons.bedtime
                                              : Icons.local_hospital,
                                        ),
                                        title: Text(data['name']),
                                        subtitle: Text(data['desc']),
                                      ),
                                      // trailing:
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('จำนวนที่เหลือ'),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 80,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                hintText: (data['amount'] ?? '')
                                                    .toString(),
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (val) => {
                                                setModalState(() {
                                                  List<dynamic> currentList =
                                                      List.from(
                                                        record['medications'] ??
                                                            [],
                                                      );

                                                  int targetIndex = 3;

                                                  while (currentList.length <=
                                                      index) {
                                                    currentList.add(null);
                                                  }

                                                  currentList[index] = {
                                                    'id': docId,
                                                    'name': data['name'],
                                                    'amount':
                                                        data['amount'] -
                                                        int.parse((val)),
                                                    'skip': false,
                                                  };

                                                  record['medications'] =
                                                      currentList;
                                                }),
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              // backgroundColor: isSkipSelected
                                              //     ? primaryColor
                                              //     : Colors.grey[300],
                                              foregroundColor:
                                                  (record['medications']
                                                          .isNotEmpty &&
                                                      record['medications'][index]['skip'] ==
                                                          true)
                                                  ? AppColors.danger
                                                  : Color(0xFFBA68C8),
                                            ),
                                            onPressed: () {
                                              setModalState(() {
                                                List<dynamic> currentList =
                                                    List.from(
                                                      record['medications'] ??
                                                          [],
                                                    );

                                                while (currentList.length <=
                                                    index) {
                                                  currentList.add(null);
                                                }

                                                currentList[index] = {
                                                  'id': docId,
                                                  'name': data['name'],
                                                  'amount': data['amount'],
                                                  'skip': true,
                                                };

                                                record['medications'] =
                                                    currentList;
                                              });
                                            },
                                            child: const Text('Skip'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
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
                                  bool isSelected =
                                      record['periodLevel'] >= level;

                                  double iconSize = 20.0 + (index * 5);

                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        record['periodLevel'] = level;
                                      });
                                    },
                                    onHorizontalDragUpdate: (details) {
                                      double position =
                                          details.localPosition.dx;

                                      setModalState(() {
                                        record['periodLevel'] =
                                            (position / iconSize)
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
                          const SizedBox(height: 20),
                          Text(
                            "Excercise:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 120, // จำกัดความกว้างช่องกรอก
                                    child: TextField(
                                      controller: _typeExController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),

                                      onChanged: (value) {
                                        record['typeEx'] = value;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        record['minExercise'] = int.parse(
                                          value,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text('นาที'),
                                ],
                              ),

                            ],
                          ),

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
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    FirebaseFirestore.instance
                                        .collection('health')
                                        .doc(data['id'])
                                        .update({
                                          // 'date':
                                          'data': record,
                                          'updateddAt':
                                              FieldValue.serverTimestamp(),
                                        });

                                    CollectionReference medicationRef =
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(data['authorId'])
                                            .collection('drugs');
                                    try {
                                      for (Map<String, dynamic> data
                                          in record['medications']) {
                                        await medicationRef
                                            .doc(data['id'])
                                            .update({
                                              'amount': data['amount'],
                                              'updatedAt':
                                                  FieldValue.serverTimestamp(),
                                            });
                                      }
                                    } finally {
                                      print('final');
                                    }
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
    // datas.sort((a, b) {
    //   Timestamp dateA = a['date'];
    //   Timestamp dateB = b['date'];
    //   return dateB.compareTo(dateA);
    // });
    List filteredDatas = datas.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime date = (data['date'] as Timestamp).toDate();

      return date.year == lastDayC.year && date.month == lastDayC.month-1;
    }).toList();
    filteredDatas.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      DateTime dateA = (dataA['date'] as Timestamp).toDate();
      DateTime dateB = (dataB['date'] as Timestamp).toDate();

      return dateB.compareTo(dateA);
    });
    List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.lightGreen,
      Colors.green,
      Colors.grey,
    ];
    //   return SizedBox(
    // height: MediaQuery.of(context).size.height * 0.8,
    //   // FractionallySizedBox(heightFactor: 0.8, // 80%
    // child:
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "บันทึกที่ผ่านมา",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (datas.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap:
                      true, // สำคัญ! เพื่อให้อยู่ใน SingleChildScrollView ได้
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDatas.length,
                  itemBuilder: (context, index) {
                    final data =
                        (filteredDatas[index].data()) as Map<String, dynamic>;
                    data['id'] = filteredDatas[index].id;

                    final mentallevel = data['data']['mental_level'] ?? -1;
                    DateTime thirtyDaysAgo = DateTime.now().subtract(
                      const Duration(days: 31),
                    ); // if(DateTime.parse(data['date']).isAfter(thirtyDaysAgo))

                    // if ((data['date'] as Timestamp).toDate().isBefore(firstDayC)
                    //    || (data['date'] as Timestamp).toDate().isAfter(
                    //       DateTime(firstDayC.year, firstDayC.month + 1, 0),
                    //     )
                    //     )
                    //   return null;
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
                          leading: mentallevel == -1
                              ? null
                              : CircleAvatar(
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
                                        : mentallevel == 5
                                        ? Icons.warning_amber_rounded
                                        : null,
                                    color: mentallevel < 0
                                        ? Colors.white
                                        : colors[mentallevel].withValues(
                                            alpha: 0.8,
                                          ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                          title: Text(
                            data['data']['symptoms'].split('\n').first ??
                                'บันทึก',
                          ),
                          subtitle: Text(
                            DateFormat(
                              'dd MMMM yyyy',
                            ).format(data['date'].toDate()),
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
                              if ((data['data']['minExercise'] ?? 0) > 0)
                                Icon(
                                  Icons.accessibility_new,
                                  color: data['data']['minExercise'] >= 30
                                      ? Colors.blue
                                      : data['data']['minExercise'] >= 10
                                      ? Colors.blue[300]
                                      : Colors.blue[100],
                                ),
                              if (data['data']['medications'].isNotEmpty)
                                Icon(
                                  Icons.medical_services,
                                  color: data['data']['medications'][0]['skip']
                                      ? Colors.grey
                                      : Color(0xFFBA68C8),
                                ),
                              if (data['data']['periodLevel'] > 0)
                                Icon(
                                  Icons.water_drop,
                                  color: AppColors.danger,
                                  size: 20.0 + (data['data']['periodLevel']),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  // ),
                ),
              ),
            ],
          ),
      ],
      // ),
    );
  }
}
