import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cheer/widgets/customRoute.dart';
import 'package:cheer/screens/mainPage.dart';
import 'package:cheer/config/routes.dart';
import 'package:cheer/themes/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce ',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.mulishTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,
      routes: Routes.getRoute(),
      onGenerateRoute: (RouteSettings settings) {
        final routeName = settings.name ?? '';

        if (routeName.contains('detail')) {
          return CustomRoute<bool>(
            builder: (BuildContext context) => MainPage(),
            settings: settings,
          );
        } else {
          return CustomRoute<bool>(
            builder: (BuildContext context) => MainPage(),
            settings: settings,
          );
        }
      },
      initialRoute: "/loading",
    );
  }
}
