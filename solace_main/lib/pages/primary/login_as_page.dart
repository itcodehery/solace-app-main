import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:solace_main/constants.dart';
import 'package:form_validator/form_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:password_strength/password_strength.dart';

enum AuthType { login, signIn }

class LoginAsPage extends StatefulWidget {
  const LoginAsPage({super.key});

  @override
  _LoginAsPageState createState() => _LoginAsPageState();
}

class _LoginAsPageState extends State<LoginAsPage> {
  //authmode
  String errorMessage = '';
  bool isLogin = true;
  bool isObscured = true;
  AuthType authMode = AuthType.login;
  late final StreamSubscription<AuthState> _auth;

  //controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();

  //keys
  final _formKey = GlobalKey<FormState>();

  //initstate
  @override
  void initState() {
    super.initState();
    _auth = supabase.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        Get.offAndToNamed("/widget_tree");
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    _auth.cancel();
    super.dispose();
  }

  Future<void> _loginOrSignUp() async {
    if (isLogin) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Logging in...",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: proprimaryColor,
        ));
        debugPrint("inside login auth");
        await supabase.auth
            .signInWithPassword(
                email: emailController.text, password: passwordController.text)
            .then((value) => Get.showSnackbar(GetSnackBar(
                  backgroundColor: proprimaryColor,
                  margin: const EdgeInsets.all(8.0),
                  duration: const Duration(seconds: 4),
                  messageText: Text(
                    "Welcome, ${emailController.text}!",
                    style: const TextStyle(
                      color: prodarkGrey,
                    ),
                  ),
                  titleText: const Text(
                    "Logged in successfully!",
                    style: TextStyle(
                      color: prodarkGrey,
                    ),
                  ),
                )));
      } on AuthException catch (e) {
        setState(() {
          errorMessage = e.message;
        });
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Error"),
                  content: Text(errorMessage),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("OK"))
                  ],
                );
              });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Signing up...",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: proprimaryColor,
      ));
      await supabase.auth.signUp(
          email: emailController.text,
          password: passwordController.text,
          data: {"username": fullNameController.text}).then((value) async {
        try {
          await supabase.from("user").upsert({
            "id": value.user!.id,
            "user_name": fullNameController.text,
            "email": emailController.text,
          });
        } on PostgrestException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.message)));
          }
        }
        Get.showSnackbar(GetSnackBar(
          margin: const EdgeInsets.all(8.0),
          backgroundColor: proprimaryColor,
          duration: const Duration(seconds: 3),
          messageText: Text(
            "Welcome, ${fullNameController.text}! What would you like today?",
            style: const TextStyle(color: prodarkGrey),
          ),
          titleText: const Text(
            "Signed up successfully!",
            style: TextStyle(color: prodarkGrey),
          ),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'solace.',
          style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.bold, color: proprimaryColor),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'For a better you.',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton(
                selectedIcon: const Icon(Icons.check),
                style: ButtonStyle(
                    side: const WidgetStatePropertyAll(BorderSide(
                      color: proprimaryColor,
                    )),
                    backgroundColor: WidgetStatePropertyAll(
                        proprimaryColor.withOpacity(0.2)),
                    foregroundColor:
                        const WidgetStatePropertyAll(proprimaryLighterColor)),
                segments: const <ButtonSegment<AuthType>>[
                  ButtonSegment(value: AuthType.login, label: Text('Login')),
                  ButtonSegment(value: AuthType.signIn, label: Text('Sign Up')),
                ],
                selected: <AuthType>{authMode},
                onSelectionChanged: (Set<AuthType> newSelection) {
                  setState(() {
                    authMode = newSelection.first;
                    isLogin = !isLogin;
                  });
                },
              ),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: proprimaryColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          focusColor: proprimaryColor,
                          label: Text('Your email')),
                      controller: emailController,
                      validator: (value) {
                        ValidationBuilder().email().maxLength(50).build();
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: passwordController,
                            obscureText: isObscured,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: proprimaryColor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                label: Text('Password')),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "The field is required!";
                              }
                              if (estimatePasswordStrength(value) < 0.3) {
                                return 'Password is too weak';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                            icon: isObscured
                                ? const Icon(Icons.hide_source)
                                : const Icon(Icons.password)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Visibility(
                        visible: !isLogin,
                        child: Column(
                          children: [
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: proprimaryColor),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  label: Text('User Name')),
                              controller: fullNameController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20),
                                FilteringTextInputFormatter.singleLineFormatter,
                                FilteringTextInputFormatter.deny(" ",
                                    replacementString: "-")
                              ],
                              validator: (value) {
                                var filter = ProfanityFilter();
                                if (filter.hasProfanity(value!)) {
                                  return "The username contains profanity!";
                                }
                                if (value.isEmpty && !isLogin) {
                                  return "The field is required!";
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        )),
                  ],
                ),
              )
            ],
          )),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                  backgroundBuilder: (context, states, child) {
                    return Container(
                        decoration: const BoxDecoration(
                            gradient: defaultGradient,
                            boxShadow: [
                              BoxShadow(
                                  color: proprimaryColor,
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: Offset(0, 0))
                            ]),
                        child: Center(
                          child: Text(
                            isLogin ? "Login" : "Sign Up",
                            style: const TextStyle(
                              color: prodarkGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: mediumTextFontSize,
                            ),
                          ),
                        ));
                  },
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _loginOrSignUp();
                  }
                },
                child: Text(
                  isLogin ? "Login" : "Sign Up",
                  style: const TextStyle(
                    color: prodarkGrey,
                    fontSize: mediumTextFontSize,
                  ),
                ))),
      ),
    );
  }
}
