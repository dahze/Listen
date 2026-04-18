import 'package:flutter/material.dart';
import 'package:listen/core/constants/app_colors.dart';

class TerminalButton extends StatelessWidget {
  final String label;
  final double scale;
  final Color color;
  final Color labelColor;
  final bool fullWidth;
  final bool isLoading;
  final VoidCallback? onTap;

  const TerminalButton({
    super.key,
    required this.label,
    required this.scale,
    required this.color,
    this.labelColor = AppColors.kTextPrimary,
    this.fullWidth = false,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          vertical: 14 * scale,
          horizontal: fullWidth ? 0 : 20 * scale,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.kPrimary),
        ),
        child:
            isLoading
                ? Center(
                  child: SizedBox(
                    height: 18 * scale,
                    width: 18 * scale,
                    child: CircularProgressIndicator(
                      color: labelColor,
                      strokeWidth: 2,
                    ),
                  ),
                )
                : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: (11 * scale).clamp(9, 14),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
      ),
    );
  }
}
