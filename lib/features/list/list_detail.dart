import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // อย่าลืมเพิ่ม intl ใน pubspec.yaml สำหรับจัดการวันที่
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../app_colors.dart';

// const DetailPage({super.key});

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(title: const Text('รายละเอียด')),
//     body: SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         columns: const [
//           DataColumn(label: Text('วันที่')),
//           DataColumn(label: Text('ข้อมูล')),
//           DataColumn(label: Text('หมายเหตุ')),
//         ],
//         rows: List.generate(3, (index) => DataRow(
//           cells: [
//             DataCell(Text('2024-05-0${index + 1}')),
//             DataCell(Text('ข้อมูล $index')),
//             DataCell(Text('โน้ต $index')),
//           ],
//         )),
//       ),
//     ),
//   );
// }
class DetailPage extends StatefulWidget {
  final String title;
  final String docId; // รับค่า ID มาจากหน้าลิสต์

  const DetailPage({super.key, required this.title, required this.docId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // เก็บข้อมูลแถวในตาราง
  List<Map<String, dynamic>> rows = [];
  bool isInitialized = false;
  int dynamicColumnsCount = 3; // ค่าเริ่มต้น 3 คอลัมน์ (สูงสุด 8)
  List<String> headers = ['หัวข้อ'];
  // (จะทำงานครั้งเดียวตอนเปิดหน้านี้ขึ้นมา)
  bool _isSuccess = false;
  bool _isHideBox = false;
  @override
  void initState() {
    super.initState();

    rows = [];
  }

  void _addRow() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      Map<String, dynamic> dynamicCells = {};
      for (int i = 0; i < headers.length; i++) {
        dynamicCells['col${i + 1}'] = {'text': '', 'num': ''};
      }
      Map<String, dynamic> newRow = {
        'date': DateFormat('dd/MM/yyyy').format(pickedDate),
        'note': '',
      };
      newRow.addAll(dynamicCells);
      setState(() {
        // rows.add({
        //   'date': DateFormat('dd/MM/yyyy').format(pickedDate),
        //   'data': List.generate(dynamicColumnsCount, (index) => ""), // สร้างช่องว่างตามจำนวนคอลัมน์
        //   'note': ""
        // });
        rows.add({...newRow});
        //   rows.add({
        //   'date': DateFormat('dd/MM/yyyy').format(pickedDate),
        //   // สร้าง Map ย่อยเพื่อเก็บ Text และ Number สำหรับคอลัมน์ 2, 3, 4
        //   'col2': {'text': '', 'num': ''},
        //   'col3': {'text': '', 'num': ''},
        //   'col4': {'text': '', 'num': ''},
        // ...dynamicCells,
        //   'note': '',
        // });
      });
    }
  }

  void _saveToFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.docId)
          .update({
            'data': rows,
            'header': headers,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      setState(() => _isSuccess = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text('บันทึกข้อมูลสำเร็จ!'),
              backgroundColor: Colors.green, //.transparent,
              elevation: 0,
              behavior: SnackBarBehavior
                  .floating, // ต้องใส่ตัวนี้ถึงจะกำหนด width ได้
              width: MediaQuery.of(context).size.width * 0.5,
              //         padding: const EdgeInsets.symmetric(horizontal: 10),
              // content: Row(
              //   children: [
              //     Icon(Icons.check_circle, color: Colors.green, size: 20),
              //     SizedBox(width: 8),
              //     Text('บันทึกแล้ว'),
              //   ],
              // ),

              // margin: const EdgeInsets.only(
              //   bottom: 16,
              //   left: 10,
              //   right: 120, // ๆ เพื่อไม่ให้มันไปทับกับปุ่ม Save
              // ),
              // content: Align(
              //   alignment: Alignment.centerLeft,
              //   child: Container(
              //     padding: const EdgeInsets.all(12),
              //     width: 200,
              //     decoration: BoxDecoration(
              //       color: Colors.green,
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: const Text(
              //       'บันทึกสำเร็จ!',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   ),
              // ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
          .closed
          .then((reason) {
            setState(() => _isSuccess = false);
          });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  DataCell _buildDoubleInputCell(Map<String, dynamic> cellData) {
    return DataCell(
      Container(
        width: 200, // กำหนดความกว้างรวมของคอลัมน์ย่อย
        child: Row(
          children: [
            // ช่อง Text
            Expanded(
              flex: 2, // ให้พื้นที่ช่องข้อความมากกว่าหน่อย
              child: TextField(
                controller: TextEditingController(text: cellData['text']),
                decoration: InputDecoration(
                  hintText: 'ข้อความ',
                  isDense: true,
                  //               border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(8),
                  //   borderSide: BorderSide(color: Colors.grey.shade300), // กำหนดสีที่นี่
                  // ),
                ),
                onChanged: (val) => cellData['text'] = val,
              ),
            ),
            const SizedBox(width: 5), // ระยะห่างระหว่าง 2 ช่องย่อย
            // ช่อง Number
            Expanded(
              flex: 1,
              child: TextField(
                keyboardType: TextInputType.number,
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                //   // FilteringTextInputFormatter.digitsOnly, // พิมพ์ได้เฉพาะตัวเลข
                //   _NumericTextFormatter(),
                // ],
                textAlign: TextAlign.right,
                controller:
                    TextEditingController(
                        text: cellData['num']?.toString() ?? '0',
                      )
                      ..selection = TextSelection.collapsed(
                        offset: (cellData['num']?.toString() ?? '0').length,
                      ),
                decoration: InputDecoration(
                  hintText: '0',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  // suffixText: "บาท",
                ),
                onChanged: (val) => cellData['num'] = val,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    final TextEditingController _editController = TextEditingController(
      text: widget.title,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('แก้ไขชื่อ'),
          content: TextField(
            controller: _editController,
            autofocus: true, // ให้คีย์บอร์ดเด้งขึ้นมาทันที
            decoration: InputDecoration(
              hintText: widget.title,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ), // สีส้มตามธีม
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ยกเลิก',
              ), //, style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // setState(() {
                //   _currentTitle = _editController.text;
                // });
                FirebaseFirestore.instance
                    .collection('lists')
                    .doc(widget.docId)
                    .update({
                      'name': _editController.text,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                Navigator.pop(context);
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title),
        title: Row(
          children: [
            Text(widget.title),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => _showEditDialog(), // ฟังก์ชันเปิดหน้าต่างแก้ชื่อ
            ),
          ],
        ),
        // actions: [
        //   // ปุ่มเพิ่มคอลัมน์ (จำกัดที่ 8)
        //   IconButton(
        //     icon: const Icon(Icons.view_column),
        //     onPressed: dynamicColumnsCount < 8
        //       ? () => setState(() => dynamicColumnsCount++)
        //       : null,
        //   ),
        // ],
      ),
      // body: StreamBuilder<DocumentSnapshot>(stream:
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('lists')
            .doc(widget.docId)
            // .snapshots(),
            // .where('authorId', isEqualTo: currentUserId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('เกิดข้อผิดพลาด'));
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!isInitialized) {
            var docData = snapshot.data?.data() as Map<String, dynamic>?;
            //  var docData = snapshot.data!.data() as Map<String, dynamic>?;
            if (docData != null && docData['data'] != null) {
              rows = List<Map<String, dynamic>>.from(
                docData['data'].map((item) => Map<String, dynamic>.from(item)),
              );
              headers = List<String>.from(
                docData['header'].map((item) => (item)),
              );
            }
            isInitialized =
                true; // ล็อคไว้ว่าโหลดมาแล้วนะ ต่อไปนี้จะจัดการเองในเครื่อง
          }
          // // ประกาศตัวแปร
          // List<Map<String, dynamic>> firebaseRows;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columns: [
                      const DataColumn(
                        label: Expanded(child: Center(child: Text('วันที่'))),
                      ),

                      // ...List.generate(dynamicColumnsCount, (index) =>
                      //   DataColumn(label: Text('ช่องที่ ${index + 1}'))
                      // ),
                      // สร้างคอลัมน์แบบ Dynamic
                      // ...List.generate(dynamicColumnsCount, (index) =>
                      ...List.generate(
                        headers.length,
                        (index) => DataColumn(
                          label:
                              //  Row(children: [
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width:
                                        120, // ต้องกำหนดความกว้างให้ช่อง Input ในหัวตารางด้วย
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      key: ValueKey('header_$index'),
                                      controller:
                                          TextEditingController(
                                              text: headers[index],
                                            )
                                            ..selection =
                                                TextSelection.fromPosition(
                                                  TextPosition(
                                                    offset:
                                                        headers[index].length,
                                                  ),
                                                ),
                                      //           controller: TextEditingController(text: headers[index] ?? '')
                                      // ..selection = TextSelection.collapsed(offset: headers[index].length),
                                      decoration: InputDecoration(
                                        hintText: '${index + 1}',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        // isDense: true, // ทำให้ช่องเล็กลงพอดีกับหัวตาราง
                                        // suffixIcon: IconButton(
                                        //   icon: const Icon(
                                        //     Icons.clear,
                                        //   ), // หรือ Icons.visibility สำหรับรหัสผ่าน
                                        //   onPressed: () {
                                        //     print('ลบคอลัมน์!');
                                        //   },
                                        // ),
                                      ),
                                      //  onChanged: (val) => rows[index] = {val: {text: rows[index]?['text'] ??'', num: rows[index]?['num'] ?? ''}},
                                      // onChanged: (val) => rows[index] = {val: {...rows[index]}},
                                      onChanged: (val) => headers[index] = val,
                                      //     onChanged: (val) {
                                      //  var data = rows[index + 1] ?? {text: '', num: ''};
                                      //  print(index);
                                      //  print(data);
                                      //       // setState(() => {
                                      //       //     rows[index + 1] = {val: {...data}}
                                      //       // });
                                      //     }
                                    ),
                                  ),
                                ),
                              ),
                          // ], ),
                        ),
                      ),
                      DataColumn(
                        label: IconButton(
                          icon: const Icon(Icons.add), // add_circle
                          // color: context.primaryColor,
                          onPressed: () {
                            setState(() {
                              headers = [...headers, '${headers.length + 1}'];
                            });
                          },
                          tooltip: 'เพิ่มคอลัมน์',
                        ),
                      ),
                      const DataColumn(label: Text('หมายเหตุ')),
                    ],
                    rows: rows.map((rowData) {
                      return DataRow(
                        cells: [
                          // DataCell(Text(rowData['date'])),
                          DataCell(
                            InkWell(
                              onTap: () async {
                                // 1. เรียกปฏิทินขึ้นมา
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      DateTime.now(), // วันที่เริ่มต้นในปฏิทิน
                                  firstDate: DateTime(
                                    2000,
                                  ), // วันที่เก่าสุดที่เลือกได้
                                  lastDate: DateTime(
                                    2100,
                                  ), // วันที่ใหม่สุดที่เลือกได้
                                  // ตกแต่งสีส้มตามธีมของคุณ
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Theme.of(
                                            context,
                                          ).primaryColor, // หัวปฏิทินสีส้ม
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedDate != null) {
                                  // 2. ถ้าผู้ใช้เลือกวันที่ (ไม่กดกากบาททิ้ง)
                                  // จัดฟอร์แมตวันที่ให้สวยงาม (เช่น 2026-02-26)
                                  // String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  String formattedDate = DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(pickedDate);

                                  // 3. อัปเดต State หรือส่งค่าไป Firebase
                                  setState(() {
                                    rowData['date'] = formattedDate;
                                  });
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(rowData['date']),
                                  // const SizedBox(width: 5),
                                  // const Icon(
                                  //   Icons.calendar_today,
                                  //   size: 14,
                                  //   color: Colors.grey,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          // ...List.generate(dynamicColumnsCount, (index) =>
                          //   DataCell(TextField(
                          //     decoration: const InputDecoration(hintText: 'ข้อความ/เลข'),
                          //     onChanged: (val) => rowData['data'][index] = val,
                          //   ))
                          // ),
                          // // สร้างช่องกรอกข้อมูลกลาง (ข้อความ + เลข)
                          // _buildDoubleInputCell(rowData['col1']),
                          // _buildDoubleInputCell(rowData['col2']),
                          // _buildDoubleInputCell(rowData['col3']),
                          ...List.generate(headers.length, (index) {
                            String colKey =
                                'col${index + 1}'; // สร้าง key เช่น col1, col2, ...

                            // ดึงข้อมูลมาตรวจสอบกัน Null
                            var cellData = rowData[colKey];

                            // ถ้าในแถวนี้มีข้อมูลคอลัมน์นี้ ให้ส่งเข้าฟังก์ชัน build ของคุณ
                            if (cellData != null) {
                              return _buildDoubleInputCell(cellData);
                            } else {
                              // กรณีถ้าข้อมูลยังไม่มี (กันแอปแครช) ให้ส่ง Cell เปล่าไปก่อน
                              return const DataCell(SizedBox.shrink());
                            }
                          }),
                          DataCell(SizedBox()),
                          DataCell(
                            TextField(
                              decoration: const InputDecoration(hintText: ''),
                              onChanged: (val) => rowData['note'] = val,
                              // ✅ ต้องมี Controller เพื่อดึงค่าจาก Map มาแสดงในช่องกรอก
                              controller:
                                  TextEditingController(
                                      text: rowData['note'] ?? '',
                                    )
                                    ..selection = TextSelection.collapsed(
                                      offset: (rowData['note'] ?? '').length,
                                    ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween, // ชิดซ้าย-ขวา อัตโนมัติ
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        // width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _addRow,
                          icon: const Icon(Icons.add),
                          label: const Text('เพิ่มแถว'),
                        ),
                      ),
                    ),
                    const Spacer(), // ดันทุกอย่างที่อยู่ข้างหลังไปชิดขวา
                    SizedBox(
                      // width: double.infinity,
                      child: TextButton.icon(
                        onPressed: _addRow,
                        icon: const Icon(Icons.horizontal_rule),
                        label: const Text('ซ่อนส่วนที่ไม่มีค่า'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    // CheckboxListTile(
                    //   title: const Text("ยอมรับเงื่อนไขการใช้งาน"),
                    //   value: _isHideBox,
                    //   onChanged: (bool? value) {
                    //     setState(() {
                    //       _isHideBox = value!;
                    //     });
                    //   },
                    //   controlAffinity: ListTileControlAffinity
                    //       .leading, // เอา Checkbox ไว้ข้างหน้า (ซ้ายสุด)
                    //   contentPadding: EdgeInsets.zero, // ลดช่องว่างขอบ
                    // ),
                  ],
                ),
              ],
            ),
          );
          // Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: ElevatedButton.icon(
          //       onPressed: _addRow, // เรียกฟังก์ชันเพิ่มแถวเดิมที่คุณมี
          //       icon: const Icon(Icons.add),
          //       label: const Text('เพิ่มแถวใหม่'),
          //       style: ElevatedButton.styleFrom(
          //         minimumSize: const Size(double.infinity, 50), // ให้ปุ่มกว้างเต็มหน้าจอ
          //         backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          //         foregroundColor: Theme.of(context).primaryColor,
          //       ),
          //     ),
          //   ),
        },
      ),
      floatingActionButton: _isSuccess
          ? null // หรือ const SizedBox.shrink() ถ้าอยากให้หายไปเลยแบบไม่มี Animation
          : FloatingActionButton.extended(
              onPressed: _saveToFirebase,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Save'),
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              // backgroundColor:  Theme.of(context).secondaryColor,
            ),
    );
  }
}

class _NumericTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // แปลงเลขเป็น format มีคอมม่า
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    double value = double.parse(cleanText);
    final formatter = NumberFormat.decimalPattern();
    // final double? value = double.tryParse(newValue.text.replaceAll(',', ''));
    // if (value == null) return oldValue;

    // final formatter = NumberFormat("#,###"); // กำหนดรูปแบบ
    final newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
