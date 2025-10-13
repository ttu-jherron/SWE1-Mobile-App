import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat; // add intl in pubspec if not present
import '../../assets/data/asset.dart';            // your existing Asset model
import '../../assets/data/asset_repository.dart'; // where your burner assets live
import '../data/maintenance_entry.dart';
import '../data/maintenance_store.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';

class AddMaintenanceSheet extends StatefulWidget {
  const AddMaintenanceSheet({super.key});

  @override
  State<AddMaintenanceSheet> createState() => _AddMaintenanceSheetState();
}


class _AddMaintenanceSheetState extends State<AddMaintenanceSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _assetId;
  DateTime? _date = DateTime.now().add(const Duration(days: 7));
  final _summaryCtrl = TextEditingController();
  final _notesCtrl   = TextEditingController();

  late final List<Asset> _assets;

  @override
  void initState() {
    super.initState();
    // Burner: pull from your in-memory asset repo
    _assets = assetRepository.getAll(); // implement .all() if you don't have it yet
    if (_assets.isNotEmpty) _assetId = _assets.first.id; // default selection
  }

  @override
  void dispose() {
    _summaryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _date ?? now;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDate: initial,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_assetId == null || _date == null) return;

    final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
    final entry = MaintenanceEntry(
      id: id,
      assetId: _assetId!,
      date: _date!,
      summary: _summaryCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    // Local in-memory save
    maintenanceStore.add(entry);

    // TODO(backend): await api.createMaintenance(entry.toJson());
    // On success -> maintenanceStore.refresh(assetId); notifyListeners();

    Navigator.pop(context); // close sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Maintenance added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM dd, yyyy');

    return SafeArea(
      child: Padding(
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
              DropdownButtonFormField<String>(
                value: _assetId,
                items: _assets
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.brand} — ${a.title}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _assetId = v),
                decoration: const InputDecoration(
                  labelText: 'Asset',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Select an asset' : null,
              ),
              const SizedBox(height: Spacing.md),

              // Summary
              TextFormField(
                controller: _summaryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Summary (e.g., “Recharge battery”)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a summary'
                    : null,
              ),
              const SizedBox(height: Spacing.md),

              // Date picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(df.format(_date ?? DateTime.now())),
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Spacing.lg),

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
    );
  }
}
