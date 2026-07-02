import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:supervisa_task_manager/database/hive_service.dart';
import 'package:supervisa_task_manager/providers/task_provider.dart';
import 'package:supervisa_task_manager/screens/task_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    HiveService.registerAdapters();
    await HiveService.instance.box;
    await initializeDateFormatting('es');
  } catch (e, s) {
    debugPrint('Error al inicializar: $e\n$s');
    debugPrint('Corrupting Hive box detected. Deleting and retrying...');
    await Hive.deleteBoxFromDisk('tasks');
    HiveService.instance.resetForTesting();
    await HiveService.instance.box;
    await initializeDateFormatting('es');
  }
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
