import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/pages/primary/home_page.dart';
import 'package:solace_main/pages/primary/mood_check_page.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:solace_main/pages/primary/settings_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'solace.',
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white24)),
              onPressed: () {
                Get.toNamed("/postcreate");
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              )),
          const SizedBox(width: 4),
        ],
      ),
      body: <Widget>[
        const HomePage(),
        const MoodCheckPage(),
        const SettingsPage()
      ][selectedIndex],
      bottomNavigationBar: CrystalNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: proprimaryColor,
          unselectedItemColor: Colors.white,
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          paddingR: const EdgeInsets.symmetric(horizontal: 20),
          items: [
            CrystalNavigationBarItem(icon: Icons.home_filled),
            CrystalNavigationBarItem(icon: Icons.mood),
            CrystalNavigationBarItem(icon: Icons.settings),
          ]),
    );
  }
}
