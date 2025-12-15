import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? date;
  final String placeholder;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.date,
    required this.onTap,
    this.placeholder = 'Вибрати дату',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          date == null
              ? placeholder
              : '${date!.day}.${date!.month}.${date!.year}',
        ),
      ),
    );
  }
}
