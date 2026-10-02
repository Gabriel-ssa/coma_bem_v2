import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:coma_bem/database/database_helper.dart';
import 'package:coma_bem/models/administrador.dart';
import 'package:coma_bem/models/avaliacao.dart';
import 'package:coma_bem/models/cliente.dart';
import 'package:coma_bem/models/dono_restaurante.dart';
import 'package:coma_bem/models/prato.dart';
import 'package:coma_bem/models/restaurante.dart';

List<String> capturar(void Function() acao) {
  final linhas = <String>[];
  runZoned(
    acao,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, linha) => linhas.add(linha),
    ),
  );
  return linhas;
}

Future<List<String>> capturarAsync(Future<void> Function() acao) async {
  final linhas = <String>[];
  await runZoned(
    () async => await acao(),
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, linha) => linhas.add(linha),
    ),
  );
  return linhas;
}

void main() {
  group('Usuario - setter de senha e dados básicos', () {
    late Cliente cliente;

    setUp(() {
      cliente = Cliente(1, 'João', 'joao@email.com', 'senha123');
    });

    test('CT-01 aceita senha com exatamente 6 caracteres (limite)', () {
      final saida = capturar(() => cliente.senha = 'abc123');
      expect(cliente.senha, 'abc123');
      expect(saida.single, contains('Sucesso'));
    });

    test('CT-02 rejeita senha com 5 caracteres e mantém a anterior', () {
      final saida = capturar(() => cliente.senha = 'abc12');
      expect(cliente.senha, 'senha123');
      expect(saida.single, contains('Erro'));
    });

    test('CT-03 rejeita senha vazia', () {
      capturar(() => cliente.senha = '');
      expect(cliente.senha, 'senha123');
    });

    test('CT-04 altera nome e e-mail pelos setters', () {
      cliente.nomeUsuario = 'João Silva';
      cliente.email = 'novo@email.com';
      expect(cliente.nomeUsuario, 'João Silva');
      expect(cliente.email, 'novo@email.com');
      expect(cliente.idUsuario, 1);
    });
  });

  group('Avaliacao - setter de ranking', () {
    late Avaliacao avaliacao;

    setUp(() {
      avaliacao = Avaliacao(1, 4, 'Muito bom', 10, 1);
    });

    test('CT-05 aceita nota válida (3)', () {
      capturar(() => avaliacao.ranking = 3);
      expect(avaliacao.ranking, 3);
    });

    test('CT-06 limita nota acima de 5 em 5', () {
      final saida = capturar(() => avaliacao.ranking = 10);
      expect(avaliacao.ranking, 5);
      expect(saida.single, contains('máxima'));
    });

    test('CT-07 limita nota 0 e negativa em 1', () {
      final saida0 = capturar(() => avaliacao.ranking = 0);
      expect(avaliacao.ranking, 1);
      expect(saida0.single, contains('mínima'));

      capturar(() => avaliacao.ranking = -3);
      expect(avaliacao.ranking, 1);
    });

    test('CT-08 aceita os valores de fronteira 1 e 5', () {
      capturar(() => avaliacao.ranking = 1);
      expect(avaliacao.ranking, 1);
      capturar(() => avaliacao.ranking = 5);
      expect(avaliacao.ranking, 5);
    });
  });

  group('Restaurante - exibirCategoriaCulinaria', () {
    Restaurante criar(String tipo) =>
        Restaurante(1, 'Casa Teste', '-23.5', '-46.6', tipo);

    test('CT-09 reconhece japonesa, italiana e brasileira', () {
      expect(capturar(criar('Japonesa').exibirCategoriaCulinaria).single,
          contains('Asiática'));
      expect(capturar(criar('Italiana').exibirCategoriaCulinaria).single,
          contains('Massas e Pizzas'));
      expect(capturar(criar('Brasileira').exibirCategoriaCulinaria).single,
          contains('feijoada'));
    });

    test('CT-10 ignora maiúsculas/minúsculas', () {
      expect(capturar(criar('ITALIANA').exibirCategoriaCulinaria).single,
          contains('Massas e Pizzas'));
    });

    test('CT-11 tipo desconhecido cai no caso padrão', () {
      expect(capturar(criar('Árabe').exibirCategoriaCulinaria).single,
          contains('Internacional ou Diversa'));
    });
  });

  group('Polimorfismo de Usuario e entidade Prato', () {
    test('CT-12 cada perfil exibe um menu diferente', () {
      final menuCliente =
          capturar(Cliente(1, 'A', 'a@a.com', '123456').exibirMenu);
      final menuAdmin =
          capturar(Administrador(2, 'B', 'b@b.com', '123456').exibirMenu);
      final menuDono = capturar(
          DonoRestaurante(3, 'C', 'c@c.com', '123456', '12.345.678/0001-99')
              .exibirMenu);

      expect(menuCliente.first, contains('Cliente'));
      expect(menuAdmin.first, contains('Administrador'));
      expect(menuDono.first, contains('Restaurante'));
    });

    test('CT-13 DonoRestaurante exibe o CNPJ em gerenciarConta', () {
      final dono =
          DonoRestaurante(3, 'C', 'c@c.com', '123456', '12.345.678/0001-99');
      expect(capturar(dono.gerenciarConta).single,
          contains('12.345.678/0001-99'));
    });

    test('CT-14 Cliente.avaliarPrato monta a mensagem esperada', () {
      final cliente = Cliente(1, 'João', 'j@j.com', '123456');
      final saida = capturar(() => cliente.avaliarPrato('Lasanha', 5));
      expect(saida.single,
          'O cliente João avaliou o prato Lasanha com nota 5.');
    });

    test('CT-15 Prato aceita foto nula e permite alterar nome e foto', () {
      final prato = Prato(1, 'Lasanha', 7);
      expect(prato.foto, isNull);
      prato.nomePrato = 'Lasanha à bolonhesa';
      prato.foto = 'lasanha.jpg';
      expect(prato.nomePrato, 'Lasanha à bolonhesa');
      expect(prato.foto, 'lasanha.jpg');
      expect(prato.idRestaurante, 7);
    });
  });

  group('DatabaseHelper', () {
    late Directory pastaTemp;
    late DatabaseHelper banco;
    var contador = 0;

    String emailUnico() => 'teste${++contador}@comabem.com';

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      pastaTemp = await Directory.systemTemp.createTemp('coma_bem_teste_');
      await databaseFactory.setDatabasesPath(pastaTemp.path);
      banco = DatabaseHelper();
    });

    tearDownAll(() async {
      try {
        final db = await banco.bancoDeDados;
        await db.close();
        await pastaTemp.delete(recursive: true);
      } catch (_) {
      }
    });

    test('CT-16 autentica usuário com credenciais válidas', () async {
      final email = emailUnico();
      await banco.inserirDados('usuario', {
        'usu_nm_nome': 'Maria',
        'usu_tx_email': email,
        'usu_tx_senha': 'senha123',
      });

      final usuario = await banco.autenticarUsuario(email, 'senha123');

      expect(usuario, isNotNull);
      expect(usuario!['usu_nm_nome'], 'Maria');
      expect(usuario['usu_tx_email'], email);
    });

    test('CT-17 retorna nulo com senha errada ou e-mail inexistente', () async {
      final email = emailUnico();
      await banco.inserirDados('usuario', {
        'usu_nm_nome': 'Pedro',
        'usu_tx_email': email,
        'usu_tx_senha': 'senha123',
      });

      expect(await banco.autenticarUsuario(email, 'errada'), isNull);
      expect(
          await banco.autenticarUsuario('naoexiste@comabem.com', 'senha123'),
          isNull);
    });

    test('CT-18 rejeita cadastro com e-mail duplicado (UNIQUE)', () async {
      final email = emailUnico();
      final dados = {
        'usu_nm_nome': 'Ana',
        'usu_tx_email': email,
        'usu_tx_senha': 'senha123',
      };
      await banco.inserirDados('usuario', dados);

      expect(() => banco.inserirDados('usuario', dados), throwsException);
    });

    test('CT-19 inserirRestaurante e listarRestaurantesPorTipo filtram por tipo',
        () async {
      await banco.inserirRestaurante({
        'res_nm_restaurante': 'Cantina Teste',
        'res_ds_tipo_culinaria': 'TipoUnitario',
        'res_nu_latitude': '-23.5',
        'res_nu_longitude': '-46.6',
      });
      await banco.inserirRestaurante({
        'res_nm_restaurante': 'Outro Teste',
        'res_ds_tipo_culinaria': 'OutroTipo',
        'res_nu_latitude': '-23.6',
        'res_nu_longitude': '-46.7',
      });

      final lista = await banco.listarRestaurantesPorTipo('TipoUnitario');

      expect(lista.length, 1);
      expect(lista.first['res_nm_restaurante'], 'Cantina Teste');
      expect(await banco.listarRestaurantesPorTipo('NaoExiste'), isEmpty);
    });

    test('CT-20 alterarDados e deletarDados retornam o nº de linhas afetadas',
        () async {
      final id = await banco.inserirDados('usuario', {
        'usu_nm_nome': 'Carlos',
        'usu_tx_email': emailUnico(),
        'usu_tx_senha': 'senha123',
      });

      final alteradas = await banco.alterarDados(
          'usuario', {'usu_nm_nome': 'Carlos Souza'}, 'usu_id_usuario', id);
      expect(alteradas, 1);

      final todos = await banco.consultarDados('usuario');
      expect(
          todos.firstWhere((u) => u['usu_id_usuario'] == id)['usu_nm_nome'],
          'Carlos Souza');

      expect(await banco.deletarDados('usuario', 'usu_id_usuario', id), 1);
      expect(await banco.deletarDados('usuario', 'usu_id_usuario', id), 0);
    });

    test('CT-21 removerPrato e atualizarAvaliacao tratam erro sem lançar exceção',
        () async {
      final saidaPrato = await capturarAsync(() => banco.removerPrato(999));
      final saidaAvaliacao =
          await capturarAsync(() => banco.atualizarAvaliacao(999, 5, 'ok'));

      expect(saidaPrato.single, anyOf(contains('Erro'), contains('Aviso')));
      expect(saidaAvaliacao.single, anyOf(contains('Erro'), contains('Aviso')));
    });
  });
}
