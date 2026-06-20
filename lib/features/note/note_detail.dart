import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app_colors.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String docId;

  const DetailPage({super.key, required this.title, required this.docId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isInitialized = false;
  String name = '';
  String content = '';
  bool isLock = false;
  String _update = '';
  List<Map<String, dynamic>> conversation = [];

  void _updateData() async {
    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.docId)
          .update({
            'name': name,
            'content': content,
            'lock': isLock,
            'updatedAt': FieldValue.serverTimestamp(),
            'conversation': conversation,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('บันทึกข้อมูลสำเร็จ!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.of(context).size.width * 0.9,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      //  Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.docId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('เกิดข้อผิดพลาด'));
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!isInitialized) {
          // var docData = snapshot.data?.data() as Map<String, String>?;
          var docData = snapshot.data!.data() as Map<String, dynamic>?;
          print(docData);
          if (docData != null) {
            name = docData['name'];
            content = docData['content'];
            isLock = docData['lock'];
            if (docData['updatedAt'] is Timestamp)
              _update = DateFormat(
                'dd MMM yyyy',
              ).format(docData['updatedAt'].toDate());

            print(conversation);
            if (docData['conversation'] != null) {
              print(docData['conversation']);
              conversation = List<Map<String, dynamic>>.from(
                (docData['conversation'] as List).map(
                  (item) => Map<String, dynamic>.from(item),
                ),
              );
            }
          }
          isInitialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Note'),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(_update, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: name),
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ',
                    border: OutlineInputBorder(),
                    // filled: true,
                    // fillColor: AppColors.gray,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.gray, width: 1.0),
                    ),
                  ),
                  onChanged: (val) => name = val,
                ),
                const SizedBox(height: 10),
                // textarea
                TextField(
                  maxLines: 15,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Note here',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.gray, width: 1.0),
                    ),
                  ),
                  controller: TextEditingController(text: content),
                  onChanged: (val) => content = val,
                ),

                // RichText(
                //   text: TextSpan(
                //     style: TextStyle(color: Colors.black, fontSize: 18), // สไตล์หลัก
                //     children: [
                //       TextSpan(text: 'Hello '),
                //       TextSpan(
                //         text: 'Flutter',
                //         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                //       ),
                //       TextSpan(text: ' Developer!'),
                //     ],
                //   ),
                // ),
                for (int i = 0; i < conversation.length; i++) ...[
                  Builder(
                    builder: (context) {
                      var entry = conversation[i];
                      String val = conversation[i]['value'] ?? '';

                      return Container(
                        margin: EdgeInsets.fromLTRB(
                          entry['side'] == "right" ? 25 : 0,
                          10,
                          entry['side'] == "left" ? 25 : 0,
                          0,
                        ),
                        child: TextField(
                          maxLines: 10,
                          minLines: 3,
                          keyboardType: TextInputType.multiline,

                          decoration: InputDecoration(
                            border: OutlineInputBorder(),

                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.gray,
                                width: 1.0,
                              ),
                            ),
                          ),
                          controller: TextEditingController(text: val),
                          onChanged: (val) => {
                            setState(() {
                              conversation[i]['value'] = val;
                            }),
                          },
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          conversation.add({'value': "", 'side': "left"});
                        });
                      },
                      child: const Icon(Icons.add, color: Colors.grey),
                    ),

                    TextButton(
                      child: const Icon(Icons.add, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          conversation.add({'value': "", 'side': "right"});
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: isKeyboardOpen
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      // width: 65,
                      // height: 65,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: FloatingActionButton(
                          heroTag: "Lock",
                          onPressed: () {
                            // isLock = !isLock;
                            setState(() => isLock = !isLock);
                            print("สถานะตอนนี้: $isLock");
                          },
                          backgroundColor: isLock
                              ? AppColors.primary
                              : AppColors.note,
                          child: Icon(
                            isLock == true ? Icons.lock : Icons.lock_open,
                            color: AppColors.gray,
                            // key: ValueKey(isLock),
                          ),
                          elevation: 2, // เงาจางๆ
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                    // const SizedBox(width: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: FloatingActionButton.extended(
                        onPressed: _updateData,
                        // icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        heroTag: "save",
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
