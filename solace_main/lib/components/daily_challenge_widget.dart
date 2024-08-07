import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/helper/shared_prefs_helper.dart';
import 'package:solace_main/models/daily_challenge_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyChallengeWidget extends StatefulWidget {
  const DailyChallengeWidget({super.key});

  @override
  _DailyChallengeWidgetState createState() => _DailyChallengeWidgetState();
}

class _DailyChallengeWidgetState extends State<DailyChallengeWidget> {
  DailyChallenge dailyChallenge = DailyChallenge(
    id: '',
    createdOn: DateTime.now(),
    challenge: '',
    dcContent: '',
  );
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    SharedPrefsHelper().readBool('isCompleted').then((value) {
      if (mounted) {
        setState(() {
          isCompleted = value;
        });
      }
    });
    _fetchDailyChallenges();
  }

  Future<void> _fetchDailyChallenges() async {
    // Fetch daily challenges from the database
    try {
      var result = await supabase.from('daily_challenges').select();
      if (mounted) {
        setState(() {
          dailyChallenge = DailyChallenge.fromJSON(result.last);
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Perform any necessary cleanup here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: propaddingallexcepttop,
      child: Card(
        color: proprimaryColor,
        child: Padding(
          padding: propaddingdefaultall,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: propaddingdefaultall,
                child: Text(
                  "Today's Daily Challenge",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: mediumTextFontSize,
                  ),
                ),
              ),
              Card(
                color: prodarkGrey,
                child: CheckboxListTile(
                  activeColor: proprimaryColor.withOpacity(0.5),
                  value: isCompleted,
                  onChanged: (e) {
                    SharedPrefsHelper().saveBool('isCompleted', e!);
                    if (mounted) {
                      setState(() {
                        isCompleted = e;
                      });
                    }
                    if (isCompleted) {
                      Get.showSnackbar(const GetSnackBar(
                          titleText: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: prodarkGrey,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Challenge Completed!",
                                style: TextStyle(
                                  fontSize: mediumTextFontSize,
                                  color: prodarkGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          messageText: Text(
                            "Good job! Keep it up!",
                            style: TextStyle(
                              fontSize: smallTextFontSize,
                              color: prodarkGrey,
                            ),
                          ),
                          duration: Duration(seconds: 3),
                          backgroundColor: proprimaryColor));
                    }
                  },
                  title: Text(
                    dailyChallenge.challenge,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: mediumTextFontSize),
                  ),
                  subtitle: Text(
                    dailyChallenge.dcContent,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: smallTextFontSize),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
