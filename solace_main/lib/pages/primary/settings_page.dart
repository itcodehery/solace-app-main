import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solace_main/constants.dart';
import 'package:solace_main/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserModel _user = UserModel(
      id: "0",
      createdAt: DateTime.now(),
      username: "Anonymous",
      email: "",
      bio: "",
      moodLastChecked: DateTime.now(),
      favoritesList: "");

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final response = await supabase
          .from('user')
          .select()
          .eq('email', supabase.auth.currentUser!.email!)
          .single();
      if (response.isNotEmpty) {
        if (mounted) {
          setState(() {
            _user = UserModel.fromJson(response);
          });
        }
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
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: proprimaryColor,
                child: ListTile(
                  leading:
                      const Icon(Icons.verified_outlined, color: prodarkGrey),
                  title: Text(
                    "Logged in as ${_user.username!}",
                    style: const TextStyle(
                        color: prodarkGrey, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _user.email ?? "",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        backgroundColor: prodarkGrey,
                        title: const Text("Log Out",
                            style: TextStyle(color: Colors.white)),
                        content: const Text("Are you sure you want to log out?",
                            style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text("Cancel",
                                style: TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await supabase.auth.signOut().then((c) {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, "/loginas", (route) => false);
                                });
                              } on PostgrestException catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.message),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text("Log Out",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    });
              },
              title: const Text(
                "Log Out",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              onTap: () {
                Get.toNamed("/favorites");
              },
              title: const Text(
                "Favorites",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ));
  }
}
