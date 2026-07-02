import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supervisa_task_manager/providers/task_provider.dart';
import 'package:supervisa_task_manager/screens/task_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const SupervisaApp(),
    ),
  );
}

class SupervisaApp extends StatelessWidget {
  const SupervisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supervisa Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}
