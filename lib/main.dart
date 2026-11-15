import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Learning App',
    home: FlexLessonScreen(),
  );
}

enum FlexDemo { expanded, flexible, spacer }

class FlexLessonScreen extends StatefulWidget {
  const FlexLessonScreen({super.key});

  @override
  State<FlexLessonScreen> createState() => _FlexLessonScreenState();
}

class _FlexLessonScreenState extends State<FlexLessonScreen> {
  FlexDemo _mode = FlexDemo.expanded;
  Axis _axis = Axis.horizontal;
  int _secondFlex = 2;

  List<Widget> get _children {
    const a = SizeBlock(id: 'A', desiredSize: 48, color: Color(0xFF1565C0));
    const b = SizeBlock(id: 'B', desiredSize: 40, color: Color(0xFFC62828));
    const c = SizeBlock(id: 'C', desiredSize: 48, color: Color(0xFF2E7D32));
    return switch (_mode) {
      FlexDemo.expanded => [
        a,
        const Expanded(child: b),
        Expanded(flex: _secondFlex, child: c),
      ],
      FlexDemo.flexible => [
        a,
        const Flexible(fit: FlexFit.loose, child: b),
        Expanded(flex: _secondFlex, child: c),
      ],
      FlexDemo.spacer => [a, const Spacer(), b, Spacer(flex: _secondFlex), c],
    };
  }

  String get _code {
    final children = switch (_mode) {
      FlexDemo.expanded =>
        '    blockA,\n'
            '    Expanded(flex: 1, child: blockB),\n'
            '    Expanded(flex: $_secondFlex, child: blockC),\n',
      FlexDemo.flexible =>
        '    blockA,\n'
            '    Flexible(flex: 1, fit: FlexFit.loose,\n      child: blockB),\n'
            '    Expanded(flex: $_secondFlex, child: blockC),\n',
      FlexDemo.spacer =>
        '    blockA,\n'
            '    Spacer(flex: 1),\n'
            '    blockB,\n'
            '    Spacer(flex: $_secondFlex),\n'
            '    blockC,\n',
    };
    return 'Flex(\n  direction: $_axis,\n'
        '  mainAxisAlignment: MainAxisAlignment.start,\n'
        '  crossAxisAlignment: CrossAxisAlignment.center,\n'
        '  children: [\n$children  ],\n)';
  }

  String get _explanation {
    if (_mode == FlexDemo.spacer) {
      return 'Блоки занимают 48 + 40 + 48 = 136. Остаток 104 делят '
          'два Spacer в пропорции 1 : $_secondFlex. Серые промежутки '
          'растут, размеры блоков сохраняются.';
    }
    final firstShare = 192 / (1 + _secondFlex);
    final secondShare = firstShare * _secondFlex;
    return 'Сначала A занимает 48. Остаток 240 − 48 = 192 делится '
        'в пропорции 1 : $_secondFlex.\n'
        'Доля B: ${firstShare.toStringAsFixed(1)}; '
        'доля C: ${secondShare.toStringAsFixed(1)}.\n'
        '${_mode == FlexDemo.expanded ? 'Expanded заставляет B и C заполнить свои доли.' : 'Flexible разрешает B занять меньше своей доли. B просит 40; C всё равно получает свою исходную долю. Остаток B не передаётся C.'}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('04 · Flex')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Как поделить свободное место',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Flex — общий виджет для ряда и столбца. '
            'Axis.horizontal соответствует Row, Axis.vertical — Column. '
            'Доли flex распределяются вдоль главной оси.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in const {
                FlexDemo.expanded: 'Expanded',
                FlexDemo.flexible: 'Flexible',
                FlexDemo.spacer: 'Spacer',
              }.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _mode == entry.key,
                  onSelected: (_) => setState(() => _mode = entry.key),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in const {
                Axis.horizontal: 'Горизонтально',
                Axis.vertical: 'Вертикально',
              }.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _axis == entry.key,
                  onSelected: (_) => setState(() => _axis = entry.key),
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
                child: Flex(
                  direction: _axis,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _children,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Внутри блоков — фактическая ширина × высота. '
            'Изначально A и C просят 48 × 48, B — 40 × 40.',
          ),
          const SizedBox(height: 12),
          Text(
            _mode == FlexDemo.spacer
                ? 'flex второго Spacer: $_secondFlex'
                : 'flex блока C: $_secondFlex',
          ),
          Slider(
            key: const ValueKey('flex-slider'),
            value: _secondFlex.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            label: '$_secondFlex',
            onChanged: (value) => setState(() => _secondFlex = value.round()),
          ),
          Text(_explanation),
          const SizedBox(height: 20),
          Text('Код примера', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SelectableText(
            _code,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          const Text(
            'blockA, blockB и blockC — экземпляры SizeBlock. '
            'Весь Flex помещён в SizedBox 240 × 240.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Проверь себя: сравни Expanded и Flexible при пропорции '
            '1 : 2. Почему C не увеличился, когда B стал меньше? '
            'Включи Spacer: что теперь получает доли свободного места?',
          ),
        ],
      ),
    ),
  );
}

class SizeBlock extends StatelessWidget {
  const SizeBlock({
    super.key,
    required this.id,
    required this.desiredSize,
    required this.color,
  });

  final String id;
  final double desiredSize;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: desiredSize,
    height: desiredSize,
    child: ColoredBox(
      key: ValueKey('block-$id'),
      color: color,
      child: LayoutBuilder(
        builder: (context, limits) => Padding(
          padding: const EdgeInsets.all(3),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$id\n${limits.maxWidth.round()} × ${limits.maxHeight.round()}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ),
  );
}
