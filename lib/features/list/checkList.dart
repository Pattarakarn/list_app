import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckList extends StatelessWidget {
  final String type;
  final bool requireDate;
  final List<Map<String, dynamic>> data;

  const CheckList({
    super.key,
    required this.type,
    required this.requireDate,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // 1. แยกรายการที่ยังไม่ได้ทำ
    final pendingItems = []; //data.where((item) => !item.isDone).toList();

    // 2. แยกรายการที่ทำเสร็จแล้ว และจัดกลุ่มตามวันที่ (YYYY-MM-DD)
    Map<String, List<dynamic>> completedGroups = {};
    // for (var item in  data.data.where((item) => item.isDone)) {
    //   String dateKey = DateFormat('dd/MM/yyyy').format(item.completedDate!);
    //   completedGroups.putIfAbsent(dateKey, () => []).add(data);
    // }
    final TextEditingController _controller = TextEditingController();
    final FocusNode _focusNode = FocusNode();
    void _addItem() {
      if (_controller.text.trim().isNotEmpty) {
        // setState(() {
        //   _items.add(_controller.text.trim());
        //   _controller.clear();
        // });

        _focusNode.requestFocus();
      }
    }

    return Scaffold(
      body: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: "Text List!",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        // color: AppColors.rand,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    _addItem();
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => {},
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...pendingItems.map(
            (item) => Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
              child: const ListTile(
                leading: Icon(Icons.checklist, color: Colors.blue),
                // title: Text(item.title),
                // แสดงวันที่ด้านขวา ถ้ามี requireDate
                // trailing: requireDate
                //     ? Text(DateFormat('dd MMM').format(item.requireDate!),
                //         style: const TextStyle(fontSize: 12, color: Colors.grey))
                //     : null,
              ),
            ),
          ),

          // const Divider(height: 40),
          ...completedGroups.entries.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    group.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...group.value.map(
                  (item) => const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(
                      'item.title',
                      style: TextStyle(decoration: TextDecoration.lineThrough),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
