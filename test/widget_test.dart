import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/main.dart';

void main() {
  testWidgets('App opens the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
