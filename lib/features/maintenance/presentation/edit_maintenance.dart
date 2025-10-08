import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import the package
import 'package:mobile_app/app.dart';
import 'package:mobile_app/core/colors.dart';
//import 'package:mobile_app/features/profile/presentation/clerk_data_handler.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';
import '../../../core/layout/app_layout.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../assets/data/asset.dart'; // change to maintenance page
import 'package:mobile_app/features/assets/data/asset_repository.dart';

//DROP DOWN ASSET NAMES
//ADD TABLE

class AddMaintenancePage extends StatefulWidget {
  const AddMaintenancePage({super.key});

  @override
  State<AddMaintenancePage> createState() => _EditMaintenancePageState();
}

class _EditMaintenancePageState extends State<AddMaintenancePage> {
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
    // CHANGE COLOR FOR WHEN IN TEXTBOX
    'New',
    'Used - Like New',
    'Used - Good',
    'Used - Poor',
  ];
  //ADDING DYNAMIC DATA
  
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
    // 1. Asset Name
    if (_selectedCondition == null) {
      missingFields.add('Condition');
    }
    // 2. Completion Date
    if (_completionDate.text.isEmpty) {
      missingFields.add('Completion Date');
    }
    // 2. Short Description
    if (_shortDescription.text.isEmpty) {
      missingFields.add('Task');
    }

    if (missingFields.isNotEmpty) {
      _showValidationErrorDialog(context);
      return; 
    }
    debugPrint('missing fields: ): $missingFields');
    


    // Create the full new Asset object
    // final newMaintenance = Asset(
    //   id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
    //   brand: _completionDate.text,
    //   title: _shortDescription.text, // Using name as title for simplicity
    //   name: '${_completionDate.text} ${_shortDescription.text}',
      
    //   // Purchase fields
    //   condition: _selectedCondition!,
    //   store: _notes.text,
    //   price: priceValue!, // Use the safely parsed and validated value
      
    //   // Default/placeholder values for Maintenance fields
    //   completionDate: DateTime.now().add(const Duration(days: 365)),
    //   shortDescription: 'Newly added asset.',
    //   notes: '',
    //   requiredMaterials: [],
    // );

    //debugPrint('Asset data captured (Passed via routing): ${newAsset.toJson()}');
    
    // Pass the new Asset object back to the previous screen
  Navigator.pop(context, AppRoutes.maintenance); 
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
              _buildConditionDropdown("Asset Name *", _selectedCondition, (newValue) {
                setState(() => _selectedCondition = newValue);
              }),
              _buildTextField("Completion Date (MM/DD/YYYY) *", _completionDate, TextInputType.datetime),
              _buildTextField("Short Description *", _shortDescription, TextInputType.text),
              _buildTextField("Notes", _notes, TextInputType.text),
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
                  onPressed: (){
                    _addMaintenance();
                      Navigator.pushNamed(
                        context,
                        AppRoutes.maintenance, // demo id
                      );
                    },
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
            initialValue: _selectedCondition,
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
            //builds the dropdown
            items: _currentAssets.map<DropdownMenuItem<String>>((String condition) {
              return DropdownMenuItem<String>(
                value: condition,
                child: 
                  Text(
                    condition,
                    style: TextStyle(
                      color: AppColors.ebonyClay,
                    )),
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
