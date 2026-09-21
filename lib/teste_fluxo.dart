import 'models/restaurante.dart';

void main() {
  // Criando uma lista (Array) simulando os dados vindos do banco
  List<Restaurante> listaDeRestaurantes = [
    Restaurante(1, 'Sushi House', '-23.5', '-46.6', 'Japonesa'),
    Restaurante(2, 'Cantina Bella', '-23.6', '-46.7', 'Italiana'),
    Restaurante(3, 'Boi Bom', '-23.7', '-46.8', 'Brasileira'),
  ];

  print('--- CATÁLOGO DE RESTAURANTES ---');

  // Controle de Fluxo: Laço de repetição for-in
  // "Para cada restaurante (res) dentro da listaDeRestaurantes, faça:"
  for (Restaurante res in listaDeRestaurantes) {
    print('Nome: ${res.nomeRestaurante} | Tipo: ${res.tipoCulinaria}');
    
    // Chamando o método com Switch que criamos no Passo 2!
    res.exibirCategoriaCulinaria(); 
    print('--------------------------------');
  }
}