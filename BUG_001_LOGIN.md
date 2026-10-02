Relatório de Bug: Falha no Fluxo de Login
ID do Bug: #001
Severidade: ALTA (Impede o acesso ao aplicativo)
Funcionalidade: Tela de Login (login_screen.dart)
1. Descrição do Problema
Durante a execução dos testes de regressão, o robô de testes de integração
não conseguiu concluir o login no aplicativo. O processo é interrompido logo
depois que a senha é digitada.
2. Passos para Reproduzir
1. Iniciar o aplicativo no emulador.
2. Informar um e-mail válido.
3. Informar uma senha válida.
4. Tentar acionar o botão principal de acesso.
3. Resultado Esperado
O robô deveria localizar o botão com o texto "Entrar", acioná-lo e ser
levado até a tela "Catálogo de Restaurantes".
4. Resultado Atual (O Erro)
O teste termina em falha por Timeout. O log do terminal registra o erro: zero
widgets with text "Entrar".
5. Causa Raiz Encontrada (Análise)
O texto do botão na interface foi trocado de "Entrar" para "Acessar", o que
fez o script do robô de automação falhar, já que ele continua buscando o
termo anterior.
