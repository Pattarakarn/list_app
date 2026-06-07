import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:list_app/app_colors.dart';

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

  // bool isPercentMode = true; // สลับโหมด % หรือ ราคา
  ValueNotifier<bool> isPercentMode = ValueNotifier<bool>(true);
  double resultA = 0;

  // Controllers สำหรับโหมด B (หุ้น)
  final _currentVolController = TextEditingController();
  final _avgPriceController = TextEditingController();
  final _marketPriceController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _buyVolController = TextEditingController();

  double totalCostNew = 0;
  double totalVolNew = 0;
  double newAvg = 0;
  double profitPercent = 0;
  double sumprice = 0;
     
  @override
  void initState() {
    super.initState();
    //  ติดตามการเปลี่ยนแปลง
    _currentVolController.addListener(_calculateResult);
    _avgPriceController.addListener(_calculateResult);
    _marketPriceController.addListener(_calculateResult);
    _buyPriceController.addListener(_calculateResult);
    _buyVolController.addListener(_calculateResult);

    isPercentMode.addListener(_calculateA);
  }

  void _calculateResult() {
    setState(() {
      double currentVol = double.tryParse(_currentVolController.text) ?? 0;
      double avgPrice = double.tryParse(_avgPriceController.text) ?? 0;
      double marketPrice = double.tryParse(_marketPriceController.text) ?? 0;
      double buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
      double buyVol = double.tryParse(_buyVolController.text) ?? 0;

      totalCostNew = (currentVol * avgPrice) + (buyVol * buyPrice);
      totalVolNew = currentVol + buyVol;
      newAvg = totalVolNew != 0 ? totalCostNew / totalVolNew : 0;
      // newAvg = totalVolNew != 0 ? ((currentVol * avgPrice) + (buyVol * buyPrice)) / (currentVol + buyVol) : 0;
      // คำนวณ % จาก market vs avg
      profitPercent = avgPrice != 0
          ? ((marketPrice - avgPrice) / avgPrice) * 100
          : 0;
      sumprice = buyPrice * buyVol;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: widget.mode == 'Utility'
            ? _buildModeU()
            : _buildModeS(
                totalCostNew,
                totalVolNew,
                newAvg,
                profitPercent,
                sumprice,
              ),
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
              selected: isPercentMode.value,
              onSelected: (val) => setState(() {
                isPercentMode.value = true;
                _ratioController.text = "100";
              }),
            ),
            const SizedBox(width: 10),
            ChoiceChip(
              label: const Text("Shopping"),
              selected: !isPercentMode.value,
              onSelected: (val) => setState(() {
                isPercentMode.value = false;
                _ratioController.text = "1";
                // resultA = 0;
              }),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _weightController,
                isPercentMode.value ? "ร้อยละ" : "น้ำหนัก/จำนวนทั้งหมด",
                onChanged: (v) => _calculateA(),
              ),
            ),
            const SizedBox(width: 5),
            if (isPercentMode.value)
              Expanded(
                child: Text(
                  "คิดเป็น ${resultA.toStringAsFixed(2)}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (!isPercentMode.value)
              Expanded(
                child: _buildTextField(
                  _totalPriceController,
                  isPercentMode.value ? "จำนวนทั้งหมด" : "ราคาสิ่งของ",
                  onChanged: (v) => _calculateA(),
                ),
              ),
          ],
        ),
        Row(
          children: [
            if (isPercentMode.value)
              Expanded(
                child: _buildTextField(
                  _totalPriceController,
                  "จำนวนทั้งหมด",
                  onChanged: (v) => _calculateA(),
                ),
              ),
                if (isPercentMode.value)   const SizedBox(width: 5),
            Expanded(
              child: _buildTextField(
                _ratioController,
                isPercentMode.value ? "จำนวนของที่มี" : "อัตราส่วน",
                onChanged: (v) => _calculateA(),
              ),
            ),
            const SizedBox(width: 5),
            if (!isPercentMode.value)
              Expanded(
                child: Text(
                  " ราคา ${resultA.toStringAsFixed(2)} ต่อ 1 ชิ้น/g",
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
      if (isPercentMode.value) {
        // คำนวณตาม %: (ราคา * %) / 100
        resultA = (weight * ratio) / totalP;
      } else {
        // คำนวณตามราคา: (ราคา * จำนวน) / น้ำหนัก (3x2/1)
        resultA = weight != 0 ? (totalP * ratio) / weight : 0;
      }
    });
  }

  Widget _buildModeS(
    double totalCostNew,
    double totalVolNew,
    double newAvg,
    double profitPercent,
    double sumprice,
  ) {
    //  double average = totalVolNew != 0 ? totalCostNew / totalVolNew : 0;
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
              color: profitPercent > 0 ? Colors.green :  profitPercent == 0 ? AppColors.gray : Colors.red,
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
          // "${(buyPrice * buyVol).toStringAsFixed(2)}",
          NumberFormat('#,###.##').format(sumprice),
        ),
        _buildResultRow(
          "ค่าดำเนินการ (ประมาณ):",
          NumberFormat.decimalPattern().format((sumprice * 1.0015) - sumprice),
          // "${(buyPrice * buyVol * 1.0015).toStringAsFixed(2)}",
        ),
        _buildResultRow(
          "Avg Price ใหม่:",
          newAvg.toStringAsFixed(2),
          // average.toStringAsFixed(2),
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    Function(String)? onChanged,
  }) {
     bool isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none, 
          filled: true,
          fillColor: isLightMode ? Colors.grey[100]: Theme.of(context).scaffoldBackgroundColor,
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
