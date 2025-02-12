import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'dart:ui';

class CustomAppBar extends StatelessWidget {
  final String titleText;
  final bool showLeading;

  final double borderRadius;

  const CustomAppBar({
    super.key,
    required this.titleText,
    this.showLeading = false,
    this.borderRadius = 25,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(borderRadius),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
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
          ),
        ),
      ),
    );
  }
}
