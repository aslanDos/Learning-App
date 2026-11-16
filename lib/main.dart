import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Learning App',
    home: ListsGridsLessonScreen(),
  );
}

enum CollectionMode { list, separated, grid }

class ListsGridsLessonScreen extends StatefulWidget {
  const ListsGridsLessonScreen({super.key});

  @override
  State<ListsGridsLessonScreen> createState() => _ListsGridsLessonScreenState();
}

class _ListsGridsLessonScreenState extends State<ListsGridsLessonScreen> {
  CollectionMode _mode = CollectionMode.list;
  int _columns = 2;
  // Выбор хранится отдельно от лениво создаваемых ячеек.
  final Set<int> _selected = {};

  String get _code => switch (_mode) {
    CollectionMode.list =>
      'ListView.builder(\n'
          '  controller: controller,\n  primary: false,\n'
          '  padding: EdgeInsets.all(8),\n'
          '  itemCount: 60,\n  itemExtent: 72,\n'
          '  itemBuilder: (context, index) => buildItem(index),\n)',
    CollectionMode.separated =>
      'ListView.separated(\n'
          '  controller: controller,\n  primary: false,\n'
          '  padding: EdgeInsets.all(8),\n  itemCount: 60,\n'
          '  itemBuilder: (context, index) => buildItem(index),\n'
          '  separatorBuilder: (context, index) =>\n'
          '      Divider(height: 8),\n)',
    CollectionMode.grid =>
      'GridView.builder(\n'
          '  controller: controller,\n  primary: false,\n'
          '  padding: EdgeInsets.all(8),\n  itemCount: 60,\n'
          '  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(\n'
          '    crossAxisCount: $_columns,\n'
          '    mainAxisSpacing: 8,\n    crossAxisSpacing: 8,\n'
          '    childAspectRatio: 1,\n  ),\n'
          '  itemBuilder: (context, index) => buildItem(index),\n)',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('06 · Lists & Grids')),
    body: SafeArea(
      child: ListView(
        key: const ValueKey('lesson-scroll'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '60 элементов — без 60 готовых виджетов',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'builder создаёт ячейки по мере необходимости: '
            'в видимой области и рядом с ней для кеша. '
            'Прокрути пример, выбери элементы и смени раскладку.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in const {
                CollectionMode.list: 'Список',
                CollectionMode.separated: 'Разделители',
                CollectionMode.grid: 'Сетка',
              }.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _mode == entry.key,
                  onSelected: (_) => setState(() => _mode = entry.key),
                ),
            ],
          ),
          if (_mode == CollectionMode.grid)
            Wrap(
              spacing: 8,
              children: [
                for (final count in [2, 3])
                  ChoiceChip(
                    label: Text('$count колонки'),
                    selected: _columns == count,
                    onSelected: (_) => setState(() => _columns = count),
                  ),
              ],
            ),
          Text('Выбрано: ${_selected.length} из 60'),
          const SizedBox(height: 8),
          CollectionDemo(
            key: ValueKey('${_mode.name}-$_columns'),
            mode: _mode,
            columns: _columns,
            selected: _selected,
            onToggle: (index) => setState(() {
              if (!_selected.add(index)) _selected.remove(index);
            }),
          ),
          const Text(
            'Нажми на ячейку, чтобы выбрать её. Выбор хранится в State '
            'экрана и сохраняется после прокрутки и смены раскладки. '
            'Новая раскладка открывается с начала.',
          ),
          const SizedBox(height: 20),
          Text('Код примера', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SelectableText(
            _code,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          const Text(
            'buildItem создаёт ячейку с ValueKey(index), получает '
            'состояние выбора из Set и передаёт нажатие экрану. '
            'Список находится в окне высотой 300, шириной до 480.',
          ),
          const SizedBox(height: 16),
          const Text(
            'itemCount — количество данных; index начинается с 0. '
            'itemExtent — высота одной строки в вертикальном списке. '
            'Grid delegate определяет размеры и расположение ячеек сетки. '
            'При childAspectRatio: 1 ячейки квадратные.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Список и сетка уже умеют прокручиваться. '
            'Не нужно оборачивать длинный ListView в SingleChildScrollView '
            'и включать shrinkWrap как универсальное исправление: '
            'это может заставить вычислять размеры большого количества детей. '
            'Дай списку конечное окно через SizedBox или Expanded.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Проверь себя: выбери первый элемент, перейди в конец, '
            'затем вернись. Почему выбор сохранился, хотя ячейка могла '
            'быть удалена из дерева? В сетке переключи 2 и 3 колонки: '
            'почему изменилась высота квадратной ячейки?',
          ),
        ],
      ),
    ),
  );
}

class CollectionDemo extends StatefulWidget {
  const CollectionDemo({
    super.key,
    required this.mode,
    required this.columns,
    required this.selected,
    required this.onToggle,
  });

  final CollectionMode mode;
  final int columns;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  State<CollectionDemo> createState() => _CollectionDemoState();
}

class _CollectionDemoState extends State<CollectionDemo> {
  final _controller = ScrollController(keepScrollOffset: false);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(BuildContext context, int index) {
    final selected = widget.selected.contains(index);
    final icon = Icon(
      selected ? Icons.check_circle : Icons.radio_button_unchecked,
    );
    return Semantics(
      key: ValueKey('item-$index'),
      selected: selected,
      child: SizedBox(
        height: 72,
        child: Card(
          margin: const EdgeInsets.all(4),
          color: selected
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
          child: InkWell(
            onTap: () => widget.onToggle(index),
            child: widget.mode == CollectionMode.grid
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('№ ${index + 1}'), icon],
                    ),
                  )
                : ListTile(title: Text('Элемент ${index + 1}'), trailing: icon),
          ),
        ),
      ),
    );
  }

  void _goTo(bool end) {
    if (!_controller.hasClients || !_controller.position.hasContentDimensions) {
      return;
    }
    // У всех строк/ячеек в примере одинаковый размер, extent известен точно.
    _controller.jumpTo(end ? _controller.position.maxScrollExtent : 0);
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = switch (widget.mode) {
      CollectionMode.list => ListView.builder(
        key: const ValueKey('collection-scroll'),
        controller: _controller,
        primary: false,
        padding: const EdgeInsets.all(8),
        itemCount: 60,
        itemExtent: 72,
        itemBuilder: _buildItem,
      ),
      CollectionMode.separated => ListView.separated(
        key: const ValueKey('collection-scroll'),
        controller: _controller,
        primary: false,
        padding: const EdgeInsets.all(8),
        itemCount: 60,
        itemBuilder: _buildItem,
        separatorBuilder: (context, index) => const Divider(height: 8),
      ),
      CollectionMode.grid => GridView.builder(
        key: const ValueKey('collection-scroll'),
        controller: _controller,
        primary: false,
        padding: const EdgeInsets.all(8),
        itemCount: 60,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.columns,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemBuilder: _buildItem,
      ),
    };
    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: Scrollbar(
                controller: _controller,
                thumbVisibility: true,
                child: scrollView,
              ),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => _goTo(false),
              child: const Text('В начало'),
            ),
            OutlinedButton(
              onPressed: () => _goTo(true),
              child: const Text('В конец'),
            ),
          ],
        ),
      ],
    );
  }
}
