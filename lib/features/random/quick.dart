import 'package:flutter/material.dart';
import 'dart:math';
import '../../app_colors.dart';
import '../../loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RandomQuick extends StatefulWidget {
  final VoidCallback onCallBack;
  const RandomQuick({super.key, required this.onCallBack});
  @override
  State<RandomQuick> createState() => _RandomQuickState();
}

class _RandomQuickState extends State<RandomQuick> {
  final TextEditingController _controller = TextEditingController();
  List<String> _items = [];
  final user = FirebaseAuth.instance.currentUser;

  void _showRandomProcess() async {
    showDialog(
      context: context,
      barrierDismissible: false, // ห้ามกดปิดจนกว่าจะสุ่มเสร็จ
      builder: (context) => AlertDialog(
        backgroundColor:
            Colors.transparent, // ทำให้พื้นหลังใสเพื่อโชว์แค่ Animation
        elevation: 0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ใช้ CircularProgressIndicator หรือ Lottie Animation ตรงนี้
            BouncingDots(),
          ],
        ),
      ),
    );

    if (_items.length > 1) await Future.delayed(const Duration(seconds: 2));

    // 3. ปิด Dialog "กำลังสุ่ม"
    if (!mounted) return;
    Navigator.pop(context);

    final random = Random();
    int randomIndex = random.nextInt(_items.length);
    String winner = _items[randomIndex];

    _showRandomResult(winner, randomIndex);
  }

  void _showRandomResult(winner, randomIndex) {
    showDialog(
      context: context,
      barrierDismissible: false, // บังคับให้กดปุ่มเพื่อปิดเท่านั้น
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            "ผลการสุ่ม 🎉",
            // style: const TextStyle(color: AppColors.secondary),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Icon(Icons.stars, color: Colors.orange, size: 80),
            const SizedBox(height: 15), //20),
            Text(
              '${winner}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.rand,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly, // จัดวางปุ่มให้สมดุล
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (_items.length == 1)
                        setState(() {
                          _items.removeAt(0);
                        });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // _items.length == 1 ? "เคลียร์และปิด" : "ปิด"
                    child: const Text("ปิด"),
                  ),
                ),

                const SizedBox(width: 10),

                if (_items.length > 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _items.removeAt(randomIndex); // ลบตัวเก่าออกก่อน
                        });
                        Navigator.pop(context); // ปิด Dialog เก่า
                        _showRandomProcess(); // เปิดอันใหม่ (สุ่มต่อทันที)
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(
                          0xFF2979FF,
                        ), // AppColors.secondary,
                      ),
                      child: Text(
                        (_items.length - 1 == 1)
                            ? "แสดงรายการสุดท้าย"
                            : "สุ่มต่อ (${_items.length - 1} รายการ)",
                        style: TextStyle(color: Colors.white),
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

  final FocusNode _focusNode = FocusNode();
  void _addItem() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _items.add(_controller.text.trim());
        _controller.clear(); // ล้างช่องพิมพ์
      });

      // 2. สั่งให้โฟกัสกลับมาที่ช่องเดิมทันที
      _focusNode.requestFocus();
    }
  }

  Future<void> _createList() async {
    try {
      await FirebaseFirestore.instance.collection('random').add({
        'items': _items,
        'createdAt': FieldValue.serverTimestamp(),
        'authorId': user?.uid,
        'name': 'Random',
      });
      setState(() => _items = []);
      // ต้องใช้คำว่า widget. นำหน้า เพื่อไปดึงค่าจากตัวแม่มาใช้
      widget.onCallBack();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canRandom = _items.length >= 2;

    // return Scaffold(
    //   body: Padding(
    //     padding: const EdgeInsets.all(20.0),
    //     child:
    //     Column(
    return Container(
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
                    hintText: "พิมพ์รายการที่ต้องการสุ่ม",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.rand,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusColor: Colors.white,
                    hoverColor: Colors.white,
                  ),
                  textInputAction: TextInputAction
                      .done, // เปลี่ยนปุ่มบนคีย์บอร์ดเป็นรูปติ๊กถูกหรือ Done
                  onSubmitted: (value) {
                    _addItem(); // เมื่อกด Enter ให้เรียกฟังก์ชันเพิ่มรายการทันที
                  },
                ),
              ),
              const SizedBox(width: 10),
              Ink(
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  gradient: LinearGradient(
                    // colors: [Colors.blue, Colors.purple],
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
          // ส่วนแสดงรายการที่เพิ่มแล้ว
          // Expanded(
          //   child: _items.isEmpty
          //       ? const Center(child: Text("")) :
          SizedBox(
            height:
                MediaQuery.of(context).size.height *
                0.25, // 30% ของความสูงหน้าจอ
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  //  color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  // color: Colors.blueAccent[80],
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text("${index + 1}"),
                      backgroundColor: Colors.white, //grey[100],
                    ),
                    title: Text(_items[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() => _items.removeAt(index)),
                    ),
                  ),
                );
              },
            ),
          ),
          //  height: MediaQuery.of(context).size.height * 0.25,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canRandom ? _showRandomProcess : null,
                    icon: Icon(
                      Icons.bolt,
                      color: canRandom ? AppColors.rand : Colors.grey,
                    ),
                    label: const Text("Quick"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFF2979FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _items.isNotEmpty ? _createList() : null;
                    },
                    icon: const Icon(Icons.bookmark_add),
                    label: const Text("บันทึก"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary, //Theme.of(context).primaryColor
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // ),
    );
  }
}
