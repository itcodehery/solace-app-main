import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solace_main/constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    if (!mounted) return;
    if (session != null) {
      debugPrint('Redirected to Home!');
      Get.offAndToNamed("/widget_tree");
    } else {
      debugPrint('Redirected to Login');
      Get.offAndToNamed("/loginas");
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "solace.",
          style: GoogleFonts.spaceMono(
            color: proprimaryColor,
            fontSize: bigTextFontSize,
          ),
        ),
      ),
    );
  }
}
