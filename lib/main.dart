import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Learning App',
    home: ScrollingLessonScreen(),
  );
}

class ScrollingLessonScreen extends StatefulWidget {
  const ScrollingLessonScreen({super.key});

  @override
  State<ScrollingLessonScreen> createState() => _ScrollingLessonScreenState();
}

class _ScrollingLessonScreenState extends State<ScrollingLessonScreen> {
  Axis _axis = Axis.vertical;
  bool _longContent = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('05 · Scrolling')),
    body: SafeArea(
      child: ListView(
        key: const ValueKey('lesson-scroll'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Окно меньше содержимого',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Viewport — видимая область прокрутки. Здесь это квадрат '
            '240 × 240. Содержимое может быть длиннее окна: свайп меняет '
            'scroll offset, а размеры окна остаются прежними.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in const {
                Axis.vertical: 'Вертикально',
                Axis.horizontal: 'Горизонтально',
              }.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _axis == entry.key,
                  onSelected: (_) => setState(() => _axis = entry.key),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Длинное содержимое'),
            subtitle: Text(_longContent ? '8 × 72 = 576' : '3 × 72 = 216'),
            value: _longContent,
            onChanged: (value) => setState(() => _longContent = value),
          ),
          ScrollDemo(
            // Каждый вариант начинает с нулевого смещения и новым controller.
            key: ValueKey('${_axis.name}-$_longContent'),
            axis: _axis,
            count: _longContent ? 8 : 3,
          ),
          const Text(
            'При смене направления или длины пример начинается с нуля. '
            'Свайп внутри квадрата прокручивает пример, снаружи — страницу урока.',
          ),
          const SizedBox(height: 20),
          Text(
            'Как устроен пример',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SelectableText(
            'SizedBox(\n'
            '  width: 240, height: 240,\n'
            '  child: Scrollbar(\n'
            '    controller: controller,\n'
            '    thumbVisibility: true,\n'
            '    child: SingleChildScrollView(\n'
            '      controller: controller,\n'
            '      primary: false,\n'
            '      scrollDirection: $_axis,\n'
            '      physics: ClampingScrollPhysics(),\n'
            '      child: ${_axis == Axis.vertical ? 'Column' : 'Row'}(\n'
            '        mainAxisSize: MainAxisSize.min,\n'
            '        children: items, // ${_longContent ? 8 : 3} элементов по 72\n'
            '      ),\n'
            '    ),\n'
            '  ),\n'
            ')',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Text(
            'ScrollController хранится в State и освобождается в dispose. '
            'Кнопки используют animateTo, а текущий offset читается через '
            'AnimatedBuilder. Scrollbar показывает положение в содержимом.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Важно про ограничения: окно прокрутки имеет конечный размер, '
            'но ребёнку разрешён неограниченный максимум вдоль оси прокрутки. '
            'Внутри этой Column нет Expanded: ему было бы не из чего вычислить '
            'конечную долю. Expanded снаружи scroll view в ограниченной Column '
            'может, наоборот, выделить конечную высоту окна.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Проверь себя: отключи длинное содержимое. Почему кнопка '
            '«В конец» больше не сдвигает элементы? Верни 8 элементов, '
            'переключи ось и сравни поведение.',
          ),
        ],
      ),
    ),
  );
}

class ScrollDemo extends StatefulWidget {
  const ScrollDemo({super.key, required this.axis, required this.count});

  final Axis axis;
  final int count;

  @override
  State<ScrollDemo> createState() => _ScrollDemoState();
}

class _ScrollDemoState extends State<ScrollDemo> {
  // Один controller обслуживает только внутреннюю область примера.
  final _controller = ScrollController(keepScrollOffset: false);

  void _scrollTo({required bool end}) {
    if (!_controller.hasClients || !_controller.position.hasContentDimensions) {
      return;
    }
    _controller.animateTo(
      end ? _controller.position.maxScrollExtent : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      for (var index = 1; index <= widget.count; index++)
        SizedBox(
          key: ValueKey('item-$index'),
          width: widget.axis == Axis.horizontal ? 72 : 240,
          height: widget.axis == Axis.vertical ? 72 : 240,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ColoredBox(
              color: index.isOdd
                  ? const Color(0xFF1565C0)
                  : const Color(0xFF2E7D32),
              child: Center(
                child: Text(
                  '№ $index',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox.square(
            dimension: 240,
            child: ColoredBox(
              key: const ValueKey('demo-viewport'),
              color: const Color(0xFFECEFF1),
              child: Scrollbar(
                controller: _controller,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  key: const ValueKey('demo-scroll'),
                  controller: _controller,
                  primary: false,
                  scrollDirection: widget.axis,
                  physics: const ClampingScrollPhysics(),
                  child: widget.axis == Axis.vertical
                      ? Column(mainAxisSize: MainAxisSize.min, children: items)
                      : Row(mainAxisSize: MainAxisSize.min, children: items),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Text(
            'Смещение: ${(_controller.hasClients ? _controller.offset : 0).round()}',
            key: const ValueKey('offset-label'),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => _scrollTo(end: false),
              child: const Text('В начало'),
            ),
            OutlinedButton(
              onPressed: () => _scrollTo(end: true),
              child: const Text('В конец'),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
