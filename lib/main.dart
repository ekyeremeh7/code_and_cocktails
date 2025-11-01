import 'package:code_and_cocktails/src/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shared/services/sembast_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initEnv();
  await initSembast();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const Map<int, Color> colorPrimary = {
    50: Color.fromRGBO(81, 86, 237, .1), // 30,110,250,
    100: Color.fromRGBO(81, 86, 237, .2),
    200: Color.fromRGBO(81, 86, 237, .3),
    300: Color.fromRGBO(81, 86, 237, .4),
    400: Color.fromRGBO(81, 86, 237, .5),
    500: Color.fromRGBO(81, 86, 237, .6),
    600: Color.fromRGBO(81, 86, 237, .7),
    700: Color.fromRGBO(81, 86, 237, .8),
    800: Color.fromRGBO(81, 86, 237, .9),
    900: Color.fromRGBO(81, 86, 237, 1),
  };
  static const MaterialColor customColor =
      MaterialColor(0xFF5156ED, colorPrimary);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code & Cocktails',
      theme: ThemeData(
        primarySwatch: customColor,
      ),
      home: const HomePage(),
    );
  }
}

Future<void> initEnv() async {
  await dotenv.load(fileName: ".env");
}

Future<void> initSembast() async {
  await SembastService().init();
}
