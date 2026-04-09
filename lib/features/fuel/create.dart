import 'package:flutter/material.dart';
import 'package:list_app/app_colors.dart';
import 'dart:ui';
import 'package:list_app/utils/constant.dart'; // อย่าลืมสำหรับ Glass Effect
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CreateListFuel extends StatefulWidget {
  final Map<String, dynamic> data;
  const CreateListFuel({super.key, required this.data});

  @override
  State<CreateListFuel> createState() => _CreateListFuelState();
}

class _CreateListFuelState extends State<CreateListFuel> {
  final _formKey = GlobalKey<FormState>();
  String? _fuelType = 'แก๊สโซฮอล์ 95';
  String? _station = 'Caltex';
  DateTime _selectedDateTime = DateTime.now();

  final _amountController = TextEditingController();
  final _litersController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isPremium = false;
  final _remarkController = TextEditingController();
  final _odometerController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  double _totalAmount = 0.0;
  int _fuelLevel = 5;
  final user = FirebaseAuth.instance.currentUser;
  void _calculateTotal() {
    double liters = double.tryParse(_litersController.text) ?? 0;
    double price = double.tryParse(_pricePerLiterController.text) ?? 0;
    setState(() {
      _totalAmount = liters * price;
      _amountController.text = (liters * price).toString();
    });
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white70, size: 20),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      // focusedBorder: const UnderlineInputBorder(
      //   borderSide: BorderSide(color: Colors.blueAccent),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.data);
    return Scaffold(
      extendBodyBehindAppBar: true, // ให้พื้นหลังทะลุขึ้นไปหลัง AppBar
      appBar: AppBar(
        title: Text(
          "Fuel Log - ${widget.data['car_name']}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // พื้นหลังเป็น Gradient เพื่อให้ Glass Effect ชัดเจน
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C5364), Color(0xFF203A43), Color(0xFF0F2027)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildGlassCard(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          // leading: const Icon(
                          //   Icons.calendar_today,
                          //   color: Colors.white70,
                          // ),
                          title: Text(
                            "วันที่: ${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}",
                            // "วันที่: ${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}  เวลา: ${TimeOfDay.fromDateTime(_selectedDateTime).format(context)}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(
                            Icons.edit_calendar,
                            color: Colors.white,
                          ),

                          onTap: () async {
                            // final picked = await showDatePicker(
                            //   context: context,
                            //   initialDate: _selectedDateTime,
                            //   firstDate: DateTime(2000),
                            //   lastDate: DateTime(2100),
                            // );
                            // if (picked != null) setState(() => _selectedDateTime = picked);

                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDateTime,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              // 2. เลือกเวลาต่อทันที
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  _selectedDateTime,
                                ),
                              );
                              if (time != null) {
                                setState(() {
                                  _selectedDateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                "เลขไมล์ปัจจุบัน (กม.)",
                                _odometerController,
                                Icons.speed,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildTextField(
                                "ตำแหน่ง / จังหวัด",
                                _locationController,
                                Icons.location_on,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        Row(
                          children: [
                            // 1. ส่วนของ "10 ขีด"
                            Expanded(
                              flex: 4, // ให้พื้นที่ส่วนขีดมากกว่า
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(10, (index) {
                                  int level = index + 1;
                                  bool isActive = level <= _fuelLevel;

                                  // กำหนดสีตามระดับความปลอดภัย
                                  Color barColor = Colors.greenAccent;
                                  if (level <= 2)
                                    barColor = Colors.redAccent;
                                  else if (level <= 5)
                                    barColor = Colors.orangeAccent;

                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _fuelLevel = level),
                                      child: Container(
                                        height: 30,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? barColor.withOpacity(0.8)
                                              : Colors.white10,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: isActive
                                                ? Colors.white70
                                                : Colors.white12,
                                          ),
                                          // เพิ่มเงาเรืองแสงให้ขีดที่เลือก
                                          boxShadow: isActive
                                              ? [
                                                  BoxShadow(
                                                    color: barColor.withOpacity(
                                                      0.4,
                                                    ),
                                                    blurRadius: 4,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            const SizedBox(width: 15),

                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Center(
                                child: Text(
                                  "${_fuelLevel * 10}%",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // _buildGlassCard(
                  //   child: Column(
                  //     children: [

                  //       const SizedBox(height: 15),

                  //       Row(
                  //         children: [
                  //           // ช่องจำนวนลิตร
                  //           Expanded(
                  //             child: TextFormField(
                  //               controller: _litersController,
                  //               keyboardType: TextInputType.number,
                  //               style: const TextStyle(color: Colors.white),
                  //               // decoration: _inputStyle("จำนวนลิตร", Icons.opacity),
                  //               onChanged: (value) =>
                  //                   _calculateTotal(), // พิมพ์แล้วคำนวณทันที
                  //             ),
                  //           ),
                  //           const SizedBox(width: 15),
                  //           // ช่องราคาน้ำมันต่อลิตร
                  //           Expanded(
                  //             child: TextFormField(
                  //               controller: _pricePerLiterController,
                  //               keyboardType: TextInputType.number,
                  //               style: const TextStyle(color: Colors.white),
                  //               // decoration: _inputStyle("ราคา/ลิตร", Icons.sell),
                  //               onChanged: (value) =>
                  //                   _calculateTotal(), // พิมพ์แล้วคำนวณทันที
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 20),

                  //       // แสดงยอดรวมเงิน (Calculated)

                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.all(15),
                        //   decoration: BoxDecoration(
                        //     color: Colors.blueAccent.withOpacity(0.2),
                        //     borderRadius: BorderRadius.circular(15),
                        //   ),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       const Text(
                        //         "ยอดรวมเงินสุทธิ:",
                        //         style: TextStyle(color: Colors.white70),
                        //       ),
                        //       Text(
                        //         "${_totalAmount.toStringAsFixed(2)} บาท",
                        //         style: const TextStyle(
                        //           color: Colors.greenAccent,
                        //           fontSize: 20,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Center(
                                  child: Text(
                                    "ยอดรวม: ${_totalAmount.toStringAsFixed(2)} บาท",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // const Text(" ",  style: const TextStyle(
                            //         color: Colors.white,)),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                controller: _pricePerLiterController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputStyle(
                                  "ราคา/ลิตร",
                                  Icons.sell,
                                ),
                                onChanged: (value) =>
                                    _calculateTotal(), // พิมพ์แล้วคำนวณทันที
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                "จำนวนบันทึก",
                                _amountController,
                                Icons.payments,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              // _buildTextField(
                              //   "จำนวนลิตร",
                              //   _litersController,
                              //   Icons.local_gas_station,
                              //   isNumber: true,
                              // ),
                              child: TextFormField(
                                controller: _litersController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputStyle(
                                  "จำนวนลิตร",
                                  Icons.local_gas_station,
                                ),
                                onChanged: (value) => _calculateTotal(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // _buildDropdown(
                        //   "ปั๊มน้ำมัน",
                        //   _station,
                        //   [
                        //     'Bangchak',
                        //     'Caltex',
                        //     'Esso',
                        //     'Shell',
                        //     'Susco',
                        //     'Ptt',
                        //     'Pt',
                        //     'อื่นๆ',
                        //   ],
                        //   (val) {
                        //     setState(() => _station = val);
                        //   },
                        // ),
                        _buildDropdown(
                          label: "ปั๊มน้ำมัน",
                          value: _station,
                          items: [
                            'Bangchak',
                            'Caltex',
                            'Esso',
                            'Shell',
                            'Susco',
                            'Ptt',
                            'Pt',
                            'อื่นๆ',
                          ],
                          icon: Icons.local_gas_station, // ใส่ไอคอนที่นี่
                          onChanged: (val) => setState(() => _station = val),
                        ),
                        //  DropdownButton<String>(
                        //       value: _fuelType,
                        //       dropdownColor: const Color(0xFF2C5364),
                        //       isExpanded: true,
                        //       underline: const SizedBox(), // เอาเส้นใต้ออกเพื่อให้ดูคลีน
                        //       style: const TextStyle(color: Colors.white),
                        //       items: <String>['ปกติ', 'เติมเต็มถัง', 'เติมแค่พอวิ่ง'].map((String value) {
                        //         return DropdownMenuItem<String>(
                        //           value: value,
                        //           child: Text(value),
                        //         );
                        //       }).toList(),
                        //       onChanged: (val) => setState(() => _fuelType = val),
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "ชนิด:",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: _buildDropdown(
                                label: "ประเภทน้ำมัน",
                                value: _fuelType,
                                items: Options.ListGas,
                                icon: Icons.local_gas_station, // ใส่ไอคอนที่นี่
                                onChanged: (val) =>
                                    setState(() => _fuelType = val),
                                isOnlyDropdown: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Premium",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Switch(
                              value: _isPremium,
                              // activeColor: Colors.p, // สีตอนเปิดให้ดูพรีเมียม
                              onChanged: (val) {
                                setState(() => _isPremium = val);
                              },
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                        // const Divider(color: Colors.white24),
                        _buildTextField(
                          "หมายเหตุ",
                          _remarkController,
                          Icons.note_add_outlined,
                        ),

                        // TextFormField(
                        //   controller: _remarkController,
                        //   maxLines: 3, // ให้พิมพ์ได้หลายบรรทัด
                        //   style: const TextStyle(color: Colors.white),
                        //   decoration: const InputDecoration(
                        //     hintText: "อื่นๆเพิ่มเติม ( สภาพจราจร, สถานะรถ)",
                        //     hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                        //     border: InputBorder.none, // ไม่มีเส้นขอบกวนสายตาใน Card
                        //     icon: Icon(Icons.note_add_outlined, color: Colors.white70),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            // await FirebaseFirestore.instance
                            //     .collection('fill-ups')
                            //     .add({

                            //     });
                            final carId = widget.data['id'];
                            final datas = {
                              'createdAt': FieldValue.serverTimestamp(),
                              'authorId': user?.uid,
                              'carId': widget.data['id'],
                              'amount': _totalAmount,
                              'date_time': _selectedDateTime,
                              'liters': _litersController.text,
                              'location': _locationController.text,
                              'isPremium': _isPremium as bool,
                              'currentMiles': _odometerController.text,
                              'pricePerLiter': _pricePerLiterController.text,
                              'remark': _remarkController.text,
                              'total_price': _amountController.text,
                              'fuelType': _fuelType,
                              'station': _station,
                              '_fuelLevel': _fuelLevel * 10,
                            };
                            WriteBatch batch = FirebaseFirestore.instance
                                .batch();

                            // - เพิ่มข้อมูลในประวัติ (Sub-collection)
                            DocumentReference refuelRef = FirebaseFirestore
                                .instance
                                .collection('cars')
                                .doc(carId)
                                .collection('fill-ups')
                                .doc();
                            // batch.set(refuelRef, datas);
                            // - อัปเดตตัวเลข Sum ที่ตัวรถ (Master)
                            DocumentReference carRef = FirebaseFirestore
                                .instance
                                .collection('cars')
                                .doc(carId);
                            batch.update(carRef, {
                              'total_spent': FieldValue.increment(
                                double.tryParse(_amountController.text) ??
                                    _totalAmount,
                              ),
                              'last_mileage': max(
                                int.parse(widget.data['last_mileage']),
                                int.parse(_odometerController.text),
                              ),
                              'refuel_count': FieldValue.increment(1),
                              'allLites': FieldValue.increment(
                                int.tryParse(_litersController.text) ?? 0,
                              ), //
                            });

                            await batch.commit();

                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            print("Error: $e");
                          }
                        }
                      },
                      child: const Text(
                        "บันทึกข้อมูล",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon, // รับไอคอนเพิ่ม (Optional)
    bool isOnlyDropdown = false, // ถ้า true จะโชว์แค่ตัว Dropdown เพียวๆ
  }) {
    final currentValue = items.contains(value) ? value : items.first;

    // ส่วนประกอบหลักของ Dropdown
    Widget dropdown = DropdownButtonFormField<String>(
      value: currentValue,
      isExpanded: true,
      dropdownColor: const Color(0xFF2C5364),
      style: const TextStyle(color: Colors.white, fontSize: 16),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
      // ถ้าแสดงแค่ Dropdown อย่างเดียว ให้เอา Decoration ออก
      decoration: isOnlyDropdown
          ? const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            )
          : InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
              prefixIcon: icon != null
                  ? Icon(icon, color: Colors.white70, size: 20)
                  : null,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              // focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
            ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );

    return dropdown;
  }
}
