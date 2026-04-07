import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:list_app/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckList extends StatelessWidget {
  final String type;
  final bool requireDate;
  final List<Map<String, dynamic>> data;
  final Function(String) addText;
  final Function(int, String, Timestamp) setFieldDate;
  final bool showRemark;
  final Function(String) setRemark;
  final TextEditingController remarkController;

  const CheckList({
    super.key,
    required this.type,
    required this.requireDate,
    required this.data,
    required this.addText,
    required this.setFieldDate,
    required this.showRemark,
    required this.setRemark,
    required this.remarkController,
  });

  @override
  Widget build(BuildContext context) {
    bool isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    final pendingItems = requireDate
        ? data.where((item) => !item['isDone']).toList()
        : data;

    Map<String, List<dynamic>> completedGroups = {};
    if (requireDate)
      for (var item in data.where((item) => item['isDone'] == true)) {
        String dateKey = item['complete_date']
            .toDate()
            .toString(); // DateFormat('dd/MM/yyyy').format(item['complete_date']);
        completedGroups.putIfAbsent(dateKey, () => []).add(item);
      }
    final TextEditingController _controller = TextEditingController();
    final FocusNode _focusNode = FocusNode();
    void _addItem() {
      if (_controller.text.trim().isNotEmpty) {
        addText(_controller.text);
        _controller.clear();
        _focusNode.requestFocus();
      }
    }

    // print(data);
    // print(completedGroups);

    void setDate(unique, type) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2025),
        lastDate: DateTime(2200),
      );
      int ind = data.indexWhere((item) => item['create_date'] == unique);
      if (pickedDate != null)
        setFieldDate(ind, type, Timestamp.fromDate(pickedDate));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 16,
                      ),
                      // filled: true,
                      // fillColor: Colors.white,
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: const BorderSide(
                      //     color: AppColors.rand,
                      //     width: 2.0,
                      //   ),
                      //   borderRadius: BorderRadius.circular(8),
                      // ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      _addItem();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ...pendingItems.map((item) =>
            ...pendingItems.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setDate(item['create_date'], 'complete');
                    },
                    icon: Icon(
                      requireDate
                          ? Icons.circle
                          : !item['isDone']
                          ? Icons.circle_outlined
                          : Icons.check_circle_outline,
                      color: requireDate
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: isLightMode ? AppColors.gray : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        // side: BorderSide(
                        //   color: Theme.of(context).colorScheme.secondary
                        // ),
                      ),
                      child: ListTile(
                        title: Text(item['text']),
                        trailing: () {
                          if (requireDate) {
                            if (item['due_date'] == null)
                              return TextButton(
                                onPressed: () =>
                                    setDate(item['create_date'], 'due'),
                                child: Text(
                                  'เลือกวันครบกำหนด',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.blue,
                                  ),
                                ),
                              );
                            // DateTime date = DateTime.parse(item['due_date']);
                            // DateTime date = DateTime.fromMillisecondsSinceEpoch(item['due_date']);
                            DateTime date = item['due_date'].toDate();
                            // return Text('null');
                            return TextButton(
                              onPressed: () =>
                                  setDate(item['create_date'], 'due'),
                              child: Text(
                                DateFormat(
                                  date.year == DateTime.now().year
                                      ? 'dd MMM'
                                      : 'dd MMM yyyy',
                                ).format(date),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.pink,
                                ),
                              ),
                            );
                            // return TextButton(
                            //     onPressed: () => setDueDate(index),
                            //     child: Text(
                            //   DateFormat(
                            //     item['due_date'].year == DateTime.now().year
                            //         ? 'dd MMM'
                            //         : 'dd MMM yyyy',
                            //   ).format(item['due_date']),
                            //       style: TextStyle(
                            //         fontSize: 12,
                            //         color: AppColors.pink,
                            //       ), )
                            // );
                          } else {
                            if (item['complete_date'] == null) return null;
                            DateTime date = item['complete_date'].toDate();
                            return TextButton(
                              onPressed: () =>
                                  setDate(item['create_date'], 'complete_date'),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(date),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                            // const SizedBox.shrink();
                          }
                        }(),
                      ),
                    ),
                  ),
                ],
              );
            }),

            if (requireDate) const Divider(height: 40),
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
                      DateFormat(
                        'dd MMM yyyy',
                      ).format(DateTime.parse(group.key)),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  ...group.value.map(
                    (item) => Card(
                      // color: Theme.of(context).cardColor,
                      color: AppColors.gray,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        // side: BorderSide(
                        //   color: Theme.of(context).colorScheme.secondary
                        // ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Text(item['text']),
                        //  decoration: TextDecoration.lineThrough,
                        trailing: () {
                          if (item['due_date'] != null)
                            return Text(
                              DateFormat(
                                'dd MMM yyyy',
                              ).format(item['due_date'].toDate()),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.blue,
                              ),
                            );
                          return null;
                        }(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
            const SizedBox(height: 10),
            if (showRemark)
              TextField(
                maxLines: 5,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'หมายเหตุ',
                  border: OutlineInputBorder(),
                ),
                controller: remarkController,
              ),
          ],
        ),
      ),
    );
  }
}
