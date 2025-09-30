import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/colors.dart';
import '../widgets/add_favorite.dart';
//IMPORT: Import the Asset data structure
import '../../assets/data/asset.dart';

//Updated to accept the Asset object and use its properties for the display text.

class AssetCard extends StatefulWidget {
  final VoidCallback? onTap; //allows you to pass a function when tapped
  //CHANGE: Pass the Asset object itself
  final Asset asset; 

  //CHANGE: Make Asset required in the constructor
  const AssetCard({super.key, required this.asset, this.onTap});

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 140,
        maxWidth: 140,
        minHeight: 60,
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(4), // ripple follows shape
          onTap: widget.onTap ?? () {
            debugPrint("AssetCard tapped: ${widget.asset.name}");
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 12, 5, 12), // tighter padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder with its own Card aesthetic
                Card(
                  margin: EdgeInsets.zero,
                  color: AppColors.nearWhite,
                  child: const SizedBox(
                    height: 75,
                    width: double.infinity,
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 40,
                        semanticLabel: 'Image of missing image',
                        color: AppColors.ebonyClay,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Spacing.sm),
                // Row with text + favorite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //CHANGE: Display the asset's brand
                    Text(
                      widget.asset.brand, 
                      style: const TextStyle(
                        color: AppColors.ebonyClay,
                        fontSize: 14,
                        height: 2.0,
                      ),
                    ),
                    const AddFavorite(),
                  ],
                ),
                SizedBox(width: Spacing.sm),
                // Description
                //CHANGE: Display the asset's title (name of the item)
                Text(
                  widget.asset.title, 
                  style: const TextStyle(
                    color: AppColors.ebonyClay,
                    fontSize: 14,
                    height: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

