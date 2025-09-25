import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_list/data.dart';
import 'package:task_list/edit.dart';

const taskBoxName = 'tasks';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>(taskBoxName);
  runApp(const MyApp());
}

const primaryColor = Color(0xff794CFF);
const primaryVariantColor = Color(0xff5C0AFF);
const primaryTextColor = Color(0xff1D2830);
const secondaryTextColor = Color(0xffAFBED0);
const lowPriority = Color(0xff3BE1F1);
const normalPriority = Color(0xffF09819);
const highPriority = primaryColor;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(color: secondaryTextColor),
          prefixIconColor: secondaryTextColor,
          border: InputBorder.none,
        ),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: primaryTextColor,
          secondary: primaryVariantColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> searchNotifier = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>(taskBoxName);
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Color(0xffF3F5F8),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => EditTaskScreen(task: Task())));
        },
        label: Row(
          children: [
            Text('Add New Task'),
            SizedBox(width: 4),
            Icon(CupertinoIcons.add, size: 20),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeData.colorScheme.secondary, themeData.colorScheme.primary],
              ),
            ),
          ),
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeData.colorScheme.primary, themeData.colorScheme.secondary],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'To Do List',
                        style: TextStyle(
                          color: themeData.colorScheme.surface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Icon(CupertinoIcons.share, color: themeData.colorScheme.surface),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 38,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.surface,
                      borderRadius: BorderRadius.circular(19),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 20),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        searchNotifier.value = controller.text;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(CupertinoIcons.search),
                        label: Text('Search Tasks...'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: searchNotifier,
              builder: (context, value, child) {
                return ValueListenableBuilder<Box<Task>>(
                  valueListenable: box.listenable(),
                  builder: (context, box, child) {
                    final List<Task> items;
                    if (controller.text.isEmpty) {
                      items = box.values.toList();
                    } else {
                      items = box.values
                          .where((task) => task.name.contains(controller.text))
                          .toList();
                    }
                    if (items.isNotEmpty) {
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: items.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Today',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 3,
                                      margin: EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(1.5),
                                      ),
                                    ),
                                  ],
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    box.clear();
                                  },
                                  color: Color(0xffEAEFF5),
                                  textColor: secondaryTextColor,
                                  elevation: 0,
                                  child: Row(
                                    children: [
                                      Text('Delete All'),
                                      SizedBox(width: 4),
                                      Icon(CupertinoIcons.delete_solid, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            final Task task = items.toList()[index - 1];
                            return TaskItem(task: task, themeData: themeData);
                          }
                        },
                      );
                    } else {
                      return EmptyState();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/empty_state.svg', width: 150),
        SizedBox(height: 12),
        Text('Your task list is empty'),
      ],
    );
  }
}

class TaskItem extends StatefulWidget {
  static const double height = 74;
  static const double borderRadius = 8;
  final Task task;
  final ThemeData themeData;

  const TaskItem({super.key, required this.task, required this.themeData});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final Color priorityColor;
    switch (widget.task.priority) {
      case Priority.low:
        priorityColor = lowPriority;
        break;
      case Priority.normal:
        priorityColor = normalPriority;
        break;
      case Priority.high:
        priorityColor = highPriority;
        break;
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => EditTaskScreen(task: widget.task)),
        );
      },
      onLongPress: () {
        widget.task.delete();
      },
      child: Container(
        height: TaskItem.height,
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: widget.themeData.colorScheme.surface,
          borderRadius: BorderRadius.circular(TaskItem.borderRadius),
        ),
        child: Row(
          children: [
            MyCheckBox(
              value: widget.task.isCompleted,
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                });
              },
              themeData: widget.themeData,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  decoration: widget.task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: 5,
              height: TaskItem.height,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(TaskItem.borderRadius),
                  bottomRight: Radius.circular(TaskItem.borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final bool value;
  final GestureTapCallback onTap;
  final ThemeData themeData;

  const MyCheckBox({
    super.key,
    required this.value,
    required this.onTap,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: !value ? Border.all(color: secondaryTextColor, width: 2) : null,
          color: value ? primaryColor : null,
        ),
        child: value
            ? Icon(
                CupertinoIcons.checkmark_alt,
                color: themeData.colorScheme.onPrimary,
                size: 18,
              )
            : null,
      ),
    );
  }
}
