import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final double radius;
  final Color? color;

  const UserAvatar({
    super.key,
    required this.initials,
    this.radius = 38,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color ?? Colors.blue.shade50,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}
