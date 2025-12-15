import 'package:flutter/material.dart';

enum TripStatus {
  past,
  ongoing,
  upcoming,
}

TripStatus getTripStatus(DateTime start, DateTime end) {
  final nowRaw = DateTime.now();
  final now = DateTime(nowRaw.year, nowRaw.month, nowRaw.day);

  final startDate = DateTime(start.year, start.month, start.day);
  final endDate = DateTime(end.year, end.month, end.day);

  if (endDate.isBefore(now)) return TripStatus.past;
  if (startDate.isAfter(now)) return TripStatus.upcoming;
  return TripStatus.ongoing;
}

IconData tripStatusIcon(TripStatus status) {
  switch (status) {
    case TripStatus.past:
      return Icons.check_circle;
    case TripStatus.ongoing:
      return Icons.play_circle_fill;
    case TripStatus.upcoming:
      return Icons.schedule;
  }
}

Color tripStatusColor(TripStatus status) {
  switch (status) {
    case TripStatus.past:
      return Colors.grey;
    case TripStatus.ongoing:
      return Colors.green;
    case TripStatus.upcoming:
      return Colors.blue;
  }
}

String tripStatusLabel(TripStatus status) {
  switch (status) {
    case TripStatus.past:
      return 'PAST';
    case TripStatus.ongoing:
      return 'ONGOING';
    case TripStatus.upcoming:
      return 'UPCOMING';
  }
}
