import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;

  const MainButton({
    required this.text, 
    required this.onPressed, 
    this.color = const Color(0xFF2E3192),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    return SizedBox(
      width: double.infinity, 
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey.shade300 : color,
          foregroundColor: isDisabled ? Colors.grey.shade500 : textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}