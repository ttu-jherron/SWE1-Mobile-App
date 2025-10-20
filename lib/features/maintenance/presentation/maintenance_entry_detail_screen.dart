import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/data/data_handler.dart';
import 'package:mobile_app/features/assets/data/asset_store.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/layout/app_layout.dart';
import '../../../core/routing.dart';
import '../data/maintenance_entry.dart';

class MaintenanceEntryDetailScreen extends StatefulWidget {
  final MaintenanceEntry entry;

  const MaintenanceEntryDetailScreen({super.key, required this.entry});

  @override
  State<MaintenanceEntryDetailScreen> createState() => _MaintenanceEntryDetailScreenState();
}

class _MaintenanceEntryDetailScreenState extends State<MaintenanceEntryDetailScreen> {
  late MaintenanceEntry _currentEntry;

  // Controllers for inline editing
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;
  late DateTime _dueDate;
  late bool _isCompleted;
  bool _editingTitle = false; // <-- Add this state variable

  final _df = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
    _titleController = TextEditingController(text: _currentEntry.maintenanceTitle);
    _descriptionController = TextEditingController(text: _currentEntry.maintenanceDescription);
    _costController = TextEditingController(text: _currentEntry.costPaid.toStringAsFixed(2));
    _dueDate = _currentEntry.maintenanceDueDate;
    _isCompleted = _currentEntry.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    DateTime initial = _dueDate;
    if (initial.isBefore(firstDate)) {
      initial = firstDate;
    }
    final picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 100),
      initialDate: initial,
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveField(String field) async {
    final dh = DataHandler.fromContext(context);
    final maintenanceId = _currentEntry.id;
    Map<String, dynamic> patch = {};

    setState(() {
      switch (field) {
        case 'title':
          _currentEntry = _currentEntry.copyWith(maintenanceTitle: _titleController.text);
          patch = {'maintenanceTitle': _titleController.text};
          break;
        case 'description':
          _currentEntry = _currentEntry.copyWith(maintenanceDescription: _descriptionController.text);
          patch = {'maintenanceDescription': _descriptionController.text};
          break;
        case 'cost':
          final cost = double.tryParse(_costController.text) ?? _currentEntry.costPaid;
          _currentEntry = _currentEntry.copyWith(costPaid: cost);
          patch = {'costPaid': cost};
          break;
        case 'dueDate':
          _currentEntry = _currentEntry.copyWith(maintenanceDueDate: _dueDate);
          patch = {'maintenanceDueDate': _dueDate.toIso8601String()};
          break;
        case 'completed':
          _currentEntry = _currentEntry.copyWith(isCompleted: _isCompleted);
          patch = {'isCompleted': _isCompleted};
          if (_isCompleted) {
            patch.addAll({'status': 'Completed'});
          }
          break;
      }
    });

    if (patch.isNotEmpty) {
      try {
        await dh.updateMaintenance(maintenanceId: maintenanceId, patch: patch);
      } catch (e) {
        // Optionally show error to user
        debugPrint('Failed to update maintenance: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 2,
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            // Header row: Maintenance Detail and X button
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 30, right: 16, bottom: 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Maintenance Detail',
                      style: const TextStyle(
                        color: AppColors.ebonyClay,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.ebonyClay,
                      size: 32,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Colored status above asset name
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.lg, top: 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
                        decoration: BoxDecoration(
                          color: _currentEntry.maintenanceStatus == 'Overdue'
                              ? Colors.red.withOpacity(0.1)
                              : _currentEntry.maintenanceStatus == 'Completed'
                                  ? Colors.green.withOpacity(0.1)
                                  : _currentEntry.maintenanceStatus == 'Upcoming'
                                      ? AppColors.darkGold.withOpacity(0.1)
                                      : AppColors.ebonyClay.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentEntry.maintenanceStatus,
                          style: TextStyle(
                            color: _currentEntry.maintenanceStatus == 'Overdue'
                                ? Colors.red
                                : _currentEntry.maintenanceStatus == 'Completed'
                                    ? Colors.green
                                    : _currentEntry.maintenanceStatus == 'Upcoming'
                                        ? AppColors.darkGold
                                        : AppColors.ebonyClay,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Asset Name as plain text
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Asset Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_currentEntry.brandName} ${_currentEntry.productName}',
                            style: const TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                    // Editable Maintenance Title
                    _InlineEditableField(
                      label: 'Maintenance Title',
                      controller: _titleController,
                      onSave: () => _saveField('title'),
                      maxLines: 2,
                      style: const TextStyle(
                        color: AppColors.ebonyClay,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    // Description (editable)
                    _InlineEditableField(
                      label: 'Description',
                      controller: _descriptionController,
                      onSave: () => _saveField('description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: Spacing.lg),
                    _InlineEditableDateField(
                      label: 'Due Date',
                      date: _dueDate,
                      onPick: () async {
                        await _pickDate();
                        _saveField('dueDate');
                      },
                    ),
                    const SizedBox(height: Spacing.lg),
                    _InlineEditableField(
                      label: 'Cost Paid',
                      controller: _costController,
                      onSave: () => _saveField('cost'),
                      keyboardType: TextInputType.number,
                      prefix: '\$',
                    ),
                    const SizedBox(height: Spacing.lg),
                    _InlineEditableCheckbox(
                      label: 'Completed',
                      value: _isCompleted,
                      onChanged: (val) {
                        setState(() {
                          _isCompleted = val ?? false;
                          _saveField('completed');
                        });
                      },
                    ),
                    const SizedBox(height: Spacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}

// Inline editable text field
class _InlineEditableField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;
  final int maxLines;
  final TextInputType keyboardType;
  final String? prefix;
  final TextStyle? style; // <-- Add this

  const _InlineEditableField({
    required this.label,
    required this.controller,
    required this.onSave,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.style, // <-- Add this
  });

  @override
  State<_InlineEditableField> createState() => _InlineEditableFieldState();
}

class _InlineEditableFieldState extends State<_InlineEditableField> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontWeight: FontWeight.w800,
      color: Colors.black87,
      fontSize: 16,
    );

    if (!_editing) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.label.isNotEmpty)
                  Text(widget.label, style: labelStyle),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (widget.prefix != null)
                      Text(widget.prefix!, style: const TextStyle(color: Colors.black54)),
                    Expanded(
                      child: Text(
                        widget.controller.text,
                        style: widget.style ?? const TextStyle(
                          color: AppColors.ebonyClay, // Ensure text is visible
                          fontSize: 15,
                        ),
                        maxLines: widget.maxLines,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
            tooltip: 'Edit',
            onPressed: () => setState(() => _editing = true),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Text(widget.label, style: labelStyle),
        const SizedBox(height: 4),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          style: widget.style ?? const TextStyle(
            color: AppColors.ebonyClay, // Ensure text is visible
            fontSize: 15,
          ),
          decoration: InputDecoration(
            prefixText: widget.prefix,
            isDense: true,
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.sandyYellow, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() => _editing = false);
                widget.onSave();
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save'),
              style: TextButton.styleFrom(foregroundColor: AppColors.ebonyClay),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => setState(() => _editing = false),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(foregroundColor: AppColors.ebonyClay),
            ),
          ],
        ),
      ],
    );
  }
}

// Inline editable date field
class _InlineEditableDateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onPick;

  const _InlineEditableDateField({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontWeight: FontWeight.w800,
      color: Colors.black87,
      fontSize: 16,
    );
    final _df = DateFormat('MMM dd, yyyy');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              const SizedBox(height: 4),
              Text(
                _df.format(date),
                style: const TextStyle(
                  color: AppColors.ebonyClay,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_calendar, color: Colors.black54, size: 20),
          tooltip: 'Edit Date',
          onPressed: onPick,
        ),
      ],
    );
  }
}

// Inline editable checkbox field
class _InlineEditableCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _InlineEditableCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontWeight: FontWeight.w800,
      color: Colors.black87,
      fontSize: 16,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 12),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.sandyYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: const BorderSide(
            color: AppColors.ebonyClay,
            width: 2,
          ),
        ),
      ],
    );
  }
}

// Non-editable detail row
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}