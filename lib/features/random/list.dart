import 'package:flutter/material.dart';
import 'dart:math';
import '../../app_colors.dart';
import '../../loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/cupertino.dart';

class ListPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const ListPage({super.key, required this.data});
  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final user = FirebaseAuth.instance.currentUser;
  // ต้องรอให้ Class สร้างเสร็จก่อน
  late dynamic _items = List.from(widget.data["items"]);
  // สร้าง List ใหม่จากการก๊อปปี้ข้อมูลต้นฉบับ
  late final List<dynamic> allItems = List.from(widget.data["items"]);
  bool onPopup = false;
  int timer = 3;

  void showRandomResult(winner, randomIndex) {
    setState(() {
      onPopup = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false, // บังคับให้กดปุ่มเพื่อปิดเท่านั้น
      builder: (context) => AlertDialog(
        // backgroundColor: Colors.white
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("Result 🎉")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_outlined, color: Colors.orange, size: 55),
                const SizedBox(width: 5),
                Text(
                  ' ${winner}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.rand,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 18),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                // Expanded( child:
                OutlinedButton(
                  onPressed: () {
                    // if (_items.length == 1)
                    setState(() {
                      _items.removeAt(0);
                    });
                    setState(() {
                      onPopup = false;
                    });
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(12),
                    // ),
                  ),
                  // _items.length == 1 ? "เคลียร์และปิด" : "ปิด"
                  child: const Text("ปิด"),
                ),

                // ),
                const SizedBox(width: 10),

                if (_items.length > 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _items.removeAt(randomIndex);
                        });
                        Navigator.pop(context);
                        showRandomProcess();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2979FF),
                      ),
                      child: Text(
                        (_items.length - 1 == 1)
                            ? "แสดงรายการสุดท้าย"
                            : "สุ่มต่อ (${_items.length - 1} รายการ)",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showRandomProcess() async {
    setState(() {
      onPopup = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [BouncingDots()],
        ),
      ),
    );

    if (_items.length > 1) await Future.delayed( Duration(seconds: timer));

    if (!mounted) return;
    Navigator.pop(context);

    final random = Random();
    int randomIndex = random.nextInt(_items.length);
    String winner = _items[randomIndex];

    showRandomResult(winner, randomIndex);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    bool canRandom = allItems.length >= 2;
    // print(widget.data);

    final FocusNode _focusNode = FocusNode();
    void _addItem() {
      if (_controller.text.trim().isNotEmpty) {
        setState(() {
          _items.add(_controller.text.trim());
          allItems.add(_controller.text.trim());
          _controller.clear();
        });

        _focusNode.requestFocus();
      }
    }

    Future<void> _updateList() async {
      try {
        await FirebaseFirestore.instance
            .collection('random')
            .doc(widget.data['id'])
            .update({
              'updatedAt': FieldValue.serverTimestamp(),
              'items': allItems,
              // 'authorId': user?.uid,
              'name': 'Random',
            });
      } catch (e) {
        print("Error: $e");
      }
    }

    void showPopup(BuildContext context) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: const Text('จัดการ'),
          // message: const Text('คุณต้องการดำเนินการอย่างไรต่อ?'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => {_updateList(), Navigator.pop(context)},
              child: const Text('บันทึก'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true, // ทำให้ตัวอักษรเป็นสีแดง (สำหรับลบ)
              onPressed: () => Navigator.pop(context),
              child: const Text('ลบข้อมูล'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true, // ทำให้ตัวหนา
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10),
              // decoration: BoxDecoration(
              //   color: const Color(0xFF0F172A).withOpacity(0.2),
              //   borderRadius: BorderRadius.circular(8),
              // ),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
          ),
        ),
      );
    }

    bool isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.data['name']}"),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              showPopup(context);
            },
            label: const Text("จัดการ"),
            style: OutlinedButton.styleFrom(
              // ElevatedButton.styleFrom(backgroundColor:
              //     AppColors.primary, //Theme.of(context).primaryColor
              // foregroundColor: Colors.white,
              // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              // elevation: 2,
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(12),
              // ),
              side: const BorderSide(
                color: AppColors.primary, // กำหนดความหนาของเส้นขอบ
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity, // บังคับให้กว้างเต็มจอ
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: "พิมพ์รายการ . . .",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.rand,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusColor: AppColors.gray,
                          hoverColor: AppColors.gray,
                        ),
                        textInputAction: TextInputAction
                            .done, // เปลี่ยนปุ่มบนคีย์บอร์ดเป็นรูปติ๊กถูกหรือ Done
                        onSubmitted: (value) {
                          _addItem();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Ink(
                      decoration: const ShapeDecoration(
                        shape: CircleBorder(),
                        gradient: LinearGradient(
                          colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      // child: IconButton.filled(
                      child: IconButton(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        // style: IconButton.styleFrom(
                        //   backgroundColor: AppColors.rand,
                        // ),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // reset();
                        setState(() {
                          _items = List.from(allItems);
                        });
                      },
                      label: const Text(
                        " Reset ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          // color: Color(0xFF2979FF),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.gray,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.timer,
                        size: 20,
                        color: AppColors.rand,
                      ),
                      label:  Text(
                        "เวลา: $timer s",
                        style:const TextStyle(color: AppColors.rand),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00E5FF)),
                      ),
                    ),
                    const SizedBox(width: 5),
                    OutlinedButton.icon(
                      onPressed: () {},
                      label: const Text(
                        "Adjust opportunity",
                        style: TextStyle(color: Color(0xFF2979FF)),
                      ),
                      style: TextButton.styleFrom(),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Expanded(
                //   child:
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    itemCount: allItems.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        key: ValueKey(index),
                        endActionPane: ActionPane(
                          motion: //DrawerMotion(),
                              const ScrollMotion(), // BehindMotion
                          extentRatio: 0.15,
                          children: [
                            // SlidableAction(
                            //   onPressed: (context) {
                            //     // ใส่โค้ดสำหรับปุ่ม "แก้ไข" ตรงนี้
                            //     print("Edit pressed");
                            //   },
                            //   backgroundColor: Colors.blue,
                            //   foregroundColor: Colors.white,
                            //   icon: Icons.edit,
                            //   label: 'แก้ไข',
                            // ),
                            const SizedBox(width: 5),
                            IconButton(
                              onPressed: () =>
                                  setState(() => allItems.removeAt(index)),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),

                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          //  color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                          // color: Colors.blueAccent[80],
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).scaffoldBackgroundColor,
                              child: Text(
                                _items.contains(allItems[index])
                                    ? "${index + 1}"
                                    : '/',
                                style: TextStyle(
                                  color: isLightMode
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            title: Text(allItems[index]),
                            // trailing: IconButton(
                          ),
                        ),
                      );
                    },
                  ),
                ),

                //  height: MediaQuery.of(context).size.height * 0.25,
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: onPopup
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min, // ให้ Row กว้างเท่ากับปุ่มภายใน
              children: [
                // FloatingActionButton.extended(
                //   heroTag: "left",
                //   onPressed: canRandom ? showRandomProcess : null,
                //   label: Text(
                //     'Random!',
                //     style: const TextStyle(fontSize: 18, color: Colors.white),
                //   ),
                //   icon: Icon(Icons.shuffle, color: Colors.white),
                //   backgroundColor: Colors.grey,
                //   shape: const RoundedRectangleBorder(
                //     borderRadius: BorderRadius.only(
                //       topLeft: Radius.circular(20),
                //       bottomLeft: Radius.circular(20),
                //       topRight: Radius.circular(0),
                //       bottomRight: Radius.circular(0),
                //     ),
                //   ),
                // ),
                FloatingActionButton.extended(
                  heroTag: "primary",
                  onPressed: canRandom ? showRandomProcess : null,
                  label: const Text(
                    'Random!',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  icon: const Icon(Icons.shuffle, color: Colors.white),
                  backgroundColor: canRandom ? AppColors.rand : Colors.grey,
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
