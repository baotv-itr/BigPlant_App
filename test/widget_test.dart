import 'package:flutter_test/flutter_test.dart';

import 'package:bigplantflutter/app.dart';

void main() {
  testWidgets('App boots to auth flow', (WidgetTester tester) async {
    await tester.pumpWidget(const BigPlantApp());
    expect(find.byType(BigPlantApp), findsOneWidget);
  });
}
