// widgets/payment_filters.dart
import 'package:flutter/material.dart';

class PaymentFiltersDialog extends StatefulWidget {
  final String currentStatus;
  final String currentType;
  final DateTime? currentDate;
  final Function(String, String, DateTime?) onApply;

  const PaymentFiltersDialog({
    super.key,
    required this.currentStatus,
    required this.currentType,
    required this.currentDate,
    required this.onApply,
  });

  @override
  State<PaymentFiltersDialog> createState() => _PaymentFiltersDialogState();
}

class _PaymentFiltersDialogState extends State<PaymentFiltersDialog> {
  late String _selectedStatus;
  late String _selectedType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    _selectedType = widget.currentType;
    _selectedDate = widget.currentDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Payments'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterSection(
            title: 'Status',
            options: const ['all', 'pending', 'paid', 'failed'],
            labels: const ['All', 'Pending', 'Paid', 'Failed'],
            selected: _selectedStatus,
            onChanged: (value) => setState(() => _selectedStatus = value),
          ),
          const SizedBox(height: 16),
          _buildFilterSection(
            title: 'Type',
            options: const ['all', 'seller_payment', 'refund'],
            labels: const ['All', 'Seller Payment', 'Refund'],
            selected: _selectedType,
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          const SizedBox(height: 16),
          _buildDateFilter(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedStatus = 'all';
              _selectedType = 'all';
              _selectedDate = null;
            });
            widget.onApply('all', 'all', null);
            Navigator.pop(context);
          },
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_selectedStatus, _selectedType, _selectedDate);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required List<String> labels,
    required String selected,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(options.length, (index) {
            final isSelected = selected == options[index];
            return ChoiceChip(
              label: Text(labels[index]),
              selected: isSelected,
              onSelected: (selected) => onChanged(options[index]),
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'No date selected'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: TextStyle(
                  color: _selectedDate == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            if (_selectedDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _selectedDate = null),
              ),
          ],
        ),
      ],
    );
  }
}