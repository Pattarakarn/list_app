import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // !เพิ่ม intl ใน pubspec.yaml สำหรับจัดการวันที่
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../app_colors.dart';
import '../../../utils/constant.dart';
import 'checkList.dart';
import 'tableList.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String docId; // รับค่า ID มาจากหน้าลิสต์

  const DetailPage({super.key, required this.title, required this.docId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Map<String, dynamic>> rows = [];
  bool isInitialized = false;

  List<String> headers = ['หัวข้อ'];

  bool _isSuccess = false;
  bool _isHideBox = false;
  String _type = 'Table';
  bool _requireDate = true;

  final TextEditingController _selectController = TextEditingController(
    text: "Table",
  );
  final TextEditingController _checkController = TextEditingController(
    text: "false",
  );

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

  final formatter = NumberFormat(
    "#,###.##",
  ); // .## คือแสดงทศนิยมเฉพาะเมื่อมีค่า
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

  void _toggleSomeValueCol() async {
    setState(() => _isHideBox = !_isHideBox);
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

  Widget _buildCustomToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            // ถ้าเลือกจะเป็นสีน้ำเงินอ่อน ถ้าไม่เลือกจะเป็นสีขาวขอบเทา
            color: isSelected
                ? Colors.blueAccent.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(30), // ทำให้กลมแบบ Toggle
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ให้ความสูงพอดีกับเนื้อหา
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ขีดเล็กๆ ด้านบนบอกว่าเลื่อนลงได้
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
                  const Text(
                    "ปรับแต่งการแสดงผล",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCustomToggle(
                        label: "Table",
                        icon: Icons.table_restaurant,
                        isSelected: _type == 'Table',
                        onTap: () => setModalState(() => _type = 'Table'),
                      ),
                      const SizedBox(width: 12),
                      _buildCustomToggle(
                        label: "Checklist",
                        icon: Icons.checklist,
                        isSelected: _type == 'Checklist',
                        onTap: () => setModalState(() => _type = 'Checklist'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.disabled_by_default,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Hide empty",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _requireDate,
                        onChanged: (val) {
                          // _toggleSomeValueCol,
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.calendar_month,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Require Date",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _requireDate,
                        // activeColor: AppColors.secondary,
                        onChanged: (val) {
                          setModalState(() => _requireDate = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // แยกส่วน Todo, Done
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: // 1. สร้าง Row เพื่อวาง 3 ช่องเรียงกัน
                    Row(
                      children: List.generate(3, (index) {
                        bool isSelected = false;
                        // selectedIndex == index; // เช็กว่าช่องนี้ถูกเลือกไหม

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // setState(() {
                              //   selectedIndex = index; // เปลี่ยนช่องที่เลือก
                              // });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 60, // ความสูงของช่องเลือก
                              decoration: BoxDecoration(
                                // ถ้าเลือกให้เป็นสีฟ้า Cyan จางๆ ที่คุณชอบ ถ้าไม่เลือกเป็นสีเทาอ่อน
                                color: isSelected
                                    ? const Color(
                                        0xFF00E5FF,
                                      ).withValues(alpha: 0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00E5FF)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // ข้อความตรงกลาง (เช่น Col 1, Col 2, Col 3)
                                  Center(
                                    child: Text(
                                      "ข้อความ/ตัวเลข",
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  // เครื่องหมายถูก (แสดงเฉพาะตอนถูกเลือก)
                                  if (isSelected)
                                    const Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF00E5FF),
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // const Text(""),
                  // สลับแกนx-y
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => {
                        //    setState(() {
                        //   _selectController.text =
                        //       newValue!;
                        // });
                        Navigator.pop(context),
                      },
                      child: const Text("Apply"),
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

  void setHeaders(_headers) {
    setState(() {
      // headers = [...headers, '${headers.length + 1}'];
      headers = _headers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              _showModal(context);
            },
          ),
          const SizedBox(width: 8), // เว้นระยะห่างจากขอบขวาเล็กน้อย
        ],
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
            print(docData);
            if (docData != null) {
              _type = docData['type'] ?? 'Table';
              if (docData['data'] != null) {
                rows = List<Map<String, dynamic>>.from(
                  docData['data'].map(
                    (item) => Map<String, dynamic>.from(item),
                  ),
                );
                headers = List<String>.from(
                  docData['header'].map((item) => (item)),
                );
              }
              // if(docData['required_date'])  _requireDate = docData['required_date'] ;
            }
            isInitialized =
                true; // ล็อคไว้ว่าโหลดมาแล้วนะ ต่อไปนี้จะจัดการเองในเครื่อง
          }

          // return SingleChildScrollView(
          //   scrollDirection: Axis.vertical,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          return (_type == "Checklist"
              ? CheckList(data: rows, type: _type, requireDate: _requireDate)
              : TableList(
                  headers: headers,
                  rows: rows,
                  requireDate: _requireDate,
                  setHeaders: setHeaders,
                  setRows: (updatedRows) {
                    // setState(() {
                    //     rowData['date'] =  updatedRows;
                    // });
                  },
                  addRow: _addRow,
                  isHideBox: _isHideBox,
                ));
          //     ],
          //   ),
          // );
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
