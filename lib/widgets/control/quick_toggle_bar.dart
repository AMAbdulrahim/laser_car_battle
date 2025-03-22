import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';

/// A more compact version of the toggle controls
class QuickToggleBar extends StatelessWidget {
  final bool controlsOnLeft;
  final bool useJoystick;
  final bool useVisualIndicator;
  final bool holdSteering;
  final VoidCallback onToggleControls;
  final VoidCallback onToggleControlType;
  final VoidCallback onToggleVisualMode;
  final VoidCallback onToggleHoldSteering;

  const QuickToggleBar({
    super.key,
    required this.controlsOnLeft,
    required this.useJoystick,
    required this.useVisualIndicator,
    required this.holdSteering,
    required this.onToggleControls,
    required this.onToggleControlType,
    required this.onToggleVisualMode,
    required this.onToggleHoldSteering,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 36,  // Much shorter height
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: CustomColors.background.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: CustomColors.textPrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Take only needed space
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon-only toggle buttons in a row
            _CompactToggleButton(
              icon: controlsOnLeft ? Icons.align_horizontal_left : Icons.align_horizontal_right,
              isActive: true,
              onTap: onToggleControls,
              tooltip: controlsOnLeft ? 'Controls on Left' : 'Controls on Right',
            ),
            _CompactToggleButton(
              icon: useJoystick ? Icons.sports_esports : Icons.keyboard_arrow_up,
              isActive: useJoystick,
              onTap: onToggleControlType,
              tooltip: useJoystick ? 'Using Joystick' : 'Using Buttons',
            ),
            _CompactToggleButton(
              icon: Icons.dashboard,
              isActive: useVisualIndicator,
              onTap: onToggleVisualMode,
              tooltip: 'Toggle Dashboard',
            ),
            _CompactToggleButton(
              icon: holdSteering ? Icons.lock : Icons.lock_open,
              isActive: holdSteering,
              onTap: onToggleHoldSteering,
              tooltip: holdSteering ? 'Steering Locked' : 'Steering Returns',
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _CompactToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? CustomColors.mainButton : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? CustomColors.textPrimary : CustomColors.buttonText,
            size: 20,
          ),
        ),
      ),
    );
  }
}