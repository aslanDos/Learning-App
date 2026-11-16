import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learningapp/main.dart';

void main() {
  Finder item(int index) => find.byKey(ValueKey('item-$index'));

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'List builds on demand and selection survives offscreen disposal',
    (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(const MyApp());
      expect(item(0), findsOneWidget);
      expect(item(59), findsNothing);
      await tester.tap(item(0));
      await tester.pumpAndSettle();
      expect(find.text('Выбрано: 1 из 60'), findsOneWidget);
      await tester.tap(find.text('В конец'));
      await tester.pumpAndSettle();
      expect(item(59).hitTestable(), findsOneWidget);
      expect(item(0), findsNothing);
      await tester.tap(find.text('В начало'));
      await tester.pumpAndSettle();
      expect(tester.widget<Semantics>(item(0)).properties.selected, isTrue);
      await tester.tap(item(0));
      await tester.pumpAndSettle();
      expect(find.text('Выбрано: 0 из 60'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Grid changes column geometry and preserves screen selection', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.tap(item(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сетка'));
    await tester.pumpAndSettle();
    expect(tester.widget<Semantics>(item(0)).properties.selected, isTrue);
    expect(tester.getTopLeft(item(0)).dy, tester.getTopLeft(item(1)).dy);
    expect(
      tester.getTopLeft(item(2)).dy,
      greaterThan(tester.getTopLeft(item(0)).dy),
    );
    final twoColumnWidth = tester.getSize(item(0)).width;
    await tester.tap(find.text('3 колонки'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(item(2)).dy, tester.getTopLeft(item(0)).dy);
    expect(tester.getSize(item(0)).width, lessThan(twoColumnWidth));
    expect(
      tester.getSize(item(0)).width,
      closeTo(tester.getSize(item(0)).height, 0.01),
    );
    await tester.tap(find.text('В конец'));
    await tester.pumpAndSettle();
    expect(item(59).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Separated list inserts gaps and reaches last item', (
    tester,
  ) async {
    useTallScreen(tester);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Разделители'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(item(1)).dy - tester.getBottomLeft(item(0)).dy, 8);
    await tester.tap(find.text('В конец'));
    await tester.pumpAndSettle();
    expect(item(59).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Three-column grid fits a narrow phone and lesson scrolls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Сетка'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('3 колонки'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 колонки'));
    await tester.pumpAndSettle();
    final grid = tester.widget<GridView>(
      find.byKey(const ValueKey('collection-scroll')),
    );
    expect(
      (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      3,
    );
    final exercise = find.textContaining('Проверь себя:');
    for (
      var attempt = 0;
      attempt < 20 && exercise.evaluate().isEmpty;
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
