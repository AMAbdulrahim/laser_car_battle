import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class TitleText extends StatefulWidget {
  const TitleText({super.key});

  @override
  State<TitleText> createState() => _TitleTextState();
}

class _TitleTextState extends State<TitleText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedText('Team'),
            _buildAnimatedText('57'),
          ],
        );
      },
    );
  }
  
  Widget _buildAnimatedText(String text) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          text,
          style: TextStyle(
            fontSize: AppSizes.fontTitle,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = CustomColors.effectColor,
            shadows: [
              Shadow(
                offset: const Offset(-1.5, -1.5),
                color: CustomColors.effectColor,
                blurRadius: _glowAnimation.value,
              ),
              Shadow(
                offset: const Offset(1.5, 1.5),
                color: CustomColors.effectColor,
                blurRadius: _glowAnimation.value,
              ),
            ],
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          style: TextStyle(
            fontSize: AppSizes.fontTitle,
            shadows: [
              Shadow(
                offset: const Offset(-1.5, -1.5),
                color: CustomColors.effectColor,
                blurRadius: _glowAnimation.value,
              ),
              Shadow(
                offset: const Offset(1.5, 1.5),
                color: CustomColors.effectColor, 
                blurRadius: _glowAnimation.value,
              ),
            ],
          ),
        ),
      ],
    );
  }
}