import 'package:homemade/features/seller/domain/accepted_order.dart';

class AcceptedOrderMockData {
  AcceptedOrderMockData._();

  static List<AcceptedOrder> demoAccepted() => [
    AcceptedOrder(
      id: 'ORDER1298D919',
      acceptedAt: DateTime(2021, 9, 11, 9, 43),
      status: AcceptedOrderStatus.readyToPickup,
      minutesRemaining: 22,
      totalPrice: 18.50,
    ),
    AcceptedOrder(
      id: 'ORDER129G6919',
      acceptedAt: DateTime(2021, 8, 31, 10, 40),
      status: AcceptedOrderStatus.preparing,
      minutesRemaining: 52,
      totalPrice: 24.00,
    ),
    AcceptedOrder(
      id: 'ORDER129G6920',
      acceptedAt: DateTime(2021, 8, 31, 10, 40),
      status: AcceptedOrderStatus.readyToPickup,
      minutesRemaining: 10,
      totalPrice: 12.50,
    ),
    AcceptedOrder(
      id: 'ORDER129G6921',
      acceptedAt: DateTime(2021, 8, 31, 10, 40),
      status: AcceptedOrderStatus.preparing,
      minutesRemaining: 31,
      totalPrice: 32.00,
    ),
    AcceptedOrder(
      id: 'ORDER129G6922',
      acceptedAt: DateTime(2021, 8, 31, 10, 40),
      status: AcceptedOrderStatus.preparing,
      minutesRemaining: 37,
      totalPrice: 9.50,
    ),
  ];

  static List<AcceptedOrder> demoHistory() => [];
}
