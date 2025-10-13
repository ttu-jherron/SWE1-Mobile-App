import 'package:flutter/material.dart';
import 'package:mobile_app/features/assets/data/asset_store.dart';
import '../../../../core/colors.dart';

class AddFavorite extends StatelessWidget {
  final String assetId;
  final double intSize;
  const AddFavorite({super.key, required this.assetId, this.intSize = 18});

  @override
  Widget build(BuildContext context) {
    // Ensure the store is bound even if this widget is used outside list pages
    assetStore.bind(context);

    return AnimatedBuilder(
      animation: assetStore,
      builder: (context, _) {
        final list = assetStore.all();
        final idx = list.indexWhere((a) => a.id == assetId);
        final exists = idx != -1;
        final isFav = exists ? (list[idx].favorite == true) : false;

        return IconButton(
          iconSize: intSize,
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : Colors.black45,
          ),
          onPressed: exists ? () => assetStore.toggleFavorite(assetId) : null,
          tooltip: isFav ? 'Unfavorite' : 'Favorite',
        );
      },
    );
  }
}