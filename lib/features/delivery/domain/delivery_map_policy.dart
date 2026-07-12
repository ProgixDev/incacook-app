/// The active route owns camera framing once available. Until then, including
/// during active-job restoration, the map should open on the driver's real
/// position instead of its static fallback coordinate.
bool shouldCenterDriverOnMapOpen({
  required bool hasActiveJob,
  required bool hasRoute,
}) => !hasActiveJob || !hasRoute;
