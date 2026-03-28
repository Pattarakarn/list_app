import 'package:flutter/material.dart';
import 'dart:math';
import '../../app_colors.dart';
import '../../loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quick.dart';

class RandomP extends StatefulWidget {
  const RandomP({super.key});

  @override
  State<RandomP> createState() => _RandomPState();
}

class _RandomPState extends State<RandomP> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        // decoration: _buildBackground(), // ใส่ Gradient เดิมของคุณ
        child: SafeArea(
          child: Column(
            children: [
              RandomQuick(
                onCallBack: () {
                  setState(() {
                    //  เมื่อเจอ setState มันจะไปรันฟังก์ชัน build(BuildContext context) ของหน้าหลักใหม่อีกรอบ
                  });
                },
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('random')
                      .where('authorId', isEqualTo: user?.uid)
                      // .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Records Found",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var data = docs[index].data() as Map<String, dynamic>;
                        // print(data);
                        return ListTile(
                          title: Text(
                            (data['name']) ?? 'random',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "( ${data['items'].length.toString()} รายการ)",
                            style: const TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
