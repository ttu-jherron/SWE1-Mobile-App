import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import the package
import 'package:mobile_app/app.dart';
import 'package:mobile_app/core/colors.dart';
import 'package:mobile_app/features/profile/presentation/clerk_data_handler.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../assets/data/asset.dart'; // change to maintenance page

//DROP DOWN ASSET NAMES
//ADD TABLE

class AddMaintenancePage extends StatefulWidget {
  const AddMaintenancePage({super.key});

  @override
  State<AddMaintenancePage> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends State<AddMaintenancePage> {
  // Controllers
  final _completionDate = TextEditingController();
  final _shortDescription = TextEditingController();
  String? _selectedCondition;
  final _notes = TextEditingController();
  final _requiredTools = TextEditingController();
  final _toolLocations = TextEditingController();
  final List<TextEditingController> controllers1 = [];
  final List<TextEditingController> controllers2 = [];

  final List<String> _currentAssets = [
    //  CHANGE TO LOGIC WHEN BACKEND
    'New',
    'Used - Like New',
    'Used - Good',
    'Used - Poor',
  ];

  @override
    void initState() {
    super.initState();
    // Initialize with 4 rows
    for (int i = 0; i < 4; i++) {
      controllers1.add(TextEditingController());
      controllers2.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _completionDate.dispose();
    _shortDescription.dispose();
    _notes.dispose();
    _requiredTools.dispose();
    _toolLocations.dispose();
    super.dispose();
    for (final c in controllers1) {
      c.dispose();
    }
    for (final c in controllers2) {
      c.dispose();
    }
  }


  // VALIDTION USING ASTERICKS (*)
  //--- Custom Dialog to show the list of missing fields ---
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
  

  // --- LOGIC: Pass the data back to the calling screen (My Assets Page) ---
  void _addMaintenance() {
    final List<String> missingFields = [];
    const double minPrice = 1.00;
    const double maxPrice = 300000.00;

    // 1. Brand Name
    if (_completionDate.text.isEmpty) {
      missingFields.add('Brand Name');
    }
    // 2. Asset Name
    if (_shortDescription.text.isEmpty) {
      missingFields.add('Asset Name');
    }
    // 3. Condition
    if (_selectedCondition == null) {
      missingFields.add('Condition');
    }
    // 4. Store
    if (_notes.text.isEmpty) {
      missingFields.add('Store');
    }
    // 5. Price (empty, invalid number, or out of range)
    final priceText = _requiredTools.text;
    final priceValue = double.tryParse(priceText);

    if (priceText.isEmpty) {
      missingFields.add('Price (cannot be empty)');
    } else if (priceValue == null) {
      missingFields.add('Price (must be a valid number)');
    } else if (priceValue < minPrice || priceValue > maxPrice) {
      missingFields.add('Price (must be between \$${minPrice.toStringAsFixed(2)} and \$${maxPrice.toStringAsFixed(2)})');
    }

    if (missingFields.isNotEmpty) {
      _showValidationErrorDialog(context);
      return; 
    }
    
    // Create the full new Asset object
    final newAsset = Asset(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      brand: _completionDate.text,
      title: _shortDescription.text, // Using name as title for simplicity
      name: '${_completionDate.text} ${_shortDescription.text}',
      
      // Purchase fields
      condition: _selectedCondition!,
      store: _notes.text,
      price: priceValue!, // Use the safely parsed and validated value
      
      // Default/placeholder values for Maintenance fields
      completionDate: DateTime.now().add(const Duration(days: 365)),
      shortDescription: 'Newly added asset.',
      notes: '',
      requiredMaterials: [],
    );

    debugPrint('Asset data captured (Passed via routing): ${newAsset.toJson()}');
    
    // Pass the new Asset object back to the previous screen
    Navigator.pop(context, newAsset); 
  }
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SingleChildScrollView(
        child: Padding( 
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Maintenance",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
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
        
              // Form Fields
              _buildConditionDropdown("AssetName *", _selectedCondition, (newValue) {
                setState(() => _selectedCondition = newValue);
              }),
              _buildTextField("Completion Date (MM/DD/YYYY) *", _completionDate, TextInputType.datetime),
              _buildTextField("Short Description *", _shortDescription, TextInputType.text),
              _buildTextField("Notes", _notes, TextInputType.text),
              _buildTextTable(context, "Required Materials", controllers1, controllers2, TextInputType.text),
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
                  style: const TextStyle(
                    color: AppColors.ebonyClay,
                    fontSize: TypographyScale.field,
                    fontWeight: FontWeight.bold,
                  ),),
              ),
              // _buildTextField("Tools", _requiredTools, TextInputType.text),
              // _buildTextField("Location", _toolLocations, TextInputType.text),
              
              const SizedBox(height: Spacing.xxl), 
        
              //SHRINK BUTTON
              // Button
              Center(
                child: ElevatedButton(
                  onPressed: _addMaintenance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ebonyClay,
                    foregroundColor: AppColors.sandyYellow,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xl, vertical: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                  ),
                  child: const Text('Save Asset'),
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  // Custom text field component 
  Widget _buildTextField(
      String label, TextEditingController controller, TextInputType type, {bool readOnly = false}) {
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
            controller: controller,
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
            initialValue: _selectedCondition,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.lightGrey,
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
                borderSide: const BorderSide(color: AppColors.lightGrey, width: 2.0),
              ),
            ),
            items: _currentAssets.map<DropdownMenuItem<String>>((String condition) {
              return DropdownMenuItem<String>(
                value: condition,
                child: Text(condition),
              );
            }).toList(),
            onChanged: onChanged,
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


Widget _buildRow({
  required int index,
  required List<TextEditingController> controller1,
  required List<TextEditingController> controller2,
  required TextInputType type}) {
  return Row(
    children:[
      SizedBox(
        width:250, 
        child:
            _buildTextInput(controller:controller1[index], type:TextInputType.text, readOnly: false),
      ),
      const SizedBox(height: Spacing.xs),
      SizedBox(
        width:250, 
        child:
          _buildTextInput(controller:controller2[index], type:TextInputType.text, readOnly: false),
      ),
    ]);
  }

Widget _buildTextInput({required TextEditingController controller,required TextInputType type,required bool readOnly,}) {
  return TextField(
    controller: controller,
    keyboardType: type, 
    readOnly: readOnly,
    style: const TextStyle(color: AppColors.ebonyClay),
    decoration: InputDecoration(
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
