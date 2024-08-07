import 'package:dart_sentiment/dart_sentiment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:info_popup/info_popup.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/helper/day_calc.dart';
import 'package:solace_main/models/mood_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MoodRecentListWidget extends StatefulWidget {
  const MoodRecentListWidget({super.key});

  @override
  _MoodRecentListWidgetState createState() => _MoodRecentListWidgetState();
}

class _MoodRecentListWidgetState extends State<MoodRecentListWidget> {
  List<MoodModel> _recentMoods = [];
  String _sentimentAnalysisString = "";
  String _finalSentiment = "";

  @override
  void initState() {
    super.initState();
    _fetchRecentMoods();
  }

  Future<void> _fetchRecentMoods() async {
    try {
      debugPrint("fetching recent moods");
      var response = await supabase
          .from('mood_track')
          .select()
          .eq('usermail', supabase.auth.currentUser!.email!)
          .order('created_at', ascending: false)
          .limit(10);
      debugPrint(response.length.toString());
      if (response.isNotEmpty) {
        _recentMoods = response.map((e) => MoodModel.fromJson(e)).toList();
        if (mounted) {
          setState(() {
            _recentMoods = _recentMoods;
            _sentimentAnalysisString =
                _recentMoods.map((element) => element.mood!).join(" ");
            debugPrint(_sentimentAnalysisString);
            _analyseSentiment();
          });
        }
      }
    } on PostgrestException catch (e) {
      debugPrint('Error: ${e.message}');
      Get.showSnackbar(GetSnackBar(
          title: 'Error',
          message: e.message,
          duration: const Duration(seconds: 3)));
    }
  }

  void _analyseSentiment() {
    final sentiment = Sentiment();
    final sentimentResult = sentiment.analysis(_sentimentAnalysisString);
    setState(() {
      _finalSentiment = sentimentResult['score'] > 0
          ? 'positive'
          : (sentimentResult['score'] < 0 ? 'negative' : 'neutral');
    });
    debugPrint(sentimentResult.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_recentMoods.isNotEmpty)
          Padding(
            padding: propaddingdefaultall,
            child: Card(
              color: prodarkGrey,
              child: Padding(
                padding: propaddingdefaultall,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("You have been feeling ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: bigTextFontSize)),
                        Text(_finalSentiment,
                            style: const TextStyle(
                                color: proprimaryColor,
                                fontSize: bigTextFontSize,
                                fontWeight: FontWeight.w700)),
                        const Text(" lately",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: bigTextFontSize)),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Based on your recent moods",
                            style: TextStyle(color: Colors.white70)),
                        SizedBox(width: 10),
                        InfoPopupWidget(
                            contentTitle:
                                "Higher number of moods lead to more accurate results",
                            child: Icon(Icons.info_outline,
                                color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          ),
        if (_recentMoods.isEmpty)
          const SizedBox(
            width: double.infinity,
            height: 200,
            child: Center(
              child: Text(
                "No Mood Data Available",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: _recentMoods.length < 3
                ? (54 * _recentMoods.length).toDouble()
                : 180.0,
            child: Stack(
              children: [
                ListView.builder(
                  physics: _recentMoods.length < 4
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  itemCount: _recentMoods.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "${_recentMoods[index].mood!} (Lvl.${_recentMoods[index].intensity.toString()})",
                        style: TextStyle(
                          color: moods[_recentMoods[index].mood!]!,
                          fontWeight: FontWeight.bold,
                          fontSize: mediumTextFontSize,
                        ),
                      ),
                      trailing: Text(
                        DayCalc(date: _recentMoods[index].createdAt!).dayAgo,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: mediumTextFontSize,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Visibility(
                      visible: _recentMoods.length > 3,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                        ),
                        width: double.infinity,
                        height: 30,
                        child: const Center(
                          child: Icon(Icons.arrow_drop_down_rounded,
                              color: Colors.white),
                        ),
                      )),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
