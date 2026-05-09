/// Lifecycle of an order from kitchen to customer doorstep.
///
/// `prepared`, `onTheWay`, `delivered` are surfaced in client-facing UI;
/// the others (`arrivedPickup`, `arrivedDropoff`, `failed`) are driver-side
/// checkpoints used to drive the courier's job flow.
enum OrderStage {
  prepared,
  arrivedPickup,
  onTheWay,
  arrivedDropoff,
  delivered,
  failed,
}
