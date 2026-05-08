import 'package:get/get.dart';
import 'package:untitled/auth/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final authController = Get.put(AuthController());
    authController.getLoginStatus();
  }
}
