import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class ModeToggleButtons extends StatelessWidget {
  final bool isHost;
  final Function(bool) onModeChanged;

  const ModeToggleButtons({
    super.key, 
    required this.isHost, 
    required this.onModeChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CustomColors.background,
        borderRadius: BorderRadius.circular(AppSizes.borderLarge),
        border: Border.all(color: CustomColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            text: 'Create Game',
            isSelected: isHost,
            onTap: () => onModeChanged(true),
          ),
          _buildToggleOption(
            text: 'Join Game',
            isSelected: !isHost,
            onTap: () => onModeChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.mainButton : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.borderMedium),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : CustomColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}