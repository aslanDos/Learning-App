// В консольном уроке print нужен для наблюдения за порядком выполнения.
// ignore_for_file: avoid_print

import 'dart:async';

Future<String> loadName() async {
  // Начало async-функции выполняется сразу.
  print('2. loadName: до await');

  // Имитируем ожидание ответа, не блокируя isolate.
  await Future<void>.delayed(const Duration(milliseconds: 50));

  print('5. loadName: после await');
  return 'Алия';
}

Future<void> main() async {
  print('1. Начало main');
  final nameFuture = loadName();
  print('3. main продолжает работу');

  // Таймер сможет выполниться, пока loadName ожидает.
  Timer.run(() {
    print('4. Другое событие во время ожидания');
  });

  // Приостанавливаем main, но не весь isolate.
  final name = await nameFuture;
  print('6. Получено имя: $name');
}
