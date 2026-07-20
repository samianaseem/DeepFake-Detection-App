import 'package:final_year_project2025/api.dart';
import 'package:final_year_project2025/home_screen.dart';
import 'package:final_year_project2025/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isObscure = true;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    String identifier = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await _apiService.login(identifier, password);

    setState(() {
      _isLoading = false;
    });

    print("Login API Response: $response");

    if (response["message"] == "Login successful" ||
        response["success"] == true) {
      String userName =
          response["user"]["name"] ?? "Guest"; // ✅ user ka naam pick karo
      String userId = response["user"]["id"].toString(); // ✅ userId bhi nikaalo
      await saveUserName(userName); // ✅ naam save karo SharedPreferences me
      await saveUserId(userId); // ✅ userId bhi save karo

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["error"] ?? "Login failed")),
      );
    }
  }

// ✅ Copy-paste karo saveUserName() function yahan bhi:
  Future<void> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
    print("Saved Name: $userName");
  }

  Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    print("Saved ID: $userId");
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
              widthFactor: 1.0,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                ),
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
                        'assets/WhatsApp Image 2025-01-24 at 2.01.05 PM.jpeg',
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(255, 231, 232, 233),
                          labelText: 'E-mail or Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        obscureText:
                            _isObscure, // Ye property password ko hide/show karegi
                        controller: _passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 231, 232, 233),
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          //suffixIcon: Icon(Icons.visibility_off),
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure =
                                    !_isObscure; // Value toggle ho jayegi
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Forgot your Password?',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.1,
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor:
                                  const Color.fromARGB(255, 129, 209, 218),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text('Login'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "OR",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor:
                              const Color.fromARGB(255, 231, 232, 233),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Create an Account'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
