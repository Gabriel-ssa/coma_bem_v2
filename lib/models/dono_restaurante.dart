import 'usuario.dart';

class DonoRestaurante extends Usuario {
  String cnpj; // Atributo exclusivo do dono

  DonoRestaurante(int id, String nome, String email, String senha, this.cnpj) 
      : super(id, nome, email, senha);

  // Polimorfismo: Comportamento exclusivo do Dono do Restaurante
  @override
  void exibirMenu() {
    print('--- Menu do Restaurante ---');
    print('1. Cadastrar novo prato');
    print('2. Ver avaliações recebidas');
  }

  @override
  void gerenciarConta() {
    print('Gerenciando dados bancários da empresa CNPJ: $cnpj.');
  }
}
