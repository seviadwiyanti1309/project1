import 'package:flutter/material.dart';
import 'home_page.dart'; // ganti dengan halaman tujuanmu

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ====== PURPLE SECTION (TEXT OVERLAP WITH ILLUSTRATION) ======
              SizedBox(
                height: 420,
                child: Stack(
                  children: [
                    // ILLUSTRATION (Background - FULL WIDTH, lebih ke atas)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0),
                        child: Image.asset(
                          "assets/images/login_illustration.png",
                          fit: BoxFit.cover, // Ubah ke cover agar mengisi penuh
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            // Placeholder jika gambar tidak ditemukan
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
                    
                    // TEXT WELCOME (Foreground - di atas gambar)
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

              // ====== WHITE CARD FORM ======
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
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

                    // Social Icons (menggunakan Icon bawaan Flutter)
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

  // Widget Social Icon dengan Icon bawaan
  Widget socialIconWidget({
    IconData? icon,
    Color? color,
    double? iconSize,
    Widget? child,
  }) {
    return InkWell(
      onTap: () {
        // Aksi ketika icon diklik
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
}