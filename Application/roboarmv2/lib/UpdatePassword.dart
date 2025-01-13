import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'CustomDialog.dart';
import 'colors.dart';
import 'forgetpassword.dart';
import 'login.dart';
import 'main.dart';

void main() {
  runApp(UpdatePassword());
}

class UpdatePassword extends StatefulWidget {
  @override
  State<UpdatePassword> createState() => _MyAppState();
}

class _MyAppState extends State<UpdatePassword> {
  TextEditingController password = TextEditingController();
  bool visibility = false;
  final User? user = supabase.auth.currentUser;
  bool pageVisibility = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            "Change Password",
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
                  "Write your current password",
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
  TextEditingController passwordP = TextEditingController();
  TextEditingController confirmPasswordP = TextEditingController();
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
              "Write the new password",
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
                    validator: (passwordValue) {
                      if (passwordValue!.isEmpty) {
                        return "Field is empty!";
                      } else if (passwordValue.length < 8) {
                        return "Password must be at least 8 characters long!";
                      } else if (!RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$').hasMatch(passwordValue)) {
                        return "Password must contain at least one uppercase \nletter (A, Z), one lowercase letter (a, z), \none digit (0, 9), and one special character (#, @, ., &)!";
                      }
                      return null;
                    },
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
                    controller: passwordP,
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    validator: (confirmPasswordValue) {
                      if (confirmPasswordValue!.isEmpty) {
                        return "Field is empty!";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Confirm Password",
                      labelStyle: const TextStyle(
                        color: secondryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_reset,
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
                    controller: confirmPasswordP,
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: MaterialButton(
              onPressed: () async {
                if (passwordP.text == confirmPasswordP.text) {
                  try {
                    final UserResponse res = await supabase.auth.updateUser(
                      UserAttributes(
                        password: passwordP.text,
                      ),
                    );
                    await supabase.auth.signOut();
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('supabaseSessionToken');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          title: 'Password has changed',
                          content: 'Your Password has been changed.\nPlease Sign in again.',
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
                        content: 'The password and confirm password are not matches!\nPlease try again.',
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

