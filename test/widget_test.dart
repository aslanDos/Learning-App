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

  testWidgets(
    'Expanded shares remaining space; Flexible may leave unused space',
    (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(const MyApp());
      expect(tester.getSize(block('A')), const Size(48, 48));
      expect(tester.getSize(block('B')), const Size(64, 40));
      expect(tester.getSize(block('C')), const Size(128, 48));

      await tester.tap(find.text('Flexible'));
      await tester.pumpAndSettle();
      expect(tester.getSize(block('B')), const Size(40, 40));
      expect(tester.getSize(block('C')), const Size(128, 48));
      final area = tester.getRect(find.byKey(const ValueKey('demo-area')));
      expect(area.right - tester.getTopRight(block('C')).dx, 24);

      await tester.tap(find.text('Вертикально'));
      await tester.pumpAndSettle();
      expect(tester.getSize(block('B')), const Size(40, 40));
      expect(tester.getSize(block('C')), const Size(48, 128));
      expect(area.bottom - tester.getBottomLeft(block('C')).dy, 24);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Flex factor changes shares and Spacer distributes empty gaps', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.drag(
      find.byKey(const ValueKey('flex-slider')),
      const Offset(1000, 0),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(block('B')).width, 48);
    expect(tester.getSize(block('C')).width, 144);

    await tester.tap(find.text('Spacer'));
    await tester.pumpAndSettle();
    expect(tester.getSize(block('A')), const Size(48, 48));
    expect(tester.getSize(block('B')), const Size(40, 40));
    expect(tester.getSize(block('C')), const Size(48, 48));
    final firstGap =
        tester.getTopLeft(block('B')).dx - tester.getTopRight(block('A')).dx;
    final secondGap =
        tester.getTopLeft(block('C')).dx - tester.getTopRight(block('B')).dx;
    expect(firstGap, closeTo(26, 0.01));
    expect(secondGap, closeTo(78, 0.01));
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
    for (final mode in ['Expanded', 'Flexible', 'Spacer']) {
      await tester.scrollUntilVisible(
        find.text(mode),
        -100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(mode));
      await tester.pumpAndSettle();
      for (final axis in ['Вертикально', 'Горизонтально']) {
        await tester.scrollUntilVisible(
          find.text(axis),
          axis == 'Вертикально' ? 100 : -100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(axis));
        await tester.pumpAndSettle();
        final demo = tester.widget<Flex>(
          find.descendant(
            of: find.byKey(const ValueKey('demo-area')),
            matching: find.byType(Flex),
          ),
        );
        expect(
          demo.direction,
          axis == 'Вертикально' ? Axis.vertical : Axis.horizontal,
        );
        expect(tester.takeException(), isNull);
      }
    }
    await tester.scrollUntilVisible(
      find.textContaining('Проверь себя:'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
