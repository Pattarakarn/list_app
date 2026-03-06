import 'package:flutter/material.dart';
import 'dart:math';
import '../../app_colors.dart';
import '../../loading.dart';

// void main() {
//   runApp(const MaterialApp(
//     home: RandomizerPage(),
//     debugShowCheckedModeBanner: false,
//   ));
// }

class RandomP extends StatefulWidget {
  const RandomP({super.key});

  @override
  State<RandomP> createState() => _RandomPState();
}

class _RandomPState extends State<RandomP> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _items = [];

  void _showRandomProcess() async {
    // String winner = _items[random.nextInt(_items.length)];

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
            // const SizedBox(height: 20),
            // const Text(
            //   "กำลังสุ่ม...",
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );

    // 2. หน่วงเวลาไว้ 2 วินาที (ให้ User ได้ลุ้น)
    await Future.delayed(const Duration(seconds: 2));

    // 3. ปิด Dialog "กำลังสุ่ม"
    if (!mounted) return;
    Navigator.pop(context);

    // 4. คำนวณผลลัพธ์
    final random = Random();
    int randomIndex = random.nextInt(_items.length);
    String winner = _items[randomIndex];

    // 5. แสดง Dialog ผลลัพธ์จริง (ใช้โค้ดเดิมที่เราคุยกัน)
    _showRandomResult(winner, randomIndex);
  }

  void _showRandomResult(winner, randomIndex) {
    showDialog(
      context: context,
      barrierDismissible: false, // บังคับให้กดปุ่มเพื่อปิดเท่านั้น
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("ผลการสุ่ม 🎉")),
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
                color: AppColors.rand, //Colors.deepPurple,
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
                // ปุ่มปิด
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // setState(() {
                      //   _items.removeAt(randomIndex);
                      // });
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
                    child: const Text("ปิด"),
                  ),
                ),

                const SizedBox(width: 10),

                if (_items.length > 1) // ถ้าเหลือของให้สุ่มต่อได้
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
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        "สุ่มต่อ (${_items.length - 1} รายการ)",
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

  // void _addItem() {
  //   if (_controller.text.trim().isNotEmpty) {
  //     setState(() {
  //       _items.add(_controller.text.trim());
  //       _controller.clear();
  //     });
  //   }
  // }
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

  @override
  Widget build(BuildContext context) {
    bool canRandom = _items.length >= 2;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("รายการที่ต้องการสุ่ม"),
      //   backgroundColor: Colors.deepPurple,
      //   foregroundColor: Colors.white,
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ส่วนช่องกรอกข้อมูล
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
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text("")) //ลองเพิ่มรายการดูก่อนนะ 😊
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // color: Colors.grey[500],
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text("${index + 1}"),
                              backgroundColor: Colors.white, //grey[100],
                            ),
                            title: Text(_items[index]),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  setState(() => _items.removeAt(index)),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // ปุ่มสุ่ม (ที่จะเปลี่ยนสีและกดได้เมื่อเงื่อนไขครบ)
            const SizedBox(height: 20),
            SizedBox(
              // width: double.infinity,
              width: MediaQuery.of(context).size.width * 0.45,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: canRandom ? _showRandomProcess : null,
                icon: const Icon(Icons.shuffle, color: Colors.white),
                label: Text(
                  'Random!',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canRandom ? AppColors.rand : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: canRandom ? 8 : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
