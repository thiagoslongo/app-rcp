import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MedicalActionCardAesp extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final String description;
  final Widget? statsWidget;
  final double? height;
  final double? cardWidth;
  final Color? cardColor;
  final Color? buttonColor;
  final Color? textColor;
  final Color? iconColor;

  const MedicalActionCardAesp({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.description,
    this.statsWidget,
    this.height,
    this.cardWidth,
    this.cardColor,
    this.buttonColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: buttonColor ?? AppColors.primary,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? Colors.white,
                      size: 24.0,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: textColor ?? Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (statsWidget != null) ...[
                const SizedBox(height: 12.0),
                Center(child: statsWidget!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}