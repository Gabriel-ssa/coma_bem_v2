/// Classe que representa a tabela de Pratos, contendo a referência ao Restaurante.
class Prato {
  // Atributos privados
  int _idPrato;
  String _nomePrato;
  String? _foto; // A interrogação significa que este campo pode ser nulo (NULL)
  int _idRestaurante; // Representa a Chave Estrangeira (FK)

  // Construtor
  Prato(this._idPrato, this._nomePrato, this._idRestaurante, [this._foto]);

  // Getters
  int get idPrato => _idPrato;
  String get nomePrato => _nomePrato;
  String? get foto => _foto;
  int get idRestaurante => _idRestaurante;

  // Setters
  set nomePrato(String nome) => _nomePrato = nome;
  set foto(String? foto) => _foto = foto;
  // idRestaurante normalmente não tem setter público pois o prato não muda de dono.
}
