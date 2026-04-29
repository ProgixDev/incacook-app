import 'package:homemade/core/services/map/models/map_route.dart';
import 'package:homemade/features/delivery/domain/delivery_driver_models.dart';

class DeliveryDriverMockData {
  DeliveryDriverMockData._();

  static List<WeeklyChallenge> challenges() => const [
    WeeklyChallenge(
      title: 'Effectue 20 livraisons et gagne 35€ de bonus',
      endsLabel: 'Termine lundi',
      progress: 0.20,
      progressLabel: '4 livraisons sur 20',
    ),
    WeeklyChallenge(
      title: 'Reste connecté 15h cette semaine',
      endsLabel: 'Termine dimanche',
      progress: 0.45,
      progressLabel: '6h45 sur 15h',
    ),
    WeeklyChallenge(
      title: 'Garde une note de 4.8 ou plus',
      endsLabel: 'Termine dimanche',
      progress: 0.96,
      progressLabel: '4.79 sur 4.8',
    ),
  ];

  static DailyStats todayStats() => const DailyStats(
    earnings: 12.20,
    onlineTime: Duration(hours: 1, minutes: 12),
    rides: 2,
  );

  static List<ScheduledPickup> upcomingPickups() => const [
    ScheduledPickup(
      sellerName: 'Aïcha Benali',
      address: '15 Rue de la Roquette',
      etaLabel: 'dans 28 min',
      coordinate: MapPoint(lng: 2.3692, lat: 48.8532),
    ),
    ScheduledPickup(
      sellerName: 'Chez Luigi',
      address: '8 Avenue Parmentier',
      etaLabel: 'dans 45 min',
      coordinate: MapPoint(lng: 2.3743, lat: 48.8617),
    ),
    ScheduledPickup(
      sellerName: 'Green Kitchen',
      address: '22 Bd Voltaire',
      etaLabel: 'dans 1h10',
      coordinate: MapPoint(lng: 2.3658, lat: 48.8579),
    ),
  ];
}
