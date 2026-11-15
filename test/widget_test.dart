import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/main.dart';

void main() {
  testWidgets('Alignment controls move the example and update its code', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('01 · Layout'), findsOneWidget);
    final block = find.byKey(const ValueKey('demo-box'));
    final centeredPosition = tester.getTopLeft(block);
    expect(tester.getSize(block), const Size(80, 80));

    await tester.tap(find.text('Слева сверху'));
    await tester.pumpAndSettle();

    final cornerPosition = tester.getTopLeft(block);
    expect(cornerPosition.dx, lessThan(centeredPosition.dx));
    expect(cornerPosition.dy, lessThan(centeredPosition.dy));
    await tester.scrollUntilVisible(find.byType(SelectableText), 200);
    expect(find.textContaining('alignment: Alignment.topLeft'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lesson fits a narrow phone and remains scrollable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.scrollUntilVisible(
      find.textContaining('Проверь себя:'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(tester.takeException(), isNull);
  });
}
