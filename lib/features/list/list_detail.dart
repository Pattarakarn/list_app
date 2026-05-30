import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // !เพิ่ม intl ใน pubspec.yaml สำหรับจัดการวันที่
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app_colors.dart';
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
  bool showRemark = true;
  bool isDateY = !false;
  final TextEditingController _remarkController = TextEditingController(
    text: "",
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
    DateTime? pickedDate;
    if (_requireDate)
      pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

    // if (pickedDate != null) {
    Map<String, dynamic> dynamicCells = {};
    for (int i = 0; i < headers.length; i++) {
      dynamicCells['col${i + 1}'] = {'text': '', 'num': ''};
    }
    Map<String, dynamic> newRow = {
      'date': pickedDate != null
          ? DateFormat('dd/MM/yyyy').format(pickedDate)
          : '',
      'note': '',
    };
    newRow.addAll(dynamicCells);
    setState(() {
      rows.add({...newRow});
    });
  }

  void _saveToFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.docId)
          .update({
            'data': rows,
            'header': _type == "Table" ? headers : [],
            'updatedAt': FieldValue.serverTimestamp(),
            'type': _type,
            'hideEmpty': _isHideBox,
            'required_date': _requireDate,
            'showRemark': showRemark,
            'remark': _remarkController.text,
            'isArchived': false,
          });
      setState(() => _isSuccess = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: const Text('บันทึกข้อมูลสำเร็จ!'),
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
      ).showSnackBar(const SnackBar(content: Text('เกิดข้อผิดพลาด')));
    }
  }

  void _showEditDialog() {
    final TextEditingController editController = TextEditingController(
      text: widget.title,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('แก้ไขชื่อ'),
          content: TextField(
            controller: editController,
            autofocus: true, // ให้คีย์บอร์ดเด้งขึ้นมาทันที
            decoration: InputDecoration(
              hintText: widget.title,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
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
                FirebaseFirestore.instance
                    .collection('lists')
                    .doc(widget.docId)
                    .update({
                      'name': editController.text,
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
    required bool isLightMode,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent.withOpacity(0.1)
                : isLightMode
                ? Colors.white
                : Colors.transparent,
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
    String type = _type;
    bool hideEmpty = _isHideBox;
    bool requireDate = _requireDate;
    bool isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      isScrollControlled: true, //
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
                        isSelected: type == 'Table',
                        onTap: () => setModalState(() => type = 'Table'),
                        isLightMode: isLightMode,
                      ),
                      const SizedBox(width: 12),
                        if (_type != "Table" || headers.length<=1)
                        _buildCustomToggle(
                        label: "Checklist",
                        icon: Icons.checklist,
                        isSelected: type == 'Checklist',
                        onTap: () => setModalState(() => type = 'Checklist'),
                        isLightMode: isLightMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_type == "Table")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
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
                          value: hideEmpty,
                          onChanged: (val) {
                            setModalState(() => hideEmpty = val);
                          },
                        ),
                      ],
                    ),
                  if (_type == "Checklist")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.horizontal_split_outlined,
                              color: AppColors.secondary,
                            ),
                            SizedBox(width: 10),
                            Text("Seperate List"),
                          ],
                        ),
                        Switch.adaptive(
                          value: hideEmpty,
                          onChanged: (val) {
                            setModalState(() => hideEmpty = val);
                          },
                        ),
                      ],
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
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
                        value: requireDate,
                        // activeColor: AppColors.secondary,
                        onChanged: (val) {
                          setModalState(() => requireDate = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:  isLightMode ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: List.generate(2, (index) {
                        bool isSelected = !false;
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
                                color: isSelected
                                    ? Colors.blueAccent.withValues(alpha: 0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                // border: Border.all(
                                //   color: isSelected
                                //       ? Colors.blueAccent
                                //       : Colors.transparent,
                                //   width: 2,
                                // ),
                              ),
                              child: Stack(
                                children: [
                                  if (isSelected && !hideEmpty)
                                    const Positioned(
                                      top: 18,
                                      left: 5,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.blueAccent,
                                        size: 18,
                                      ),
                                    ),
                                  if (_type == "Table")
                                    Center(
                                      child: Text(
                                        index == 0 ? "ข้อความ" : "ตัวเลข",
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
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // if (_type == "Table")
                  //   CheckboxListTile(
                  //     title: Transform.translate(
                  //       offset: Offset(-10, 0),
                  //       child: Text("Rotate axis"),
                  //     ),
                  //     value: isDateY,
                  //     onChanged: (bool? value) {
                  //       setModalState(() => isDateY = !isDateY);
                  //     },
                  //     controlAffinity: ListTileControlAffinity.leading,
                  //   ),
                  CheckboxListTile(
                    title: Transform.translate(
                      offset: const Offset(-10, 0),
                      child: const Text("Show remark"),
                    ),
                    value: showRemark,
                    onChanged: (bool? value) {
                      // setModalState(() => showRemark = value);
                      setModalState(() => showRemark = !showRemark);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    //  visualDensity:  VisualDensity(horizontal: -4.0, vertical: 0),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () => {
                        setState(() {
                          _type = type;
                          showRemark = showRemark;
                          isDateY = isDateY;
                          _requireDate = requireDate;
                          _isHideBox = hideEmpty;
                        }),
                        // if(isDateY)
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

  void setHeaders(header) {
    setState(() {
      // headers = [...headers, '${headers.length + 1}'];
      headers = header;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
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
            // print(docData);
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
              _requireDate = docData['required_date'];
              showRemark = docData['showRemark'] ?? false;
              _remarkController.text = docData['remark'] ?? '';
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
              ? CheckList(
                  data: rows,// rows.map(row => row.col1.text),
                  type: _type,
                  requireDate: _requireDate,
                  addText: (val) {
                    setState(() {
                      // Map<String, dynamic> newObj = {DateFormat('yyyyMMddHHmmss').format(DateTime.now()): val};
                      rows.add({
                        'text': val,
                        "isDone": false,
                        'create_date': DateFormat(
                          'yyyyMMddHHmmss',
                        ).format(DateTime.now()),
                        'due_date': null,
                      });
                    });
                  },
                  setFieldDate: (ind, type, date) {
                    setState(() {
                      if (type == "due") rows[ind]['due_date'] = date;
                      if (type == "complete") {
                        rows[ind]['complete_date'] = date;
                        rows[ind]['isDone'] = true;
                      }
                    });
                  },
                  showRemark: showRemark,
                  setRemark: (val) {
                    _remarkController.text = val;
                  },
                  remarkController: _remarkController,
                )
              : TableList(
                  headers: headers,
                  rows: rows,
                  requireDate: _requireDate,
                  setHeaders: setHeaders,
                  setRows: (updatedRows) {
                    print(updatedRows);
                    // setState(() {
                    //     rowData['date'] =  updatedRows;
                    // });
                  },
                  addRow: _addRow,
                  isHideBox: _isHideBox,
                  showRemark: showRemark,
                  isDateY: isDateY,
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
      floatingActionButton: _isSuccess || isKeyboardOpen
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
