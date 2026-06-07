import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
// import 'package:flutter/services.dart';
//  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),

class TableList extends StatelessWidget {
  final bool requireDate;
  final List<String> headers;
  final Function(List<String>) setHeaders;
  final List<Map<String, dynamic>> rows;
  final Function(List<Map<String, dynamic>>) setRows;
  final Function() addRow;
  final bool isHideBox;
  final bool showRemark;
  final bool isDateY;

  const TableList({
    super.key,
    required this.headers,
    required this.rows,
    required this.setHeaders,
    required this.requireDate,
    required this.setRows,
    required this.addRow,
    required this.isHideBox,
    required this.showRemark,
    required this.isDateY,
  });

  DataCell _buildDoubleInputCell(Map<String, dynamic> cellData) {
    return DataCell(
      SizedBox(
        width: 210, // กำหนดความกว้างรวมของคอลัมน์ย่อย
        child: Row(
          children: [
            if (!(cellData['text'].toString().isEmpty && isHideBox))
              Expanded(
                flex: 2, // ให้พื้นที่ช่องข้อความมากกว่าหน่อย
                child: TextField(
                  controller: TextEditingController(text: cellData['text']),
                  decoration: const InputDecoration(
                    hintText: '',
                    isDense: true,
                  ),
                  onChanged: (val) => cellData['text'] = val,
                ),
              ),
            const SizedBox(width: 5),

            if (!(cellData['num'].toString().isEmpty && isHideBox))
              Expanded(
                flex: 1,
                child: TextField(
                  // keyboardType: TextInputType.number,
                  // inputFormatters: [
                  //   //   // FilteringTextInputFormatter.digitsOnly, // พิมพ์ได้เฉพาะตัวเลข
                  //   CurrencyTextInputFormatter.currency(
                  //     locale: 'ko',
                  //     symbol: '', // ถ้าไม่อยากให้มีเครื่องหมาย $ หรือ ฿ นำหน้า
                  //     decimalDigits: 2,
                  //   ),
                  // ],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  controller:
                      TextEditingController(
                          text: cellData['num']?.toString() ?? '0',
                          // text: (cellData['num'] is num && cellData['num'] > 0)
                          //     ? formatter.format(cellData['num'])
                          //     : (cellData['num']?.toString() ?? '0'),
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
                    hintStyle: TextStyle(
                      color: Colors.grey.withValues(
                        alpha: 0.5,
                      ), // ค่า alpha ยิ่งน้อยยิ่งจาง (0.0 - 1.0)
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
      // appBar: AppBar(title: Text("Type: $type")),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(color: Colors.grey.shade300),
                columns: [
                  if (requireDate)
                    DataColumn(
                      label: Expanded(
                        child: Center(child: Text(isDateY ? 'วันที่' : '')),
                      ),
                    ),

                  ...List.generate(
                    isDateY ? headers.length : rows.length,
                    (index) => DataColumn(
                      label:
                          //  Row(children: [
                          Expanded(
                            child: Center(
                              child: SizedBox(
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
                                                offset: headers[index].length,
                                              ),
                                            ),
                                  //           controller: TextEditingController(text: headers[index] ?? '')
                                  // ..selection = TextSelection.collapsed(offset: headers[index].length),
                                  decoration: InputDecoration(
                                    hintText: '${index + 1}',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                  // headers.length > 0 ? null :
                  DataColumn(
                    label: IconButton(
                      icon: const Icon(Icons.add), // add_circle
                      onPressed: () {
                        setHeaders([...headers, '${headers.length + 1}']);
                        // setState(() {
                        //   headers = [...headers, '${headers.length + 1}'];
                        // });
                      },
                      tooltip: 'เพิ่มคอลัมน์',
                    ),
                  ),
                  if (showRemark) const DataColumn(label: Text('หมายเหตุ')),
                ],
                //  rows.map(r => r.date)
                // rows: (isDateY ? rows : headers).map((rowData) {
                rows: rows.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> rowData = entry.value;
                  // rows: rows.map((rowData) {
                  // final headersObj = headers.map((h)) ({date: h}));

                  return DataRow(
                    cells: [
                      if (requireDate)
                        DataCell(
                          InkWell(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(
                                  2000,
                                ), // วันที่เก่าสุดที่เลือกได้
                                lastDate: DateTime(
                                  2100,
                                ), // วันที่ใหม่สุดที่เลือกได้
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Theme.of(context).primaryColor,
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
                                final row = [...rows];
                                row[index]['date'] = formattedDate;
                                setRows(row);
                                // setState(() {
                                //   rowData['date'] = formattedDate;
                                // });
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Text(isDateY ? rowData['date'] : rowData),
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

                      ...List.generate(isDateY ? headers.length : rows.length, (
                        index,
                      ) {
                        String colKey =
                            'col${index + 1}'; // สร้าง key เช่น col1, col2, ...

                        // ดึงข้อมูลมาตรวจสอบกัน Null
                        var cellData = rowData[colKey];
                        // var cellData = rows[index];

                        // ถ้าในแถวนี้มีข้อมูลคอลัมน์นี้ ให้ส่งเข้าฟังก์ชัน build ของคุณ
                        if (cellData != null) {
                          return _buildDoubleInputCell(cellData);
                        } else {
                          // กรณีถ้าข้อมูลยังไม่มี (กันแอปแครช) ให้ส่ง Cell เปล่าไปก่อน
                        }
                        return const DataCell(SizedBox.shrink());
                      }),
                      const DataCell(SizedBox()),
                      // if (showRemark) const DataCell(SizedBox.shrink()),
                      if (showRemark)
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
                      onPressed: addRow,
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มแถว'),
                    ),
                  ),
                ),
                const Spacer(), // ดันทุกอย่างที่อยู่ข้างหลังไปชิดขวา
              ],
            ),
          ],
        ),
      ),
    );
  }
}
