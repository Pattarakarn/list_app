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
    final selection = _controller.selection;

    // หาตำแหน่ง Cursor ปัจจุบัน (ถ้าไม่มีการจิ้ม ให้เริ่มที่ท้ายสุดของข้อความ)
    int cursorPosition = selection.baseOffset;
    if (cursorPosition < 0) cursorPosition = input.length;

    String newInput = input;
    int newCursorOffset = cursorPosition;

    if (text == "C") {
      // 1. กดลบ (Backspace): ลบตัวอักษรก่อนหน้าตำแหน่ง Cursor 1 ตัว
      if (input.isNotEmpty && cursorPosition > 0) {
        newInput =
            input.substring(0, cursorPosition - 1) +
            input.substring(cursorPosition);
        newCursorOffset = cursorPosition - 1; // เลื่อน Cursor ถอยหลัง 1 ช่อง
      }
    } else if (text == "=") {
      newInput = _result.isNotEmpty ? _result : input;
      _result = "";
      newCursorOffset = newInput.length; // เลื่อน Cursor ไปท้ายสุด
    } else if (text == "+/-") {
      if (input.startsWith('-')) {
        newInput = input.substring(1);
        newCursorOffset = (cursorPosition - 1).clamp(0, newInput.length);
      } else {
        newInput = '-$input';
        newCursorOffset = cursorPosition + 1;
      }
    } else if (text == "( )") {
      int openBrackets = '('.allMatches(input).length;
      int closeBrackets = ')'.allMatches(input).length;

      String bracketToInsert = (openBrackets == closeBrackets) ? '(' : ')';

      newInput =
          input.substring(0, cursorPosition) +
          bracketToInsert +
          input.substring(cursorPosition);
      newCursorOffset = cursorPosition + 1;
    } else {
      if (input == "0") {
        newInput = text;
        newCursorOffset = text.length;
      } else {
        newInput =
            input.substring(0, cursorPosition) +
            text +
            input.substring(cursorPosition);
        newCursorOffset =
            cursorPosition + text.length; // เลื่อน Cursor ไปข้างหลังตัวที่แทรก
      }
    }

    try {
      if (newInput.isEmpty || newInput == "0") {
        _result = "";
      } else {
        String mathExpression = newInput
            .replaceAll('÷', '/')
            .replaceAll('×', '*');
        Parser p = Parser();
        Expression exp = p.parse(mathExpression);
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);

        _result = eval % 1 == 0 ? eval.toInt().toString() : eval.toString();
      }
    } catch (e) {
      // ถ้าสูตรยังพิมพ์ไม่สมบูรณ์ (เช่น 5 +) ให้คงผลลัพธ์เดิมไว้ ไม่ต้องโชว์ Error
    }

    setState(() {
      // อัปเดตข้อความและรักษาตำแหน่ง Cursor ด้วย TextEditingValue
      _controller.value = TextEditingValue(
        text: newInput,
        selection: TextSelection.fromPosition(
          TextPosition(offset: newCursorOffset),
        ),
      );
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
                    style: TextStyle(
                      color: isLightMode ? Colors.black : Colors.grey,
                    ),
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
                                .multiline, // ใช้ text เพื่อให้พิมพ์เครื่องหมายได้ง่าย
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
      onLongPress: () => {
        if (text == "C")
          setState(() {
            _controller.text = "0";
            _result = "";
          }),
      },
    );
  }
}
