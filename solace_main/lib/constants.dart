import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

int selectedIndex = 0;

const proprimaryColor = Color.fromARGB(255, 186, 255, 99);
const proprimaryLighterColor = Color.fromARGB(255, 216, 255, 169);
const proprimaryDarkerColor = Color.fromARGB(255, 140, 236, 55);
const prodarkGrey = Color.fromARGB(255, 30, 30, 30);
const propaddingdefaultall = EdgeInsets.all(8);
const propaddingallexceptbottom = EdgeInsets.fromLTRB(8, 8, 8, 0);
const propaddingallexcepttop = EdgeInsets.fromLTRB(8, 0, 8, 8);
const propaddingdefaulthorizontal = EdgeInsets.symmetric(horizontal: 8);
const propaddingdefaultvertical = EdgeInsets.symmetric(vertical: 8);
const bigTextFontSize = 18.0;
const mediumTextFontSize = 14.0;
const smallTextFontSize = 12.0;
const defaultGradient = LinearGradient(colors: [
  proprimaryColor,
  proprimaryDarkerColor,
]);

final Map<String, Color> moods = {
  "Happy": const Color.fromARGB(255, 255, 245, 159),
  "Sad": const Color.fromARGB(255, 170, 217, 255),
  "Angry": const Color.fromARGB(255, 255, 170, 164),
  "Excited": const Color.fromARGB(255, 243, 173, 255),
  "Anxious": const Color.fromARGB(255, 255, 224, 177),
  "Calm": const Color.fromARGB(255, 169, 255, 172),
  "Frustrated": const Color.fromARGB(255, 255, 174, 201),
  "Tired": Colors.grey,
  "Energetic": const Color.fromARGB(255, 220, 255, 179),
  "Stressed": const Color.fromARGB(255, 255, 195, 177),
  "Confident": const Color.fromARGB(255, 255, 233, 169),
};

final List<String> daysOfTheWeek = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];
