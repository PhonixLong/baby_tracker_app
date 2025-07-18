import 'package:get/get.dart';
import '../views/home/home_view.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(name: Routes.home, page: () => HomeView()),
    // 这里可以继续添加其他页面
  ];
}

class Routes {
  static const home = '/';
  // 这里可以继续添加其他路由常量
}
