import 'package:flutter_test/flutter_test.dart';
import 'package:travel_organizer/main.dart'; // назва пакета з pubspec.yaml

void main() {
  testWidgets('TravelMateApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelOrganizer());
    await tester.pump(); // перший кадр
  });
}
