import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/text_strings.dart';

/// The vehicle a driver uses for deliveries. Each value carries the PNG
/// icon, display title, and one-line subtitle so the picker page can
/// render entirely off the enum.
enum DriverVehicleType {
  bicycle(
    AppImages.vehicleBicycle,
    AppTexts.signupDriverVehicleBicycleTitle,
    AppTexts.signupDriverVehicleBicycleSubtitle,
  ),
  scooter(
    AppImages.vehicleScooter,
    AppTexts.signupDriverVehicleScooterTitle,
    AppTexts.signupDriverVehicleScooterSubtitle,
  ),
  car(
    AppImages.vehicleCar,
    AppTexts.signupDriverVehicleCarTitle,
    AppTexts.signupDriverVehicleCarSubtitle,
  );

  const DriverVehicleType(this.iconPath, this.title, this.subtitle);

  final String iconPath;
  final String title;
  final String subtitle;

  /// Whether this vehicle type requires the extra documents page
  /// (driving license, carte grise, insurance).
  bool get requiresMotorizedDocs =>
      this == DriverVehicleType.scooter || this == DriverVehicleType.car;
}
