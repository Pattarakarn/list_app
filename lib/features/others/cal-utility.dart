import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class UtilityPage extends StatefulWidget {
  final String mode;

  const UtilityPage({super.key, required this.mode});

  @override
  State<UtilityPage> createState() => _UtilityPageState();
}

class _UtilityPageState extends State<UtilityPage> {
  // Controllers สำหรับโหมด A
  final _weightController = TextEditingController(text: "100");
  final _totalPriceController = TextEditingController();
  final _ratioController =
      TextEditingController(); // ช่องที่ 3 (เปอร์เซ็นต์ หรือ จำนวน)

  bool isPercentMode = true; // สลับโหมด % หรือ ราคา
  double resultA = 0;

  // Controllers สำหรับโหมด B (หุ้น)
  final _currentVolController = TextEditingController();
  final _avgPriceController = TextEditingController();
  final _marketPriceController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _buyVolController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: widget.mode == 'Utility' ? _buildModeU() : _buildModeS(),
      ),
    );
  }

  Widget _buildModeU() {
    return Column(
      children: [
        Row(
          children: [
            ChoiceChip(
              label: const Text("Percent"),
              selected: isPercentMode,
              onSelected: (val) => setState(() {
                isPercentMode = true;
                _ratioController.text = "100";
              }),
            ),
            const SizedBox(width: 10),
            ChoiceChip(
              label: const Text("Shopping"),
              selected: !isPercentMode,
              onSelected: (val) => setState(() {
                isPercentMode = false;
                _ratioController.text = "1";
              }),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _weightController,
                isPercentMode ? "ร้อยละ" : "น้ำหนัก/จำนวนทั้งหมด",
                onChanged: (v) => _calculateA(),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _buildTextField(
                _totalPriceController,
                isPercentMode ? "จำนวนทั้งหมด" : "ราคาสิ่งของ",
                onChanged: (v) => _calculateA(),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _ratioController,
                isPercentMode ? "จำนวนของที่มี" : "อัตราส่วน",
                onChanged: (v) => _calculateA(),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: !isPercentMode
                  ? Text(
                      " ราคาต่อ 1 ชิ้น/กรัม: ${resultA.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      "คิดเป็น ${resultA.toStringAsFixed(2)}%",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  void _calculateA() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    double totalP = double.tryParse(_totalPriceController.text) ?? 0;
    double ratio = double.tryParse(_ratioController.text) ?? 0;

    setState(() {
      if (isPercentMode) {
        // คำนวณตาม %: (ราคา * %) / 100
        resultA = (weight * ratio) / totalP;
      } else {
        // คำนวณตามราคา: (ราคา * จำนวน) / น้ำหนัก (3x2/1)
        resultA = weight != 0 ? (totalP * ratio) / weight : 0;
      }
    });
  }

  Widget _buildModeS() {
    double currentVol = double.tryParse(_currentVolController.text) ?? 0;
    double avgPrice = double.tryParse(_avgPriceController.text) ?? 0;
    double marketPrice = double.tryParse(_marketPriceController.text) ?? 0;
    double buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
    double buyVol = double.tryParse(_buyVolController.text) ?? 0;

    // คำนวณ % จาก market vs avg
    double profitPercent = avgPrice != 0
        ? ((marketPrice - avgPrice) / avgPrice) * 100
        : 0;

    // คำนวณหุ้นใหม่
    double totalCostNew = (currentVol * avgPrice) + (buyVol * buyPrice);
    double totalVolNew = currentVol + buyVol;
    double newAvg = totalVolNew != 0 ? totalCostNew / totalVolNew : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_currentVolController, "Current Vol"),
        _buildTextField(_avgPriceController, "Avg. Price"),
        _buildTextField(_marketPriceController, "Market Price"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "กำไร/ขาดทุน: ${profitPercent.toStringAsFixed(2)} %",
            style: TextStyle(
              color: profitPercent >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ),
        const Divider(thickness: 2),
        const Text("ซื้อเพิ่ม", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(child: _buildTextField(_buyPriceController, "ราคาซื้อ")),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_buyVolController, "จำนวน")),
          ],
        ),
        const SizedBox(height: 20),
        _buildResultRow(
          "ราคารวมที่ซื้อเพิ่ม:",
          "${(buyPrice * buyVol).toStringAsFixed(2)}",
        ),
        _buildResultRow(
          "ค่าดำเนินการ (ประมาณ):",
          "${(buyPrice * buyVol * 1.0015).toStringAsFixed(2)}",
        ), // ตย. หักค่าคอม
        _buildResultRow(
          "Avg Price ใหม่:",
          newAvg.toStringAsFixed(2),
          isBold: true,
        ),
      ],
    );
  }

  // --- Helper Widgets ---
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none, // ไม่มีเส้นขอบตามที่ขอ
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildResultRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
