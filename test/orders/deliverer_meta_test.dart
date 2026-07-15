import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/constants/text_strings.dart';

/// The tracking card's driver line. This was a hardcoded "1k+ livraisons" for
/// every driver — it now renders the real lifetime count from the tracking
/// snapshot, so the copy has to survive the values real data actually produces
/// (a brand-new driver, and the singular).
void main() {
  group('trackingDelivererMeta', () {
    test('a driver on their first job is named as new, not "0 livraisons"', () {
      expect(AppTexts.trackingDelivererMeta(0), 'Nouveau livreur');
    });

    test('one delivery is singular', () {
      expect(AppTexts.trackingDelivererMeta(1), '1 livraison');
    });

    test('many deliveries are plural and show the real count', () {
      expect(AppTexts.trackingDelivererMeta(2), '2 livraisons');
      expect(AppTexts.trackingDelivererMeta(1043), '1043 livraisons');
    });

    test('a negative count degrades to the new-driver copy', () {
      // Not reachable today (the column is an integer with DEFAULT 0), but the
      // label must never render "-1 livraisons" if a bad read ever lands.
      expect(AppTexts.trackingDelivererMeta(-1), 'Nouveau livreur');
    });
  });
}
