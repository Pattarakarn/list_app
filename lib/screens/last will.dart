import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WillPage extends StatefulWidget {
  @override
  State<WillPage> createState() => _WillPageState();
}

class _WillPageState extends State<WillPage> {
  bool unlocked = false;
  final TextEditingController guessController = TextEditingController();

  void checkPassword(String realCode) {
    if (guessController.text == realCode) {
      setState(() {
        unlocked = true;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("รหัสไม่ถูกต้อง")));
    }
  }

  final user = FirebaseAuth.instance.currentUser;
  final noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('Testament')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs[0].data() as Map<String, dynamic>;
          // print(datas);
          noteController.text = data['note'];

          final apps = List<String>.from(data['apps'] ?? []);
          final insurance = List<String>.from(data['insurance'] ?? []);
          final assets = List<String>.from(data['assets'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= PROFILE =================
                Text("ชื่อ: ${data['name']}"),
                Text("Email: ${data['email']}"),

                const SizedBox(height: 20),

                // ================= PASSWORD GUESS =================
                if (!unlocked)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("สุ่มรหัสเพื่อปลดล็อคข้อมูล"),
                      TextField(
                        controller: guessController,
                        decoration: const InputDecoration(hintText: "กรอก"),
                      ),
                      ElevatedButton(
                        onPressed: () => checkPassword(data['hintCode']),
                        child: const Text("ยืนยัน"),
                      ),
                    ],
                  ),

                if (unlocked) ...[
                  const SizedBox(height: 10),
                  Text("🔐 Password: ${data['password']}"),
                ],

                const SizedBox(height: 20),

                // ================= 2 COLUMNS =================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("📱 Apps"),
                          ...apps.map((e) => Text("- $e")),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("🛡 Insurance"),
                          ...insurance.map((e) => Text("- $e")),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= ASSETS =================
                const Text("🏠 ทรัพย์สิน"),
                ...assets.map((e) => Text("- $e")),

                const Text("บช ธนาคาร"),
                const SizedBox(height: 20),
                const Text("test"),
                TextField(
                  controller: noteController,
                  // onChanged: (value) {
                  //   data[''] = int.parse(value);
                  // },
                  minLines: 3,
                  maxLines: 15,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'หมายเหตุเพิ่มเติม',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "บันทึกข้อมูล",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () async {
                    final datas = {
                      //password [{value: ,app}]
                      // insurance
                      //  bank
                      // asset
                      'note': noteController.text,
                      'created_at': DateTime.now(),
                    };
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .collection('Testament')
                        .add(datas);
                        print('success');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
