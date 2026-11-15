import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/main.dart';

void main() {
  Finder block(String id) => find.byKey(ValueKey('block-$id'));

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Row and Column change axes and distribute free space', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(const MyApp());
    final area = tester.getRect(find.byKey(const ValueKey('demo-area')));
    expect(tester.getTopLeft(block('B')).dx, tester.getTopRight(block('A')).dx);
    expect(tester.getCenter(block('A')).dy, area.center.dy);

    await tester.tap(find.text('spaceBetween'));
    await tester.pumpAndSettle();
    expect(tester.getTopRight(block('C')).dx, area.right);
    expect(
      tester.getTopLeft(block('B')).dx,
      greaterThan(tester.getTopRight(block('A')).dx),
    );

    await tester.tap(find.text('Column'));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(block('C')).dy, area.bottom);
    expect(
      tester.getTopLeft(block('B')).dy,
      greaterThan(tester.getBottomLeft(block('A')).dy),
    );

    await tester.tap(find.byKey(const ValueKey('cross-end')));
    await tester.pumpAndSettle();
    expect(tester.getTopRight(block('A')).dx, area.right);
    expect(tester.getTopRight(block('B')).dx, area.right);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Stack layers overlap and Positioned anchors C independently', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Stack'));
    await tester.pumpAndSettle();
    final area = tester.getRect(find.byKey(const ValueKey('demo-area')));
    expect(tester.getTopLeft(block('A')), area.topLeft);
    expect(tester.getTopLeft(block('B')), area.topLeft);

    await tester.tap(find.text('C через Positioned'));
    await tester.pumpAndSettle();
    final anchored = tester.getTopRight(block('C'));
    expect(anchored, area.topRight + const Offset(-16, 16));
    await tester.tap(find.text('bottomRight'));
    await tester.pumpAndSettle();
    expect(tester.getTopRight(block('C')), anchored);
    expect(tester.getBottomRight(block('A')), area.bottomRight);

    await tester.tap(find.text('Поменять слои A и B'));
    await tester.pumpAndSettle();
    final stack = tester.widget<Stack>(
      find.descendant(
        of: find.byKey(const ValueKey('demo-area')),
        matching: find.byType(Stack),
      ),
    );
    expect((stack.children.first as DemoBlock).id, 'B');
    expect((stack.children[1] as DemoBlock).id, 'A');
    expect(tester.takeException(), isNull);
  });

  testWidgets('All modes fit a narrow phone and lesson scrolls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    for (final mode in ['Column', 'Stack']) {
      await tester.tap(find.text(mode));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.scrollUntilVisible(
      find.textContaining('Проверь себя:'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
