import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mobile_app/core/data/data_handler.dart';
import 'package:mobile_app/features/assets/data/asset_store.dart';
import '../../assets/data/asset.dart';
import '../../assets/data/asset_repository.dart';
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

  // State variables
  String? _assetId;
  DateTime? _date = DateTime.now();
  final _summaryCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

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
              if (_isLoadingAssets)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
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

              // Summary
              TextFormField(
                controller: _summaryCtrl,
                minLines: 1,
                maxLines: null, // grow to fit content
                textInputAction: TextInputAction.newline,
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
                minLines: 3,
                maxLines: null, // grow to fit content
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
