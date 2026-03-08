import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sukun/core/constants/route.dart';

import 'myservises.dart';

/// A middleware class that redirects routes based on the value of a shared preference.
/// If the value of the shared preference "step" is "2", the user is redirected to the home page.// mymiddleware.dart
class MyMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;
  MyServices myServices = Get.find();
  @override
  RouteSettings? redirect(String? route) {
    if (myServices.sharedPreferences.getString("step") == "2") {
      return const RouteSettings(name: AppRoute.home);
    }
    return null;
  }
}
