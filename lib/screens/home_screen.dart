// lib/screens/home_screen.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'cadastro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _todosRestaurantes = [];
  List<Map<String, dynamic>> _restaurantesFiltrados = [];
  final TextEditingController _searchController = TextEditingController();

  // Paleta
  static const Color darkGreen = Color(0xFF244C35);
  static const Color mainGreen = Color(0xFF4F8061);
  static const Color lightGreen = Color(0xFFE8EEE9);
  static const Color orange = Color(0xFFD46A42);
  static const Color background = Color(0xFFFAFBF8);
  static const Color textPrimary = Color(0xFF202A22);
  static const Color textSecondary = Color(0xFF7C857F);
  static const Color border = Color(0xFFD9E0DA);
  static const Color brown = Color(0xFF8C6E50);

  // ==========================================================================
  // CAMINHOS DAS IMAGENS
  // Se as suas fotos estiverem em outra pasta, ajuste só estas duas linhas.
  // ==========================================================================
  static const String _fotoJapones = 'assets/images/restaurante_japones.jpg';
  static const String _fotoItaliano = 'assets/images/restaurante_italiano.jpg';
  static const String _fotoArabe = 'assets/images/restaurante_arabe.jpg';
  static const String _fotoCapitaes = 'assets/images/restaurante_capitaes.jpg';
  static const String _fotoNice = 'assets/images/restaurante_nice.jpg';
  static const String _fotoLucca = 'assets/images/restaurante_lucca.jpg';
  static const String _fotoNaus = 'assets/images/restaurante_naus.jpg';

  // ==========================================================================
  // RESTAURANTES FIXOS
  // Para adicionar, remover ou editar um restaurante fixo, mexa só nesta lista.
  // O nome de cada um precisa ser único (ele identifica o fixo ao excluir).
  // ==========================================================================
  static const List<Map<String, dynamic>> _restaurantesFixos = [
    {
      'res_nm_restaurante': 'Katsuya',
      'res_ds_tipo_culinaria': 'Japonesa',
      'nota': '4.5',
      'foto_asset': _fotoJapones,
    },
    {
      'res_nm_restaurante': 'Spoleto',
      'res_ds_tipo_culinaria': 'Italiana',
      'nota': '4.5',
      'foto_asset': _fotoItaliano,
    },
    {
      'res_nm_restaurante': 'Habibs',
      'res_ds_tipo_culinaria': 'Árabe',
      'nota': '4.0',
      'foto_asset': _fotoArabe,
    },
    {
      'res_nm_restaurante': 'Capitães Gastronomia',
      'res_ds_tipo_culinaria': 'Brasileira',
      'nota': '4.5',
      'foto_asset': _fotoCapitaes,
    },
    {
      'res_nm_restaurante': 'Dona Nice Steakhouse',
      'res_ds_tipo_culinaria': 'Brasileira',
      'nota': '5.0 ',
      'foto_asset': _fotoNice,
    },
    {
      'res_nm_restaurante': 'Cantina Di Lucca',
      'res_ds_tipo_culinaria': 'Italiana',
      'nota': '4.0',
      'foto_asset': _fotoLucca,
    },
    {
      'res_nm_restaurante': 'Naus Restaurante',
      'res_ds_tipo_culinaria': 'Brasileira',
      'nota': '4.5',
      'foto_asset': _fotoNaus,
    },
  ];

  @override
  void initState() {
    super.initState();
    _carregarRestaurantes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // CONTROLE DOS FIXOS EXCLUÍDOS (guardado no banco)
  // ==========================================================================
  Future<Set<String>> _fixosExcluidos() async {
    final db = await DatabaseHelper().bancoDeDados;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS fixo_excluido '
      '(fix_nm_restaurante TEXT PRIMARY KEY)',
    );
    final linhas = await db.query('fixo_excluido');
    return linhas.map((l) => l['fix_nm_restaurante'].toString()).toSet();
  }

  Future<void> _registrarFixoExcluido(String nome) async {
    final db = await DatabaseHelper().bancoDeDados;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS fixo_excluido '
      '(fix_nm_restaurante TEXT PRIMARY KEY)',
    );
    await db.rawInsert(
      'INSERT OR REPLACE INTO fixo_excluido (fix_nm_restaurante) VALUES (?)',
      [nome],
    );
  }

  // Junta os fixos (que não foram excluídos) com os cadastrados no banco
  void _carregarRestaurantes() async {
    try {
      final excluidos = await _fixosExcluidos();
      final fixos = _restaurantesFixos
          .where((r) => !excluidos.contains(r['res_nm_restaurante']))
          .toList();

      var dados = await DatabaseHelper().consultarDados('restaurante');
      debugPrint('CARREGADOS: ${dados.length} restaurantes do banco');

      if (!mounted) return;
      setState(() {
        _todosRestaurantes = [...fixos, ...dados];
        _restaurantesFiltrados = _todosRestaurantes;
      });
    } catch (e, s) {
      debugPrint('ERRO AO CARREGAR: $e\n$s');
      if (!mounted) return;
      // Mesmo com erro no banco, os fixos continuam aparecendo
      setState(() {
        _todosRestaurantes = [..._restaurantesFixos];
        _restaurantesFiltrados = _todosRestaurantes;
      });
    }
  }

  // Abre a tela de cadastro e recarrega a lista ao voltar
  Future<void> _abrirCadastro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroScreen()),
    );
    _carregarRestaurantes();
  }

  void _filtrarRestaurantes(String texto) {
    setState(() {
      if (texto.isEmpty) {
        _restaurantesFiltrados = _todosRestaurantes;
      } else {
        _restaurantesFiltrados = _todosRestaurantes.where((restaurante) {
          final nome = (restaurante['res_nm_restaurante'] ?? '')
              .toString()
              .toLowerCase();
          final culinaria = (restaurante['res_ds_tipo_culinaria'] ?? '')
              .toString()
              .toLowerCase();
          final busca = texto.toLowerCase();

          return nome.contains(busca) || culinaria.contains(busca);
        }).toList();
      }
    });
  }

  // Exclui qualquer restaurante: os cadastrados (têm id) saem do banco;
  // os fixos (sem id) são registrados como excluídos.
  Future<void> _confirmarExclusao(Map<String, dynamic> item) async {
    final nome = (item['res_nm_restaurante'] ?? '').toString();
    final int? id = item['res_id_restaurante'] as int?;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Excluir restaurante',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: darkGreen,
          ),
        ),
        content: Text(
          'Deseja excluir "$nome"? Essa ação não pode ser desfeita.',
          style: const TextStyle(fontSize: 13, color: textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: orange, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      if (id != null) {
        await DatabaseHelper().deletarDados(
          'restaurante',
          'res_id_restaurante',
          id,
        );
      } else {
        await _registrarFixoExcluido(nome);
      }

      if (!mounted) return;
      setState(() {
        _todosRestaurantes = _todosRestaurantes
            .where((r) => !identical(r, item))
            .toList();
        _restaurantesFiltrados = _restaurantesFiltrados
            .where((r) => !identical(r, item))
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurante excluído.')),
      );
    } catch (e, s) {
      debugPrint('ERRO AO EXCLUIR: $e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  // Imagem padrão (usada quando o restaurante não tem foto cadastrada)
  String _obterCaminhoFoto(String culinaria) {
    final tipo = culinaria.toLowerCase();
    if (tipo.contains('japones') || tipo.contains('japonês')) {
      return _fotoJapones;
    }
    return _fotoItaliano;
  }

  // Nota exibida no card: fixos usam o campo 'nota' (texto);
  // cadastrados usam a avaliação salva no banco (0 a 5).
  String _obterNota(Map<String, dynamic> item) {
    if (item['nota'] != null) return item['nota'].toString();
    final valor = (item['res_nu_avaliacao'] as num?)?.toDouble() ?? 0;
    return valor.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 14),

            // Campo de busca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _searchController,
                  onChanged: _filtrarRestaurantes,
                  style: const TextStyle(fontSize: 12, color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar restaurantes...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA39D),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: Color(0xFF4A5A4F),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 20,
                    ),
                    filled: true,
                    fillColor: lightGreen,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            const _Categories(),
            const SizedBox(height: 14),

            // Grade de restaurantes
            Expanded(
              child: _restaurantesFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum restaurante encontrado.',
                        style: TextStyle(color: textSecondary, fontSize: 14),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: _restaurantesFiltrados.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 145,
                        ),
                        itemBuilder: (context, index) {
                          final item = _restaurantesFiltrados[index];
                          final culinaria =
                              (item['res_ds_tipo_culinaria'] ?? '').toString();
                          final nome =
                              (item['res_nm_restaurante'] ?? '').toString();
                          final String? fotoAsset =
                              item['foto_asset'] as String?;

                          return _RestaurantCard(
                            name: nome,
                            category: culinaria,
                            rating: _obterNota(item),
                            imagePath:
                                fotoAsset ?? _obterCaminhoFoto(culinaria),
                            fotoBytes: item['res_im_foto'] as Uint8List?,
                            onDelete: () => _confirmarExclusao(item),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),

      // Botão flutuante (abre o cadastro)
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: SizedBox(
          width: 44,
          height: 44,
          child: FloatingActionButton(
            onPressed: _abrirCadastro,
            backgroundColor: darkGreen,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),

      // Barra inferior ("Adicionar" abre o cadastro)
      bottomNavigationBar: _BottomBar(onAdd: _abrirCadastro),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, Seja bem-vindo!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _HomeScreenState.darkGreen,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: _HomeScreenState.orange,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Definir Localização',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: _HomeScreenState.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _HomeScreenState.lightGreen,
              shape: BoxShape.circle,
              border: Border.all(color: _HomeScreenState.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 17,
              color: _HomeScreenState.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories();

  static const List<_CategoryChip> _items = [
    _CategoryChip('Italiana', _HomeScreenState.darkGreen),
    _CategoryChip('Japonesa', _HomeScreenState.orange),
    _CategoryChip('Brasileira', _HomeScreenState.mainGreen),
    _CategoryChip('Lanches', _HomeScreenState.brown),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final c = _items[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.color,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              c.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final String name;
  final String category;
  final String rating;
  final String imagePath;
  final Uint8List? fotoBytes;
  final VoidCallback? onDelete;

  const _RestaurantCard({
    required this.name,
    required this.category,
    required this.rating,
    required this.imagePath,
    this.fotoBytes,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _HomeScreenState.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: fotoBytes != null
                    ? Image.memory(
                        fotoBytes!,
                        height: 85,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imagePath,
                        height: 85,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('ERRO FOTO: $imagePath -> $error');
                          return Container(
                            height: 85,
                            width: double.infinity,
                            color: const Color(0xFFE2B98A),
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              imagePath,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (onDelete != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: _HomeScreenState.orange,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _HomeScreenState.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: _HomeScreenState.textSecondary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: _HomeScreenState.orange,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: _HomeScreenState.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback? onAdd;

  const _BottomBar({this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _HomeScreenState.mainGreen,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              const _NavItem(
                icon: Icons.home_outlined,
                label: 'Início',
                selected: true,
              ),
              _NavItem(
                icon: Icons.add_circle_outline_rounded,
                label: 'Adicionar',
                onTap: onAdd,
              ),
              const _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white.withOpacity(0.5);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip {
  final String label;
  final Color color;

  const _CategoryChip(this.label, this.color);
}