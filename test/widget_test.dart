import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/main.dart';

void main() {
  final block = find.byKey(const ValueKey('demo-box'));

  Future<void> requestSize(WidgetTester tester, {required bool maximum}) async {
    final slider = find.byKey(const ValueKey('size-slider'));
    await tester.drag(slider, Offset(maximum ? 1000 : -1000, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('Constraints restrict the requested size in each mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(tester.getSize(block), const Size(120, 120));

    await tester.tap(find.text('Tight'));
    await tester.pumpAndSettle();
    expect(tester.getSize(block), const Size(200, 160));

    await requestSize(tester, maximum: false);
    expect(find.text('Запрос SizedBox: 40 × 40'), findsOneWidget);
    expect(tester.getSize(block), const Size(200, 160));

    await tester.tap(find.text('Min + Max'));
    await tester.pumpAndSettle();
    expect(tester.getSize(block), const Size(80, 80));

    await tester.tap(find.text('Loose'));
    await tester.pumpAndSettle();
    expect(tester.getSize(block), const Size(40, 40));

    await requestSize(tester, maximum: true);
    expect(find.text('Запрос SizedBox: 240 × 240'), findsOneWidget);
    expect(tester.getSize(block), const Size(200, 160));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lesson remains readable and scrollable on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.scrollUntilVisible(
      find.textContaining('Проверь себя:'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
