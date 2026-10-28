import 'package:perto_mapa/models/local.dart';
import 'package:perto_mapa/screens/mapa_screen.dart';
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  test('Local reads Firestore values and applies defaults', () {
    final local = Local.fromMap('abc', {
      'nome': 'Café Central',
      'categoria': 'Cafeteria',
      'cidade': 'Campinas',
      'avaliacao': 4.7,
      'distancia': 1,
      'horario': '08:00 - 18:00',
      'descricao': 'Café de bairro',
    });

    expect(local.id, 'abc');
    expect(local.avaliacao, 4.7);
    expect(local.distancia, 1.0);
    expect(local.favorito, isFalse);
    expect(local.toMap()['nome'], 'Café Central');
  });

  testWidgets('map screen exposes city selection, search and Firebase notice',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MapaScreen(firebaseReady: false),
    ));

    expect(find.text('Explore o mapa'), findsOneWidget);
    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.text('Campinas'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Explorar locais salvos'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Explorar locais salvos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Firebase ainda não configurado'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Firebase ainda não configurado'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
