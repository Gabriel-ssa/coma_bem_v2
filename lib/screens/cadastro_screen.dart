// lib/screens/cadastro_screen.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _culinariaController = TextEditingController();

  
  Uint8List? _fotoBytes;

  
  double _avaliacao = 0;

  String _latitude = '';
  String _longitude = '';

  final ImagePicker _picker = ImagePicker();

  
  static const Color darkGreen = Color(0xFF244C35);
  static const Color mainGreen = Color(0xFF4F8061);
  static const Color lightGreen = Color(0xFFE8EEE9);
  static const Color orange = Color(0xFFD46A42);
  static const Color background = Color(0xFFFAFBF8);
  static const Color textPrimary = Color(0xFF202A22);
  static const Color textSecondary = Color(0xFF7C857F);
  static const Color border = Color(0xFFD9E0DA);

  @override
  void dispose() {
    _nomeController.dispose();
    _culinariaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarFoto(ImageSource origem) async {
    final XFile? foto = await _picker.pickImage(
      source: origem,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (foto == null) return;

    final bytes = await foto.readAsBytes();
    if (!mounted) return;

    setState(() {
      _fotoBytes = bytes;
    });
  }

  Future<void> _tirarFoto() => _selecionarFoto(ImageSource.camera);

  Future<void> _escolherDaGaleria() => _selecionarFoto(ImageSource.gallery);

  void _salvarCadastro() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe o nome do restaurante'),
        ),
      );
      return;
    }

    Map<String, dynamic> dadosRestaurante = {
      'res_nm_restaurante': _nomeController.text.trim(),
      'res_ds_tipo_culinaria': _culinariaController.text.trim(),
      'res_nu_latitude': _latitude,
      'res_nu_longitude': _longitude,
      'res_im_foto': _fotoBytes,
      'res_nu_avaliacao': _avaliacao,
    };

    try {
      final id = await DatabaseHelper().inserirDados(
        'restaurante',
        dadosRestaurante,
      );
      debugPrint('INSERIDO: id=$id nome=${_nomeController.text.trim()}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurante cadastrado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e, s) {
      debugPrint('ERRO AO SALVAR: $e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
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

  Widget _photoButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: SizedBox(
        height: 42,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18, color: darkGreen),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkGreen,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: darkGreen, width: 1),
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );
  }


  Widget _estrelas() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final posicao = i + 1;
        IconData icone;
        if (_avaliacao >= posicao) {
          icone = Icons.star_rounded;
        } else if (_avaliacao >= posicao - 0.5) {
          icone = Icons.star_half_rounded;
        } else {
          icone = Icons.star_border_rounded;
        }
        return Icon(icone, size: 26, color: orange);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: darkGreen),
        title: const Text(
          'Novo Cadastro',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkGreen,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              TextField(
                controller: _nomeController,
                style: const TextStyle(fontSize: 13, color: textPrimary),
                decoration: _fieldDecoration(
                  hint: 'Nome do restaurante',
                  icon: Icons.storefront_outlined,
                ),
              ),
              const SizedBox(height: 12),

              
              TextField(
                controller: _culinariaController,
                style: const TextStyle(fontSize: 13, color: textPrimary),
                decoration: _fieldDecoration(
                  hint: 'Tipo de culinária (ex: Italiana, Japonesa)',
                  icon: Icons.restaurant_menu_rounded,
                ),
              ),
              const SizedBox(height: 22),

              
              const Text(
                'Avaliação',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _estrelas(),
                        Text(
                          _avaliacao.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: darkGreen,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: orange,
                        inactiveTrackColor: border,
                        thumbColor: orange,
                        overlayColor: orange.withOpacity(0.15),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _avaliacao,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        onChanged: (valor) {
                          setState(() {
                            _avaliacao = valor;
                          });
                        },
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        Text(
                          '5',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const Text(
                'Foto do prato',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 10),

              
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _fotoBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          _fotoBytes!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 32,
                            color: mainGreen,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Nenhuma foto selecionada',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),

              
              Row(
                children: [
                  _photoButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Tirar foto',
                    onPressed: _tirarFoto,
                  ),
                  const SizedBox(width: 10),
                  _photoButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Galeria',
                    onPressed: _escolherDaGaleria,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _salvarCadastro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Salvar cadastro',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}