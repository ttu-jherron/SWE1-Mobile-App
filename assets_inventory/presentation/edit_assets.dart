import 'dart:io'; // Required for Image Picker
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../assets/data/asset.dart';
import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/routing.dart';

class EditAssetPage extends StatefulWidget {
  final Asset asset;
  
  const EditAssetPage({super.key, required this.asset});

  @override
  State<EditAssetPage> createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> {
  // Controllers
  late final TextEditingController _brandController;
  late final TextEditingController _nameController;
  String? _selectedCondition;
  late final TextEditingController _storeController;
  late final TextEditingController _priceController;

  // State for the selected image file path
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();


  final List<String> _conditions = [
    'New',
    'Used - Like New',
    'Used - Good',
    'Used - Poor',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing asset data
    _brandController = TextEditingController(text: widget.asset.brand);
    _nameController = TextEditingController(text: widget.asset.title);
    _selectedCondition = widget.asset.condition;
    _storeController = TextEditingController(text: widget.asset.store);
    // Note: Price is a double, converting to string for controller
    _priceController = TextEditingController(text: widget.asset.price.toStringAsFixed(2));
    
    // Load existing image path
    _imagePath = widget.asset.imagePath;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _nameController.dispose();
    _storeController.dispose();
    _priceController.dispose();
    super.dispose();
  }
  
  // --- Image Picking Logic ---
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              // Option to clear the existing image
              if (_imagePath != null) 
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imagePath = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  // ---------------------------

  // --- Custom Dialog to show the list of missing fields ---
  void _showValidationErrorDialog(BuildContext context, List<String> missingFields) {
    // Generate a comma-separated list with "and" before the last item
    final String fieldsList = missingFields.length > 1
      ? '${missingFields.sublist(0, missingFields.length - 1).join(', ')}, and ${missingFields.last}'
      : missingFields.first;

    final String contentMessage = 
      'The following field(s) must be filled out correctly to save the asset: $fieldsList.';

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

  //Pass the updated data back to the calling screen (My Assets Page) ---
  void _saveAsset() {
    final List<String> missingFields = [];
    const double minPrice = 1.00;
    const double maxPrice = 300000.00;

    // 1. Brand Name
    if (_brandController.text.isEmpty) { missingFields.add('Brand Name'); }
    // 2. Asset Name
    if (_nameController.text.isEmpty) { missingFields.add('Asset Name'); }
    // 3. Condition
    if (_selectedCondition == null) { missingFields.add('Condition'); }
    // 4. Store
    if (_storeController.text.isEmpty) { missingFields.add('Store'); }
    
    // 5. Price (empty, invalid number, or out of range)
    final priceText = _priceController.text;
    final priceValue = double.tryParse(priceText);

    if (priceText.isEmpty) {
      missingFields.add('Price (cannot be empty)');
    } else if (priceValue == null) {
      missingFields.add('Price (must be a valid number)');
    } else if (priceValue < minPrice || priceValue > maxPrice) {
      missingFields.add('Price (must be between \$${minPrice.toStringAsFixed(2)} and \$${maxPrice.toStringAsFixed(2)})');
    }

    if (missingFields.isNotEmpty) {
      _showValidationErrorDialog(context, missingFields);
      return; 
    }
    
    // Create the updated Asset object by copying and updating
    final updatedAsset = widget.asset.copyWith(
      brand: _brandController.text,
      title: _nameController.text, 
      name: '${_brandController.text} ${_nameController.text}',
      
      condition: _selectedCondition!,
      store: _storeController.text,
      price: priceValue!,
      imagePath: () => _imagePath, //The updated/cleared image path is saved
    );

    debugPrint('Asset data updated (Passed via routing): ${updatedAsset.toJson()}');

    // Pass the updated Asset object back to the previous screen (My Assets Page)
    Navigator.pop(context, updatedAsset); 
  }
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nearWhite, 
      appBar: AppBar(
        backgroundColor: AppColors.ebonyClay,
        iconTheme: const IconThemeData(color: AppColors.sandyYellow), 
        title: const Text(
          "Edit Asset",
          style: TextStyle(
            color: AppColors.sandyYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Spacing.lg), 
            
            // Image selection area (photo preview or placeholder)
            _buildImagePicker(),

            // Form Fields start here
            _buildTextField("Brand Name", _brandController, TextInputType.text),
            _buildTextField("Asset Name", _nameController, TextInputType.text),
            _buildConditionDropdown("Condition", _selectedCondition, (newValue) {
              setState(() => _selectedCondition = newValue);
            }),
            _buildTextField("Store", _storeController, TextInputType.text),
            _buildTextField("Price", _priceController, TextInputType.number),
            
            const SizedBox(height: Spacing.xxl), 

            // Button
            Center(
              child: ElevatedButton(
                onPressed: _saveAsset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ebonyClay,
                  foregroundColor: AppColors.sandyYellow,
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xl, vertical: Spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.md),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }
  
  /// UI component for selecting or displaying an asset image. If an image is present,
  /// it is displayed. shows a dialog to change or remove the photo.
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.nearWhite, 
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: AppColors.ebonyClay.withOpacity(0.1), width: 1),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(Radii.md),
                child: Image.file(
                  File(_imagePath!), // Display the image from the local path
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: AppColors.ebonyClay,
                      size: 40,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Add Asset Photo (Optional)',
                      style: TextStyle(
                        color: AppColors.ebonyClay.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
              fillColor: readOnly ? AppColors.nearWhite : Colors.white,
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
                borderSide: const BorderSide(color: AppColors.sandyYellow, width: 2.0),
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
            value: _selectedCondition,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
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
                borderSide: const BorderSide(color: AppColors.sandyYellow, width: 2.0),
              ),
            ),
            items: _conditions.map<DropdownMenuItem<String>>((String condition) {
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

