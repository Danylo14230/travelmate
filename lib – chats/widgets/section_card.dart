import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget? child;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const SectionCard({
    super.key,
    required this.title,
    this.child,
    this.icon,
    this.onTap,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: Colors.blue),
              if (icon != null) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
            ],
          ),
          if (child != null) const SizedBox(height: 10),
          if (child != null) child!,
        ],
      ),
    );

    final card = Card(
      color: color ?? Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: content,
    );

    return onTap != null
        ? InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: card,
    )
        : card;
  }
}
