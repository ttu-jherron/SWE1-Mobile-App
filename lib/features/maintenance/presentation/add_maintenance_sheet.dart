import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mobile_app/core/data/data_handler.dart';
import 'package:mobile_app/features/assets/data/asset_store.dart';
import '../../assets/data/asset.dart';
import 'package:mobile_app/features/maintenance/data/maintenance_store.dart';
import 'package:mobile_app/features/assets/data/asset_repository.dart';
import '../../assets/data/asset_repository.dart';
import '../data/maintenance_entry.dart';
import '../data/maintenance_store.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';

const String _demoUserId = 'user_33UeIDzYloCoZABaaCR1WPmV7MT';

class AddMaintenanceSheet extends StatefulWidget {
  const AddMaintenanceSheet({super.key});

  @override
  State<AddMaintenanceSheet> createState() => _AddMaintenanceSheetState();
}

class _AddMaintenanceSheetState extends State<AddMaintenanceSheet> {
  final _formKey = GlobalKey<FormState>();

  // State variables
  String? _assetId;
  DateTime? _dueDate = DateTime.now();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedStatus = 'Upcoming';

  List<Asset> _assets = [];
  bool _isLoadingAssets = true;

  // Helper: truncate long labels to 100 chars with ellipsis
  String _assetLabel(Asset a) {
    final s = '${a.brand} — ${a.title}';
    return s.length <= 100 ? s : '${s.substring(0, 100)}…';
  }

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    // Use the assetStore to get the cached list of assets
    final fetchedAssets = assetStore.all();
    if (mounted) {
      setState(() {
        _assets = fetchedAssets;
        // Set a default selection if the list is not empty
        if (_assets.isNotEmpty) {
          _assetId = _assets.first.id;
        }
        _isLoadingAssets = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDate: initial,
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_assetId == null || _dueDate == null) return;

    Asset asset = assetStore.getById(_assetId!);
    final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
    final entry = MaintenanceEntry(
      id: id,
      assetId: _assetId!,
      brandName: asset.brand,
      productName: asset.name,
      assetCategory: asset.category,
      costPaid: asset.price,
      maintenanceDueDate: _dueDate!,
      maintenanceTitle: _titleController.text.trim(),
      maintenanceDescription: _descriptionController.text.trim(),
      maintenanceStatus: _selectedStatus!,
      preserveFromPrior: false,
      isCompleted: false,
    );

    try {
      await maintenanceStore.add(entry);
      Navigator.pop(context); // close sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance added')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add maintenance: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM dd, yyyy');

    return SafeArea(
      child: SingleChildScrollView(
        // ADD this padding to shift content above keyboard
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          color: AppColors.ebonyClay,
          padding: const EdgeInsets.fromLTRB(Spacing.xl, Spacing.lg, Spacing.xl, Spacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  const Text('Add Maintenance',
                      style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 18)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Asset picker
              _isLoadingAssets ? const Center(child: CircularProgressIndicator()) : DropdownButtonFormField<String>(
                  value: _assetId,
                  isExpanded: true,
                  menuMaxHeight: kMinInteractiveDimension * 4, // show 4 items, then scroll
                  items: _assets.map((a) {
                    return DropdownMenuItem(
                      value: a.id,
                      child: Text(
                        _assetLabel(a),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return _assets.map<Widget>((a) {
                      return Text(
                        _assetLabel(a),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }).toList();
                  },
                  onChanged: (v) => setState(() => _assetId = v),
                  decoration: const InputDecoration(
                    labelText: 'Asset',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null ? 'Select an asset' : null,
                ),
              const SizedBox(height: Spacing.md),



              // Maintenance Due Date
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Maintenance Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(df.format(_dueDate ?? DateTime.now())),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Maintenance Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Maintenance Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a maintenance title'
                    : null,
              ),
              const SizedBox(height: Spacing.md),

              // Maintenance Description
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Maintenance Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Maintenance Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'Overdue', child: Text('Overdue')),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value),
                decoration: const InputDecoration(
                  labelText: 'Maintenance Status',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Select a status' : null,
              ),
              const SizedBox(height: Spacing.md),



              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ebonyClay,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xl, vertical: Spacing.sm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
  );
}
}