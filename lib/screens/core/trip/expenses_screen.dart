import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/expense.dart';
import '../../../models/trip.dart';
import '../../../providers/expenses_provider.dart';
import '../../../providers/trip_provider.dart';
import '../../../widgets/date_picker_field.dart';

class ExpensesScreen extends StatefulWidget {
  static const routeName = '/expenses';
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late final String tripId;
  bool _loaded = false;
  String _filter = 'all';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    tripId = ModalRoute.of(context)!.settings.arguments as String;
    context.read<ExpensesProvider>().loadForTrip(tripId);
    _loaded = true;
  }

  // ===== TRIP =====

  Trip _trip() => context.read<TripProvider>().getById(tripId)!;
  double get _budget => _trip().budget;
  String get _currency => _trip().currency;
  int get _days => _trip().duration > 0 ? _trip().duration : 1;

  // ===== ICONS =====

  IconData _icon(String c) {
    switch (c) {
      case 'accommodation':
        return Icons.hotel_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _color(String c) {
    switch (c) {
      case 'accommodation':
        return Colors.indigo;
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ===== FILTER =====

  List<Expense> _filtered(List<Expense> list) {
    if (_filter == 'all') return list;
    return list.where((e) => e.category == _filter).toList();
  }

  // ============================================================
  // ADD / EDIT DIALOG
  // ============================================================

  void _showExpenseDialog({Expense? expense}) {
    final isEdit = expense != null;

    final titleCtl = TextEditingController(text: expense?.title ?? '');
    final amountCtl =
    TextEditingController(text: expense?.amount.toString() ?? '');

    DateTime? date = expense?.date;
    String category = expense?.category ?? 'other';

    final trip = _trip();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isEdit ? 'Редагувати витрату' : 'Додати витрату'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleCtl,
                  decoration: const InputDecoration(labelText: 'Назва'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Сума'),
                ),
                const SizedBox(height: 12),

                // ===== DATE FIELD =====
                DatePickerField(
                  date: date,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date ?? trip.startDate,
                      firstDate: trip.startDate, // ✅ від початку
                      lastDate: trip.endDate,   // ✅ до кінця
                    );
                    if (picked != null) {
                      setState(() => date = picked);
                    }
                  },
                ),

                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Категорія'),
                  items: const [
                    DropdownMenuItem(
                        value: 'accommodation', child: Text('Проживання')),
                    DropdownMenuItem(value: 'food', child: Text('Їжа')),
                    DropdownMenuItem(
                        value: 'transport', child: Text('Транспорт')),
                    DropdownMenuItem(value: 'other', child: Text('Інше')),
                  ],
                  onChanged: (v) => category = v ?? 'other',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtl.text);

                if (titleCtl.text.trim().isEmpty ||
                    amount == null ||
                    amount <= 0 ||
                    date == null) {
                  return;
                }

                // 🔥 ЖОРСТКА ВАЛІДАЦІЯ ДАТИ
                if (date!.isBefore(trip.startDate) ||
                    date!.isAfter(trip.endDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Дата витрати поза межами подорожі'),
                    ),
                  );
                  return;
                }

                final provider = context.read<ExpensesProvider>();

                if (isEdit) {
                  await provider.updateExpense(
                    tripId,
                    expense!.copyWith(
                      title: titleCtl.text.trim(),
                      amount: amount,
                      category: category,
                      date: date!,
                    ),
                  );
                } else {
                  await provider.addExpense(
                    tripId,
                    Expense(
                      id: '',
                      title: titleCtl.text.trim(),
                      amount: amount,
                      category: category,
                      date: date!,
                    ),
                  );
                }

                Navigator.pop(ctx);
              },
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpensesProvider>();
    final expenses = provider.expensesForTrip(tripId);
    final filtered = _filtered(expenses);

    final total = provider.totalForTrip(tripId);
    final remain = _budget - total;
    final percent =
    _budget > 0 ? (total / _budget).clamp(0.0, 1.0) : 0.0;
    final avgPerDay = total / _days;

    return Scaffold(
      appBar: AppBar(title: const Text('Витрати')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            children: [
              // ===== HEADER =====
              Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ВИКОРИСТАНО',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_currency${total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'ЗАЛИШОК',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_currency${remain.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: percent),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          '${(percent * 100).toStringAsFixed(0)}% від бюджету',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (filtered.isEmpty)
                const Center(child: Text('Немає витрат'))
              else
                ...filtered.map(
                      (e) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        _color(e.category).withOpacity(0.15),
                        child: Icon(_icon(e.category),
                            color: _color(e.category)),
                      ),
                      title: Text(e.title),
                      subtitle: Text(
                          '${e.date.day}.${e.date.month}.${e.date.year}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_currency${e.amount.toStringAsFixed(2)}'),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showExpenseDialog(expense: e),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                provider.deleteExpense(tripId, e.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              Text('Середньо на день: ${avgPerDay.toStringAsFixed(2)}'),
            ],
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: ElevatedButton.icon(
              onPressed: () => _showExpenseDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Додати витрату'),
            ),
          ),
        ],
      ),
    );
  }
}
