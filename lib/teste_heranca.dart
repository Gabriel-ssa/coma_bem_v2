import 'models/cliente.dart';
import 'models/administrador.dart';
import 'models/dono_restaurante.dart';
import 'models/usuario.dart'; // Importando a classe base

void main() {
  // Criando diferentes tipos de usuários
  Cliente cliente = Cliente(1, 'João', 'joao@email.com', '123456');
  Administrador admin = Administrador(2, 'Chefia', 'admin@comabem.com', 'admin123');
  DonoRestaurante dono = DonoRestaurante(3, 'Sra. Bella', 'bella@cantina.com', 'senha789', '12.345.678/0001-99');

  // Criando uma lista genérica de 'Usuarios'. 
  // Como todos herdam de Usuario, a lista aceita todos eles!
  List<Usuario> listaDeUsuarios = [cliente, admin, dono];

  for (Usuario user in listaDeUsuarios) {
    print('\nLogado como: ${user.nomeUsuario}');
    
    // Polimorfismo: O Dart sabe qual menu exibir para cada um!
    user.exibirMenu(); 
    user.gerenciarConta();
  }

  // Especialização: Testando o método que só o Cliente tem
  print('\n--- Ação Específica ---');
  cliente.avaliarPrato('Lasanha', 5);
  
  // Se tentarmos admin.avaliarPrato(), o sistema dará erro, 
  // pois o administrador não tem esse comportamento mapeado!
}
