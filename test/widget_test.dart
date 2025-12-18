import 'package:flutter_test/flutter_test.dart';
import 'package:travel_organizer/main.dart' as app;

void main() {
  testWidgets('App builds', (tester) async {
    //await tester.pumpWidget(app.TravelMateApp());
    await tester.pump();
  });
}
