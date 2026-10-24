import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TimkerjaBrandedLogo extends StatelessWidget {
  final bool isDarkText;
  final double iconSize;

  const TimkerjaBrandedLogo({
    super.key,
    this.isDarkText = false,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    // Sesuaikan warna primary dengan toska desain: Color(0xFF00A896)
    const Color primaryColor = AppColors.primary;
    const Color darkTextColor = AppColors.primaryDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.groups_rounded,
          color: isDarkText ? primaryColor : Colors.white,
          size: iconSize,
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Tim',
                style: TextStyle(
                  fontSize: iconSize * 0.45,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDarkText ? primaryColor : darkTextColor,
                ),
              ),
              TextSpan(
                text: 'Kerja',
                style: TextStyle(
                  fontSize: iconSize * 0.45,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDarkText ? darkTextColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
