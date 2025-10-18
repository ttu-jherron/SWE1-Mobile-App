import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat; // add intl in pubspec if not present
import 'package:mobile_app/app.dart';
import 'package:mobile_app/core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import '../../assets/data/asset.dart';
import 'package:mobile_app/features/assets/data/asset_repository.dart';
import '../data/maintenance_entry.dart';
import 'package:mobile_app/features/maintenance/data/maintenance_store.dart';
import '../../../core/data/data_handler.dart';
import 'package:clerk_flutter/clerk_flutter.dart';


//DROP DOWN ASSET NAMES
//ADD TABLE

class AddMaintenancePage extends StatefulWidget {
  const AddMaintenancePage({super.key});

  @override
  State<AddMaintenancePage> createState() => _EditMaintenancePageState();
}

class _EditMaintenancePageState extends State<AddMaintenancePage> {
  // Controllers
  final _completionDateCtrl = TextEditingController();
  final _shortDescriptionCtrl = TextEditingController();
  String? _assetName;
  final _notesCtrl = TextEditingController();
  final _requiredToolsCtrl = TextEditingController();
  final _toolLocationsCtrl = TextEditingController();
  final List<TextEditingController> controllers1 = [];
  final List<TextEditingController> controllers2 = [];
  late final List<Asset> _currentAssets;
  
  DateTime? _date = DateTime.now().add(const Duration(days: 7));

  String? _assetId;
  //ADDING DYNAMIC DATA
  
  @override
    void initState() {
      super.initState();
      // Initialize with 4 rows
      for (int i = 0; i < 4; i++) {
        controllers1.add(TextEditingController());
        controllers2.add(TextEditingController());
    }

    _currentAssets = assetRepository.getAll(); // implement .all() if you don't have it yet
    if (_currentAssets.isNotEmpty) _assetId = _currentAssets.first.id; // default selection
    //WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromSources());
  }

  @override
    // Future<void> _prefillFromSources() async {
    // final auth = ClerkAuth.of(context);
    // final u = auth.user;
    // Map<String, dynamic>? backend;
    // try {
    //   final dh = DataHandler.fromContext(context);
    //   backend = await dh.backendFetchProfile(force: true);
    // } catch (_) {
    //   // ignore; will fall back to Clerk-only data
    // }

    // if (!mounted) return;
    // setState(() {
    //   _completionDateCtrl.text =
    //       (backendUsername?.trim().isNotEmpty == true ? backendUsername : u?.username)?.trim() ?? '';
    //   _shortDescriptionCtrl.text =
    //       (backendEmail?.trim().isNotEmpty == true ? backendEmail : u?.email)?.trim() ?? '';
    //   _notesCtrl.text = (backendFirst ?? u?.firstName ?? '').trim();
    //   _requiredToolsCtrl.text = (backendLast ?? u?.lastName ?? '').trim();
    //   _toolLocationsCtrl.text = (backendPhone ?? '').trim();
    // });
  // }

  //for the date picker
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

  // void _submit() {
  //   if (!_formKey.currentState!.validate()) return;
  //   if (_assetId == null || _date == null) return;

  //   final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
  //   final entry = MaintenanceEntry(
  //     id: id,
  //     assetId: _assetId!,
  //     date: _date!,
  //     summary: _summaryCtrl.text.trim(),
  //     notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
  // // Local in-memory save
  //   maintenanceStore.add(entry);
  //   );


  // VALIDTION USING ASTERICKS (*)
  void _showValidationErrorDialog(BuildContext context) {
    final String contentMessage = 'The field(s) with an asterick (*) must be filled out in order to save the asset.';
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Required Information Missing'),
          content: Text(contentMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // ----------------------------------------------------
  

  //FIX VALIDATION: works too well

  // --- LOGIC: Pass the data back to the calling screen (My Assets Page) ---
  void _addMaintenance() {
    //validation + error message
    final List<String> missingFields = [];

    // // 1. Asset Name
    // if (_assetId == null) {
    //   missingFields.add('Asset Name');
    // }
    // // 2. Completion Date
    // if (_completionDateCtrl.text.isEmpty) {
    //   missingFields.add('Completion Date');
    // }
    // // 2. Short Description
    // if (_shortDescriptionCtrl.text.isEmpty) {
    //   missingFields.add('Description');
    // }

    // if (missingFields.isNotEmpty) {
    //   _showValidationErrorDialog(context);
    //   return; 
    // }

    debugPrint('MISSING FIELDS: ): $missingFields');
    
    final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
    final entry = MaintenanceEntry(
      id: id,
      assetId: _assetId!,
      date: _date!,
      summary: _shortDescriptionCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    maintenanceStore.add(entry);

    debugPrint('Asset data captured (Passed via routing): $entry');

    Navigator.pop(context); // close sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Maintenance added')),
    );
  }
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments;
    Asset? a;
    if (args is Asset) {
      a = args;
    } else if (args is String) {
      try {
        a = assetRepository.getAll().firstWhere((x) => x.id == args);
      } catch (_) {
        a = null;
      }
    }

    return AppLayout(
      currentIndex: 2,
        body: Scaffold(
        backgroundColor: Colors.white, 
        body: SingleChildScrollView(
          child: Padding( 
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Edit Maintenance",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black87,
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
                const SizedBox(height: Spacing.lg), 
                Text(
                  "* - Must be filled out",
                  style: const TextStyle(
                    color: AppColors.ebonyClay,
                    fontSize: TypographyScale.field,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                
                if (a == null)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Asset not found', style: TextStyle(color: Colors.black87)),
                  )
                else

                // Form Fields
                _buildConditionDropdown("Asset Name *", _assetName, (newValue) {
                  setState(() => _assetName = newValue);
                }),

                _buildDatePicker("Completion Date (MM/DD/YYYY) *", _completionDateCtrl, TextInputType.datetime),
                
                _buildTextField("Short Description *", _shortDescriptionCtrl, TextInputType.text),
                _buildTextField("Notes", _notesCtrl, TextInputType.text),
                _buildTextTable(context, "Needed Materials", controllers1, controllers2, TextInputType.text),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      controllers1.add(TextEditingController());
                      controllers2.add(TextEditingController());
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.ebonyClay,
                    size: 14),
                  label: const Text(
                    "Add Row",
                    style: TextStyle(
                      color: AppColors.ebonyClay,
                      fontSize: TypographyScale.field,
                      fontWeight: FontWeight.bold,
                    ),),
                ),
                
                const SizedBox(height: Spacing.xxl), 
          
                // Button
                Center(
                  child: ElevatedButton(
                    onPressed:
                      _addMaintenance,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.ebonyClay,
                      foregroundColor: AppColors.sandyYellow,
                      padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.xl, vertical: Spacing.sm),
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
      );
  }

  //CUSTOM COMPONENTS ------------------------------------------------------

  final df = DateFormat('MM dd, yyyy');
  //Custom Date Picker widget
  Widget _buildDatePicker(
    String label, TextEditingController controller, TextInputType type, {bool readOnly = false}){
    return Padding(
      padding:  const EdgeInsets.only(top: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ebonyClay,
              fontSize: TypographyScale.field,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                filled: true,
                fillColor: readOnly ? Colors.white : AppColors.lightGrey,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: Spacing.xs, horizontal: Spacing.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Radii.sm),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Radii.sm),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Radii.sm),
                  borderSide: const BorderSide(color: AppColors.ebonyClay, width: 2.0),
                ),
              ),
              child: Text(df.format(_date ?? DateTime.now())),
            ),
          ),
        ],
      ),
    );
    }

  // Custom text field component 
  Widget _buildTextField(
      String label, TextEditingController mainController, TextInputType type, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ebonyClay,
              fontSize: TypographyScale.field,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          TextField(
            controller: mainController,
            keyboardType: type,
            readOnly: readOnly,
            style: const TextStyle(color: AppColors.ebonyClay),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? Colors.white : AppColors.lightGrey,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: Spacing.xs, horizontal: Spacing.sm),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.sm),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.sm),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.sm),
                borderSide: const BorderSide(color: AppColors.ebonyClay, width: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom dropdown component 
  Widget _buildConditionDropdown(String label, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //dropdown menu label
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ebonyClay,
              fontSize: TypographyScale.field,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: Spacing.xs),

          DropdownButtonFormField<String>(
            initialValue: _assetName,
            //selected text style
            style: const TextStyle(
              color: AppColors.ebonyClay, // text color inside the box
              fontSize: TypographyScale.field,
            ),
            //drop down menu background
            dropdownColor: AppColors.lightGrey,
            //drop down decorations
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.lightGrey,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: Spacing.xs, horizontal: Spacing.sm
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.sm),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.sm),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.sm),
                borderSide: const BorderSide(color: AppColors.lightGrey, width: 2.0),
              ),
            ),
            value: _assetId,
                items: _currentAssets
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.brand} — ${a.title}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => 
                  _assetId = v),
                validator: (v) => v == null ? 'Select an asset' : null,
          ),
        ],
      ),
    );
  }
}

Widget _buildTextTable(
  BuildContext context,
  String label,
  List<TextEditingController> controllers1,
  List<TextEditingController> controllers2,
  TextInputType type, {
  bool readOnly = false,
}) {
  // total column width = 250 + gap + 250 = 250 + Spacing.md + 250
  final double totalWidth = 250 + Spacing.md + 250;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          label,
          style: const TextStyle(
            color: AppColors.ebonyClay,
            fontSize: TypographyScale.field,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: Spacing.xs),

        // Horizontal scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 1.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: Text(
                        "Tools",
                        style: const TextStyle(
                          color: AppColors.ebonyClay,
                          fontSize: TypographyScale.field,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    SizedBox(
                      width: 250,
                      child: Text(
                        "Current Location",
                        style: const TextStyle(
                          color: AppColors.ebonyClay,
                          fontSize: TypographyScale.field,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Spacing.xs),

                // Divider Bar
                SizedBox(
                  width: totalWidth,
                  child: Divider(
                    thickness: 2,
                    color: AppColors.lightGrey,
                  ),
                ),

                const SizedBox(height: Spacing.xs),

                // START OF THE TABLE
                Column(
                  children: List<Widget>.generate(
                    controllers1.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.xs),
                        child: Row(
                          children: [
                            // Tool input box
                            SizedBox(
                              width: 250,
                              child: _buildTextInput(
                                controller: controllers1[index],
                                type: type,
                                readOnly: readOnly,
                                currentValue: ' '//MAKE CONDITIONAL
                              ),
                            ),

                            const SizedBox(width: Spacing.xs),

                            // Location input box
                            SizedBox(
                              width: 250,
                              child: _buildTextInput(
                                controller: controllers2[index],
                                type: type,
                                readOnly: readOnly,
                                currentValue: ' ' //MAKE CONDITIONAL
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


Widget _buildTextInput({required TextEditingController controller,required TextInputType type, required currentValue, required bool readOnly,}) {
  return TextField(
    controller: controller,
    keyboardType: type, 
    readOnly: readOnly,
    style: const TextStyle(color: AppColors.ebonyClay),
    decoration: InputDecoration(
      hintText: currentValue,
      filled: true,
      fillColor: readOnly ? Colors.white : AppColors.lightGrey,
      contentPadding: const EdgeInsets.symmetric(
        vertical: Spacing.xs,
        horizontal: Spacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: const BorderSide(
          color: AppColors.ebonyClay,
          width: 2.0,
        ),
      ),
    ),
  );
}
