import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/expense.dart';
import '../../../models/trip.dart';
import '../../../providers/expenses_provider.dart';
import '../../../providers/trip_provider.dart';

class ExpensesScreen extends StatefulWidget {
  static const routeName = '/expenses';
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late final String tripId;
  String _filter = 'all';
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    tripId = ModalRoute.of(context)!.settings.arguments as String;
    context.read<ExpensesProvider>().loadForTrip(tripId);
    _loaded = true;
  }

  // ===== TRIP HELPERS =====

  Trip _trip() =>
      context.read<TripProvider>().getById(tripId)!;

  double get _budget => _trip().budget;
  String get _currency => _trip().currency;
  int get _days => _trip().duration > 0 ? _trip().duration : 1;
  DateTime get _startDate => _trip().startDate;

  // ===== FILTER =====

  List<Expense> _filtered(List<Expense> items) {
    if (_filter == 'all') return items;
    return items.where((e) => e.category == _filter).toList();
  }

  double _total(List<Expense> items) =>
      items.fold(0.0, (p, e) => p + e.amount);

  // ===== ADD DIALOG =====

  Future<void> _showAddDialog() async {
    final provider = context.read<ExpensesProvider>();
    final formKey = GlobalKey<FormState>();

    final titleCtl = TextEditingController();
    final amountCtl = TextEditingController();
    final dateCtl = TextEditingController();

    String category = 'other';

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Додати витрату'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: titleCtl,
                  decoration: const InputDecoration(labelText: 'Назва'),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Введіть назву' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountCtl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Сума'),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Некоректна сума';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: dateCtl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Дата',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Дата обовʼязкова' : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: _startDate,
                      firstDate: _startDate,
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      dateCtl.text =
                          picked.toIso8601String().split('T').first;
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration:
                  const InputDecoration(labelText: 'Категорія'),
                  items: const [
                    DropdownMenuItem(
                        value: 'accommodation',
                        child: Text('Проживання')),
                    DropdownMenuItem(
                        value: 'food', child: Text('Їжа')),
                    DropdownMenuItem(
                        value: 'transport', child: Text('Транспорт')),
                    DropdownMenuItem(
                        value: 'other', child: Text('Інше')),
                  ],
                  onChanged: (v) => category = v ?? 'other',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Скасувати')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final amount = double.parse(amountCtl.text);
              final currentTotal =
              _total(provider.expenses);
              if (currentTotal + amount > _budget) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Перевищення бюджету')),
                );
                return;
              }

              final expense = Expense(
                id: '',
                title: titleCtl.text.trim(),
                amount: amount,
                category: category,
                date: DateTime.parse(dateCtl.text),
              );

              await provider.addExpense(tripId, expense);
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );

    if (res == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Витрату додано')),
      );
    }
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpensesProvider>();
    final expenses = provider.expenses;
    final filtered = _filtered(expenses);

    final total = _total(expenses);
    final remain = _budget - total;
    final percent = _budget > 0 ? (total / _budget).clamp(0.0, 1.0) : 0.0;
    final avgPerDay = total / _days;

    return Scaffold(
      appBar: AppBar(title: const Text('Витрати')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            children: [
              // ===== HEADER =====
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text('ВИКОРИСТАНО'),
                            Text(
                              '$_currency${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('ЗАЛИШОК'),
                            Text(
                              '$_currency${remain.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: percent),
                    const SizedBox(height: 8),
                    Text(
                        '${(percent * 100).toStringAsFixed(0)}% від бюджету'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ===== FILTERS =====
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('all', 'Усі'),
                    _chip('accommodation', 'Проживання'),
                    _chip('food', 'Їжа'),
                    _chip('transport', 'Транспорт'),
                    _chip('other', 'Інше'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ===== LIST =====
              if (filtered.isEmpty)
                const Center(child: Text('Немає витрат'))
              else
                ...filtered.map((e) => Card(
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text(
                        e.date.toIso8601String().split('T').first),
                    trailing: Text(
                        '$_currency${e.amount.toStringAsFixed(2)}'),
                    onLongPress: () =>
                        context.read<ExpensesProvider>().deleteExpense(
                          tripId,
                          e.id,
                        ),
                  ),
                )),

              const SizedBox(height: 12),

              // ===== AVG =====
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        'Середньо на день: ${avgPerDay.toStringAsFixed(2)}'),
                    Text('Днів: $_days'),
                  ],
                ),
              ),
            ],
          ),

          // ===== ADD =====
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('Додати витрату'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == key,
        onSelected: (_) => setState(() => _filter = key),
      ),
    );
  }
}
