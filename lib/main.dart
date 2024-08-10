import 'package:flutter/material.dart';
import 'package:task_management/Screens/add_task_screen.dart';
import 'package:task_management/Models/task.dart';
import 'package:task_management/database/task_database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        cardColor: Colors.lightBlue[50],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  String _sortBy = 'Alphabetical';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      List<Task> tasks = await TaskDatabase.instance.readAllTasks();
      if (_sortBy == 'Alphabetical') {
        tasks.sort((a, b) => a.title.compareTo(b.title));
      } else if (_sortBy == 'Priority') {}
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  void _addTask(Task task) async {
    final newTask = await TaskDatabase.instance.create(task);
    setState(() {
      _tasks.add(newTask);
      _loadTasks();
    });
  }

  void _deleteSelectedTasks() async {
    final selectedTasks = _tasks.where((task) => task.isCompleted).toList();
    for (var task in selectedTasks) {
      await TaskDatabase.instance.delete(task.id!);
    }
    setState(() {
      _tasks.removeWhere((task) => task.isCompleted);
    });
  }

  void _onSortChanged(String? value) {
    setState(() {
      _sortBy = value!;
      _loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelectedTasks,
            tooltip: 'Delete Selected Tasks',
          ),
          PopupMenuButton<String>(
            onSelected: _onSortChanged,
            itemBuilder: (BuildContext context) {
              return ['Alphabetical', 'Priority'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Tasks',
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.blue[50],
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      _tasks[index].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _tasks[index].description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    trailing: Checkbox(
                      value: _tasks[index].isCompleted,
                      onChanged: (bool? value) {
                        setState(() {
                          _tasks[index] =
                              _tasks[index].copyWith(isCompleted: value!);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(onTaskAdded: _addTask),
            ),
          );
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
