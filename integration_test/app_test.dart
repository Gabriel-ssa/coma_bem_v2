import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:coma_bem/main.dart' as app;

void main() {
IntegrationTestWidgetsFlutterBinding.ensureInitialized();
testWidgets('Validação Funcional: O robô vai fazer login sozinho', (WidgetTester tester) async {
  app.main();

  await tester.pumpAndSettle();

  final campoEmail = find.byType(TextFormField).first;
  
  final campoSenha = find.byType(TextFormField).last;

  final botaoEntrar = find.text('Entrar');

  await tester.enterText(campoEmail, 'admin@comabem.com');
  await tester.enterText(campoSenha, '1234');
  await tester.pumpAndSettle();
  await tester.tap(botaoEntrar);
  await tester.pumpAndSettle();

  expect(find.text('Catálogo de Restaurantes'), findsOneWidget);
});
}
