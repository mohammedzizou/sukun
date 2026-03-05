/// This file contains the implementation of the `MyServices` class, which is a GetX service used for managing various utility functions.
/// It includes methods for handling connectivity changes, storing and retrieving data securely, and performing backups.
/// The class also initializes the necessary dependencies and provides methods for token management.
/// To use this service, call the `initialServices` function to initialize the `MyServices` instance.
// ignore_for_file: depend_on_referenced_packages

library;

import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyServices extends GetxService {
  late SharedPreferences sharedPreferences;
  //final BaseRepository _baseRepository = getIt<BaseRepository>();
  Map<String, dynamic> myMap = {};
  @override
  void onInit() async {
    super.onInit();
  }

 

  Future<MyServices> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }
}

Future<void> initServices() async {
  await Get.putAsync(() => MyServices().init());
}
