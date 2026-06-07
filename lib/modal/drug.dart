import 'package:flutter/material.dart';
import 'package:list_app/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddDrugDialog extends StatefulWidget {
  const AddDrugDialog({super.key});

  @override
  State<AddDrugDialog> createState() => _AddDrugDialogState();
}

class _AddDrugDialogState extends State<AddDrugDialog> {
  // สร้าง Controller สำหรับรับค่าตัวหนังสือ
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final amountController = TextEditingController();
  final doseController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  String mealTime = 'หลังอาหาร'; // 'ก่อนอาหาร' หรือ 'หลังอาหาร'
  Map<String, bool> schedule = {
    'เช้า': false,
    'กลางวัน': false,
    'เย็น': false,
    'ก่อนนอน': false,
  };
  DateTime? expiryDate;

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'เพิ่มข้อมูลยา',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      scrollable: true,
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ชื่อยา'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
              ),
              // TextField(
              //   controller: amountController,
              //   decoration: const InputDecoration(labelText: 'จำนวนเม็ดต่อแผง'),
              //   keyboardType: TextInputType.number,
              // ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // ช่องปริมาณ (มก.)
                  Expanded(
                    child: TextField(
                      controller:
                          doseController, // อย่าลืมประกาศ Controller นี้ด้านบน
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ปริมาณยา',
                        suffixText: 'มก.',
                        hintText: 'เช่น 500',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // ระยะห่างระหว่าง 2 ช่อง
                  // ช่องจำนวนเม็ด/แผง
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'จำนวน',
                        suffixText: 'เม็ด/แผง',
                        hintText: 'เช่น 10',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              const Text(
                'เวลา:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio(
                    value: 'beforemeal',
                    groupValue: mealTime,
                    onChanged: (v) => setState(() => mealTime = v!),
                    activeColor: Colors.blue,
                  ),
                  const Text('ก่อนอาหาร'),
                  Radio(
                    value: 'aftermeal',
                    groupValue: mealTime,
                    onChanged: (v) => setState(() => mealTime = v!),
                    activeColor: Colors.blue,
                  ),
                  const Text('หลังอาหาร'),
                  Radio(
                    value: 'whenneed',
                    groupValue: mealTime,
                    onChanged: (v) => setState(() => mealTime = v!),
                    activeColor: Colors.blue,
                  ),
                  const Text('เมื่อมีอาการ'),
                ],
              ),

              const Text(
                'ช่วงเวลา:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                children: schedule.keys.map((String key) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: schedule[key],
                        onChanged: (bool? value) =>
                            setState(() => schedule[key] = value!),
                      ),
                      Text(key),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  expiryDate == null
                      ? 'เลือกวันหมดอายุ'
                      : 'หมดอายุ: ${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}',
                ),
                trailing: const Icon(
                  Icons.calendar_month,
                  color: AppColors.secondary,
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) setState(() => expiryDate = picked);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final drugData = {
                    'name': nameController.text,
                    'desc': descController.text,
                    'amount': double.tryParse(amountController.text),
                    'dose': double.tryParse(doseController.text),
                    'mealTime': mealTime,
                    'schedule': schedule,
                    'expiry': expiryDate,
                    'created_at': DateTime.now(),
                  };
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('drugs')
                      .add(drugData);
                  Navigator.pop(context, drugData);
                },
                child: const Text('สร้าง'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
