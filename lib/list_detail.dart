import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // อย่าลืมเพิ่ม intl ใน pubspec.yaml สำหรับจัดการวันที่
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; 

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

  const DetailPage({super.key,  required this.title, required this.docId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // เก็บข้อมูลแถวในตาราง
  List<Map<String, dynamic>> rows = [];
  bool isInitialized = false;
  int dynamicColumnsCount = 3; // ค่าเริ่มต้น 3 คอลัมน์ (สูงสุด 8)
 List<String>  headers = ['หัวข้อ'];
// (จะทำงานครั้งเดียวตอนเปิดหน้านี้ขึ้นมา)
  @override
  void initState() {
    super.initState();

    // ใส่ข้อมูล Mock ของคุณตรงนี้
    rows = [
      // {
      //   'date': '24/02/2026',
      //   'col2': {'text': '', 'num': ''},
      //   'col3': {'text': '', 'num': ''},
      //   'col4': {'text': '', 'num': ''},
      //   'note': 'ข้อมูลตัวอย่าง 1'
      // },
    ];
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
    dynamicCells['col${i + 1}'] = {'text':  '', 'num': ''};
  }
  Map<String, dynamic> newRow = {
    'date': DateFormat('dd/MM/yyyy').format(pickedDate),
    'note': ''
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
    print(headers);
  try {
    await FirebaseFirestore.instance
        .collection('lists')
        .doc(widget.docId)
        .update({'data': rows, 'header': headers}); 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกข้อมูลสำเร็จ!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating, // ต้องใส่ตัวนี้ถึงจะกำหนด width ได้
    width: MediaQuery.of(context).size.width * 0.5,
    // shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.circular(10),
    // ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
    );
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
              decoration:  InputDecoration(
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
              inputFormatters: [
FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
  ],
  textAlign: TextAlign.right,
  controller: TextEditingController(text: cellData['num']?.toString() ?? '0')
            ..selection = TextSelection.collapsed(offset: (cellData['num']?.toString() ?? '0').length),
              decoration:  InputDecoration(
                hintText: '0',
                isDense: true,
               border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.grey.shade300), // กำหนดสีที่นี่
  ),
              ),
              onChanged: (val) => cellData['num'] = val,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // title: Text('ทดสอบ'),
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
      body: StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.docId) // หรือชื่อเอกสารที่คุณระบุไว้
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('เกิดข้อผิดพลาด'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!isInitialized) {
    var docData = snapshot.data?.data() as Map<String, dynamic>?;
          print(docData);
    //  var docData = snapshot.data!.data() as Map<String, dynamic>?;
    if (docData != null && docData['data'] != null) {
      rows = List<Map<String, dynamic>>.from(
        docData['data'].map((item) => Map<String, dynamic>.from(item)),
      );
      headers = List<String>.from(
        docData['header'].map((item) => (item)),
      );
      print(headers);
    }
    isInitialized = true; // ล็อคไว้ว่าโหลดมาแล้วนะ ต่อไปนี้จะจัดการเองในเครื่อง
  }
  // // ประกาศตัวแปร
  // List<Map<String, dynamic>> firebaseRows;

        // 4. เอา UI เดิมของคุณมาวางตรงนี้
        return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
    children: [
       SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade300),
            columns: [
              const DataColumn(label: Expanded(child: Center(child: Text('วันที่') ))),
              // ...List.generate(dynamicColumnsCount, (index) => 
              //   DataColumn(label: Text('ช่องที่ ${index + 1}'))
              // ),
              // สร้างคอลัมน์แบบ Dynamic
              // ...List.generate(dynamicColumnsCount, (index) => 
              ...List.generate(headers.length, (index) =>
                  DataColumn(
                    label:Expanded(child: Center(child:
                     Container(
                      width: 100, // ต้องกำหนดความกว้างให้ช่อง Input ในหัวตารางด้วย
                      child: TextField(
                        textAlign: TextAlign.center,
                        key: ValueKey('header_$index'),
                        controller: TextEditingController(text: headers[index])
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: headers[index].length),
            ),
              //           controller: TextEditingController(text: headers[index] ?? '')
              // ..selection = TextSelection.collapsed(offset: headers[index].length),
                        decoration:  InputDecoration(
                          hintText: '${index + 1}',
                           border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(8),
                           borderSide: BorderSide(color: Colors.grey.shade300), // กำหนดสีที่นี่
                           ),
                           // isDense: true, // ทำให้ช่องเล็กลงพอดีกับหัวตาราง
                           ),
                          //  onChanged: (val) => rows[index] = {val: {text: rows[index]?['text'] ??'', num: rows[index]?['num'] ?? ''}},
                                // onChanged: (val) => rows[index] = {val: {...rows[index]}},
                                onChanged: (val) => headers[index] =val,
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
                    ))
                           ),
                           ),
                           const DataColumn(label: Text('หมายเหตุ')),
                            ],
                             rows: rows.map((rowData) {
                              return DataRow(cells: [
                                DataCell(Text(rowData['date'])),
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
      String colKey = 'col${index + 1}'; // สร้าง key เช่น col1, col2, ...
      
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
                DataCell(TextField(
                  decoration: const InputDecoration(hintText: ''),
                  onChanged: (val) => rowData['note'] = val,
                  // ✅ ต้องมี Controller เพื่อดึงค่าจาก Map มาแสดงในช่องกรอก
    controller: TextEditingController(text: rowData['note'] ?? '')
      ..selection = TextSelection.collapsed(offset: (rowData['note'] ?? '').length),
                )),
              ]);
            }).toList(),
            
          ),
        ),

        const SizedBox(height: 20),

      // 3. วาง Padding ของปุ่มไว้ตรงนี้ (ต่อท้ายตาราง)
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
    ]
        )
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
      }
      ),
      floatingActionButton: FloatingActionButton.extended(
       onPressed: _saveToFirebase,
          icon: const Icon(Icons.save),
        label: const Text('Save'),
      ),
    );
  }
}