import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_state.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool obscurePassword = true;

  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF3B82F6),
            ],
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(24),

              child: Container(
                padding:
                    const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                          30),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(.1),
                      blurRadius: 20,
                    )
                  ],
                ),

                child: Column(

                  children: [

                    // LOGO

                    Container(
                      width: 90,
                      height: 90,

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.blue.shade50,
                        shape:
                            BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.school,
                        size: 50,
                        color:
                            Color(0xFF2563EB),
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    const Text(
                      "AttachMate",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    const Text(
                      "Your Gateway to Attachments & Internships",
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),

                    const SizedBox(
                        height: 35),

                    // EMAIL

                    TextField(
                      controller:
                          emailController,

                      decoration:
                          InputDecoration(
                        labelText:
                            "Email Address",

                        prefixIcon:
                            const Icon(
                          Icons.email,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      15),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    // PASSWORD

                    TextField(
                      controller:
                          passwordController,

                      obscureText:
                          obscurePassword,

                      decoration:
                          InputDecoration(
                        labelText:
                            "Password",

                        prefixIcon:
                            const Icon(
                          Icons.lock,
                        ),

                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons
                                    .visibility_off
                                : Icons
                                    .visibility,
                          ),
                          onPressed: () {

                            setState(() {

                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      15),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    Row(
                      children: [

                        Checkbox(
                          value:
                              rememberMe,

                          onChanged:
                              (value) {

                            setState(() {

                              rememberMe =
                                  value!;
                            });
                          },
                        ),

                        const Text(
                          "Remember Me",
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed: () {

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          "Forgot Password",
        ),
        content: const Text(
          "Password reset feature coming soon.",
        ),
      );
    },
  );

},

                          child: const Text(
                            "Forgot Password?",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 20),

                    // LOGIN BUTTON

                    SizedBox(
                      width:
                          double.infinity,
                      height: 55,

                      child:
                          ElevatedButton(

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFF2563EB),

                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    15),
                          ),
                        ),

                        onPressed: () async {
                          final email = emailController.text.trim();
                          final password = passwordController.text;
                          try {
                            await context.read<AuthState>().login(email, password);
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          } catch (error) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error.toString()),
                                backgroundColor: Colors.red.shade700,
                              ),
                            );
                          }
                        },
                        child:
                            const Text(
                          "Login",
                          style:
                              TextStyle(
                            fontSize:
                                18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      "Don't have an account?",
    ),
    TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Register Screen Coming Soon",
            ),
          ),
        );
      },
      child: const Text(
        "Register",
      ),
    ),
  ],
),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
