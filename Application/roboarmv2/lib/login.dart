import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roboarmv2/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'CustomDialog.dart';
import 'colors.dart';
import 'forgetpassword.dart';
import 'home.dart';
import 'main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

Future<void> signInWithGoogleOnDesktop(BuildContext context) async {
  try {
    await supabase.auth.signInWithOAuth(OAuthProvider.google);
    final Session? session = supabase.auth.currentSession;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('supabaseSessionToken', session?.accessToken ?? '');
  } catch (error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Google Sign-In Error',
          content: 'An error occurred while signing in with Google.',
        );
      },
    );
  }
}

Future<AuthResponse> _googleSignIn() async {
  const webClientId = '1004640859410-ktna75av95thc7bd5552gob9h3rlrrsa.apps.googleusercontent.com';
  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId: webClientId,
  );
  final googleUser = await googleSignIn.signIn();
  final googleAuth = await googleUser!.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;
  if (accessToken == null) {
    throw 'No Access Token found.';
  }
  if (idToken == null) {
    throw 'No ID Token found.';
  }
  return supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );
}

Future<void> _saveSessionToSharedPreferences(String accessToken) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('supabaseSessionToken', accessToken);
}

Future<void> _googleSignInAndNavigate(BuildContext context) async {
  try {
    final AuthResponse res = await _googleSignIn();
    final Session? session = res.session;
    final User? user = res.user;
    if (session != null) {
      await _saveSessionToSharedPreferences(session.accessToken!);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => home()),
            (Route<dynamic> route) => false,
      );
    }
  } catch (error, stackTrace) {
    print("Google Sign-In Error: $error");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Google Sign-In Error',
          content: 'An error occurred while signing in with Google.',
        );
      },
    );
  }
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey();
  bool visibility = false;

  @override
  Widget build(BuildContext context) {
    BuildContext scaffoldContext;
    return MaterialApp(
      color: backgroundColor,
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            scaffoldContext = context;
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Image.asset(
                          "images/roboarmlogo.png",
                          height: MediaQuery.of(context).size.height / 5,
                        ),
                        const Text(
                          "RoboArm",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            validator: (emailValue) {
                              if (emailValue!.isEmpty) {
                                return "Field is empty!";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "Email",
                              labelStyle: const TextStyle(
                                color: secondryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: secondryColor,
                                size: 35,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: secondryColor, width: 2),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: secondryColor, width: 2),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: secondryColor,
                            ),
                            controller: email,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            validator: (passwordValue) {
                              if (passwordValue!.isEmpty) {
                                return "Field is empty!";
                              }
                              return null;
                            },
                            obscureText: !visibility,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "Password",
                              labelStyle: const TextStyle(
                                color: secondryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: secondryColor,
                                size: 35,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  visibility
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: secondryColor,
                                  size: 35,
                                ),
                                onPressed: () {
                                  setState(() {
                                    visibility = !visibility;
                                  });
                                },
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: secondryColor, width: 2),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: secondryColor, width: 2),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: secondryColor,
                            ),
                            controller: password,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const forgetpassword()),
                          );
                        },
                        child: const Text(
                          "Forget password?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: secondryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  MaterialButton(
                    onPressed: () async {
                      try {
                        final AuthResponse res = await supabase.auth.signInWithPassword(
                          email: email.text,
                          password: password.text,
                        );
                        final Session? session = res.session;
                        final User? user = res.user;

                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString('supabaseSessionToken', session?.accessToken ?? '');

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => home()),
                              (Route<dynamic> route) => false,
                        );
                      } catch (error) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              title: 'Wrong entry!',
                              content: 'Check the email or password.',
                            );
                          },
                        );
                      }
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: secondryColor, width: 2.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Do not have an account?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: secondryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const SignUp()));
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              width: 30,
                              color: primaryColor,
                              height: 2,
                            ),
                            const Text(
                              "Or Login with",
                              style: TextStyle(
                                color: secondryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              width: 30,
                              color: primaryColor,
                              height: 2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        MaterialButton(
                          onPressed: () async {
                            if(Platform.isAndroid){
                              await _googleSignInAndNavigate(context);
                            } else if (Platform.isWindows){
                              await signInWithGoogleOnDesktop(context);
                            }
                          },
                          color: backgroundColor,
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: secondryColor,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Image.asset(
                            "images/google_logo.png",
                            width: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
