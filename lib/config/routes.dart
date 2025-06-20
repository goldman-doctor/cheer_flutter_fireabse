import 'package:flutter/material.dart';
import 'package:cheer/screens/mainpage.dart';
import 'package:cheer/screens/loadingpage.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoute() {
    return <String, WidgetBuilder>{
      '/': (_) => MainPage(),
      '/loading': (_) => LoadingPage(),
    };
  }
}
