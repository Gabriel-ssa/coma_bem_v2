/// Classe que representa a tabela de Usuários do banco de dados.
abstract class Usuario {
  // Atributos privados (encapsulamento utilizando o prefixo _)
  int _idUsuario;
  String _nomeUsuario;
  String _email;
  String _senha;

  // Construtor nomeado para inicializar os objetos
  Usuario(this._idUsuario, this._nomeUsuario, this._email, this._senha);

  // Getters: permitem ler os dados protegidos
  int get idUsuario => _idUsuario;
  String get nomeUsuario => _nomeUsuario;
  String get email => _email;
  String get senha => _senha;

  // Setters: permitem alterar os dados protegidos de forma controlada
  set nomeUsuario(String nome) {
    _nomeUsuario = nome;
  }

  set email(String email) {
    _email = email;
  }

  // O acesso à senha deve ser rigoroso. O setter permite alteração, 
  // mas em um app real aqui entraria a lógica de criptografia.
  // Setter para a senha com controle de fluxo if/else
  set senha(String novaSenha) {
    // Verifica se a nova senha possui 6 ou mais caracteres
    if (novaSenha.length >= 6) {
      _senha = novaSenha; // Atualiza o atributo privado
      print('Sucesso: Senha cadastrada/atualizada.');
    } else {
      // Bloqueia a alteração e exibe a mensagem de erro
      print('Erro: A senha deve ter 6 ou mais caracteres. Operação cancelada.');
    }
  }

  // ==================================================================
  // MÉTODOS ABSTRATOS (Polimorfismo)
  // Cada "filho" desta classe será obrigado a implementar esses 
  // métodos do seu próprio jeito.
  // ==================================================================
  void exibirMenu();
  void gerenciarConta();
}
