import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _input = "0";
  String _result = "0";

  void _onPressed(String text) {
    setState(() {
      if (text == "C") {
        _input = "0";
        _result = "";
      } else if (text == "=") {
        _input = _result; //ผลลัพธ์มาแทนที่เลขข้างบน
        _result = "";
      } else if (text == "+/-") {
        if (_input.startsWith('-')) {
          _input = _input.substring(1);
        } else {
          _input = '-$_input';
        }
      } else {
        // ถ้าเริ่มด้วย 0 ให้ทับไปเลย ถ้าไม่ใช่ให้ต่อท้าย
        if (_input == "0") {
          _input = text;
        } else {
          _input += text;
        }

        try {
          // แปลง ÷ เป็น / และ × เป็น * ก่อนส่งไปคำนวณ
          String mathExpression = _input
              .replaceAll('÷', '/')
              .replaceAll('×', '*');

          // ใช้ Parser จาก math_expressions (ถ้าติดตั้งไว้)
          Parser p = Parser();
          Expression exp = p.parse(mathExpression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);

          // ถ้าเลขเป็นจำนวนเต็ม (เช่น 10.0) ให้แสดงเป็น 10
          _result = eval % 1 == 0 ? eval.toInt().toString() : eval.toString();
        } catch (e) {
          // ถ้ายังพิมพ์ไม่เสร็จ (เช่น 5 +) ให้ข้ามไปก่อน ไม่ต้องโชว์ Error
          _result = _result;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      "C",
      "()",
      "%",
      "÷",
      "7",
      "8",
      "9",
      "×",
      "4",
      "5",
      "6",
      "-",
      "1",
      "2",
      "3",
      "+",
      "+/-",
      "0",
      ".",
      "=",
    ];
    bool isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      // backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        // title: const Text("General"),
        backgroundColor: const Color(0xFFF3F7F9),
        // actions: [
        //   PopupMenuButton<String>(
        //     onSelected: (value) {
        //       print("คุณเลือก: $value");
        //       // ใส่ logic เปลี่ยนหน้าหรือเปลี่ยนสถานะตรงนี้
        //     },
        //     itemBuilder: (BuildContext context) {
        //       return {'Option 1', 'Option 2', 'Settings'}.map((String choice) {
        //         return PopupMenuItem<String>(
        //           value: choice,
        //           child: Text(choice),
        //         );
        //       }).toList();
        //     },
        //   ),
        // ],
        centerTitle: true,
        title: ConstrainedBox(
          constraints: BoxConstraints(), //minWidth: 180),
          child: DropdownButtonHideUnderline(
            // ซ่อนเส้นใต้เพื่อให้ดูคลีน
            child: DropdownButton<String>(
              value: "General", // ค่าปัจจุบัน
              items: <String>['General', 'Stock', 'Utility'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                // อัปเดตสถานะเมื่อเลือก
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _input,
                      style: const TextStyle(
                        // color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      NumberFormat(
                        "#,###",
                      ).format(double.parse(_result)).toString(),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isLightMode
                    ? const Color(0xFF334155).withOpacity(0.7)
                    : Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                ),
                itemBuilder: (context, index) {
                  return _buildButton(buttons[index], isLightMode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, bool isLightMode) {
    bool isNumber = double.tryParse(text) != null || text == ".";

    Color btnBg;
    if (text == "C") {
      btnBg = Theme.of(context).scaffoldBackgroundColor;
    } else if (!isNumber || text == "+/-") {
      btnBg = const Color(0xFFFF9500); // สีส้มสำหรับเครื่องหมาย
    } else {
      btnBg = isLightMode
          ? Colors.white
          : Theme.of(context).scaffoldBackgroundColor;
      // btnColor = const Color(0xFF334155); // สี Slate สำหรับตัวเลข
    }

    return InkWell(
      onTap: () => _onPressed(text),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: btnBg),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: text == "C"
                  ? Colors.redAccent
                  : (isNumber && !isLightMode)
                  ? Colors.white
                  : Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
