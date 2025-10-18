import 'dart:io'; // Required for Image Picker
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; //Image Picker
import '../../assets/data/asset.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/data/data_handler.dart';

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  // Controllers
  final _brandController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedCondition;
  final _storeController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  // Location suggestions (prefilled from existing assets)
  List<String> _locationSuggestions = <String>[];

  // Purchase date & status & favorite
  DateTime _purchaseDate = DateTime.now();
  String _selectedStatus = 'Active';
  bool _favorite = false;

  // NEW: State for the selected image file path
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _conditions = [
    'New',
    'Used - Like New',
    'Used - Good',
    'Used - Poor',
  ];
  final List<String> _statusOptions = [
    'Active',
    'Inactive',
    'Maintenance',
    'Retired',
  ];

  // NEW: Logic to handle image picking from a specific source (Camera or Gallery)
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // NEW: Logic to show the modal selection menu
  void _pickImage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ebonyClay, // Dark background for the sheet
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              // Option 1: Photo Library
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.nearWhite,
                ),
                title: const Text(
                  'Photo Library',
                  style: TextStyle(color: AppColors.nearWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              // Option 2: Camera
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.nearWhite,
                ),
                title: const Text(
                  'Camera',
                  style: TextStyle(color: AppColors.nearWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Load previous asset locations for autocomplete after first frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadLocationSuggestions(),
    );
  }

  Future<void> _loadLocationSuggestions() async {
    try {
      final handler = DataHandler.fromContext(context);
      final assets = await handler.getAssets(staleOk: true);
      final set = assets
          .map((a) => a.currentLocation)
          .where((s) => s.trim().isNotEmpty)
          .toSet();
      setState(() {
        _locationSuggestions = set.toList();
      });
    } catch (e) {
      debugPrint('Failed to load location suggestions: $e');
    }
  }

  //----------------------------------------
  // --- Custom Dialog to show the list of missing fields ---
  void _showValidationErrorDialog(
    BuildContext context,
    List<String> missingFields,
  ) {
    // Generate a comma-separated list with "and" before the last item
    final String fieldsList = missingFields.length > 1
        ? '   - ${missingFields.sublist(0, missingFields.length - 1).join('\n   - ')} \n   - ${missingFields.last}'
        : missingFields.first;

    final String contentMessage =
        'The following field(s) must be filled out correctly to save the asset:\n\n$fieldsList';

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

  // --- LOGIC: Pass the data back to the calling screen (My Assets Page) ---
  void _addAsset() async {
    final List<String> missingFields = [];
    const double minPrice = 1.00;
    const double maxPrice = 300000.00;

    // 1. Brand Name
    if (_brandController.text.isEmpty) {
      missingFields.add('Brand Name');
    }
    // 2. Asset Name
    if (_nameController.text.isEmpty) {
      missingFields.add('Asset Name');
    }
    // 3. Condition
    if (_selectedCondition == null) {
      missingFields.add('Condition');
    }
    // 4. Location (currentLocation)
    if (_storeController.text.isEmpty) {
      missingFields.add('Location');
    }

    // 6. Category (optional) - no required validation

    // 5. Price (empty, invalid number, or out of range)
    final priceText = _priceController.text;
    final priceValue = double.tryParse(priceText);

    if (priceText.isEmpty) {
      missingFields.add('Price');
    } else if (priceValue == null) {
      missingFields.add('Price');
    } else if (priceValue < minPrice || priceValue > maxPrice) {
      missingFields.add(
        'Price (must be between \$${minPrice.toStringAsFixed(2)} and \$${maxPrice.toStringAsFixed(2)})',
      );
    }

    if (missingFields.isNotEmpty) {
      _showValidationErrorDialog(context, missingFields);
      return;
    }

    try {
      final dataHandler = DataHandler.fromContext(context);

      await dataHandler.addAsset(
        itemName: _nameController.text,
        brandName: _brandController.text,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : 'Uncategorized',
        purchaseDate: _purchaseDate,
        purchaseCost: priceValue!,
        currentLocation: _storeController.text,
        images: _imagePath != null ? [_imagePath!] : [],
        conditionDescription: _selectedCondition!,
        status: _selectedStatus,
        favorite: _favorite,
      );

      // ✅ Success dialog or toast/snackbar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Asset added successfully!")),
      );

      Navigator.pop(context, true); // Return to previous screen
    } catch (e) {
      debugPrint('Error adding asset: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add asset: $e")));

      // Create the full new Asset object
      final newAsset = Asset(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        brand: _brandController.text,
        title: _nameController.text, // Using name as title for simplicity
        name: '${_brandController.text} ${_nameController.text}',

        // Purchase fields
        condition: _selectedCondition!,
        //store: _storeController.text,
        price: priceValue!, // Use the safely parsed and validated value
        imagePath: _imagePath, // NEW: Include the image path
        // Category / status / favorite
        // NOTE: Asset model does not store category/status separately; we include them in notes via shortDescription

        // Default/placeholder values for Maintenance fields
        completionDate: _purchaseDate,
        shortDescription: 'Newly added asset.',
        notes: '',
        requiredMaterials: [],
        currentLocation: '',
      );

      debugPrint(
        'Asset data captured (Passed via routing): ${newAsset.toJson()}',
      );

      // Pass the new Asset object back to the previous screen
      Navigator.pop(context);
    }
  }
  //---------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: MediaQuery.of(context).size.height * 0.13,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(30, 30, 4, 10),
            alignment: Alignment.topLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Add Asset",
                  style: TextStyle(
                    color: AppColors.ebonyClay,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.ebonyClay,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          // Form Content
          Expanded(
            child: Container(
              color: AppColors.nearWhite,
              child: SingleChildScrollView(
                // FIX: Removed horizontal padding from the ScrollView to eliminate the 'white bars'
                padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage, // Calls the modal selection
                      // FIX: Added horizontal padding here to match field padding
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                        ),
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(Radii.md),
                            border: Border.all(
                              color: AppColors.sandyYellow,
                              width: 2,
                            ),
                            image: _imagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(_imagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _imagePath == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: AppColors.ebonyClay,
                                      size: 40,
                                    ),
                                    SizedBox(height: Spacing.sm),
                                    Text(
                                      'Tap to Add Image',
                                      style: TextStyle(
                                        color: AppColors.ebonyClay,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),

                    // Text Fields
                    _buildTextField(
                      label: 'Brand',
                      controller: _brandController,
                    ),
                    _buildTextField(label: 'Name', controller: _nameController),

                    // Category (optional)
                    _buildTextField(
                      label: 'Category',
                      controller: _categoryController,
                    ),

                    // Condition Dropdown
                    _buildDropdownField(
                      label: 'Condition',
                      currentValue: _selectedCondition,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCondition = newValue;
                        });
                      },
                    ),

                    // Status Dropdown
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        0,
                        Spacing.lg,
                        Spacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: const TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: TypographyScale.field,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            // Ensure selected value text is visible (force dark color)
                            selectedItemBuilder: (BuildContext context) {
                              return _statusOptions.map<Widget>((
                                String status,
                              ) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      color: AppColors.ebonyClay,
                                      fontSize: TypographyScale.field,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: Spacing.xs,
                                horizontal: Spacing.sm,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Radii.sm),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _statusOptions
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? v) {
                              setState(() {
                                if (v != null) _selectedStatus = v;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Location with autocomplete suggestions and helper hint
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        0,
                        Spacing.lg,
                        Spacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: TypographyScale.field,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == '') {
                                    return _locationSuggestions;
                                  }
                                  return _locationSuggestions.where((
                                    String option,
                                  ) {
                                    return option.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                                  });
                                },
                            onSelected: (String selection) {
                              _storeController.text = selection;
                            },
                            fieldViewBuilder:
                                (
                                  context,
                                  controller,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  controller.text = _storeController.text;
                                  return TextFormField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    onFieldSubmitted: (_) => onFieldSubmitted(),
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.ebonyClay,
                                    ),
                                    onChanged: (v) => _storeController.text = v,
                                  );
                                },
                          ),
                          const SizedBox(height: Spacing.xs),
                          const Text(
                            'Where is this item stored? e.g., Garage, Warehouse B, Toolshed',
                            style: TextStyle(
                              color: AppColors.ebonyClay,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTextField(
                      label: 'Price',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),

                    const SizedBox(height: Spacing.lg),

                    // Button
                    // FIX: Added horizontal padding to the button to align with fields
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _addAsset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ebonyClay,
                            foregroundColor: AppColors.sandyYellow,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xl,
                              vertical: Spacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Radii.md),
                            ),
                          ),
                          child: const Text('Save New Asset'),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for the text fields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      // FIX: Added horizontal padding (20px on left/right) to contain the field
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with optional red asterisk
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: AppColors.ebonyClay,
                fontSize: TypographyScale.field,
                fontWeight: FontWeight.bold,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: TypographyScale.field,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xs),

          // Input field
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.ebonyClay),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
                  color: AppColors.sandyYellow,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for the condition dropdown
  Widget _buildDropdownField({
    required String label,
    required String? currentValue,
    required void Function(String? newValue)? onChanged,
  }) {
    return Padding(
      // FIX: Added horizontal padding (20px on left/right) to contain the field
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with optional red asterisk
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: AppColors.ebonyClay,
                fontSize: TypographyScale.field,
                fontWeight: FontWeight.bold,
              ),
              children: [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: TypographyScale.field,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.xs),

          // Dropdown field
          DropdownButtonFormField<String>(
            value: currentValue,
            selectedItemBuilder: (BuildContext context) {
              return _conditions.map<Widget>((String condition) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    condition,
                    style: const TextStyle(
                      color: AppColors.ebonyClay,
                      fontSize: TypographyScale.field,
                    ),
                  ),
                );
              }).toList();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
                  color: AppColors.sandyYellow,
                  width: 2.0,
                ),
              ),
            ),
            items: _conditions.map<DropdownMenuItem<String>>((
              String condition,
            ) {
              return DropdownMenuItem<String>(
                value: condition,
                child: Text(
                  condition,
                  style: const TextStyle(color: AppColors.nearWhite),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
