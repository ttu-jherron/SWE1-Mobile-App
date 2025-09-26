import 'package:flutter/material.dart';
// import '../../../../core/constants.dart';
import '../../../../core/colors.dart';
// import '../../../maintenance/data/maintenance_item.dart';

class AddFavorite extends StatefulWidget {
  const AddFavorite({Key? key}) : super(key: key);

  @override
  State<AddFavorite> createState() => _AddFavoriteState();
}

class _AddFavoriteState extends State<AddFavorite> {
  bool _isClicked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // still tappable
      onTap: () {
        setState(() {
          _isClicked = !_isClicked;
        });
      },
      child: Icon(
        _isClicked ? Icons.favorite : Icons.favorite_border,
        color: _isClicked ? Colors.red : AppColors.ebonyClay,
        size: 14, // exact match to your text size
      ),
    );
  }
}