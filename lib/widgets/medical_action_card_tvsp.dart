// FV / TVSP 

import 'package:flutter/material.dart';

class MedicalActionCardTvsp extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final String description;
  final Widget? statsWidget;
  final double? height; // Altura do cartão
  final double? buttonWidth; // Largura do botão
  final double? cardWidth; // Largura do cartão
  final Color? buttonColor;
  final Color? textColor;
  final Color? iconColor;

  const MedicalActionCardTvsp({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.description,
    this.statsWidget,
    this.buttonColor,
    this.textColor,
    this.iconColor,
    this.height,
    this.buttonWidth,
    this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
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
                      color: buttonColor ?? Theme.of(context).primaryColor,
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