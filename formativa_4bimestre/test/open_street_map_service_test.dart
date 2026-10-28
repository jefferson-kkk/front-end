import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:perto_mapa/services/open_street_map_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('search uses the selected city bounds and parses real places', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'nominatim.openstreetmap.org');
      expect(request.url.queryParameters['q'], 'padaria, Campinas, Brasil');
      expect(request.url.queryParameters['bounded'], '1');
      expect(request.url.queryParameters['viewbox'], '-47.25,-22.75,-46.85,-23.10');
      expect(request.headers['User-Agent'], 'PertoFlutterApp/1.0');
      return http.Response(jsonEncode([
        {
          'osm_type': 'way',
          'osm_id': 123,
          'name': 'Padaria Central',
          'type': 'bakery',
          'display_name': 'Padaria Central, Campinas, Brasil',
          'lat': '-22.90',
          'lon': '-47.06',
        },
      ]), 200);
    });

    final lugares = await const OpenStreetMapService().buscarPorTexto(
      termo: 'padaria',
      cidade: 'Campinas',
      client: client,
    );

    expect(lugares, hasLength(1));
    expect(lugares.single.name, 'Padaria Central');
    expect(lugares.single.category, 'bakery');
    expect(lugares.single.position.latitude, -22.90);
    expect(lugares.single.position.longitude, -47.06);
  });
}