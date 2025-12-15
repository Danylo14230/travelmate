import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/trip.dart';
import '../../../widgets/app_button.dart';
import '../../../services/validators.dart';
import '../../../providers/trip_provider.dart';

class CreateTripScreen extends StatefulWidget {
  static const routeName = '/create-trip';
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _destCtl = TextEditingController();
  final _budgetCtl = TextEditingController();

  DateTime? _start;
  DateTime? _end;
  String _currency = 'USD';

  bool _isLoadedFromArgs = false;
  Trip? _existingTrip;
  bool get _isEditing => _existingTrip != null;

  @override
  void dispose() {
    _titleCtl.dispose();
    _destCtl.dispose();
    _budgetCtl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoadedFromArgs) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Trip) {
      _existingTrip = args;
      _fillFromExisting(args);
    }
    _isLoadedFromArgs = true;
  }

  void _fillFromExisting(Trip t) {
    _titleCtl.text = t.title;
    _destCtl.text = t.destinations.join(', ');
    _currency = t.currency;
    _budgetCtl.text = t.budget.toString();
    _start = t.startDate;
    _end = t.endDate;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final duration =
    _start != null && _end != null ? _end!.difference(_start!).inDays + 1 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редагувати подорож' : 'Нова подорож'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleCtl,
                  decoration: const InputDecoration(
                    labelText: 'Назва подорожі *',
                  ),
                  validator: Validators.required,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _destCtl,
                  decoration: const InputDecoration(
                    labelText: 'Напрямок (через кому) *',
                  ),
                  validator: Validators.required,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _datePickerField(
                        label: 'Початок',
                        date: _start,
                        onTap: () => _pickStart(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _datePickerField(
                        label: 'Кінець',
                        date: _end,
                        onTap: () => _pickEnd(context),
                      ),
                    ),
                  ],
                ),

                if (duration > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Тривалість: $duration днів',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    DropdownButton<String>(
                      value: _currency,
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        DropdownMenuItem(value: 'UAH', child: Text('UAH')),
                      ],
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _budgetCtl,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Орієнтовний бюджет',
                        ),
                        validator: Validators.budget,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        outlined: true,
                        color: Colors.orange,
                        label: 'Скасувати',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: _isEditing ? 'Зберегти' : 'Створити',
                        onPressed: _onSave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // DATE PICKERS (ВИПРАВЛЕНІ)
  // =====================================================

  Widget _datePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final text = date == null
        ? 'Оберіть дату'
        : '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Future<void> _pickStart(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: _start ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _start = picked;

        // 🔥 якщо кінець був раніше — скидаємо
        if (_end != null && _end!.isBefore(_start!)) {
          _end = null;
        }
      });
    }
  }

  Future<void> _pickEnd(BuildContext ctx) async {
    final base = _start ?? DateTime.now();

    final picked = await showDatePicker(
      context: ctx,
      initialDate: _end ?? base,
      firstDate: base, // 🔥 не можна раніше старту
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _end = picked);
    }
  }

  // =====================================================
  // SAVE
  // =====================================================

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final dateError = Validators.dateOrder(_start, _end);
    if (dateError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(dateError)));
      return;
    }

    final duration = _end!.difference(_start!).inDays + 1;

    final trip = Trip(
      id: _existingTrip?.id ?? '',
      title: _titleCtl.text.trim(),
      startDate: _start!,
      endDate: _end!,
      duration: duration,
      destinations: _destCtl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      budget: double.tryParse(_budgetCtl.text) ?? 0,
      currency: _currency,
      readiness: _existingTrip?.readiness ?? 0,
    );

    final provider = context.read<TripProvider>();

    if (_isEditing) {
      await provider.updateTrip(trip);
    } else {
      await provider.addTrip(trip);
    }

    Navigator.of(context).pop(true);
  }
}
