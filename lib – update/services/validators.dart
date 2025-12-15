class Validators {
  /// Перевірка текстових полів (обов’язкових)
  static String? required(String? value, {String message = 'Обов’язкове поле'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Валідація напрямків (destinations)
  /// Формат: "Рим, Італія" або список через кому
  static String? destinations(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Вкажіть напрямок';
    }

    final list = value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (list.isEmpty) {
      return 'Вкажіть хоча б одне місце';
    }

    if (list.length > 5) {
      return 'Максимум 5 напрямків';
    }

    return null;
  }

  /// Валідація бюджету
  static String? budget(String? value) {
    if (value == null || value.trim().isEmpty) return null; // необов'язкове поле

    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Введіть число';
    }

    if (parsed <= 0) {
      return 'Бюджет не може бути від’ємним';
    }

    if (parsed > 1000000) {
      return 'Занадто велике значення';
    }

    return null;
  }

  /// Валідація дат (викликається вручну перед сабмітом)
  static String? dateOrder(DateTime? start, DateTime? end) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (start == null || end == null) {
      return 'Оберіть початок та кінець подорожі';
    }

    // ❗ Забороняємо вибирати минулу дату
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    if (normalizedStart.isBefore(normalizedToday)) {
      return 'Дата початку не може бути ранішою за сьогодні';
    }

    if (normalizedEnd.isBefore(normalizedToday)) {
      return 'Дата завершення не може бути ранішою за сьогодні';
    }

    // ❗ Дата кінця має бути після початку
    if (normalizedEnd.isBefore(normalizedStart)) {
      return 'Дата кінця має бути після дати початку';
    }

    return null;
  }

}
