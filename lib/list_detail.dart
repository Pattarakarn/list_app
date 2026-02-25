import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // อย่าลืมเพิ่ม intl ใน pubspec.yaml สำหรับจัดการวันที่
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
  const DetailPage({super.key, required this.title});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // เก็บข้อมูลแถวในตาราง
  List<Map<String, dynamic>> rows = [];
  int dynamicColumnsCount = 3; // ค่าเริ่มต้น 3 คอลัมน์ (สูงสุด 8)
// (จะทำงานครั้งเดียวตอนเปิดหน้านี้ขึ้นมา)
  @override
  void initState() {
    super.initState();
    
    // ใส่ข้อมูล Mock ของคุณตรงนี้
    rows = [
      {
        'date': '24/02/2026',
        'col2': {'text': 'ค่าอาหาร', 'num': '500'},
        'col3': {'text': 'ค่ารถ', 'num': '100'},
        'col4': {'text': 'เบ็ดเตล็ด', 'num': '50'},
        'note': 'ข้อมูลตัวอย่าง 1'
      },
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
      setState(() {
        // rows.add({
        //   'date': DateFormat('dd/MM/yyyy').format(pickedDate),
        //   'data': List.generate(dynamicColumnsCount, (index) => ""), // สร้างช่องว่างตามจำนวนคอลัมน์
        //   'note': ""
        // });
        rows.add({
        'date': DateFormat('dd/MM/yyyy').format(pickedDate),
        // สร้าง Map ย่อยเพื่อเก็บ Text และ Number สำหรับคอลัมน์ 2, 3, 4
        'col2': {'text': '', 'num': ''},
        'col3': {'text': '', 'num': ''},
        'col4': {'text': '', 'num': ''},
        'note': '',
      });
      });
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
                border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.grey.shade300), // กำหนดสีที่นี่
  ),
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
              decoration:  InputDecoration(
                hintText: 'เลข',
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade300),
            columns: [
              const DataColumn(label: Text('วันที่')),
              // ...List.generate(dynamicColumnsCount, (index) => 
              //   DataColumn(label: Text('ช่องที่ ${index + 1}'))
              // ),
              // สร้างคอลัมน์แบบ Dynamic
              ...List.generate(dynamicColumnsCount, (index) => 
                  DataColumn(
    label: Container(
      width: 100, // ต้องกำหนดความกว้างให้ช่อง Input ในหัวตารางด้วย
      child: TextField(
        decoration:  InputDecoration(
          hintText: '${index + 1}',
        border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.grey.shade300), // กำหนดสีที่นี่
  ),
          // isDense: true, // ทำให้ช่องเล็กลงพอดีกับหัวตาราง
        ),
      ),
    ),
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
                // สร้างช่องกรอกข้อมูลกลาง (ข้อความ + เลข)
                _buildDoubleInputCell(rowData['col2']),
    _buildDoubleInputCell(rowData['col3']),
    _buildDoubleInputCell(rowData['col4']),
                DataCell(TextField(
                  decoration: const InputDecoration(hintText: 'โน้ต...'),
                  onChanged: (val) => rowData['note'] = val,
                )),
              ]);
            }).toList(),
          ),
        ),

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

      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRow,
        label: const Text('เพิ่มแถว'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}