// lib/screens/cadastro_perfil_screen.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'login_screen.dart';

class CadastroPerfilScreen extends StatefulWidget {
  const CadastroPerfilScreen({super.key});

  @override
  State<CadastroPerfilScreen> createState() => _CadastroPerfilScreenState();
}

class _CadastroPerfilScreenState extends State<CadastroPerfilScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _salvando = false;

  // Paleta
  static const Color darkGreen = Color(0xFF244C35);
  static const Color lightGreen = Color(0xFFE8EEE9);
  static const Color orange = Color(0xFFD46A42);
  static const Color background = Color(0xFFFAFBF8);
  static const Color textSecondary = Color(0xFF7C857F);
  static const Color border = Color(0xFFD9E0DA);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  bool _emailValido(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$').hasMatch(email);
  }

  void _criarConta() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu nome')),
      );
      return;
    }
    if (!_emailValido(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um e-mail válido')),
      );
      return;
    }
    if (senha.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha precisa ter pelo menos 4 caracteres'),
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      await DatabaseHelper().inserirDados('usuario', {
        'usu_nm_nome': nome,
        'usu_tx_email': email,
        'usu_tx_senha': senha,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // E-mail duplicado (UNIQUE) cai aqui
      final mensagem = e.toString().contains('UNIQUE')
          ? 'Esse e-mail já está cadastrado'
          : 'Erro ao criar conta: $e';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
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
                      SizedBox(height: constraints.maxHeight * 0.06),

                      // Botão voltar
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: darkGreen),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 8),

                      // Título
                      const Text(
                        'Criar conta',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Preencha seus dados para começar',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      const SizedBox(height: 24),

                      // Nome
                      TextField(
                        controller: _nomeController,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 13),
                        decoration: _fieldDecoration(
                          hint: 'Nome completo',
                          icon: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 12),

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
                      const SizedBox(height: 24),

                      // Botão criar conta
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _salvando ? null : _criarConta,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: _salvando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const Spacer(),

                      // Já tem conta
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Já tem uma conta? ',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Entrar',
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