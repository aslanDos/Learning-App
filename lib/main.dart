import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Learning App',
    home: ConstraintsLessonScreen(),
  );
}

enum ConstraintMode { loose, tight, bounded }

class ConstraintsLessonScreen extends StatefulWidget {
  const ConstraintsLessonScreen({super.key});

  @override
  State<ConstraintsLessonScreen> createState() =>
      _ConstraintsLessonScreenState();
}

class _ConstraintsLessonScreenState extends State<ConstraintsLessonScreen> {
  ConstraintMode _mode = ConstraintMode.loose;
  double _requestedSize = 120;

  BoxConstraints get _constraints => switch (_mode) {
    ConstraintMode.loose => BoxConstraints.loose(const Size(200, 160)),
    ConstraintMode.tight => const BoxConstraints.tightFor(
      width: 200,
      height: 160,
    ),
    ConstraintMode.bounded => const BoxConstraints(
      minWidth: 80,
      maxWidth: 200,
      minHeight: 80,
      maxHeight: 160,
    ),
  };

  String get _constraintsCode => switch (_mode) {
    ConstraintMode.loose => 'BoxConstraints.loose(Size(200, 160))',
    ConstraintMode.tight =>
      'BoxConstraints.tightFor(\n    width: 200, height: 160,\n  )',
    ConstraintMode.bounded =>
      'BoxConstraints(\n    minWidth: 80, maxWidth: 200,\n'
          '    minHeight: 80, maxHeight: 160,\n  )',
  };

  @override
  Widget build(BuildContext context) {
    final limits = _constraints;
    return Scaffold(
      appBar: AppBar(title: const Text('02 · Constraints')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Почему width не всегда работает?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Родитель задаёт диапазон размеров. Ребёнок может выбрать '
              'только размер внутри него. Попробуй запросить 40, 120 и 240 '
              'в каждом режиме.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in const {
                  ConstraintMode.loose: 'Loose',
                  ConstraintMode.tight: 'Tight',
                  ConstraintMode.bounded: 'Min + Max',
                }.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _mode == entry.key,
                    onSelected: (_) => setState(() => _mode = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Допустимая ширина: ${limits.minWidth.round()}…${limits.maxWidth.round()}\n'
              'Допустимая высота: ${limits.minHeight.round()}…${limits.maxHeight.round()}',
            ),
            const SizedBox(height: 12),
            // Center даёт области примера возможность быть меньше ширины списка.
            Center(
              child: SizedBox.square(
                dimension: 240,
                child: ColoredBox(
                  color: const Color(0xFFECEFF1),
                  child: Center(
                    // Этот родитель задаёт ограничения для SizedBox ниже.
                    child: ConstrainedBox(
                      constraints: limits,
                      child: SizedBox(
                        width: _requestedSize,
                        height: _requestedSize,
                        child: ColoredBox(
                          key: const ValueKey('demo-box'),
                          color: const Color(0xFF1565C0),
                          // Здесь ограничения уже отражают реальный размер блока.
                          child: LayoutBuilder(
                            builder: (context, actual) => Padding(
                              padding: const EdgeInsets.all(4),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${actual.maxWidth.round()} × ${actual.maxHeight.round()}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
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
            const Text('Числа внутри синего блока — его фактический размер.'),
            const SizedBox(height: 16),
            Text(
              'Запрос SizedBox: ${_requestedSize.round()} × ${_requestedSize.round()}',
            ),
            Slider(
              key: const ValueKey('size-slider'),
              value: _requestedSize,
              min: 40,
              max: 240,
              divisions: 10,
              label: '${_requestedSize.round()}',
              onChanged: (value) => setState(() => _requestedSize = value),
            ),
            const Text(
              'Loose: минимум 0, можно быть меньше максимума.\n'
              'Tight: минимум равен максимуму, размер уже определён.\n'
              'Min + Max: можно выбирать размер между заданными границами. '
              'Это тоже bounded constraints; loose и tight в этом примере '
              'также имеют конечные максимумы.',
            ),
            const SizedBox(height: 20),
            Text('Код примера', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SelectableText(
              'ConstrainedBox(\n'
              '  constraints: $_constraintsCode,\n'
              '  child: SizedBox(\n'
              '    width: ${_requestedSize.round()},\n'
              '    height: ${_requestedSize.round()},\n'
              '    child: ColoredBox(color: Colors.blue),\n'
              '  ),\n'
              ')',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const Text(
              'В приложении этот фрагмент находится внутри Center в области '
              '240 × 240. В другом окружении результат может отличаться: '
              'ConstrainedBox учитывает и ограничения своего родителя.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Проверь себя: при запросе 240 × 240 во всех трёх режимах '
              'получается 200 × 160. Почему? А что получится при запросе 40 × 40?',
            ),
          ],
        ),
      ),
    );
  }
}
