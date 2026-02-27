import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA), // สีพื้นหลังขาวนวลๆ
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // --- Header Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "สวัสดีตอนเช้า,",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        "คุณสมชาย ✨",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=11',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
              // --- Search Bar (สวยกว่าบล็อกปกติ) ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    hintText: "ค้นหาโน้ตของคุณ...",
                  ),
                ),
              ),

              SizedBox(height: 30),
              // --- Category List ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryCard(
                    "รายการ",
                    Icons.list_alt,
                    Colors.blueAccent,
                  ),
                  _buildCategoryCard(
                    "โน้ต",
                    Icons.edit_note,
                    Colors.orangeAccent,
                  ),
                  _buildCategoryCard(
                    "สำคัญ",
                    Icons.star_outline,
                    Colors.redAccent,
                  ),
                ],
              ),

              SizedBox(height: 30),
              Text(
                "โน้ตล่าสุด",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),

              // --- Recent Note Card ---
              _buildNoteCard(
                "ไอเดียโปรเจกต์ใหม่",
                "ลองใช้ Flutter ทำแอปโน้ตที่สวยที่สุดในโลก...",
                "2 ชม. ที่แล้ว",
              ),
              _buildNoteCard(
                "รายการซื้อของ",
                "ไข่ไก่, นมสด, ขนมปัง, กาแฟ...",
                "เมื่อวานนี้",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget ช่วยสร้างการ์ดหมวดหมู่
  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  // Widget ช่วยสร้างการ์ดโน้ต
  Widget _buildNoteCard(String title, String subtitle, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
