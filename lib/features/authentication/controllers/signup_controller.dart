import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  //* variables
  final privacyPolicy = true.obs;
  final hidePassword = true.obs;
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userName = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final password = TextEditingController();

  //* seller-specific
  final restaurantName = TextEditingController();
  final restaurantAddress = TextEditingController();

  //* delivery-specific
  final vehicleType = TextEditingController();
  final licenseNumber = TextEditingController();

  GlobalKey<FormState> signupFormKey =
      GlobalKey<FormState>(); //? form key for form validation

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    userName.dispose();
    email.dispose();
    phoneNumber.dispose();
    password.dispose();
    restaurantName.dispose();
    restaurantAddress.dispose();
    vehicleType.dispose();
    licenseNumber.dispose();
    super.onClose();
  }

  //* signup

  // void signup() async {
  //   try {
  //     //* start loading
  //     CustomFullscreenLoader.openLoadingDialog(
  //       'We are processing your information...',
  //       TAnimations.check,
  //     );

  //     //* check internet connection
  //     final isConnected = await NetworkManager.instance.isConnected();
  //     if (!isConnected) {
  //       CustomFullscreenLoader.stopLoading();
  //       return;
  //     }

  //     //* form validation
  //     if (!signupFormKey.currentState!.validate()) {
  //       CustomFullscreenLoader.stopLoading();
  //       return;
  //     }

  //     //* privacy policy check
  //     if (!privacyPolicy.value) {
  //       CustomLoaders.warningSnackBar(
  //         title: 'Accept privacy policy',
  //         message:
  //             'In order to create your account you have to accept our privacy policy',
  //       );
  //       CustomFullscreenLoader.stopLoading();
  //       return;
  //     }

  //     //* register user in the firebase authentication and save user data in firebase
  //     final userCredential =
  //         await AuthenticationRepository.instance.registerWithEmailAndPassword(
  //       email.text.trim(),
  //       password.text.trim(),
  //     ); //? trim() to remove spaces

  //     //* save authenticated user data in firestore
  //     final newUser = UserModel(
  //       id: userCredential.user!.uid,
  //       firstName: firstName.text.trim(),
  //       lastName: lastName.text.trim(),
  //       username: userName.text.trim(),
  //       email: email.text.trim(),
  //       password: password.text.trim(),
  //       phoneNumber: phoneNumber.text.trim(),
  //       profilePicture: '',
  //     );

  //     //? we use Get.put() instead of instance because we didn't initiate the instance yet
  //     final userRepository = Get.put(UserRepository());
  //     await userRepository.saveUserRecord(newUser);

  //     //* remove loader
  //     CustomFullscreenLoader.stopLoading();

  //     //* show success message
  //     CustomLoaders.successSnackBar(
  //       title: 'Congratulations',
  //       message: 'Your account has been created, verify email to continue.',
  //     );

  //     //* move to verify email screen
  //     Get.to(() => VerifyEmailScreen(email: email.text.trim()));
  //   } catch (e) {
  //     //* remove the loader
  //     CustomFullscreenLoader.stopLoading();

  //     //* show some generic error to the user
  //     CustomLoaders.errorSnackBar(title: 'Oh snap!', message: e.toString());
  //   }
  // }
}
