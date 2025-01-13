import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'CustomDialog.dart';
import 'colors.dart';
import 'login.dart';
import 'main.dart';

void main() {
  runApp(const SignUp());
}

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController username = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "New Account",
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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: formState,
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
                          controller: password,
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
                          controller: confirmPassword,
                          obscureText: true,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          validator: (usernameValue) {
                            if (usernameValue!.isEmpty) {
                              return "Field is empty!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: "Username",
                            labelStyle: const TextStyle(
                              color: secondryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            prefixIcon: const Icon(
                              Icons.account_circle_outlined,
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
                          controller: username,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                MaterialButton(
                  onPressed: () async {
                    if(password.text == confirmPassword.text){
                      try {
                        final AuthResponse res = await supabase.auth.signUp(
                          email: email.text,
                          password: password.text,
                          data: {'username': username.text},
                        );
                        final Session? session = res.session;
                        final User? user = res.user;
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString('supabaseSessionToken', session?.accessToken ?? '');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              title: 'Confirm your email',
                              content: 'We have sent you an email that you entered to verify your email, confirm and log in.',
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
                              content: 'An error occurred: $error',
                            );
                          },
                        );
                      }
                    }else {
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
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
