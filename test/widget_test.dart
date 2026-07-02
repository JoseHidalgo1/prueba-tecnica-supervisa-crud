import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:provider/provider.dart';

import 'package:supervisa_task_manager/database/hive_service.dart';
import 'package:supervisa_task_manager/main.dart';
import 'package:supervisa_task_manager/providers/task_provider.dart';

void main() {
  setUp(() async {
    Hive.init('test_dir');
    HiveService.registerAdapters();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('App renders task list screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider(),
        child: const SupervisaApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Tareas'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
