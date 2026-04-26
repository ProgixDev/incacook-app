import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homemade/app.dart';

void main() async {
  //* add widgets bindings
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  //? this line ensures that the firebase initialization finishes first, then initialize the design widgets

  //* init local storage
  await GetStorage.init();

  //* await native splash
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const App());
}
