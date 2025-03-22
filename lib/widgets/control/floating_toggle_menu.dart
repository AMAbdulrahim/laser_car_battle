import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';

class FloatingToggleMenu extends StatefulWidget {
  final bool controlsOnLeft;
  final bool useJoystick;
  final bool useVisualIndicator;
  final bool holdSteering;
  final VoidCallback onToggleControls;
  final VoidCallback onToggleControlType;
  final VoidCallback onToggleVisualMode;
  final VoidCallback onToggleHoldSteering;

  const FloatingToggleMenu({
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
  State<FloatingToggleMenu> createState() => _FloatingToggleMenuState();
}

class _FloatingToggleMenuState extends State<FloatingToggleMenu> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fixed: Use Container with constraints instead of Stack with Positioned
    return Container(
      width: 56,  // Width of the FAB
      height: _isOpen ? 300 : 56,  // Height expands when menu is open
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expandable options - placed first so they appear above the FAB
          if (_isOpen)
            FadeTransition(
              opacity: _animation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildOptionButton(
                      widget.controlsOnLeft ? 'Controls: Left' : 'Controls: Right',
                      widget.controlsOnLeft ? Icons.align_horizontal_left : Icons.align_horizontal_right,
                      widget.onToggleControls,
                    ),
                    const SizedBox(height: 8),
                    _buildOptionButton(
                      widget.useJoystick ? 'Joystick' : 'Buttons',
                      widget.useJoystick ? Icons.sports_esports : Icons.keyboard_arrow_up,
                      widget.onToggleControlType,
                    ),
                    const SizedBox(height: 8),
                    _buildOptionButton(
                      widget.useVisualIndicator ? 'Dashboard: On' : 'Dashboard: Off',
                      Icons.dashboard,
                      widget.onToggleVisualMode,
                      active: widget.useVisualIndicator,
                    ),
                    const SizedBox(height: 8),
                    _buildOptionButton(
                      widget.holdSteering ? 'Steering: Hold' : 'Steering: Return',
                      widget.holdSteering ? Icons.lock : Icons.lock_open,
                      widget.onToggleHoldSteering,
                      active: widget.holdSteering,
                    ),
                  ],
                ),
              ),
            ),
          
          // Main toggle button always visible at the bottom
          FloatingActionButton(
            backgroundColor: CustomColors.mainButton,
            foregroundColor: CustomColors.textPrimary,
            onPressed: _toggleMenu,
            child: Icon(_isOpen ? Icons.close : Icons.tune),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String label, IconData icon, VoidCallback onTap, {bool active = true}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: CustomColors.mainButton.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: CustomColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon, 
                color: active ? CustomColors.textPrimary : CustomColors.buttonText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}