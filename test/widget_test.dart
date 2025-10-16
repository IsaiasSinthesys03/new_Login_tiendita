// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:TiendaApp/main.dart';

void main() {
  testWidgets('Test inicial - Verifica que la app inicia correctamente', (WidgetTester tester) async {
    // Construye nuestra aplicación y dispara un frame.
    await tester.pumpWidget(const TienditaApp()); 

    // Dado que la app inicia en LoginScreen si no hay sesión, 
    // verificamos que encuentra el texto de la pantalla de inicio de sesión.
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Sistema de Inventario y Ventas'), findsOneWidget);
  });
}