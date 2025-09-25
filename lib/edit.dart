import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_list/data.dart';
import 'package:task_list/main.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.task.name,
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.surface,
        foregroundColor: themeData.colorScheme.onSurface,
        title: Text('Edit Task'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.task.name = _controller.text;
          if (widget.task.isInBox) {
            widget.task.save();
          } else {
            final box = Hive.box<Task>(taskBoxName);
            box.add(widget.task);
          }
          Navigator.of(context).pop();
        },
        label: Row(
          children: [
            Text('Save Changes'),
            SizedBox(width: 4),
            Icon(CupertinoIcons.checkmark, size: 20),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 1,
                  child: PriorityItem(
                    label: 'High',
                    color: highPriority,
                    isSelected: widget.task.priority == Priority.high,
                    onTap: () {
                      setState(() {
                        widget.task.priority = Priority.high;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: PriorityItem(
                    label: 'Normal',
                    color: normalPriority,
                    isSelected: widget.task.priority == Priority.normal,
                    onTap: () {
                      setState(() {
                        widget.task.priority = Priority.normal;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: PriorityItem(
                    label: 'Low',
                    color: lowPriority,
                    isSelected: widget.task.priority == Priority.low,
                    onTap: () {
                      setState(() {
                        widget.task.priority = Priority.low;
                      });
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                enableSuggestions: false,
                decoration: InputDecoration(
                  label: Text(
                    'Add a task for today...',
                    style: TextStyle(color: primaryTextColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriorityItem extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final GestureTapCallback onTap;

  const PriorityItem({
    super.key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(width: 2, color: secondaryTextColor.withAlpha(50)),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: PriorityCheckBox(value: isSelected, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriorityCheckBox extends StatelessWidget {
  final bool value;
  final Color color;

  const PriorityCheckBox({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color),
      child: value
          ? Icon(CupertinoIcons.checkmark_alt, color: Colors.white, size: 14)
          : null,
    );
  }
}
