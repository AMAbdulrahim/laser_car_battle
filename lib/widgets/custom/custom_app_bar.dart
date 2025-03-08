import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'dart:ui';

import 'package:laser_car_battle/utils/constants.dart';

class CustomAppBar extends StatelessWidget {
  final String titleText;
  final bool showLeading;
  final double borderRadius;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final String? actionTooltip;
  final List<PopupMenuEntry<String>>? actionItems;
  final Function(String)? onActionItemSelected;

  const CustomAppBar({
    super.key,
    required this.titleText,
    this.showLeading = false,
    this.borderRadius = 25,
    this.actionIcon,
    this.onActionPressed,
    this.actionTooltip,
    this.actionItems,
    this.onActionItemSelected,
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
            title: Text(
              titleText,
              style: TextStyle(fontSize: AppSizes.appBarTitle),
            ),
            backgroundColor: CustomColors.appBarBackground,
            leading: showLeading
                ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                : null,
            actions: actionIcon != null
                ? [
                    if (actionItems != null && onActionItemSelected != null)
                      PopupMenuButton<String>(
                        icon: Icon(actionIcon),
                        tooltip: actionTooltip,
                        onSelected: onActionItemSelected,
                        itemBuilder: (context) => actionItems!,
                        color: CustomColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(actionIcon),
                        onPressed: onActionPressed,
                        tooltip: actionTooltip,
                      ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
