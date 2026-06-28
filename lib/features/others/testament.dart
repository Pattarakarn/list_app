// ovider.of<UserProvider> bottomNavigationBar

// การบริจาคร่างกายหรืออวัยวะ
// สถานที่วาระสุดท้าย
// นต้องการให้จัดงานศพดังนี

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalPage extends StatefulWidget {
  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ให้พื้นหลังทะลุขึ้นไปหลัง AppBar
      appBar: AppBar(
        title: Text(
          "", //" ${widget.data['car_name']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Text(':)'),
    );
  }
}
