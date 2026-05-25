// ============================
// login_screen.dart
// ============================

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F0),
      body: Row(
        children: [
          // LEFT
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(60),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff184D2F), Color(0xff48B97B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AGRICONNECT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.eco, color: Colors.white, size: 80),
                  const SizedBox(height: 24),
                  const Text(
                    "Selamat Datang\nKembali!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 52,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Masuk ke platform AGRICONNECT untuk memantau hasil panen dan harga komoditas.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      height: 1.8,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // RIGHT
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Masuk",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            "Belum punya akun?",
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Daftar sekarang",
                              style: TextStyle(
                                color: Color(0xff2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      inputField(hint: "Email", icon: Icons.email_outlined),

                      const SizedBox(height: 20),

                      TextField(
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Lupa password?",
                            style: TextStyle(color: Color(0xff2E7D32)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1E5631),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Kembali ke Beranda"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputField({required String hint, required IconData icon}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
