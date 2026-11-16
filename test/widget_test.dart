import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/main.dart';

void main() {
  final viewport = find.byKey(const ValueKey('demo-viewport'));
  ScrollController controller(WidgetTester tester) => tester
      .widget<SingleChildScrollView>(find.byKey(const ValueKey('demo-scroll')))
      .controller!;

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'Swipe scrolls content inside a fixed viewport and buttons navigate',
    (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(controller(tester).position.maxScrollExtent, 336);
      expect(tester.getSize(viewport), const Size(240, 240));
      final outer = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const ValueKey('lesson-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );

      await tester.drag(viewport, const Offset(0, -120));
      await tester.pumpAndSettle();
      expect(controller(tester).offset, greaterThan(0));
      expect(outer.position.pixels, 0);
      expect(tester.getSize(viewport), const Size(240, 240));

      await tester.tap(find.text('В конец'));
      await tester.pumpAndSettle();
      expect(controller(tester).offset, 336);
      expect(find.text('Смещение: 336'), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const ValueKey('item-8'))).bottom,
        tester.getRect(viewport).bottom,
      );
      await tester.tap(find.text('В начало'));
      await tester.pumpAndSettle();
      expect(controller(tester).offset, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Horizontal scrolling and short content use correct extents', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Горизонтально'));
    await tester.pumpAndSettle();
    await tester.drag(viewport, const Offset(-140, 0));
    await tester.pumpAndSettle();
    expect(controller(tester).offset, greaterThan(0));
    await tester.tap(find.text('В конец'));
    await tester.pumpAndSettle();
    expect(controller(tester).offset, 336);

    await tester.tap(find.text('Длинное содержимое'));
    await tester.pumpAndSettle();
    expect(controller(tester).offset, 0);
    expect(controller(tester).position.maxScrollExtent, 0);
    await tester.tap(find.text('В конец'));
    await tester.pumpAndSettle();
    expect(controller(tester).offset, 0);
    await tester.tap(find.text('Вертикально'));
    await tester.pumpAndSettle();
    expect(controller(tester).position.maxScrollExtent, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Narrow phone can scroll the entire lesson outside the demo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    final exercise = find.textContaining('Проверь себя:');
    // Жест начинается на поле страницы, вне внутреннего viewport.
    for (
      var attempt = 0;
      attempt < 15 && exercise.evaluate().isEmpty;
      attempt++
    ) {
      await tester.dragFrom(const Offset(8, 480), const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    expect(exercise, findsOneWidget);
    await tester.ensureVisible(exercise);
    await tester.pumpAndSettle();
    expect(exercise.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
