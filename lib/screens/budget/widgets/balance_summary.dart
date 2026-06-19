import 'package:flutter/material.dart';

class BalanceSummary extends StatelessWidget {
  final double jeDois;
  final double onMeDoit;

  const BalanceSummary({
    super.key,
    required this.jeDois,
    required this.onMeDoit,
  });

  @override
  Widget build(BuildContext context) {
    final maxBalance = (jeDois > onMeDoit ? jeDois : onMeDoit);
    final maxScale = maxBalance > 0 ? maxBalance * 1.2 : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBalanceBar("Je dois", jeDois, maxScale, const Color(0xFFD81B60)),
        const SizedBox(height: 24),
        _buildBalanceBar("On me doit", onMeDoit, maxScale, const Color(0xFF4CE0B3)),
      ],
    );
  }

  Widget _buildBalanceBar(String label, double value, double max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text("${value.toStringAsFixed(2)}€", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            widthFactor: value / max,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
