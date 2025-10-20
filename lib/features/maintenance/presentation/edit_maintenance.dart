import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import '../data/maintenance_entry.dart';
import '../data/maintenance_store.dart';

//DROP DOWN ASSET NAMES
//ADD TABLE

class AddMaintenancePage extends StatefulWidget {
  const AddMaintenancePage({super.key});

  @override
  State<AddMaintenancePage> createState() => _EditMaintenancePageState();
}

class _EditMaintenancePageState extends State<AddMaintenancePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _costController = TextEditingController();
  final _recurrenceIntervalController = TextEditingController();
  final _recurrenceUnitController = TextEditingController();
  final _requiredToolsController = TextEditingController();
  final _toolLocationController = TextEditingController();

  // State variables
  String? _selectedStatus;
  DateTime? _dueDate;
  bool _isCompleted = false;
  MaintenanceEntry? _entry;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is MaintenanceEntry && !_initialized) {
      _entry = args;
      _initializeFields();
      _initialized = true;
    }
  }

  void _initializeFields() {
    if (_entry == null) return;
    _titleController.text = _entry!.maintenanceTitle;
    _descriptionController.text = _entry!.maintenanceDescription;
    _dueDate = _entry!.maintenanceDueDate;
    _dueDateController.text = DateFormat('MMM dd, yyyy').format(_entry!.maintenanceDueDate);
    _costController.text = _entry!.costPaid.toString();
    _selectedStatus = _entry!.maintenanceStatus;
    _isCompleted = _entry!.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _costController.dispose();
    _recurrenceIntervalController.dispose();
    _recurrenceUnitController.dispose();
    _requiredToolsController.dispose();
    _toolLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    DateTime initial = _dueDate ?? firstDate;
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
      final selectedDate = DateTime(picked.year, picked.month, picked.day);
      if (_dueDate == null || !_dueDate!.isAtSameMomentAs(selectedDate)) {
        setState(() {
          _dueDate = selectedDate;
          _dueDateController.text = DateFormat('MMM dd, yyyy').format(selectedDate);
        });
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_entry == null) return;

    // Additional validation for due date
    if (_dueDate != null && _dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 0)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance due date must be today or in the future')),
      );
      return;
    }

    final updatedEntry = MaintenanceEntry(
      id: _entry!.id,
      assetId: _entry!.assetId,
      brandName: _entry!.brandName,
      productName: _entry!.productName,
      assetCategory: _entry!.assetCategory,
      costPaid: double.tryParse(_costController.text) ?? _entry!.costPaid,
      maintenanceDueDate: _dueDate ?? _entry!.maintenanceDueDate,
      maintenanceTitle: _titleController.text.trim(),
      maintenanceDescription: _descriptionController.text.trim(),
      maintenanceStatus: _selectedStatus ?? _entry!.maintenanceStatus,
      preserveFromPrior: _entry!.preserveFromPrior,
      isCompleted: _isCompleted,
    );

    try {
      await maintenanceStore.update(updatedEntry); // This will update the existing entry
      Navigator.pop(context, updatedEntry); // Pass back the updated entry
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update maintenance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: 2,
      body: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Edit Maintenance",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.ebonyClay,
                            fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(), 
                        icon: const Icon(Icons.close, color: AppColors.ebonyClay, size:28),
                        tooltip: 'Close',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                  const SizedBox(height: Spacing.xxl),
                  Text(
                    "* - Must be filled out",
                    style: const TextStyle(
                      color: AppColors.ebonyClay,
                      fontSize: TypographyScale.field,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
      
                  // Title
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.ebonyClay),
                    decoration: InputDecoration(
                      labelText: 'Maintenance Title*',
                      labelStyle: TextStyle(color: AppColors.ebonyClay),
                      fillColor: AppColors.lightGrey,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.sm),
                        borderSide: const BorderSide(
                          color: AppColors.ebonyClay,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.sm),
                        borderSide: const BorderSide(
                          color: AppColors.ebonyClay,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter a maintenance title'
                        : null,
                  ),
                  const SizedBox(height: Spacing.md),
      
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: null,
                    readOnly: false,
                    style: const TextStyle(color: AppColors.ebonyClay),
                    decoration: InputDecoration(
                      labelText: 'Maintenance Description',
                      labelStyle: TextStyle(color: AppColors.ebonyClay),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: Spacing.xs,
                      horizontal: Spacing.sm,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.sm),
                      borderSide: const BorderSide(
                        color: AppColors.ebonyClay,
                        width: 2.0,
                        ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.sm),
                      borderSide: const BorderSide(
                        color: AppColors.ebonyClay,
                        width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
      
                  // Due Date
                  TextFormField(
                    controller: _dueDateController,
                    readOnly: true,
                    onTap: _pickDate,
                    style: const TextStyle(color: AppColors.ebonyClay),
                    decoration: InputDecoration(
                      labelText: 'Maintenance Due Date',
                      labelStyle: TextStyle(color: AppColors.ebonyClay),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: Spacing.xs, horizontal: Spacing.sm),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.sm),
                        borderSide: const BorderSide(
                          color: AppColors.ebonyClay,
                          width: 2.0,
                          ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.sm),
                        borderSide: const BorderSide(color: AppColors.ebonyClay, width: 2.0),
                      ),
                    ),
                  ),
                  if (_dueDate != null && _dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1))))
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Due date must be today or in the future',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: Spacing.md),
      
                  // Cost
                  TextFormField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.ebonyClay),
                    decoration: InputDecoration(
                      labelText: 'Cost Paid*',
                      labelStyle: TextStyle(color: AppColors.ebonyClay),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: Spacing.xs, horizontal: Spacing.sm),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.sm),
                        borderSide: const BorderSide(
                          color: AppColors.ebonyClay,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.sm),
                        borderSide: const BorderSide(color: AppColors.ebonyClay, width: 2.0),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Cost is required';
                      final cost = double.tryParse(v);
                      if (cost == null) return 'Enter a valid number';
                      if (cost < 0.01 || cost > 1000000) return 'Cost must be between 0.01 and 1,000,000';
                      return null;
                    },
                  ),
                  const SizedBox(height: Spacing.md),
      
                  // Completed Checkbox
                  CheckboxListTile(
                    title: const Text('Completed', style: TextStyle(color: AppColors.ebonyClay)),
                    value: _isCompleted,
                    onChanged: (value) => setState(() => _isCompleted = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    side: BorderSide(color: AppColors.ebonyClay, width:2.0),
                    activeColor: AppColors.ebonyClay,
                    checkColor: AppColors.nearWhite,
                  ),
                  const SizedBox(height: Spacing.xxl),
      
                  // Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ebonyClay,
                        foregroundColor: AppColors.sandyYellow,
                        padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xl, vertical: Spacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                      ),
                      child: const Text('Save Maintenance'),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}