import 'package:flutter/material.dart';
import 'dart:math';

// Entry point
void main() {
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Task model
class Task {
  final String title;
  final String description;
  bool isCompleted;
  final Color color;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.color,
  });
}

// Welcome Page
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Todo App!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Organize your tasks efficiently and stay productive.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// App widget with routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.green,
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              secondary: Colors.greenAccent,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            cardColor: Colors.grey[900],
            colorScheme: ColorScheme.dark(
              primary: Colors.green.shade700,
              secondary: Colors.greenAccent.shade700,
            ),
          ),
          themeMode: currentMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomePage(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}

// Home screen (Todo list)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> todoList = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int updateIndex = -1;

  final List<Color> titleColors = [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.cyan,
  ];

  void _showTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(updateIndex == -1 ? 'Add Task' : 'Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final task = Task(
                    title: _titleController.text,
                    description: _descController.text,
                    color: titleColors[Random().nextInt(titleColors.length)],
                  );
                  setState(() {
                    if (updateIndex == -1) {
                      todoList.add(task);
                    } else {
                      todoList[updateIndex] = Task(
                        title: task.title,
                        description: task.description,
                        isCompleted: todoList[updateIndex].isCompleted,
                        color: task.color,
                      );
                      updateIndex = -1;
                    }
                  });
                  _titleController.clear();
                  _descController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteItem(int index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  void toggleComplete(int index) {
    setState(() {
      todoList[index].isCompleted = !todoList[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todo Application",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                final task = todoList[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        color: task.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      task.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => toggleComplete(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteItem(index),
                        ),
                      ],
                    ),
                    onTap: () {
                      _titleController.text = task.title;
                      _descController.text = task.description;
                      updateIndex = index;
                      _showTaskDialog();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _titleController.clear();
          _descController.clear();
          updateIndex = -1;
          _showTaskDialog();
        },
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
