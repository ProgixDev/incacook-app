import 'package:homemade/core/services/map/models/map_route.dart';

class WeeklyChallenge {
  const WeeklyChallenge({
    required this.title,
    required this.endsLabel,
    required this.progress,
    required this.progressLabel,
  });

  final String title;
  final String endsLabel;

  //* 0.0–1.0
  final double progress;
  final String progressLabel;
}

class DailyStats {
  const DailyStats({
    required this.earnings,
    required this.onlineTime,
    required this.rides,
  });

  final double earnings;
  final Duration onlineTime;
  final int rides;
}

class ScheduledPickup {
  const ScheduledPickup({
    required this.sellerName,
    required this.address,
    required this.etaLabel,
    required this.coordinate,
  });

  final String sellerName;
  final String address;
  final String etaLabel;
  final MapPoint coordinate;
}
