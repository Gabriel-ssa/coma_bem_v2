import 'dart:io';
// Importe as classes que você criou na Atividade 8
import 'models/usuario.dart';
import 'models/cliente.dart';
import 'models/administrador.dart';

void main() {
  // Lista genérica que aceitará qualquer tipo de usuário graças à Herança!
  List<Usuario> usuariosCadastrados = [];
  bool sistemaRodando = true;

  print('=== BEM-VINDO AO SIMULADOR DE OBJETOS COMA BEM ===');

  // Controle de Fluxo: Laço de repetição contínuo
  while (sistemaRodando) {
    print('\nSelecione uma ação:');
    print('1 - Cadastrar novo Cliente');
    print('2 - Cadastrar novo Administrador');
    print('3 - Listar perfis e exibir Menus (Testar Polimorfismo)');
    print('4 - Sair do Sistema');
    stdout.write('Sua opção: ');
    
    // Lê o que o usuário digitou no terminal
    String? opcao = stdin.readLineSync();

    // Controle de Fluxo: Múltiplas escolhas
    switch (opcao) {
      case '1':
        print('\n--- CADASTRO DE CLIENTE ---');
        stdout.write('Digite o nome do cliente: ');
        String? nome = stdin.readLineSync();
        
        // ====================================================================
        // DESAFIO 1: PROGRAME O CADASTRO DE CLIENTE
        // 1. Crie um objeto do tipo Cliente passando o 'nome' digitado.
        //    (Para o ID, Email e Senha, você pode inventar valores fictícios).
        // 2. Adicione este objeto dentro da lista 'usuariosCadastrados'.
        // 3. Imprima uma mensagem de sucesso.
        // ====================================================================
        
        print('Ops, a lógica do Desafio 1 ainda não foi feita!');
        break;

      case '2':
        print('\n--- CADASTRO DE ADMINISTRADOR ---');
        stdout.write('Digite o nome do administrador: ');
        String? nomeAdmin = stdin.readLineSync();
        
        // ====================================================================
        // DESAFIO 2: PROGRAME O CADASTRO DE ADMINISTRADOR
        // 1. Crie um objeto do tipo Administrador passando o 'nomeAdmin'.
        // 2. Adicione este objeto dentro da lista 'usuariosCadastrados'.
        // 3. Imprima uma mensagem de sucesso.
        // ====================================================================
        
        print('Ops, a lógica do Desafio 2 ainda não foi feita!');
        break;

      case '3':
        print('\n--- LISTAGEM DE USUÁRIOS ---');
        
        // ====================================================================
        // DESAFIO 3: PROGRAME A LISTAGEM (POLIMORFISMO)
        // 1. Verifique se a lista 'usuariosCadastrados' está vazia. Se estiver, 
        //    imprima "Nenhum usuário cadastrado".
        // 2. Caso tenha usuários, faça um laço de repetição (for) percorrendo a lista.
        // 3. Imprima o nome do usuário.
        // 4. Chame o método exibirMenu() para provar que o Polimorfismo funciona!
        // ====================================================================
        
        print('Ops, a lógica do Desafio 3 ainda não foi feita!');
        break;

      case '4':
        sistemaRodando = false;
        print('\nEncerrando o simulador... Até logo!');
        break;

      default:
        print('\nOpção inválida! Digite um número de 1 a 4.');
    }
  }
}