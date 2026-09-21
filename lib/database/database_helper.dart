import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Classe responsável por gerenciar a conexão com o banco de dados SQLite
/// e realizar as transações de autenticação, inserção, consulta, alteração e deleção.
class DatabaseHelper {
  static final DatabaseHelper _instancia = DatabaseHelper._interno();
  static Database? _bancoDeDados;

  factory DatabaseHelper() => _instancia;

  DatabaseHelper._interno();

  /// Inicia a conexão com o banco de dados.
  Future<Database> get bancoDeDados async {
    if (_bancoDeDados != null) return _bancoDeDados!;
    _bancoDeDados = await _iniciarBanco();
    return _bancoDeDados!;
  }

  /// Configura o caminho do banco no dispositivo e cria as tabelas se for a primeira execução.
  Future<Database> _iniciarBanco() async {
    String caminhoBanco = await getDatabasesPath();
    String caminhoCompleto = join(caminhoBanco, 'coma_bem.db');
    return await openDatabase(
      caminhoCompleto,
      version: 1,
      onCreate: _criarTabelas,
      // Garante que a tabela e as colunas existam, mesmo em bancos antigos
      onOpen: (db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS restaurante (
            res_id_restaurante INTEGER PRIMARY KEY AUTOINCREMENT,
            res_nm_restaurante TEXT NOT NULL,
            res_ds_tipo_culinaria TEXT,
            res_nu_latitude TEXT,
            res_nu_longitude TEXT,
            res_im_foto BLOB,
            res_nu_avaliacao REAL DEFAULT 0
          )
        ''');

        // Adiciona colunas novas em bancos criados antes delas
        final colunas = await db.rawQuery('PRAGMA table_info(restaurante)');
        final nomes = colunas.map((c) => c['name']).toList();

        if (!nomes.contains('res_im_foto')) {
          await db.execute('ALTER TABLE restaurante ADD COLUMN res_im_foto BLOB');
        }
        if (!nomes.contains('res_nu_avaliacao')) {
          await db.execute(
            'ALTER TABLE restaurante ADD COLUMN res_nu_avaliacao REAL DEFAULT 0',
          );
        }
      },
    );
  }

  /// Cria a estrutura inicial do banco de dados (Tabelas).
  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE usuario (
        usu_id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        usu_tx_email TEXT NOT NULL UNIQUE,
        usu_tx_senha TEXT NOT NULL
      )
    ''');
    // A tabela restaurante é criada no onOpen (acima).
    // As demais tabelas (prato, avaliacao) da Atividade 4 devem ser inseridas aqui.
  }

  // ============================================================================
  // TRANSAÇÕES DE MANIPULAÇÃO DE DADOS (CRUD) E AUTENTICAÇÃO
  // ============================================================================

  /// Realiza a AUTENTICAÇÃO do usuário.
  /// Retorna os dados do usuário em caso de sucesso, ou nulo se as credenciais forem inválidas.
  Future<Map<String, dynamic>?> autenticarUsuario(
    String email,
    String senha,
  ) async {
    Database db = await bancoDeDados;
    List<Map<String, dynamic>> resultado = await db.query(
      'usuario',
      where: 'usu_tx_email = ? AND usu_tx_senha = ?',
      whereArgs: [email, senha],
    );
    if (resultado.isNotEmpty) return resultado.first;
    return null;
  }

  /// Realiza a INSERÇÃO (Create) de um novo registro.
  /// Retorna o ID numérico gerado para o novo registro.
  Future<int> inserirDados(String tabela, Map<String, dynamic> dados) async {
    Database db = await bancoDeDados;
    return await db.insert(tabela, dados);
  }

  /// Realiza a CONSULTA (Read) de registros.
  /// Retorna uma lista com todos os dados cadastrados na tabela solicitada.
  Future<List<Map<String, dynamic>>> consultarDados(String tabela) async {
    Database db = await bancoDeDados;
    return await db.query(tabela);
  }

  /// Realiza a ALTERAÇÃO (Update) de um registro existente.
  /// Retorna o número de linhas que foram modificadas no banco.
  Future<int> alterarDados(
    String tabela,
    Map<String, dynamic> novosDados,
    String colunaId,
    int id,
  ) async {
    Database db = await bancoDeDados;
    return await db.update(
      tabela,
      novosDados,
      where: '$colunaId = ?',
      whereArgs: [id],
    );
  }

  /// Realiza a DELEÇÃO (Delete) de um registro.
  /// Retorna o número de linhas excluídas.
  Future<int> deletarDados(String tabela, String colunaId, int id) async {
    Database db = await bancoDeDados;
    return await db.delete(tabela, where: '$colunaId = ?', whereArgs: [id]);
  }

  /// Insere um novo restaurante no banco de dados.
  Future<void> inserirRestaurante(Map<String, dynamic> dadosRestaurante) async {
    try {
      Database db = await bancoDeDados;
      int idGerado = await db.insert('restaurante', dadosRestaurante);
      print('Sucesso: Restaurante cadastrado com o ID $idGerado.');
    } catch (erro) {
      print('Erro ao tentar cadastrar o restaurante: $erro');
    }
  }

  /// Retorna uma lista de restaurantes filtrada pelo tipo de culinária (ex: 'Italiana').
  Future<List<Map<String, dynamic>>> listarRestaurantesPorTipo(
    String tipo,
  ) async {
    try {
      Database db = await bancoDeDados;
      List<Map<String, dynamic>> lista = await db.query(
        'restaurante',
        where: 'res_ds_tipo_culinaria = ?',
        whereArgs: [tipo],
      );
      print('Sucesso: Foram encontrados ${lista.length} restaurantes.');
      return lista;
    } catch (erro) {
      print('Erro ao buscar restaurantes do tipo $tipo: $erro');
      return [];
    }
  }

  /// Atualiza o ranking (nota) e o texto de recomendação de uma avaliação existente.
  Future<void> atualizarAvaliacao(
    int idAvaliacao,
    int novaNota,
    String novoTexto,
  ) async {
    try {
      Database db = await bancoDeDados;

      int linhasAfetadas = await db.update(
        'avaliacao',
        {'avl_nu_ranking': novaNota, 'avl_tx_recomendacao': novoTexto},
        where: 'avl_id_avaliacao = ?',
        whereArgs: [idAvaliacao],
      );

      if (linhasAfetadas > 0) {
        print('Sucesso: Avaliação atualizada.');
      } else {
        print('Aviso: Nenhuma avaliação encontrada com o ID $idAvaliacao.');
      }
    } catch (erro) {
      print('Erro ao atualizar a avaliação: $erro');
    }
  }

  /// Exclui permanentemente um prato do cardápio utilizando seu ID.
  Future<void> removerPrato(int idPrato) async {
    try {
      Database db = await bancoDeDados;

      int linhasAfetadas = await db.delete(
        'prato',
        where: 'pra_id_prato = ?',
        whereArgs: [idPrato],
      );

      if (linhasAfetadas > 0) {
        print('Sucesso: Prato deletado do cardápio.');
      } else {
        print('Aviso: Nenhum prato encontrado com o ID $idPrato.');
      }
    } catch (erro) {
      print('Erro ao tentar remover o prato: $erro');
    }
  }
}