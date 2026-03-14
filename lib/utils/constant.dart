import 'package:flutter/material.dart';
import '../../app_colors.dart';

// class MenuItem {
//   final String label;
//   final IconData icon;
//   final String route; // เอาไว้บอกว่าจะไปหน้าไหน
//   final Object color;
//   final int index;

//   MenuItem({required this.label, required this.icon,  this.route, required this.color, required this.index});
// }

class AppMenus {
  static List<Map<String, dynamic>> mainNavItems = [
    // {'icon': Icons.home, 'label': 'หลัก', 'color': Colors.blue, 'index': 0},
    {
      'icon': Icons.list,
      'label': 'ลิสต์',
      'color': AppColors.primary,
      'index': 1,
    },
    // list_alt_rounded
    {'icon': Icons.note, 'label': 'โน้ต', 'color': AppColors.note, 'index': 2},
    // description_rounded
    {
      'icon': Icons.auto_awesome,
      'label': 'random',
      'color': [Color(0xFF00E5FF), Color(0xFF2979FF)],
      'index': 3,
    },
    {
      'icon': Icons.health_and_safety,
      'label': 'health',
      'color': [Color(0xFFF06292), Color(0xFFBA68C8)],
      'index': 4,
    },
  ];
  //static List<MenuItem> mainNavItems =  [
  //  MenuItem(label: 'ลิสต์', icon: Icons.list, route: '/',color: AppColors.primary,index: 1,),
  // MenuItem(label: 'โน้ต', icon: Icons.note, color: AppColors.note,index: 2,),
  // MenuItem(label: 'random', icon: Icons.auto_awesome, color: [Color(0xFF00E5FF), Color(0xFF2979FF)],index: 3,),
  // ];
}

// enum OptionType {
//   table("ตาราง", "Table"),
//   checklist("checklist", "Checklist"),

//   final String label;
//   final String value;
//   // final IconData icon;
//   const MenuCategory(this.label, this.value);
// }
class Options {
  static List<Map<String, String>> TypeList = [
    {"label": "ตาราง", "value": "Table"},
    {"label": "checklist", "value": "Checklist"},
  ];
}
