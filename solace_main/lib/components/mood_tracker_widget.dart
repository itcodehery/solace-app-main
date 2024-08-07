// mood_tracker_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/helper/day_calc.dart';
import 'package:solace_main/models/mood_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MoodTrackerWidget extends StatefulWidget {
  const MoodTrackerWidget({super.key});

  @override
  State<MoodTrackerWidget> createState() => _MoodTrackerWidgetState();
}

class _MoodTrackerWidgetState extends State<MoodTrackerWidget> {
  List<MoodModel> moodData = [];

  @override
  void initState() {
    super.initState();
    _fetchMoodData();
  }

  Future<void> _fetchMoodData() async {
    try {
      debugPrint("Fetching mood data");
      final data = await supabase
          .from('mood_track')
          .select()
          .eq('usermail', supabase.auth.currentUser!.email!);
      debugPrint(data.first.toString());
      if (data.isNotEmpty) {
        setState(() {
          for (var e in data) {
            moodData.add(MoodModel.fromJson(e));
          }
          moodData = moodData.reversed.toList();
        });
        debugPrint(moodData.first.mood ?? "No mood");
      } else {
        debugPrint("No mood data available");
        return;
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } catch (error) {
      if (mounted) {
        SnackBar(
          content: const Text('Unexpected error occurred'),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (moodData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(proprimaryColor),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)))),
                minimumSize: WidgetStatePropertyAll(Size.fromHeight(40))),
            onPressed: () {
              _fetchMoodData();
              if (moodData.isEmpty) {
                Get.showSnackbar(const GetSnackBar(
                  duration: Duration(seconds: 3),
                  messageText: Text(
                    "No Mood Data Available!",
                    style: TextStyle(
                      color: proprimaryColor,
                    ),
                  ),
                ));
              }
            },
            child: const Text("How's your Mood?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: prodarkGrey,
                ))),
      );
    }
    return SizedBox(
      height: 120,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: moodData.length,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 115,
                  height: 100,
                  decoration: BoxDecoration(
                      color: index == 0 ? proprimaryColor : prodarkGrey,
                      borderRadius: BorderRadius.circular(6)),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: prodarkGrey,
                              title: ListTile(
                                leading: Icon(
                                  Icons.mood_rounded,
                                  color: moods[moodData[index].mood!],
                                ),
                                title: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    moodData[index].mood!,
                                    style: TextStyle(
                                      color: moods[moodData[index].mood!]!,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                trailing:
                                    Text("Lvl.${moodData[index].intensity}",
                                        style: TextStyle(
                                          color: moods[moodData[index].mood!]!,
                                          fontWeight: FontWeight.bold,
                                          fontSize: mediumTextFontSize,
                                        )),
                              ),
                            );
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.mood,
                              color: index == 0 ? prodarkGrey : Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            moodData[index].mood!,
                            style: TextStyle(
                              color: index == 0 ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: mediumTextFontSize,
                            ),
                          ),
                          Text(DayCalc(date: moodData[index].createdAt!).dayAgo,
                              style: TextStyle(
                                  color: index == 0
                                      ? Colors.black87
                                      : Colors.white70,
                                  fontSize: smallTextFontSize)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
