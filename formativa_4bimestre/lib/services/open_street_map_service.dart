import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RealPlace {
  const RealPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.position,
  });

  final String id;
  final String name;
  final String category;
  final String address;
  final LatLng position;
}

class OpenStreetMapService {
  const OpenStreetMapService();

  static DateTime _ultimaConsulta = DateTime.fromMillisecondsSinceEpoch(0);

  static const _limitesCidade = <String, String>{
    'São Paulo': '-46.84,-23.32,-46.36,-23.80',
    'Campinas': '-47.25,-22.75,-46.85,-23.10',
    'Jundiaí': '-47.08,-23.05,-46.70,-23.32',
  };

  Future<List<RealPlace>> buscarLocais({
    required String cidade,
  }) async {
    return buscarPorTexto(termo: 'restaurant', cidade: cidade);
  }

  Future<List<RealPlace>> buscarPorTexto({
    required String termo,
    required String cidade,
    http.Client? client,
  }) async {
    if (cidade == 'Todas') {
      final resultados = <RealPlace>[];
      for (final cidadeAtual in ['São Paulo', 'Campinas', 'Jundiaí']) {
        resultados.addAll(await buscarPorTexto(
          termo: termo,
          cidade: cidadeAtual,
          client: client,
        ));
      }
      return resultados;
    }
    final consulta = termo.trim().isEmpty ? 'restaurant' : termo.trim();
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'format': 'jsonv2',
      'q': '$consulta, $cidade, Brasil',
      'limit': '30',
      'bounded': '1',
      'viewbox': _limitesCidade[cidade] ?? _limitesCidade['São Paulo']!,
      'accept-language': 'pt-BR',
    });
    final espera = const Duration(seconds: 1) -
        DateTime.now().difference(_ultimaConsulta);
    if (espera > Duration.zero) await Future<void>.delayed(espera);
    _ultimaConsulta = DateTime.now();

    final headers = <String, String>{'Accept': 'application/json'};
    if (!kIsWeb) headers['User-Agent'] = 'PertoFlutterApp/1.0';
    final resposta = await (client == null
        ? http.get(uri, headers: headers)
        : client.get(uri, headers: headers)).timeout(const Duration(seconds: 20));
    if (resposta.statusCode != 200) {
      throw Exception('A busca de lugares retornou HTTP ${resposta.statusCode}.');
    }

    final elementos = jsonDecode(resposta.body) as List<dynamic>;
    final locais = <RealPlace>[];
    for (final elemento in elementos) {
      if (elemento is! Map<String, dynamic>) continue;
      final lat = double.tryParse(elemento['lat']?.toString() ?? '');
      final lon = double.tryParse(elemento['lon']?.toString() ?? '');
      if (lat == null || lon == null) continue;
      final nome = elemento['name'] as String?;
      final endereco = elemento['display_name'] as String? ?? cidade;
      final tipo = elemento['type'] as String? ??
          elemento['category'] as String? ?? 'Local';
      locais.add(RealPlace(
        id: '${elemento['osm_type']}/${elemento['osm_id']}',
        name: nome == null || nome.isEmpty ? endereco.split(',').first : nome,
        category: tipo.replaceAll('_', ' '),
        address: endereco,
        position: LatLng(lat, lon),
      ));
    }
    return locais;
  }
}