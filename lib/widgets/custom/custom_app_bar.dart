import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';

class CustomAppBar extends StatelessWidget {
  final String titleText;
  final bool showLeading;

  const CustomAppBar({
    super.key,
    required this.titleText,
    this.showLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(titleText),
      backgroundColor: CustomColors.appBarBackground,
      leading: showLeading
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : null,
    );
  }
}
