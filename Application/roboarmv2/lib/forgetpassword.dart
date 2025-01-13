import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'CustomDialog.dart';
import 'colors.dart';
import 'login.dart';
import 'main.dart';

void main() {
  runApp(const forgetpassword());
}

class forgetpassword extends StatefulWidget {
  const forgetpassword({Key? key}) : super(key: key);
  @override
  State<forgetpassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<forgetpassword> {
  TextEditingController email = TextEditingController();
  GlobalKey<FormState> fieldState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Forget Password",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          backgroundColor: secondryColor,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: primaryColor,
                size: 30,
              ),
            ),
          ],
        ),
        body: Builder(
          builder: (scaffoldContext) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15.0),
                  child: const Text(
                    "Enter the email associated with the account to send the reset password email.",
                    style: TextStyle(
                      color: secondryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    child: TextFormField(
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
                  ),
                ),
                MaterialButton(
                  onPressed: ()  async {
                    if (!(email.text!.isEmpty)) {
                      supabase.auth.resetPasswordForEmail(email.text);
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      bool containsToken = prefs.containsKey('supabaseSessionToken');
                      if (containsToken) {
                        await prefs.remove('supabaseSessionToken');
                        final User? user = supabase.auth.currentUser;
                        if(user!.appMetadata?["provider"] == "google"){
                          GoogleSignIn().signOut();
                        }
                        await supabase.auth.signOut();
                      }
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialog(
                            title: 'Sending reset email complete',
                            content: 'We have sent you an email to reset your password\nReset and return to log in.',
                            onOkPressed: (BuildContext context) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => Login()),
                                    (Route<dynamic> route) => false,
                              );
                            },
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialog(
                            title: 'Wrong Entry!',
                            content: 'Please Write your email.',
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
                      "Send reset password email",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
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
