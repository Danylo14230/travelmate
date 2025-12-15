import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_organizer/main.dart';

void main() {
  testWidgets('TravelMate app starts', (WidgetTester tester) async {
    // Запускаємо додаток
    await tester.pumpWidget(const TravelMateApp());

    // Перевіряємо, що MaterialApp існує
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
