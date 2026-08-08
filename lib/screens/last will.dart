import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WillPage extends StatefulWidget {
  @override
  State<WillPage> createState() => _WillPageState();
}

class _WillPageState extends State<WillPage> {
  bool unlocked = false;
  bool _isDataInitialized = false;
  String? _currentDocId;
  final TextEditingController guessController = TextEditingController();

  void checkPassword(String realCode) {
    if (guessController.text == realCode) {
      setState(() {
        unlocked = true;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("รหัสไม่ถูกต้อง")));
    }
  }

  final user = FirebaseAuth.instance.currentUser;
  final noteController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // 1. Controllers สำหรับจัดการ Dynamic Fields
  final List<TextEditingController> _emailControllers = [
    // TextEditingController(),
  ];

  final List<Map<String, TextEditingController>> _bankControllers = [
    // {
    //   'accNo': TextEditingController(),
    //   'accName': TextEditingController(),
    //   'branch': TextEditingController(),
    //   'appUsername': TextEditingController(),
    // },
  ];

  final List<Map<String, TextEditingController>> _assetControllers = [
    // {
    //   'name': TextEditingController(),
    //   'initialAmount': TextEditingController(),
    //   'currentAmount': TextEditingController(),
    // },
  ];

  final List<Map<String, dynamic>> _insuranceControllers = [
    // {
    //   'companyPlan': TextEditingController(),
    //   'startDate': TextEditingController(),
    //   'endDate': TextEditingController(),
    //   'paymentType': 'รายเดือน', // ค่าเริ่มต้น
    //   'premium': TextEditingController(),
    //   'coverage': TextEditingController(),
    // },
  ];

  // 2. ข้อมูลลับ (Credentials) และระบบล็อก
  final List<Map<String, TextEditingController>> _credentialControllers = [];
  final TextEditingController _unlockPasswordController =
      TextEditingController();
  bool _isCredentialsUnlocked = false;

  // --- ฟังก์ชันเพิ่ม/ลบ สำหรับ Dynamic Fields ---
  void _addEmail() =>
      setState(() => _emailControllers.add(TextEditingController()));

  void _addBank() => setState(
    () => _bankControllers.add({
      'accNo': TextEditingController(),
      'accName': TextEditingController(),
      'branch': TextEditingController(),
      'appUsername': TextEditingController(),
    }),
  );

  void _addCredential() {
    if (_credentialControllers.isEmpty) {
      _isCredentialsUnlocked = !false;
    }
    setState(() {
      _credentialControllers.add({
        'appTool': TextEditingController(),
        'password': TextEditingController(),
      });
    });
  }

  void _addAsset() => setState(
    () => _assetControllers.add({
      'name': TextEditingController(),
      'initialAmount': TextEditingController(),
      'currentAmount': TextEditingController(),
    }),
  );

  void _addInsurance() => setState(
    () => _insuranceControllers.add({
      'companyPlan': TextEditingController(),
      'startDate': TextEditingController(),
      'endDate': TextEditingController(),
      'paymentType': 'รายเดือน',
      'premium': TextEditingController(),
      'coverage': TextEditingController(),
    }),
  );

  final List<Map<String, TextEditingController>> _phoneControllers = [];
  void _addPhone() {
    setState(() {
      _phoneControllers.add({
        'phoneNumber': TextEditingController(),
        'network': TextEditingController(),
      });
    });
  }

  Future<void> _saveToFirebase() async {
    try {
      List<String> emails = _emailControllers
          .map((c) => c.text)
          .where((t) => t.isNotEmpty)
          .toList();

      List<Map<String, dynamic>> banks = _bankControllers
          .map(
            (b) => {
              'accNo': b['accNo']!.text,
              'accName': b['accName']!.text,
              'branch': b['branch']!.text,
              'appUsername': b['appUsername']!.text,
            },
          )
          .toList();

      List<Map<String, dynamic>> assets = _assetControllers
          .map(
            (a) => {
              'name': a['name']!.text,
              'initialAmount': double.tryParse(a['initialAmount']!.text) ?? 0.0,
              'currentAmount': double.tryParse(a['currentAmount']!.text) ?? 0.0,
            },
          )
          .toList();

      List<Map<String, dynamic>> credentials = _credentialControllers
          .map(
            (c) => {
              'appTool': c['appTool']!.text,
              'password': c['password']!.text,
            },
          )
          .toList();

      List<Map<String, dynamic>> insurances = _insuranceControllers
          .map(
            (i) => {
              'companyPlan': i['companyPlan']!.text,
              'startDate': i['startDate']!.text,
              'endDate': i['endDate']!.text,
              'paymentType': i['paymentType'],
              'premium': double.tryParse(i['premium']!.text) ?? 0.0,
              'coverage': double.tryParse(i['coverage']!.text) ?? 0.0,
            },
          )
          .toList();

      List<Map<String, dynamic>> phones = _phoneControllers
          .map(
            (p) => {
              'phoneNumber': p['phoneNumber']?.text ?? '',
              'network': p['network']?.text ?? '',
            },
          )
          .where(
            (item) => item['phoneNumber'].toString().trim().isNotEmpty,
          ) // กรองทิ้งถ้าไม่ยอมกรอกเบอร์โทร
          .toList();

      Map<String, dynamic> finalData = {
        'emails': emails,
        'phones': phones,
        'banks': banks,
        'credentials': credentials,
        'assets': assets,
        'insurances': insurances,
        'note': noteController.text,
        'created_at': DateTime.now(),
      };

      if (_currentDocId == null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('Testament')
            .add(finalData);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('Testament')
            .doc(_currentDocId)
            .set(
              {...finalData, 'updated_at': FieldValue.serverTimestamp()},
              SetOptions(merge: true),
            ); // merge: true ป้องกันข้อมูลฟิลด์อื่นๆ ที่ไม่ได้แก้โดนลบหาย
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('🔄 อัปเดตข้อมูลสำเร็จ!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  // ฟังก์ชันเช็ครหัสผ่านปลดล็อก โดยเทียบกับ "ทุกรหัสที่มีอยู่ในชุดข้อมูล"
  void _checkUnlockCredentials() {
    String input = _unlockPasswordController.text;

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ กรุณากรอกรหัสผ่านเพื่อเดา')),
      );
      return;
    }

    bool isMatched = _credentialControllers.any((cred) {
      final controller = cred['password'];

      return controller != null && controller.text == input;
    });

    if (isMatched) {
      setState(() {
        _isCredentialsUnlocked = true;
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ รหัสผ่านไม่ตรงกับข้อมูลใดๆ ในระบบ ลองใหม่นะ'),
        ),
      );
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    void initData(datas) {
      for (var phone in datas['phones']) {
        _phoneControllers.add({
          'phoneNumber': TextEditingController(
            text: phone['phoneNumber']?.toString() ?? '',
          ),
          'network': TextEditingController(
            text: phone['network']?.toString() ?? '',
          ),
        });
      }
      for (var mail in datas['emails']) {
        _emailControllers.add(
          TextEditingController(text: mail?.toString() ?? ''),
        );
      }
      for (var b in datas['banks']) {
        _bankControllers.add({
          'accNo': TextEditingController(text: b['accNo']?.toString() ?? ''),
          'accName': TextEditingController(
            text: b['accName']?.toString() ?? '',
          ),
          'branch': TextEditingController(text: b['branch']?.toString() ?? ''),
          'appUsername': TextEditingController(
            text: b['appUsername']?.toString() ?? '',
          ),
        });
      }

      for (var c in datas['credentials']) {
        _credentialControllers.add({
          'appTool': TextEditingController(
            text: c['appTool']?.toString() ?? '',
          ),
          'password': TextEditingController(
            text: c['password']?.toString() ?? '',
          ),
        });
      }

      for (var a in datas['assets']) {
        _assetControllers.add({
          'name': TextEditingController(text: a['name']?.toString() ?? ''),
          'initialAmount': TextEditingController(
            text: a['initialAmount']?.toString() ?? '',
          ),
          'currentAmount': TextEditingController(
            text: a['currentAmount']?.toString() ?? '',
          ),
        });
      }

      for (var i in datas['insurances']) {
        _insuranceControllers.add({
          'companyPlan': TextEditingController(
            text: i['companyPlan']?.toString() ?? '',
          ),
          'startDate': TextEditingController(
            text: i['startDate']?.toString() ?? '',
          ),
          'endDate': TextEditingController(
            text: i['endDate']?.toString() ?? '',
          ),
          'paymentType': i['paymentType']?.toString(),
          'premium': TextEditingController(
            text: i['premium']?.toString() ?? '',
          ),
          'coverage': TextEditingController(
            text: i['coverage']?.toString() ?? '',
          ),
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("${user?.displayName}")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('Testament')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs[0].data() as Map<String, dynamic>;

          noteController.text = data['note'] ?? '';

          if (!_isDataInitialized) {
            initData(data);
            _isDataInitialized = true;
            _currentDocId = snapshot.data!.docs[0].id;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📱 ข้อมูลเบอร์โทรศัพท์',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 28,
                      ), // ใช้ไอคอนเส้นขอบธรรมดา
                      onPressed: _addPhone,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ..._phoneControllers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var phone = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2, // ให้ช่องเบอร์โทรยาวกว่านิดหน่อย
                          child: TextFormField(
                            controller: phone['phoneNumber'],
                            keyboardType: TextInputType
                                .phone, 
                            decoration: InputDecoration(
                              // labelText: 'เบอร์โทรศัพท์ ที่ ${idx + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1, // ช่องเครือข่ายสั้นกว่า
                          child: TextFormField(
                            controller: phone['network'],
                            decoration: InputDecoration(
                              labelText: 'เครือข่าย / โน้ต',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    // เปลี่ยนจาก ListView เป็น Column ตรงนี้!
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    // ListView(  padding: const EdgeInsets.all(16.0),
                    children: [
                      // --- 1. ข้อมูลอีเมล์ ---
                      _buildSectionHeader('📧 อีเมล์', Colors.blue, _addEmail),
                      ..._emailControllers.asMap().entries.map((entry) {
                        int idx = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              // labelText: 'อีเมล์ที่ ${idx + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        );
                      }),
                      const Divider(height: 32),

                      // --- 2. ข้อมูลธนาคาร ---
                      _buildSectionHeader(
                        '🏦 ข้อมูลธนาคาร',
                        Colors.green,
                        _addBank,
                      ),
                      ..._bankControllers.map(
                        (bank) => Card(
                          color:
                              data['banks'].any(
                                (d) => d['accNo'] == bank['accNo']?.text,
                              )
                              ? Theme.of(context).scaffoldBackgroundColor
                              : Colors.green.shade50,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: bank['accName'],
                                        decoration: const InputDecoration(
                                          labelText: 'ธ.',
                                        ),
                                        style: TextStyle(
                                          color:
                                              data['banks'].any(
                                                (d) =>
                                                    d['accNo'] ==
                                                    bank['accNo']?.text,
                                              )
                                              ? Theme.of(
                                                  context,
                                                ).scaffoldBackgroundColor
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: bank['branch'],
                                        decoration: const InputDecoration(
                                          labelText: 'สาขา',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: bank['accNo'],
                                        decoration: const InputDecoration(
                                          labelText: 'เลขบัญชี',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: bank['appUsername'],
                                        decoration: const InputDecoration(
                                          labelText: 'Username ของแอป',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 32),

                      // --- 3. ข้อมูลลับ (Credentials) ที่ต้องกรอกรหัสปลดล็อกก่อน ---
                      Card(
                        color: Theme.of(
                          context,
                        ).scaffoldBackgroundColor, //Colors.amber.shade50,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.amber.shade600,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // หัวข้อและปุ่มเพิ่ม (ปุ่มจะกดได้ก็ต่อเมื่อ มี 0 ข้อมูล หรือ ปลดล็อกแล้วเท่านั้น)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '🔒 Credentials',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  if (_credentialControllers.isEmpty ||
                                      _isCredentialsUnlocked)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: Colors.amber,
                                        size: 28,
                                      ),
                                      onPressed: _addCredential,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // CASE 1: มีข้อมูล > 0 และยังไม่ได้ปลดล็อก -> บังคับใส่รหัสก่อน
                              if (_credentialControllers.isNotEmpty &&
                                  !_isCredentialsUnlocked)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'มีข้อมูลลับบันทึกอยู่ ${_credentialControllers.length} รายการ กรุณาใส่รหัสผ่านตัวใดตัวหนึ่งในชุดข้อมูลนี้เพื่อเปิดดูหรือแก้ไข',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _unlockPasswordController,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  'กรอกรหัสผ่านที่เคยบันทึกไว้...',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: _checkUnlockCredentials,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.amber,
                                          ),
                                          child: const Text('ปลดล็อก'),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              // CASE 2: ยังไม่มีข้อมูลเลย (0 ข้อมูล) หรือ ปลดล็อกรหัสผ่านแล้ว -> แสดง List ให้พิมพ์/ดูได้
                              else ...[
                                // if (_credentialControllers.isEmpty)
                                //   const Padding(
                                //     padding: EdgeInsets.symmetric(
                                //       vertical: 8.0,
                                //     ),
                                //     child: Text(
                                //       'ยังไม่มีข้อมูลลับ กดปุ่ม + ด้านบนเพื่อเพิ่มข้อมูลชุดแรกได้ทันที',
                                //       style: TextStyle(color: Colors.grey),
                                //     ),
                                //   ),

                                ..._credentialControllers.asMap().entries.map((
                                  entry,
                                ) {
                                  int idx = entry.key;
                                  var cred = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: cred['appTool'],
                                            decoration: InputDecoration(
                                              hintText:
                                                  'กรอกชื่อแอป/เครื่องมือ',
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: cred['password'],
                                            decoration: InputDecoration(
                                              labelText:
                                                  'รหัสผ่าน ที่ ${idx + 1}',
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 32),

                      // --- 4. ข้อมูลทรัพย์สิน ---
                      _buildSectionHeader(
                        '💰 ทรัพย์สิน',
                        Colors.purple,
                        _addAsset,
                      ),
                      ..._assetControllers.map(
                        (asset) => Card(
                          color: Colors.purple.shade50,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: asset['name'],
                                    decoration: const InputDecoration(
                                      labelText: 'ชื่อทรัพย์สิน',
                                    ),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: asset['initialAmount'],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'ยอดเต็ม',
                                    ),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: asset['currentAmount'],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'ยอดคงเหลือ',
                                    ),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 32),

                      // --- 5. ข้อมูลประกัน ---
                      _buildSectionHeader(
                        '🛡️ ข้อมูลประกัน',
                        Colors.teal,
                        _addInsurance,
                      ),
                      ..._insuranceControllers.map(
                        (ins) => Card(
                          color: Colors.teal.shade50,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: ins['companyPlan'],
                                  decoration: const InputDecoration(
                                    labelText: 'บริษัท / แผน',
                                  ),
                                  style: TextStyle(color: Colors.black),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: ins['startDate'],
                                        decoration: const InputDecoration(
                                          labelText: 'เริ่ม',
                                        ),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: ins['endDate'],
                                        decoration: const InputDecoration(
                                          labelText: 'สิ้นสุด',
                                        ),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: ins['paymentType'],
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'รายเดือน',
                                            child: Text('รายเดือน'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'รายปี',
                                            child: Text('รายปี'),
                                          ),
                                        ],
                                        onChanged: (val) => setState(
                                          () => ins['paymentType'] = val,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'รอบบิล',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: ins['premium'],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'จำนวน',
                                        ),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: ins['coverage'],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'กรณีเสียชีวิต',
                                        ),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: noteController,
                  // onChanged: (value) {
                  //   data[''] = int.parse(value);
                  // },
                  minLines: 3,
                  maxLines: 15,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'หมายเหตุเพิ่มเติม',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "บันทึกข้อมูล",
                      // style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    onPressed: () async {
                      _saveToFirebase();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    Color color,
    VoidCallback onAddPressed,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle, color: color, size: 28),
          onPressed: onAddPressed,
        ),
      ],
    );
  }
}
