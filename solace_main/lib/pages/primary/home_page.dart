import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solace_main/components/mood_tracker_widget.dart';
import 'package:solace_main/components/social_posts_feed.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? user;
  DateTime? moodLastChecked;
  int selectedMoodIndex = 0;
  double selectedMoodIntensity = 1.0;

  @override
  void initState() {
    super.initState();
    _userDetailsRetrieval().then((v) {
      if (mounted && user != null && user!.moodLastChecked != null) {
        if (user!.moodLastChecked!.day != DateTime.now().toLocal().day) {
          debugPrint(
              "Result of comparison: ${(user!.moodLastChecked!.day != DateTime.now().day).toString()}");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            buildTheMoodDialog();
          });
        } else {
          debugPrint(
              "Result of comparison: ${(user!.moodLastChecked!.day != DateTime.now().day).toString()}");
          debugPrint("Mood already checked today!");
        }
      } else {
        debugPrint("Something went wrong!");
      }
    });
  }

  Future<dynamic> buildTheMoodDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              contentPadding: const EdgeInsets.all(16.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'How is your Mood today?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: mediumTextFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: List.generate(
                        moods.length,
                        (index) => ChoiceChip(
                          selectedColor: moods.values.elementAt(index),
                          backgroundColor: Colors.black,
                          label: Text(
                            moods.keys.elementAt(index),
                            style: TextStyle(
                              color: selectedMoodIndex == index
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          selected: selectedMoodIndex == index,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedMoodIndex = selected ? index : 0;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'How intense is this Mood?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: mediumTextFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    selectedMoodIntensity.floor().toString(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: bigTextFontSize),
                  ),
                  const SizedBox(height: 8.0),
                  Slider(
                    value: selectedMoodIntensity,
                    activeColor: moods.values.elementAt(selectedMoodIndex),
                    onChanged: (double value) {
                      setState(() {
                        selectedMoodIntensity = value;
                      });
                    },
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: selectedMoodIntensity.toStringAsFixed(1),
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundBuilder: (context, states, child) {
                            return Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: prodarkGrey,
                              ),
                              child: child,
                            );
                          },
                          shape: const WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6))))),
                      onPressed: () {
                        _saveTodayMood().then((v) {
                          _updateUserLastMoodChecked();
                          Navigator.pop(context);
                        });
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: mediumTextFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _userDetailsRetrieval() async {
    try {
      debugPrint("fetching user details");
      debugPrint(supabase.auth.currentUser!.email!);
      var res = await supabase
          .from('user')
          .select()
          .eq('email', supabase.auth.currentUser!.email!)
          .single();

      setState(() {
        user = UserModel.fromJson(res);
        moodLastChecked = user!.moodLastChecked;
      });
      debugPrint(user!.username);
      debugPrint("Mood last Checked: $moodLastChecked");
    } on PostgrestException catch (e) {
      debugPrint('Error: ${e.message}');
    }
  }

  Future<void> _saveTodayMood() async {
    try {
      await supabase.from('mood_track').insert([
        {
          'usermail': supabase.auth.currentUser!.email!,
          'mood': moods.keys.elementAt(selectedMoodIndex),
          'intensity': selectedMoodIntensity.floor(),
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);
      if (mounted) {
        Get.showSnackbar(const GetSnackBar(
          titleText: Text("Today's Mood Saved!",
              style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 4),
          messageText: Text(
            "You can check your mood history in the mood tracker",
            style: TextStyle(color: Colors.white70),
          ),
        ));
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 10),
          content: Text(
            e.message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: prodarkGrey,
        ));
      }
    }
  }

  Future<void> _updateUserLastMoodChecked() async {
    try {
      await supabase.from('user').update({
        'mood_last_checked': DateTime.now().toIso8601String(),
      }).eq('email', supabase.auth.currentUser!.email!);
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            e.message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: prodarkGrey,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoodTrackerWidget(),
            ListTile(
              title: Text(
                "Top Posts",
                style: TextStyle(
                    fontSize: mediumTextFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
            SocialPostsFeed(),
          ],
        ),
      ),
    );
  }
}
