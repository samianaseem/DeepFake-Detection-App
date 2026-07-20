import 'package:final_year_project2025/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isLoading = false;

  Future<void> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
  }

  void handleSignup() async {
    setState(() => _isLoading = true);

    final name = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill all fields"),
      ));
      setState(() => _isLoading = false);
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Passwords do not match"),
      ));
      setState(() => _isLoading = false);
      return;
    }

    final result = await ApiService.signupUser(
      name: name,
      email: email,
      password: pass,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      await saveUserName(result['name']);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Welcome ${result['name']}"),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message']),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.5,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/WhatsApp Image 2025-01-24 at 2.01.05 PM.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sign Up",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _usernameController,
                        decoration: _inputDecoration("Username"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: _inputDecoration("E-mail"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: _passwordInputDecoration("Password", () {
                          setState(() => _isObscure = !_isObscure);
                        }, _isObscure),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _isObscure2,
                        decoration:
                            _passwordInputDecoration("Re-Enter Password", () {
                          setState(() => _isObscure2 = !_isObscure2);
                        }, _isObscure2),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: handleSignup,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor:
                              const Color.fromARGB(255, 129, 209, 218),
                          foregroundColor: Colors.black,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white))
                            : const Text("Create Account"),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(255, 231, 232, 233),
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  InputDecoration _passwordInputDecoration(
      String label, VoidCallback onToggle, bool isObscure) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(255, 231, 232, 233),
      labelText: label,
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggle,
      ),
    );
  }
}
