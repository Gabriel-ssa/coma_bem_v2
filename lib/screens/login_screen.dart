// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'cadastro_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Paleta
  static const Color darkGreen = Color(0xFF244C35);
  static const Color lightGreen = Color(0xFFE8EEE9);
  static const Color orange = Color(0xFFD46A42);
  static const Color background = Color(0xFFFAFBF8);
  static const Color textSecondary = Color(0xFF7C857F);
  static const Color border = Color(0xFFD9E0DA);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
  }) {
    OutlineInputBorder outline(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA5ADA7)),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF4A5A4F)),
      prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 20),
      filled: true,
      fillColor: lightGreen,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: outline(border),
      enabledBorder: outline(border),
      focusedBorder: outline(darkGreen, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final logoSize = (width * 0.40).clamp(130.0, 150.0);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.07),

                      // Logo
                      Center(
                        child: Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.restaurant,
                              size: 80,
                              color: darkGreen,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.05),

                      // Título
                      const Text(
                        'Acesse sua conta',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // E-mail
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 13),
                        decoration: _fieldDecoration(
                          hint: 'E-mail',
                          icon: Icons.mail_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Senha
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 13),
                        decoration: _fieldDecoration(
                          hint: 'Senha',
                          icon: Icons.lock_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botão Entrar
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: orange.withOpacity(0.3),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Esqueci minha senha
                      const Center(
                        child: Text(
                          'Esqueci minha senha?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: darkGreen,
                            decoration: TextDecoration.underline,
                            decorationColor: darkGreen,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Criar conta
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Ainda não tem conta? ',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CadastroScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Criar conta',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: darkGreen,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: darkGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}