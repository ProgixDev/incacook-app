import 'package:get/get.dart';

import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/repositories/signup_repository.dart';

/// Local binding for the signup wizard.
///
/// [AuthRepository], [UsersRepository], [ApiClient], and [TokenStorage]
/// are registered globally in `main.dart` so the controller can reach
/// them via `Get.find()`.
class SignupFlowBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupRepository>(SignupRepository.new, fenix: true);
    Get.lazyPut<SignupFlowController>(SignupFlowController.new);
  }
}
