import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'CustomDialog.dart';
import 'colors.dart';
import 'forgetpassword.dart';
import 'login.dart';
import 'main.dart';

void main() {
  runApp(UpdateEmail());
}

class UpdateEmail extends StatefulWidget {
  @override
  State<UpdateEmail> createState() => _MyAppState();
}

class _MyAppState extends State<UpdateEmail> {
  TextEditingController password = TextEditingController();
  bool visibility = false;
  bool pageVisibility = false;

  @override
  void initState() {
    super.initState();
    final User? user = supabase.auth.currentUser;
    pageVisibility = user?.appMetadata?["provider"] == "google" ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            "Update Email",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          backgroundColor: secondryColor,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: primaryColor,
                size: 30,
              ),
            )
          ],
        ),
        body: pageVisibility
            ? NewWidget()
            : Center(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Enter your password",
                  style: TextStyle(color: secondryColor, fontSize: 23, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 20),
                Container(
                  child: TextFormField(
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
                          visibility ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                ),
                SizedBox(height: 20),
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
                SizedBox(height: 20),
                MaterialButton(
                  onPressed: () async {
                    try {
                      final User? user = supabase.auth.currentUser;
                      final AuthResponse res = await supabase.auth.signInWithPassword(
                        email: user?.email,
                        password: password.text,
                      );
                      setState(() {
                        pageVisibility = true;
                      });
                    } catch (error) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialog(
                            title: 'Wrong Password!',
                            content: 'You have entered wrong password!\nPlease try again.',
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
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewWidget extends StatelessWidget {
  TextEditingController email = TextEditingController();
  GlobalKey<FormState> formStateP = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              "Write new Email",
              style: TextStyle(color: secondryColor, fontSize: 23, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Form(
              //key: formStateP,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    validator: (emailValue) {
                      if (emailValue!.isEmpty) {
                        return "Field is empty!";
                      } else if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$").hasMatch(emailValue)) {
                        return "Enter a valid email address!\nexample@mail.com";
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: MaterialButton(
              onPressed: () async {
                if (email.text != "" ) {
                  try {
                    final UserResponse res = await supabase.auth.updateUser(
                      UserAttributes(
                        email: email.text,
                      ),
                    );

                    final User? user = supabase.auth.currentUser;
                    if(user!.appMetadata?["provider"] == "google"){
                      GoogleSignIn().signOut();
                    }

                    await supabase.auth.signOut();
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('supabaseSessionToken');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          title: 'About to change',
                          content: '\nPlease confirm this process, we have sent email in both emails to confirm the process\nConfirm it and return to Sign Up again.',
                          onOkPressed: (BuildContext context) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => Login()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                        );
                      },
                    );
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          title: 'Error!',
                          content: 'Sorry something is wrong!\nPlease try again.',
                        );
                      },
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: 'Entry is wrong!',
                        content: 'Filed is empty!\nPlease try again.',
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
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: const Text(
                  "Confirm",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

