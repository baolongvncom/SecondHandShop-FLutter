import 'package:firebase_auth_turtorial/services/notify_messages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_turtorial/components/my_button.dart';
import 'package:firebase_auth_turtorial/components/my_textfield.dart';
import 'package:firebase_auth_turtorial/pages/Authentication%20Pages/authentication_services/authentication.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  // check loading circle
  bool isLoadingCircle = false;

  // check sign in state
  bool isSignIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 30),

                // welcome back, you've been missed!
                Text(
                  "Let's create your account!",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // username textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // loading circle
                if (isLoadingCircle)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

                // sign up button
                MyButton(
                  text: 'Sign Up',
                  onTap: () async {
                    if (passwordController.text ==
                        confirmPasswordController.text) {
                      setState(() {
                        isLoadingCircle =
                            true; // Bắt đầu hiển thị hình tròn tiến trình
                      });

                      isSignIn = await AuthService().registerUser(
                        emailController.text,
                        passwordController.text,
                        context,
                      );

                      // send sign in state
                      await AuthService.setSignInState(isSignIn);

                      setState(() {
                        isLoadingCircle =
                            false; // Kết thúc hiển thị hình tròn tiến trình
                      });
                    } else {
                      wrongConfirmPasswordMessage(context);
                      await AuthService.setSignInState(false);
                    }
                  },
                ),

                const SizedBox(height: 30),

                const SizedBox(height: 30),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
