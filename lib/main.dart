import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Learning App',
    home: LayoutGroupLessonScreen(),
  );
}

enum DemoLayout { row, column, stack }

class LayoutGroupLessonScreen extends StatefulWidget {
  const LayoutGroupLessonScreen({super.key});

  @override
  State<LayoutGroupLessonScreen> createState() =>
      _LayoutGroupLessonScreenState();
}

class _LayoutGroupLessonScreenState extends State<LayoutGroupLessonScreen> {
  DemoLayout _layout = DemoLayout.row;
  MainAxisAlignment _main = MainAxisAlignment.start;
  CrossAxisAlignment _cross = CrossAxisAlignment.center;
  Alignment _stackAlignment = Alignment.topLeft;
  bool _positioned = false;
  bool _reverse = false;

  List<Widget> get _blocks => const [
    DemoBlock(id: 'A', width: 56, height: 40, color: Color(0xFF1565C0)),
    DemoBlock(id: 'B', width: 72, height: 56, color: Color(0xFFC62828)),
    DemoBlock(id: 'C', width: 40, height: 72, color: Color(0xFF2E7D32)),
  ];

  Widget _buildDemo() {
    final blocks = _blocks;
    return switch (_layout) {
      DemoLayout.row => Row(
        mainAxisAlignment: _main,
        crossAxisAlignment: _cross,
        children: blocks,
      ),
      DemoLayout.column => Column(
        mainAxisAlignment: _main,
        crossAxisAlignment: _cross,
        children: blocks,
      ),
      DemoLayout.stack => Stack(
        alignment: _stackAlignment,
        children: [
          ...(_reverse ? blocks.take(2).toList().reversed : blocks.take(2)),
          if (_positioned)
            Positioned(top: 16, right: 16, child: blocks[2])
          else
            blocks[2],
        ],
      ),
    };
  }

  String get _code {
    const blocks =
        '    blockA, // 56 × 40\n'
        '    blockB, // 72 × 56\n'
        '    blockC, // 40 × 72\n';
    if (_layout != DemoLayout.stack) {
      final name = _layout == DemoLayout.row ? 'Row' : 'Column';
      return '$name(\n'
          '  mainAxisAlignment: $_main,\n'
          '  crossAxisAlignment: $_cross,\n'
          '  children: [\n$blocks  ],\n)';
    }
    return 'Stack(\n'
        '  alignment: $_stackAlignment,\n'
        '  children: [\n'
        '    ${_reverse ? 'blockB' : 'blockA'},\n'
        '    ${_reverse ? 'blockA' : 'blockB'},\n'
        '${_positioned ? '    Positioned(top: 16, right: 16,\n      child: blockC),\n' : '    blockC,\n'}'
        '  ],\n)';
  }

  @override
  Widget build(BuildContext context) {
    final isStack = _layout == DemoLayout.stack;
    return Scaffold(
      appBar: AppBar(title: const Text('03 · Row, Column, Stack')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Один набор детей — три способа размещения',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Row — ряд. Column — столбец. Stack — слои. '
              'Блоки имеют разные размеры, чтобы было видно выравнивание.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final mode in DemoLayout.values)
                  ChoiceChip(
                    label: Text(switch (mode) {
                      DemoLayout.row => 'Row',
                      DemoLayout.column => 'Column',
                      DemoLayout.stack => 'Stack',
                    }),
                    selected: _layout == mode,
                    onSelected: (_) => setState(() => _layout = mode),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox.square(
                dimension: 240,
                child: ColoredBox(
                  key: const ValueKey('demo-area'),
                  color: const Color(0xFFECEFF1),
                  child: _buildDemo(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isStack
                  ? 'Следующий ребёнок рисуется поверх предыдущего. '
                        'Сейчас зелёный C — последний слой.'
                  : _layout == DemoLayout.row
                  ? 'Главная ось → горизонталь. Поперечная ось ↓ вертикаль.'
                  : 'Главная ось ↓ вертикаль. Поперечная ось → горизонталь.',
            ),
            const SizedBox(height: 12),
            if (!isStack) ...[
              const Text('mainAxisAlignment — вдоль главной оси'),
              Wrap(
                spacing: 8,
                children: [
                  for (final value in const [
                    MainAxisAlignment.start,
                    MainAxisAlignment.center,
                    MainAxisAlignment.spaceBetween,
                  ])
                    ChoiceChip(
                      label: Text(value.name),
                      selected: _main == value,
                      onSelected: (_) => setState(() => _main = value),
                    ),
                ],
              ),
              const Text('crossAxisAlignment — вдоль поперечной оси'),
              Wrap(
                spacing: 8,
                children: [
                  for (final value in const [
                    CrossAxisAlignment.start,
                    CrossAxisAlignment.center,
                    CrossAxisAlignment.end,
                  ])
                    ChoiceChip(
                      key: ValueKey('cross-${value.name}'),
                      label: Text(value.name),
                      selected: _cross == value,
                      onSelected: (_) => setState(() => _cross = value),
                    ),
                ],
              ),
            ] else ...[
              const Text('alignment — выравнивание детей без Positioned'),
              Wrap(
                spacing: 8,
                children: [
                  for (final entry in const {
                    'topLeft': Alignment.topLeft,
                    'center': Alignment.center,
                    'bottomRight': Alignment.bottomRight,
                  }.entries)
                    ChoiceChip(
                      label: Text(entry.key),
                      selected: _stackAlignment == entry.value,
                      onSelected: (_) =>
                          setState(() => _stackAlignment = entry.value),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('C через Positioned'),
                subtitle: const Text('top: 16, right: 16 относительно Stack'),
                value: _positioned,
                onChanged: (value) => setState(() => _positioned = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Поменять слои A и B'),
                value: _reverse,
                onChanged: (value) => setState(() => _reverse = value),
              ),
            ],
            const SizedBox(height: 20),
            Text('Код примера', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SelectableText(
              _code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const Text(
              'blockA, blockB и blockC — цветные блоки из класса '
              'DemoBlock. Пример находится в SizedBox 240 × 240.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Проверь себя: выбери spaceBetween в Row, затем Column. '
              'Почему промежутки поменяли направление? В Stack включи '
              'Positioned и меняй alignment. Почему C больше не перемещается?',
            ),
          ],
        ),
      ),
    );
  }
}

class DemoBlock extends StatelessWidget {
  const DemoBlock({
    super.key,
    required this.id,
    required this.width,
    required this.height,
    required this.color,
  });

  final String id;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: ValueKey('block-$id'),
    width: width,
    height: height,
    child: ColoredBox(
      color: color,
      child: Center(
        child: Text(id, style: const TextStyle(color: Colors.white)),
      ),
    ),
  );
}
