import 'package:incacook/features/seller/domain/order_request.dart';

class OrderRequestMockData {
  OrderRequestMockData._();

  static List<OrderRequest> demoRequests() => [
    OrderRequest(
      id: 'ORDER1298D919',
      placedAt: DateTime(2021, 9, 11, 9, 43),
      items: const [
        OrderRequestItem(
          name: 'Poori Masala',
          price: 90,
          portion: 'Half',
          quantity: 1,
        ),
        OrderRequestItem(
          name: 'chikku shake',
          price: 90,
          portion: 'Half',
          quantity: 4,
        ),
      ],
      note:
          "It is a long established that a reader will be distracted by the t. "
          "The point of using Lorem Ipsum is that it has a more-or-less normal "
          "distribution of........",
      paymentStatus: 'Non payé : Paiement à la livraison',
      deliverTo: '12 Rue Saint-Antoine, 75004 Paris',
    ),
    OrderRequest(
      id: 'ORDER1298D920',
      placedAt: DateTime(2021, 9, 11, 10, 12),
      items: const [
        OrderRequestItem(
          name: 'Couscous Royal',
          price: 14,
          portion: 'Plein',
          quantity: 2,
        ),
        OrderRequestItem(
          name: 'Thé à la menthe',
          price: 3,
          portion: 'Standard',
          quantity: 2,
        ),
      ],
      note: 'Pas trop épicé s\'il vous plaît, merci.',
      paymentStatus: 'Payé : Carte bancaire',
      deliverTo: '8 Boulevard Voltaire, 75011 Paris',
    ),
    OrderRequest(
      id: 'ORDER1298D921',
      placedAt: DateTime(2021, 9, 11, 11, 5),
      items: const [
        OrderRequestItem(
          name: 'Tajine poulet citron',
          price: 12,
          portion: 'Plein',
          quantity: 1,
        ),
      ],
      note: 'Sonner deux fois à l\'interphone.',
      paymentStatus: 'Non payé : Paiement à la livraison',
      deliverTo: '45 Rue de la Roquette, 75011 Paris',
    ),
  ];
}
