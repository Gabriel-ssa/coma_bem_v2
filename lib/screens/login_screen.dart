// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'cadastro_perfil_screen.dart';
import 'home_screen.dart';
import '../database/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _entrando = false;

  // Paleta
  static const Color darkGreen = Color(0xFF244C35);
  static const Color lightGreen = Color(0xFFE8EEE9);
  static const Color orange = Color(0xFFD46A42);
  static const Color background = Color(0xFFFAFBF8);
  static const Color textSecondary = Color(0xFF7C857F);
  static const Color border = Color(0xFFD9E0DA);

  // ==========================================================================
  // CONTA FIXA
  // Funciona mesmo sem estar cadastrada no banco. Para adicionar outra,
  // copie um bloco e mude o e-mail e a senha.
  // ==========================================================================
  static const List<Map<String, String>> _contasFixas = [
    {'email': 'admin@comabem.com', 'senha': '1234'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  bool _validarContaFixa(String email, String senha) {
    return _contasFixas.any(
      (c) => c['email'] == email.toLowerCase() && c['senha'] == senha,
    );
  }

  void _entrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o e-mail e a senha')),
      );
      return;
    }

    setState(() => _entrando = true);

    try {
      
      if (_validarContaFixa(email.toLowerCase(), senha)) {
        _irParaHome();
        return;
      }

      
      final usuario = await DatabaseHelper().autenticarUsuario(email, senha);
      if (usuario != null) {
        _irParaHome();
        return;
      }

      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha incorretos')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  void _irParaHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
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
      suffixIcon: suffixIcon,
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
    final logoSize = (width * 0.32).clamp(110.0, 140.0);

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
                            'assets/images/logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.restaurant,
                              size: 100,
                              color: darkGreen,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.05),

                      
                      const Text(
                        'Acesse sua conta',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 20),

                      
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

                      
                      TextField(
                        controller: _senhaController,
                        obscureText: !_senhaVisivel,
                        style: const TextStyle(fontSize: 13),
                        decoration: _fieldDecoration(
                          hint: 'Senha',
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => _senhaVisivel = !_senhaVisivel);
                            },
                            icon: Icon(
                              _senhaVisivel
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: const Color(0xFF4A5A4F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _entrando ? null : _entrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: orange.withOpacity(0.3),
                            shape: const StadiumBorder(),
                          ),
                          child: _entrando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
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
                                    builder: (context) =>
                                        const CadastroPerfilScreen(),
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