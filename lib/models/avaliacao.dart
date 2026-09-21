/// Classe que une os dados do usuário e do prato avaliado.
class Avaliacao {
  // Atributos privados
  int _idAvaliacao;
  int _ranking; // Nota de 1 a 5
  String _recomendacao; // Texto da avaliação
  int _idPrato; // FK
  int _idUsuario; // FK

  // Construtor
  Avaliacao(this._idAvaliacao, this._ranking, this._recomendacao, this._idPrato, this._idUsuario);

  // Getters
  int get idAvaliacao => _idAvaliacao;
  int get ranking => _ranking;
  String get recomendacao => _recomendacao;
  int get idPrato => _idPrato;
  int get idUsuario => _idUsuario;

  // Setters
  // Setter para a nota da avaliação com controle de fluxo if/else
  set ranking(int nota) {
    if (nota >= 1 && nota <= 5) {
      _ranking = nota; // A nota é válida, então salvamos.
      print('Nota $nota salva com sucesso!');
    } else if (nota > 5) {
      _ranking = 5; // Se o usuário tentar dar nota 10, o sistema trava em 5.
      print('Aviso: A nota máxima permitida é 5.');
    } else {
      _ranking = 1; // Se tentar dar nota 0 ou negativa, o sistema trava em 1.
      print('Aviso: A nota mínima permitida é 1.');
    }
  }

  set recomendacao(String texto) => _recomendacao = texto;
}
