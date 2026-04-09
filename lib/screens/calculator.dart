import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';
import '../features/others/cal-utility.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // String _input = "0";
  String _result = "0";
  String _mode = "General";
  final TextEditingController _controller = TextEditingController(text: "");

  void _onPressed(String text) {
    String input = _controller.text;
    setState(() {
      if (text == "C") {
        input = "0";
        _result = "";
      } else if (text == "=") {
        input = _result; //ผลลัพธ์มาแทนที่เลขข้างบน
        _result = "";
      } else if (text == "+/-") {
        if (input.startsWith('-')) {
          input = input.substring(1);
        } else {
          input = '-$input';
        }
      } else if (text == "( )") {
        int openBrackets = '('.allMatches(text).length;
        int closeBrackets = ')'.allMatches(text).length;
        if (openBrackets == closeBrackets) {
          input += 'x(';
        // if (openBrackets > closeBrackets) {
        } else {
          input += ')';
        }
      } else {
        // ถ้าเริ่มด้วย 0 ให้ทับไปเลย ถ้าไม่ใช่ให้ต่อท้าย
        if (input == "0") {
          input = text;
        } else {
          input += text;
        }

        try {
          // แปลง ÷ เป็น / และ × เป็น * ก่อนส่งไปคำนวณ
          String mathExpression = input
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
      setState(() {
        _controller.text = input;
      });
    });
  }

  final formatter = NumberFormat("#,###.##");
  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      "C",
      "( )",
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
    TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
    ) {
      // 1. กรองตัวอักษรที่ไม่ต้องการออก (Allow only math chars & digits)
      final regExp = RegExp(r'[0-9\+\-\*\/\(\)\.]');
      String newText = newValue.text
          .split('')
          .where((char) => regExp.hasMatch(char))
          .join();

      // 2. Logic การใส่ Comma (ใช้ Regex แยกกลุ่มตัวเลขออกจากเครื่องหมาย)
      // แยกส่วนที่เป็นตัวเลขออกมาเพื่อใส่ comma แล้วเอากลับไปรวมกับเครื่องหมาย
      String formatted = newText.replaceAllMapped(RegExp(r'\d+'), (match) {
        double val = double.parse(match.group(0)!);
        return formatter.format(val);
      });

      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return Scaffold(
      // backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        centerTitle: true,
        title: ConstrainedBox(
          constraints: const BoxConstraints(), //minWidth: 180),
          child: DropdownButtonHideUnderline(
            // ซ่อนเส้นใต้เพื่อให้ดูคลีน
            child: DropdownButton<String>(
              value: _mode,
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
                setState(() {
                  _mode = newValue as String;
                });
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _mode == "General"
            ? Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Text(
                          //   _input,
                          //   style: const TextStyle(
                          //     // color: Colors.white,
                          //     fontSize: 48,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          TextField(
                            minLines: 2,
                            maxLines: null,
                            controller: _controller,
                            keyboardType: TextInputType
                                .text, // ใช้ text เพื่อให้พิมพ์เครื่องหมายได้ง่าย
                            inputFormatters: [
                              // ถ้าอยากคุมแค่ตัวอักษรเบื้องต้นใช้ตัวนี้
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9\+\-\*\/\(\)\.]'),
                              ),
                              // ถ้าอยากให้มีคอมม่าด้วย ให้ใช้ Class ที่เราสร้างข้างบน (ต้องปรับจูนเพิ่มตามความซับซ้อน)
                            ],
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            NumberFormat(
                                  "#,###.###",
                                  // ).format(double.parse(_result)).toString(),
                                )
                                .format(double.tryParse(_result) ?? 0.0)
                                .toString(),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 22,
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
                          ? Colors.grey
                          : const Color(0xFF1E293B),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: buttons.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
              )
            : UtilityPage(mode: _mode),
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
