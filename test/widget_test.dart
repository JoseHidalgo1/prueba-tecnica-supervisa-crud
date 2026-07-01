import 'package:flutter_test/flutter_test.dart';

import 'package:supervisa_task_manager/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const SupervisaApp());
    expect(find.text('Tareas'), findsOneWidget);
    expect(find.text('Bienvenido'), findsOneWidget);
  });
}
