import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';

class DetalhesScreen extends StatefulWidget {
  const DetalhesScreen({super.key, required this.local, required this.service});
  final Local local;
  final LocalService service;

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  late Local _local;
  bool _salvandoFavorito = false;

  @override
  void initState() {
    super.initState();
    _local = widget.local;
  }

  Future<void> _alternarFavorito() async {
    final novoValor = !_local.favorito;
    setState(() => _salvandoFavorito = true);
    try {
      await widget.service.alterarFavorito(_local.id, novoValor);
      if (mounted) setState(() => _local = _local.copyWith(favorito: novoValor));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível atualizar o favorito.')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvandoFavorito = false);
    }
  }

  IconData get _icone => switch (_local.categoria.toLowerCase()) {
        'academia' => Icons.fitness_center_rounded,
        'alimentação' => Icons.restaurant_rounded,
        'cafeteria' => Icons.coffee_rounded,
        'saúde' => Icons.local_hospital_rounded,
        'lazer' => Icons.sports_esports_rounded,
        _ => Icons.storefront_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('Detalhes', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: _local.favorito ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
            onPressed: _salvandoFavorito ? null : _alternarFavorito,
            icon: Icon(
              _local.favorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _local.favorito ? const Color(0xFFBC4B42) : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Container(
            height: 235,
            decoration: BoxDecoration(color: const Color(0xFFDDE6D5),
              borderRadius: BorderRadius.circular(22)),
            clipBehavior: Clip.antiAlias,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(
                'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1000&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(
                    colors: [Color(0xFFB8C9AE), Color(0xFFE8E5D4)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Center(child: Icon(Icons.location_city_rounded,
                    size: 88, color: Color(0xFF55745F))),
                ),
              ),
              Positioned(
                left: 15,
                bottom: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Icon(_icone, size: 15, color: const Color(0xFF28594B)),
                    const SizedBox(width: 6),
                    Text(_local.categoria,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Text(_local.nome, style: const TextStyle(
            color: Color(0xFF173D35), fontSize: 28, height: 1.1,
            fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 17, color: Color(0xFF65716A)),
            const SizedBox(width: 3),
            Text(_local.cidade, style: const TextStyle(color: Color(0xFF65716A))),
            const SizedBox(width: 14),
            const Icon(Icons.star_rounded, size: 18, color: Color(0xFFDA9C28)),
            Text(' ${_local.avaliacao.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 12),
            Text('${_local.distancia.toStringAsFixed(1)} km',
              style: const TextStyle(color: Color(0xFF65716A))),
          ]),
          const SizedBox(height: 25),
          const Text('SOBRE O LOCAL', style: TextStyle(
            color: Color(0xFF68736C), fontSize: 10, fontWeight: FontWeight.w900,
            letterSpacing: 1.2)),
          const SizedBox(height: 9),
          Text(_local.descricao.isEmpty ? 'Nenhuma descrição cadastrada.' : _local.descricao,
            style: const TextStyle(color: Color(0xFF35453D), height: 1.55, fontSize: 15)),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              const Icon(Icons.schedule_rounded, color: Color(0xFF28594B)),
              const SizedBox(width: 11),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('HORÁRIO', style: TextStyle(color: Color(0xFF788078),
                  fontSize: 10, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(_local.horario, style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Ver no mapa'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(53),
              backgroundColor: const Color(0xFF173D35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }
}