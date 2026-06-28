import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FuelLogPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String carId;
  const FuelLogPage({super.key, required this.data, required this.carId});
  @override
  State<FuelLogPage> createState() => _FuelLogPageState();
}

class _FuelLogPageState extends State<FuelLogPage> {
  final user = FirebaseAuth.instance.currentUser;
  String _filterMode = '12_months';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.data['car_name'])),
      body: Column(
        children: [
          // _buildFilterSegment(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cars')
                  .doc(widget.carId)
                  .collection('fill-ups')
                  .orderBy('date_time', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                  );
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('ไม่มีข้อมูลการเติมน้ำมัน'));
                }

                // แปลงข้อมูลจาก Firebase เป็น List ของตัวแปรที่คำนวณแล้ว
                final allData = _processAndFilterData(snapshot.data!.docs);

                if (allData.isEmpty) {
                  return const Center(
                    child: Text('ไม่มีข้อมูลในช่วงเวลาที่เลือก'),
                  );
                }

                // คำนวณยอดสรุป (Summary) ของข้อมูลที่ผ่านการกรองแล้ว
                final totalCount = allData.length;
                final validAvgList = allData
                    .where((item) => item['avg'] != null)
                    .map((item) => item['avg'] as double);
                final totalAvg = validAvgList.isNotEmpty
                    ? validAvgList.reduce((a, b) => a + b) / validAvgList.length
                    : 0.0;

                return Column(
                  children: [
                    // ส่วนแสดงสรุปผลรวม (Summary Card)
                    _buildSummaryCard(totalCount, totalAvg),

                    Expanded(
                      child: ListView.builder(
                        itemCount: allData.length,
                        // แสดงจากใหม่ไปเก่าในหน้าจอ (กลับด้านเพื่อให้ตัวล่าสุดอยู่บนสุด)
                        itemBuilder: (context, index) {
                          final item = allData[allData.length - 1 - index];
                          return _buildDataRow(item);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSegment() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: '12_months',
            label: Text('12 เดือนล่าสุด'),
            icon: Icon(Icons.calendar_month),
          ),
          ButtonSegment(
            value: 'yearly',
            label: Text('รายปีที่มีข้อมูล'),
            icon: Icon(Icons.analytics),
          ),
        ],
        selected: {_filterMode},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _filterMode = newSelection.first;
          });
        },
      ),
    );
  }

  // ส่วนการประมวลผลคำนวณค่า Avg และคัดกรองวันที่
  List<Map<String, dynamic>> _processAndFilterData(
    List<QueryDocumentSnapshot> docs,
  ) {
    List<Map<String, dynamic>> processedList = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < docs.length; i++) {
      final data = docs[i].data() as Map<String, dynamic>;
    print(data);

      DateTime date = (data['date_time'] as Timestamp).toDate();
      double mile =
          double.tryParse(data['currentMiles']) ??
          0; // (data['currentMiles'] as num).toDouble();
      double price = double.tryParse(data['pricePerLiter']) ?? 0;
      double liters = double.tryParse(data['liters']) ?? 0;

      double? avg;
      if (i > 0) {
        // สูตร: (ไมล์ครั้งนี้ - ไมล์ครั้งก่อน) / จำนวนลิตรครั้งนี้
        double prevMile =
            double.tryParse(
              (docs[i - 1].data() as Map<String, dynamic>)['currentMiles'],
            ) ??
            0;
        if (liters > 0) {
          avg = (mile - prevMile) / liters;
        }
      }

      // ตรวจสอบเงื่อนไขการกรองเวลา
      bool isIncluded = false;
      if (_filterMode == '12_months') {
        // หาเฉพาะข้อมูลที่อยู่ในช่วง 365 วันที่ผ่านมา
        DateTime twelveMonthsAgo = now.subtract(const Duration(days: 365));
        if (date.isAfter(twelveMonthsAgo)) isIncluded = true;
      } else {
        // รายปีที่มีข้อมูล (ในที่นี้คือเอาทั้งหมดที่เก็บไว้ในระบบมาแสดง)
        isIncluded = true;
      }

      if (isIncluded) {
        processedList.add({
          'date': date,
          'mile': mile,
          'price': price,
          'avg': avg, // ครั้งแรกสุดของระบบจะเป็น null
          'total_price':   (data['amount'] ?? 0 as num).toDouble()
          // 'total_price':   double.tryParse(data['total_price']) ?? 0
        });
      }
    }
    return processedList;
  }

  // ส่วนแสดงการสรุปผลด้านบน
  Widget _buildSummaryCard(int totalCount, double totalAvg) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
              
                Text(
                  '$totalCount ครั้ง',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade400),
            Column(
              children: [
                const Text(
                  'ประหยัดเฉลี่ยรวม',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '${totalAvg.toStringAsFixed(2)} กม./ลิตร',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ส่วนแสดงผลแต่ละแถวใน ListView
  Widget _buildDataRow(Map<String, dynamic> item) {
    String formattedDate = DateFormat('dd MMM yyyy').format(item['date']);
    double mile = item['mile'];
    double price = item['price'];
    double? avg = item['avg'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text('เลขไมล์: ${mile.toStringAsFixed(0)} กม.'),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text(
                  // '฿${price.toStringAsFixed(0)}',
                  '฿${item['total_price'].toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16, color: Colors.orange ),
                ),
                Row(
                  children: [
                    const Text(
                      'เฉลี่ย: ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      avg != null ? '${avg.toStringAsFixed(2)} km/l' : '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: avg == null ? Colors.black : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
