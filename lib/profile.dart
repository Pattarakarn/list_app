import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
     mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          const Text('Name: Flutter Beginner', style: TextStyle(fontSize: 20)),
          const Text('Email: hello@flutter.com'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () { /* ใส่ logic logout ตรงนี้ */ },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}