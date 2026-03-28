import 'package:flutter/material.dart';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RandomQuick extends StatefulWidget {
  final VoidCallback onCallBack;
  const RandomQuick({super.key, required this.onCallBack});
  @override
  State<RandomQuick> createState() => _RandomQuickState();
}

class _RandomQuickState extends State<RandomQuick> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _createList() async {
    // try {
    //   await FirebaseFirestore.instance.collection('random').add({
    //     'items': _items,
    //     'createdAt': FieldValue.serverTimestamp(),
    //     'authorId': user?.uid,
    //     'name': 'Random',
    //   });
    //   setState(() => _items = []);
    //   // ต้องใช้คำว่า widget. นำหน้า เพื่อไปดึงค่าจากตัวแม่มาใช้
    //   widget.onCallBack();
    // } catch (e) {
    //   print("Error: $e");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // บังคับให้กว้างเต็มจอ
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: [Row(children: [])]),
      // ),
    );
  }
}
