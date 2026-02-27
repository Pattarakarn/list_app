import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'ยินดีต้อนรับ!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // const Text('เลือกเมนูด้านซ้ายเพื่อเริ่มต้นใช้งาน'),
        ],
      ),
    );
  }
}
