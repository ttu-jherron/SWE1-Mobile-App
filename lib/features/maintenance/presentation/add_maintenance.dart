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

//REMOVE PHOTO 
//DROP DOWN ASSET NAMES
//CHANGE NAMES
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

  final List<String> _currentAssets = [
    //  CHANGE TO LOGIC WHEN BACKEND
    'New',
    'Used - Like New',
    'Used - Good',
    'Used - Poor',
  ];

  @override
  void dispose() {
    _completionDate.dispose();
    _shortDescription.dispose();
    _notes.dispose();
    _requiredTools.dispose();
    _toolLocations.dispose();
    super.dispose();
  }


  // TODO: NEW VALIDTION USING ASTERICKS (*)
  // --- Custom Dialog to show the list of missing fields ---
  // void _showValidationErrorDialog(BuildContext context, List<String> missingFields) {
  //   // Generate a comma-separated list with "and" before the last item
  //   final String fieldsList = missingFields.length > 1
  //     ? '${missingFields.sublist(0, missingFields.length - 1).join(', ')}, and ${missingFields.last}'
  //     : missingFields.first;

  //   final String contentMessage = 
  //     'The following field(s) must be filled out correctly to save the asset: $fieldsList.';

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext dialogContext) {
  //       return AlertDialog(
  //         title: const Text('Required Information Missing'),
  //         content: Text(contentMessage),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               Navigator.of(dialogContext).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
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

    // if (missingFields.isNotEmpty) {
    //   _showValidationErrorDialog(context, missingFields);
    //   return; 
    // }
    
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

      //MOVE THIS INSIDE PAGE
      // appBar: AppBar(
      //   // Use colors from the AppHeaderBar style
      //   backgroundColor: AppColors.ebonyClay,
      //   iconTheme: const IconThemeData(color: AppColors.sandyYellow), 
      //   title: const Text(
      //     "Add New Maintenance",
      //     style: TextStyle(
      //       color: AppColors.sandyYellow,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
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
        
              // Form Fields
              _buildConditionDropdown("AssetName", _selectedCondition, (newValue) {
                setState(() => _selectedCondition = newValue);
              }),
              _buildTextField("Completion Date (MM/DD/YYYY)", _completionDate, TextInputType.datetime),
              _buildTextField("Short Description", _shortDescription, TextInputType.text),
              _buildTextField("Notes", _notes, TextInputType.text),
              _buildTextTable(context, "Required Materials", _requiredTools, _toolLocations, TextInputType.text),
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
                  child: const Text('Save New Asset'),
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

 // Custom input table component 
  Widget _buildTextTable(
    BuildContext context,
    String label, TextEditingController controller1, TextEditingController controller2, TextInputType type, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
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
              //TOOLS COLUMN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tools",
                    style: const TextStyle(
                      color: AppColors.ebonyClay,
                      fontSize: TypographyScale.field,
                      fontWeight: FontWeight.normal,  //CHANGE TO ITALICIZED
                    ),
                  ),
                  Text(
                    "Current Location",
                    style: const TextStyle(
                      color: AppColors.ebonyClay,
                      fontSize: TypographyScale.field,
                      fontWeight: FontWeight.normal,  //CHANGE TO ITALICIZED
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: 
                    Divider(
                      height: 14,
                      thickness: 2,
                      color: AppColors.lightGrey
                    ),
              ),
              
              //REQUIRED TOOL COLUMN - default 4 textfields 
              Column(
                  children: [
                    Table(
                      columnWidths: const {
                        0: FractionColumnWidth(0.8),
                        1: FractionColumnWidth(0.8),
                        },
                      children: [
                        TableRow( 
                          children: [
                            _buildTextInput(controller:controller1, type:TextInputType.text, readOnly: false),
                            const SizedBox(width: Spacing.md),
                            _buildTextInput(controller:controller2, type:TextInputType.text, readOnly: false),
                        ]),
                        // TableRow( children: [
                        //    _buildTextInput(controller:controller1, type:TextInputType.text, readOnly: false),
                        //    _buildTextInput(controller:controller2, type:TextInputType.text, readOnly: false),
                        // ])
                      ],
                    ),
                    ],
                ),
                    /*IconButton(
                      onPressed: () {
                        debugPrint("Add Maintenance Required Tool was pressed!");
                        Row(
                          children: [
                            _buildTextInput(controller:controller1, type:TextInputType.text, readOnly: false),
                            _buildTextInput(controller:controller2, type:TextInputType.text, readOnly: false),
                            ],
                          );
                          },
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.ebonyClay,
                            size: 28,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ), */
             ],
           ),
        ),
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
