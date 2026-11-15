import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Learning App',
    home: LayoutLessonScreen(),
  );
}

class LayoutLessonScreen extends StatefulWidget {
  const LayoutLessonScreen({super.key});

  @override
  State<LayoutLessonScreen> createState() => _LayoutLessonScreenState();
}

class _LayoutLessonScreenState extends State<LayoutLessonScreen> {
  double _size = 80;
  double _padding = 16;
  Alignment _alignment = Alignment.center;

  static const _positions = {
    'Слева сверху': Alignment.topLeft,
    'По центру': Alignment.center,
    'Справа снизу': Alignment.bottomRight,
  };

  String get _alignmentCode => switch (_alignment) {
    Alignment.topLeft => 'Alignment.topLeft',
    Alignment.bottomRight => 'Alignment.bottomRight',
    _ => 'Alignment.center',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('01 · Layout')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Как виджет получает размер и место',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Родитель передаёт ограничения → ребёнок выбирает размер '
              'в этих пределах → родитель размещает ребёнка. '
              'Размеры во Flutter измеряются в логических пикселях.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Попробуй: перемести синий блок в угол, затем увеличь отступ.',
            ),
            const SizedBox(height: 12),
            // Оранжевый фон показывает пространство, занятое Padding.
            SizedBox(
              height: 240,
              child: ColoredBox(
                color: const Color(0xFFFFE0B2),
                child: Padding(
                  padding: EdgeInsets.all(_padding),
                  child: ColoredBox(
                    color: const Color(0xFFECEFF1),
                    // Align занимает доступную область и размещает ребёнка.
                    child: Align(
                      alignment: _alignment,
                      child: SizedBox(
                        width: _size,
                        height: _size,
                        child: const ColoredBox(
                          key: ValueKey('demo-box'),
                          color: Color(0xFF1565C0),
                          child: Center(
                            child: Text(
                              'child',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Оранжевый — отступ. Серый — область для выравнивания.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final position in _positions.entries)
                  ChoiceChip(
                    label: Text(position.key),
                    selected: _alignment == position.value,
                    onSelected: (_) {
                      setState(() => _alignment = position.value);
                    },
                  ),
              ],
            ),
            Text('Размер блока: ${_size.round()} × ${_size.round()}'),
            Slider(
              value: _size,
              min: 48,
              max: 120,
              divisions: 9,
              label: '${_size.round()}',
              onChanged: (value) => setState(() => _size = value),
            ),
            Text('Отступ: ${_padding.round()}'),
            Slider(
              value: _padding,
              min: 0,
              max: 40,
              divisions: 10,
              label: '${_padding.round()}',
              onChanged: (value) => setState(() => _padding = value),
            ),
            const SizedBox(height: 12),
            Text('Код примера', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SelectableText(
              'SizedBox(\n'
              '  height: 240,\n'
              '  child: Padding(\n'
              '    padding: EdgeInsets.all(${_padding.round()}),\n'
              '    child: Align(\n'
              '      alignment: $_alignmentCode,\n'
              '      child: SizedBox(\n'
              '        width: ${_size.round()},\n'
              '        height: ${_size.round()},\n'
              '        child: ColoredBox(color: Color(0xFF1565C0)),\n'
              '      ),\n'
              '    ),\n'
              '  ),\n'
              ')',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const Text('Для краткости в коде скрыты фон и подпись блока.'),
            const SizedBox(height: 20),
            const Text(
              'Что здесь делает каждый виджет:\n\n'
              '• SizedBox запрашивает размер в пределах ограничений родителя.\n'
              '• Padding оставляет отступ внутри своей области.\n'
              '• Align размещает ребёнка в доступной области.\n'
              '• Center — частный случай Align с выравниванием по центру.\n'
              '• ColoredBox рисует фон, чтобы границы были видны.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Проверь себя: почему при выравнивании по центру одинаковый '
              'отступ со всех сторон не сдвигает блок? Переключись на угол '
              'и сравни. Объясни результат через область, которую получает Align.',
            ),
          ],
        ),
      ),
    );
  }
}
