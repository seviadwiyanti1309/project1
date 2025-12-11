import 'package:flutter/material.dart';
import 'package:project1/main.dart';
import 'package:project1/page_user/user_home.dart';
import 'home_page.dart'; 
import 'page_user/user_home.dart'; 
import 'services/auth_services.dart';
import 'models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 420,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0),
                        child: Image.asset(
                          "assets/images/login_illustration.png",
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.transparent,
                              child: const Center(
                                child: Icon(
                                  Icons.computer,
                                  size: 150,
                                  color: Colors.white30,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    Positioned(
                      top: 40,
                      left: 32,
                      right: 32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Welcome back!",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Login here!",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    TextField(
                      controller: emailController,
                      enabled: !_isLoading,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        labelText: "Email/Username",
                        labelStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black54, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Password
                    TextField(
                      controller: passwordController,
                      enabled: !_isLoading,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black54, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
                          disabledBackgroundColor: Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // OR
                    const Center(
                      child: Text(
                        "Or",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Social Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        socialIconWidget(
                          icon: Icons.g_mobiledata,
                          color: const Color(0xFFDB4437),
                          iconSize: 32,
                        ),
                        const SizedBox(width: 24),
                        socialIconWidget(
                          icon: Icons.facebook,
                          color: const Color(0xFF4267B2),
                          iconSize: 26,
                        ),
                        const SizedBox(width: 24),
                        socialIconWidget(
                          child: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/6/6f/Logo_of_Twitter.svg',
                            width: 20,
                            height: 20,
                            color: const Color(0xFF1DA1F2),
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.alternate_email,
                                size: 20,
                                color: Color(0xFF1DA1F2),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle Login dengan Role-based Navigation
  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Email dan password wajib diisi", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthServices().login(email, password);

      setState(() => _isLoading = false);

      if (result["success"]) {
        final user = result["user"] as UserModel;
        
        _showSnackBar("Login berhasil! Selamat datang ${user.name}", isError: false);

        // Navigate berdasarkan role
        if (user.isHR()) {
          // Untuk HR -> ke HR Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        } else {
          // Untuk User -> ke Home Page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HRDashboard()),
          );
        }
      } else {
        _showSnackBar(result["message"], isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Error: ${e.toString()}", isError: true);
    }
  }

  // Helper untuk SnackBar
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Widget Social Icon
  Widget socialIconWidget({
    IconData? icon,
    Color? color,
    double? iconSize,
    Widget? child,
  }) {
    return InkWell(
      onTap: () {
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12, width: 1),
          color: Colors.white,
        ),
        child: child ??
            Icon(
              icon,
              color: color,
              size: iconSize ?? 24,
            ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}