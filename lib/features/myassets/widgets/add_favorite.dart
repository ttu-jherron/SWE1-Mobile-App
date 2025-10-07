import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../assets/data/asset_store.dart';


class AddFavorite extends StatelessWidget {
  final String assetId;
  final double intSize;
  const AddFavorite({super.key, required this.assetId, this.intSize = 18});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: assetStore,
      builder: (context, _) {
        final isFav = assetStore.getById(assetId).favorite == true;
        return IconButton(
          iconSize: intSize,
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : Colors.black45,
          ),
          onPressed: () => assetStore.toggleFavorite(assetId),
          tooltip: isFav ? 'Unfavorite' : 'Favorite',
        );
      },
    );
  }
}