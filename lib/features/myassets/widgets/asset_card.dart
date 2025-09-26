import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/colors.dart';
import '../widgets/add_favorite.dart';
// import '../../../maintenance/data/maintenance_item.dart';

class AssetCard extends StatefulWidget {
  final VoidCallback? onTap; // 👈 allows you to pass a function when tapped

  const AssetCard({Key? key, this.onTap}) : super(key: key);

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
        color: AppColors.nearWhite,
        child: InkWell(
          borderRadius: BorderRadius.circular(4), // ripple follows shape
          onTap: widget.onTap ?? () {
            debugPrint("AssetCard tapped");
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(4, 10, 4, 10), // tighter padding
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
                SizedBox(width: Spacing.xs),
                // Row with text + favorite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Predator",
                      style: TextStyle(
                        color: AppColors.ebonyClay,
                        fontSize: 14,
                        height: 1.0,
                      ),
                    ),
                    AddFavorite(),
                  ],
                ),
                SizedBox(width: Spacing.xs),
                // Description
                Text(
                  "350 Power Station",
                  style: TextStyle(
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