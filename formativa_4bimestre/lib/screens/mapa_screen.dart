import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../services/open_street_map_service.dart';
import 'resultados_screen.dart';

const cidades = ['São Paulo', 'Campinas', 'Jundiaí'];

const _centrosDasCidades = <String, LatLng>{
  'São Paulo': LatLng(-23.5505, -46.6333),
  'Campinas': LatLng(-22.9056, -47.0608),
  'Jundiaí': LatLng(-23.1857, -46.8978),
};

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _pesquisaController = TextEditingController();
  final _mapaService = const OpenStreetMapService();
  late final LocalService? _localService;
  String _cidade = cidades.first;
  List<RealPlace> _lugaresReais = const [];
  bool _carregandoLugares = true;
  String? _erroBusca;

  @override
  void initState() {
    super.initState();
    _localService = widget.firebaseReady ? LocalService() : null;
    _buscarLugares();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _buscarLugares() async {
    setState(() {
      _carregandoLugares = true;
      _erroBusca = null;
    });
    try {
      final lugares = await _mapaService.buscarLocais(
        cidade: _cidade,
      );
      if (!mounted) return;
      setState(() {
        _lugaresReais = lugares;
        _carregandoLugares = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroBusca = 'Não foi possível carregar os locais. Toque para tentar novamente.';
        _carregandoLugares = false;
      });
    }
  }

  void _abrirResultados() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResultadosScreen(
          firebaseReady: widget.firebaseReady,
          cidadeInicial: _cidade,
          pesquisaInicial: _pesquisaController.text,
        ),
      ),
    );
  }

  void _mostrarLugar(String nome, String categoria, LatLng posicao) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nome, style: const TextStyle(
                color: Color(0xFF173D35), fontSize: 20, fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 5),
              Text(categoria, style: const TextStyle(color: Color(0xFF68736C))),
              const SizedBox(height: 12),
              Text('${posicao.latitude.toStringAsFixed(5)}, ${posicao.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF68736C))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = _localService?.listarLocais() ?? Stream<List<Local>>.value(const []);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F16B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.near_me_rounded, color: Color(0xFF173D35)),
                ),
                const SizedBox(width: 11),
                const Text('PERTO', style: TextStyle(
                  color: Color(0xFF173D35), fontSize: 17, fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                )),
                const Spacer(),
                IconButton(
                  tooltip: 'Ver resultados salvos',
                  onPressed: _abrirResultados,
                  icon: const Icon(Icons.format_list_bulleted_rounded),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text('SEU PRÓXIMO\nLUGAR FAVORITO', style: TextStyle(
              color: Color(0xFF173D35), fontSize: 31, height: 1.04,
              fontWeight: FontWeight.w900,
            )),
            const SizedBox(height: 9),
            const Text('Descubra bons lugares por perto.', style: TextStyle(
              color: Color(0xFF68736C), fontSize: 15,
            )),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              initialValue: _cidade,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                prefixIcon: Icon(Icons.location_city_rounded),
              ),
              items: cidades.map((cidade) => DropdownMenuItem(
                value: cidade, child: Text(cidade),
              )).toList(),
              onChanged: (cidade) {
                if (cidade == null) return;
                setState(() => _cidade = cidade);
                _buscarLugares();
              },
            ),
            const SizedBox(height: 11),
            TextField(
              controller: _pesquisaController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _abrirResultados(),
              decoration: InputDecoration(
                hintText: 'O que você está procurando?',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Pesquisar locais salvos',
                  onPressed: _abrirResultados,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              const Text('Explore o mapa', style: TextStyle(
                color: Color(0xFF173D35), fontWeight: FontWeight.w800, fontSize: 17,
              )),
              const Spacer(),
              IconButton(
                tooltip: 'Atualizar lugares reais',
                onPressed: _carregandoLugares ? null : _buscarLugares,
                icon: const Icon(Icons.refresh_rounded),
              ),
              Text(_cidade.toUpperCase(), style: const TextStyle(
                color: Color(0xFF758078), fontSize: 10, fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              )),
            ]),
            const SizedBox(height: 5),
            StreamBuilder<List<Local>>(
              stream: stream,
              builder: (context, snapshot) {
                final locaisSalvos = (snapshot.data ?? const <Local>[]).where(
                  (local) => local.cidade == _cidade &&
                      (local.latitude != 0 || local.longitude != 0),
                ).toList();
                return _MapaReal(
                  key: ValueKey(_cidade),
                  centro: _centrosDasCidades[_cidade]!,
                  lugares: _lugaresReais,
                  locaisSalvos: locaisSalvos,
                  carregando: _carregandoLugares,
                  erro: _erroBusca,
                  aoTocar: _mostrarLugar,
                  aoRecarregar: _buscarLugares,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${_lugaresReais.length} lugares do OpenStreetMap e locais cadastrados',
              style: const TextStyle(fontSize: 11, color: Color(0xFF68736C)),
            ),
            const SizedBox(height: 17),
            FilledButton.icon(
              onPressed: _abrirResultados,
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Explorar locais salvos'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: const Color(0xFF173D35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            if (!widget.firebaseReady) ...[
              const SizedBox(height: 15),
              const _FirebaseAviso(),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapaReal extends StatelessWidget {
  const _MapaReal({
    super.key,
    required this.centro,
    required this.lugares,
    required this.locaisSalvos,
    required this.carregando,
    required this.erro,
    required this.aoTocar,
    required this.aoRecarregar,
  });

  final LatLng centro;
  final List<RealPlace> lugares;
  final List<Local> locaisSalvos;
  final bool carregando;
  final String? erro;
  final void Function(String nome, String categoria, LatLng posicao) aoTocar;
  final VoidCallback aoRecarregar;

  @override
  Widget build(BuildContext context) {
    final marcadoresReais = lugares.map((lugar) => Marker(
      point: lugar.position,
      width: 46,
      height: 46,
      child: _Pino(
        icone: Icons.place_rounded,
        cor: const Color(0xFFB34335),
        aoTocar: () => aoTocar(lugar.name, lugar.category, lugar.position),
      ),
    ));
    final marcadoresSalvos = locaisSalvos.map((local) {
      final posicao = LatLng(local.latitude, local.longitude);
      return Marker(
        point: posicao,
        width: 46,
        height: 46,
        child: _Pino(
          icone: Icons.bookmark_rounded,
          cor: const Color(0xFF173D35),
          aoTocar: () => aoTocar(local.nome, local.categoria, posicao),
        ),
      );
    });

    return SizedBox(
      height: 310,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          FlutterMap(
            options: MapOptions(initialCenter: centro, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.formativa_4bimestre',
              ),
              MarkerLayer(markers: [...marcadoresReais, ...marcadoresSalvos]),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (carregando)
            const Positioned(
              top: 10,
              left: 10,
              child: _MapaStatus(
                icone: Icons.sync_rounded,
                mensagem: 'Buscando lugares reais...',
              ),
            ),
          if (erro != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: aoRecarregar,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      const Icon(Icons.cloud_off_rounded, size: 18,
                        color: Color(0xFF8C5B16)),
                      const SizedBox(width: 7),
                      Expanded(child: Text(erro!, style: const TextStyle(fontSize: 11))),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class _Pino extends StatelessWidget {
  const _Pino({required this.icone, required this.cor, required this.aoTocar});

  final IconData icone;
  final Color cor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => Material(
    color: cor,
    shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
    elevation: 3,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: aoTocar,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Icon(icone, color: Colors.white, size: 23),
      ),
    ),
  );
}

class _MapaStatus extends StatelessWidget {
  const _MapaStatus({required this.icone, required this.mensagem});

  final IconData icone;
  final String mensagem;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icone, size: 16, color: const Color(0xFF173D35)),
        const SizedBox(width: 6),
        Text(mensagem, style: const TextStyle(fontSize: 11)),
      ]),
    ),
  );
}

class _FirebaseAviso extends StatelessWidget {
  const _FirebaseAviso();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF0D8),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.cloud_off_rounded, color: Color(0xFF8C5B16), size: 20),
        SizedBox(width: 10),
        Expanded(child: Text(
          'Firebase ainda não configurado. Execute flutterfire configure e habilite o Cloud Firestore para carregar e salvar locais.',
          style: TextStyle(color: Color(0xFF684A20), height: 1.35, fontSize: 12),
        )),
      ],
    ),
  );
}