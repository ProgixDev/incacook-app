import 'package:get/get.dart';
import 'package:incacook/features/authentication/domain/user_type.dart';
import 'package:incacook/features/authentication/presentation/screens/signup.dart';

class UserTypeSelectionController extends GetxController {
  static UserTypeSelectionController get instance => Get.find();

  final Rxn<UserType> selectedUserType = Rxn<UserType>();

  static const List<UserType> userTypes = [
    UserType.client,
    UserType.seller,
    UserType.delivery,
  ];

  void selectUserType(UserType type) => selectedUserType.value = type;

  void continueToSignup() {
    final type = selectedUserType.value;
    if (type == null) return;
    Get.to(() => SignupScreen(userType: type));
  }
}
