import 'package:flutter/material.dart';
import '../../../../core/colors.dart';

class AddFavorite extends StatefulWidget {
  final double intSize; // store the size as a field

  const AddFavorite({this.intSize = 14, Key? key}) : super(key: key);
  // You can also provide a default size

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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Icon(
          _isClicked ? Icons.favorite : Icons.favorite_border,
          color: _isClicked ? Colors.red : AppColors.ebonyClay,
          size: widget.intSize, // access the size via widget.size
        ),
      ),
    );
  }
}
