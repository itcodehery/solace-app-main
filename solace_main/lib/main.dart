import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solace_main/pages/secondary/favorites_page.dart';
import 'package:solace_main/pages/primary/home_page.dart';
import 'package:solace_main/pages/primary/login_as_page.dart';
import 'package:solace_main/pages/primary/mood_check_page.dart';
import 'package:solace_main/pages/secondary/post_create_page.dart';
import 'package:solace_main/pages/secondary/resources_page.dart';
import 'package:solace_main/pages/splash_page.dart';
import 'package:solace_main/pages/widget_tree.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
      url: dotenv.env['PROJ_URL']!, anonKey: dotenv.env['PROJ_API_KEY']!);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Solace',
      home: const SplashPage(),
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lime),
          ),
          focusColor: Colors.lime,
        ),
        primarySwatch: Colors.lime,
        primaryColor: Colors.lime,
        textTheme: GoogleFonts.manropeTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        "/widget_tree": (context) => const WidgetTree(),
        "/home": (context) => const HomePage(),
        "/loginas": (context) => const LoginAsPage(),
        "/postcreate": (context) => const PostCreatePage(),
        "/moodcheck": (context) => const MoodCheckPage(),
        "/favorites": (context) => const FavoritesPage(),
        "/resources": (context) => const ResourcesPage(),
      },
    );
  }
}
