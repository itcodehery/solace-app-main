import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:info_popup/info_popup.dart';
import 'package:solace_main/components/daily_challenge_widget.dart';
import 'package:solace_main/components/mood_recent_list_widget.dart';
import 'package:solace_main/constants.dart';
import 'package:http/http.dart' as http;
import 'package:solace_main/models/quote_model.dart';

class MoodCheckPage extends StatefulWidget {
  const MoodCheckPage({super.key});

  @override
  _MoodCheckPageState createState() => _MoodCheckPageState();
}

class _MoodCheckPageState extends State<MoodCheckPage> {
  int selectedMoodIndex = 0;
  double selectedMoodIntensity = 1.0;
  List<QuoteModel> quotes = [QuoteModel(authorName: "...", quoteText: "...")];
  int random = 0;

  @override
  void initState() {
    fetchQuotes();
    super.initState();
  }

  Future<void> fetchQuotes() async {
    const apiUrl = "https://zenquotes.io/api/quotes/";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final quoteFinal = data.map(
        (quote) {
          return QuoteModel.fromJson(quote);
        },
      ).toList();
      random = Random().nextInt(quoteFinal.length);
      if (mounted) {
        setState(() {
          quotes = quoteFinal;
          debugPrint(quoteFinal.first.quoteText!);

          debugPrint(random.toString());
          debugPrint(quotes[random].quoteText!);
        });
      }
    } else {
      // throw Exception('Failed to load quotes');
      Get.showSnackbar(const GetSnackBar(
        titleText: Text("Failed to fetch Quotes!"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                "Mood Check",
                style: GoogleFonts.spaceMono(
                  color: Colors.white,
                  fontSize: bigTextFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMainButtons(),
            const DailyChallengeWidget(),
            ListTile(
              title: Text(
                "stats / Recent Days",
                style: GoogleFonts.spaceMono(
                  color: Colors.white,
                  fontSize: bigTextFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const MoodRecentListWidget(),
            Visibility(
              visible: (quotes.isNotEmpty && random < quotes.length),
              child: Column(
                children: [
                  ListTile(
                    title: Text("Quote of the Day",
                        style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: bigTextFontSize,
                          fontWeight: FontWeight.bold,
                        )),
                    trailing: const InfoPopupWidget(
                        contentTitle: "From ZenQuotes.io",
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.white70,
                        )),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: prodarkGrey,
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "“${quotes[random].quoteText!}”",
                            style: const TextStyle(
                                color: Colors.white, fontSize: bigTextFontSize),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            quotes[random].authorName!,
                            style: const TextStyle(color: proprimaryColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButtons() {
    return Container(
      margin: propaddingallexceptbottom,
      height: 100,
      child: GridView.builder(
          itemCount: 2,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2,
          ),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (index == 0) {
                  Get.toNamed('/postcreate');
                } else {
                  Get.toNamed('/resources');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: index == 0 ? proprimaryColor : prodarkGrey,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: propaddingdefaultall,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        index == 0
                            ? Icons.create_outlined
                            : Icons.sentiment_very_satisfied_rounded,
                        color: index == 0 ? prodarkGrey : proprimaryColor,
                      ),
                      const Spacer(),
                      Text(
                        index == 0 ? 'Write a Post' : 'Find Resources',
                        style: TextStyle(
                            fontSize: mediumTextFontSize,
                            fontWeight: FontWeight.w600,
                            color: index == 0 ? prodarkGrey : Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
