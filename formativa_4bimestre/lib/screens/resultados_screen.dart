import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../services/open_street_map_service.dart';
import '../widgets/local_form_dialog.dart';
import 'detalhes_screen.dart';
import 'mapa_screen.dart';

class ResultadosScreen extends StatefulWidget {
  const ResultadosScreen({
    super.key,
    required this.firebaseReady,
    required this.cidadeInicial,
    this.pesquisaInicial = '',
  });

  final bool firebaseReady;
  final String cidadeInicial;
  final String pesquisaInicial;

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  late final TextEditingController _pesquisa;
  late final LocalService? _service;
  final _mapaService = const OpenStreetMapService();
  late String _cidade;
  String _categoria = 'Todas';
  bool _somenteFavoritos = false;
  bool _buscandoWeb = false;
  String? _erroWeb;
  List<RealPlace> _lugaresWeb = const [];
  int _idBusca = 0;

  static const _categorias = [
    'Todas', 'Academia', 'Alimentação', 'Cafeteria', 'Saúde', 'Serviços', 'Lazer',
  ];

  @override
  void initState() {
    super.initState();
    _pesquisa = TextEditingController(text: widget.pesquisaInicial);
    _cidade = widget.cidadeInicial;
    _service = widget.firebaseReady ? LocalService() : null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _buscarNaWeb());
  }

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  String _termoDaBusca() {
    final termo = _pesquisa.text.trim();
    if (termo.isNotEmpty) return termo;
    return switch (_categoria) {
      'Academia' => 'gym',
      'Alimentação' => 'restaurant',
      'Cafeteria' => 'cafe',
      'Saúde' => 'pharmacy',
      'Serviços' => 'bank',
      'Lazer' => 'park',
      _ => 'restaurant',
    };
  }

  Future<void> _buscarNaWeb() async {
    final idBusca = ++_idBusca;
    setState(() {
      _buscandoWeb = true;
      _erroWeb = null;
    });
    try {
      final lugares = await _mapaService.buscarPorTexto(
        termo: _termoDaBusca(),
        cidade: _cidade,
      );
      if (!mounted || idBusca != _idBusca) return;
      setState(() {
        _lugaresWeb = lugares;
        _buscandoWeb = false;
      });
    } catch (_) {
      if (!mounted || idBusca != _idBusca) return;
      setState(() {
        _lugaresWeb = const [];
        _erroWeb = 'Não foi possível buscar lugares agora. Verifique a conexão e tente novamente.';
        _buscandoWeb = false;
      });
    }
  }

  Future<void> _formulario({Local? local}) async {
    final resultado = await showDialog<Local>(
      context: context,
      builder: (_) => LocalFormDialog(local: local),
    );
    if (resultado == null || _service == null) return;
    try {
      if (local == null) {
        await _service.adicionar(resultado);
      } else {
        await _service.atualizar(resultado);
      }
      _mensagem(local == null ? 'Local cadastrado.' : 'Alterações salvas.');
    } catch (_) {
      _mensagem('Não foi possível salvar. Verifique o Firestore e as regras.');
    }
  }

  Future<void> _excluir(Local local) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir local?'),
        content: Text('“${local.nome}” será removido permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFAE3B31)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || _service == null) return;
    try {
      await _service.excluir(local.id);
      _mensagem('Local excluído.');
    } catch (_) {
      _mensagem('Não foi possível excluir o local.');
    }
  }

  void _mensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  List<Local> _filtrar(List<Local> locais) {
    final termo = _pesquisa.text.trim().toLowerCase();
    return locais.where((local) {
      final cidadeOk = _cidade == 'Todas' || local.cidade == _cidade;
      final categoriaOk = _categoria == 'Todas' || local.categoria == _categoria;
      final textoOk = termo.isEmpty || local.nome.toLowerCase().contains(termo) ||
          local.categoria.toLowerCase().contains(termo);
      return cidadeOk && categoriaOk && textoOk &&
          (!_somenteFavoritos || local.favorito);
    }).toList()..sort((a, b) => a.distancia.compareTo(b.distancia));
  }

  void _abrirLugar(RealPlace lugar) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lugar.name, style: const TextStyle(
              color: Color(0xFF173D35), fontSize: 20, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 5),
            Text(lugar.category, style: const TextStyle(color: Color(0xFF68736C))),
            const SizedBox(height: 10),
            Text(lugar.address, style: const TextStyle(
              color: Color(0xFF68736C), fontSize: 13, height: 1.4,
            )),
            const SizedBox(height: 10),
            Text('${lugar.position.latitude.toStringAsFixed(5)}, ${lugar.position.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF68736C))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locaisStream = _service?.listarLocais() ??
        Stream<List<Local>>.value(const []);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Adicionar local',
            onPressed: widget.firebaseReady ? () => _formulario() : null,
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
          child: Column(children: [
            TextField(
              controller: _pesquisa,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _buscarNaWeb(),
              decoration: InputDecoration(
                hintText: 'Buscar nome ou categoria',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Buscar lugares',
                  onPressed: _buscarNaWeb,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _cidade,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                items: ['Todas', ...cidades].map((cidade) => DropdownMenuItem(
                  value: cidade,
                  child: Text(cidade, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _cidade = value);
                  _buscarNaWeb();
                },
              )),
              const SizedBox(width: 9),
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                items: _categorias.map((categoria) => DropdownMenuItem(
                  value: categoria,
                  child: Text(categoria, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _categoria = value);
                  _buscarNaWeb();
                },
              )),
            ]),
            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                selected: _somenteFavoritos,
                label: const Text('Favoritos'),
                avatar: const Icon(Icons.favorite_rounded, size: 17),
                onSelected: (value) => setState(() => _somenteFavoritos = value),
              ),
            ),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<Local>>(
            stream: locaisStream,
            builder: (context, snapshot) {
              final locais = _filtrar(snapshot.data ?? const []);
              if (_buscandoWeb && _lugaresWeb.isEmpty && locais.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_erroWeb != null && _lugaresWeb.isEmpty && locais.isEmpty) {
                return _EstadoVazio(
                  icon: Icons.cloud_off_outlined,
                  title: 'Busca indisponível',
                  subtitle: _erroWeb!,
                  onRetry: _buscarNaWeb,
                );
              }
              if (_lugaresWeb.isEmpty && locais.isEmpty && !_buscandoWeb) {
                return const _EstadoVazio(
                  icon: Icons.travel_explore_rounded,
                  title: 'Nenhum local encontrado',
                  subtitle: 'Tente outro nome ou escolha uma categoria diferente.',
                );
              }
              final total = _lugaresWeb.length + locais.length +
                  (_buscandoWeb || _erroWeb != null ? 1 : 0);
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 2, 18, 24),
                itemCount: total,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index < _lugaresWeb.length) {
                    final lugar = _lugaresWeb[index];
                    return _LugarWebCard(lugar: lugar, onTap: () => _abrirLugar(lugar));
                  }
                  final indiceLocal = index - _lugaresWeb.length;
                  if (indiceLocal < locais.length) {
                    final local = locais[indiceLocal];
                    return _LocalCard(
                      local: local,
                      onTap: () {
                        final service = _service;
                        if (service == null) return;
                        Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (_) => DetalhesScreen(local: local, service: service),
                        ));
                      },
                      onEdit: () => _formulario(local: local),
                      onDelete: () => _excluir(local),
                    );
                  }
                  return ListTile(
                    leading: Icon(_buscandoWeb
                        ? Icons.sync_rounded : Icons.cloud_off_outlined),
                    title: Text(_buscandoWeb ? 'Buscando lugares...' : _erroWeb!),
                    trailing: _erroWeb == null ? null : IconButton(
                      tooltip: 'Tentar novamente',
                      onPressed: _buscarNaWeb,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
      floatingActionButton: widget.firebaseReady
          ? FloatingActionButton.extended(
              onPressed: () => _formulario(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Cadastrar'),
              backgroundColor: const Color(0xFFE0F16B),
              foregroundColor: const Color(0xFF173D35),
            )
          : null,
    );
  }
}

class _LugarWebCard extends StatelessWidget {
  const _LugarWebCard({required this.lugar, required this.onTap});

  final RealPlace lugar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF9E5E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.place_rounded, color: Color(0xFFB34335)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lugar.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 4),
              Text(lugar.category, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF737C75), fontSize: 12)),
              const SizedBox(height: 4),
              Text(lugar.address, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF737C75), fontSize: 11)),
            ],
          )),
          const SizedBox(width: 6),
          const Icon(Icons.open_in_new_rounded, size: 18, color: Color(0xFF68736C)),
        ]),
      ),
    ),
  );
}

class _LocalCard extends StatelessWidget {
  const _LocalCard({required this.local, required this.onTap,
    required this.onEdit, required this.onDelete});

  final Local local;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData get _icone => switch (local.categoria.toLowerCase()) {
        'academia' => Icons.fitness_center_rounded,
        'alimentação' => Icons.restaurant_rounded,
        'cafeteria' => Icons.coffee_rounded,
        'saúde' => Icons.local_hospital_rounded,
        'lazer' => Icons.sports_esports_rounded,
        _ => Icons.storefront_rounded,
      };

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: const Color(0xFFE9EEDD),
              borderRadius: BorderRadius.circular(13)),
            child: Icon(_icone, color: const Color(0xFF28594B)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(local.nome, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 4),
              Text('${local.categoria} · ${local.cidade}', maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF737C75), fontSize: 12)),
              const SizedBox(height: 7),
              Row(children: [
                const Icon(Icons.star_rounded, color: Color(0xFFDA9C28), size: 16),
                Text(' ${local.avaliacao.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.near_me_outlined, color: Color(0xFF738077), size: 14),
                Text(' ${local.distancia.toStringAsFixed(1)} km',
                  style: const TextStyle(color: Color(0xFF737C75), fontSize: 12)),
              ]),
            ],
          )),
          PopupMenuButton<String>(
            tooltip: 'Ações do local',
            onSelected: (value) => value == 'editar' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'editar', child: Text('Editar')),
              PopupMenuItem(value: 'excluir', child: Text('Excluir')),
            ],
          ),
        ]),
      ),
    ),
  );
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 42, color: const Color(0xFF728078)),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF727A74), height: 1.4)),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ]),
    ),
  );
}