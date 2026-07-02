import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:supervisa_task_manager/main.dart';
import 'package:supervisa_task_manager/providers/task_provider.dart';

void main() {
  setUp(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App renders task list screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider(),
        child: const SupervisaApp(),
      ),
    );

    // Espera a que el post-frame callback cargue las tareas
    await tester.pump();

    expect(find.text('Tareas'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
