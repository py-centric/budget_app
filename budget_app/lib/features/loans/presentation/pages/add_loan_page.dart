import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/loans/domain/entities/loan.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_event.dart';

class AddLoanPage extends StatefulWidget {
  final Loan? existingLoan;

  const AddLoanPage({super.key, this.existingLoan});

  @override
  State<AddLoanPage> createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _loanDate = DateTime.now();
  LoanDirection _direction = LoanDirection.lent;
  bool _includeInProjections = false;

  bool get isEditing => widget.existingLoan != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingLoan != null) {
      _borrowerNameController.text = widget.existingLoan!.borrowerName;
      _amountController.text = widget.existingLoan!.loanAmount.toString();
      _loanDate = widget.existingLoan!.loanDate;
      _notesController.text = widget.existingLoan!.notes ?? '';
      _direction = widget.existingLoan!.direction;
      _includeInProjections = widget.existingLoan!.includeInProjections;
    }
  }

  @override
  void dispose() {
    _borrowerNameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Loan' : 'Add Loan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _borrowerNameController,
              decoration: const InputDecoration(
                labelText: 'Borrower Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter borrower name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Loan Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter loan amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid positive amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Loan Date'),
              subtitle: Text(
                '${_loanDate.day}/${_loanDate.month}/${_loanDate.year}',
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Add notes about this loan',
              ),
              maxLines: 3,
              maxLength: 1000,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loan Direction',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<LoanDirection>(
                      segments: const [
                        ButtonSegment(
                          value: LoanDirection.lent,
                          label: Text('Lent by Me'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                        ButtonSegment(
                          value: LoanDirection.owed,
                          label: Text('Owed to Me'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                      ],
                      selected: {_direction},
                      onSelectionChanged: (Set<LoanDirection> selected) {
                        setState(() {
                          _direction = selected.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include in Projections'),
              subtitle: const Text('Show in financial forecasts'),
              value: _includeInProjections,
              onChanged: (value) {
                setState(() {
                  _includeInProjections = value;
                });
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saveLoan,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(isEditing ? 'Update Loan' : 'Save Loan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _loanDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _loanDate = picked;
      });
    }
  }

  void _saveLoan() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final loan = Loan(
        id: widget.existingLoan?.id ?? 'loan_${now.millisecondsSinceEpoch}',
        borrowerName: _borrowerNameController.text.trim(),
        loanAmount: double.parse(_amountController.text),
        loanDate: _loanDate,
        status: widget.existingLoan?.status ?? LoanStatus.outstanding,
        remainingBalance:
            widget.existingLoan?.remainingBalance ??
            double.parse(_amountController.text),
        notes: notes,
        direction: _direction,
        includeInProjections: _includeInProjections,
        createdAt: widget.existingLoan?.createdAt ?? now,
        updatedAt: now,
      );

      if (isEditing) {
        context.read<LoanBloc>().add(UpdateLoan(loan));
      } else {
        context.read<LoanBloc>().add(AddLoan(loan));
      }

      Navigator.pop(context);
    }
  }
}
