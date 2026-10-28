import 'package:flutter/material.dart';

import '../models/local.dart';
import '../screens/mapa_screen.dart';

class LocalFormDialog extends StatefulWidget {
  const LocalFormDialog({super.key, this.local});
  final Local? local;

  @override
  State<LocalFormDialog> createState() => _LocalFormDialogState();
}

class _LocalFormDialogState extends State<LocalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _avaliacao;
  late final TextEditingController _distancia;
  late final TextEditingController _horario;
  late final TextEditingController _descricao;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late String _cidade;
  late String _categoria;

  static const _categorias = [
    'Academia', 'Alimentação', 'Cafeteria', 'Saúde', 'Serviços', 'Lazer',
  ];

  @override
  void initState() {
    super.initState();
    final local = widget.local;
    _nome = TextEditingController(text: local?.nome ?? '');
    _avaliacao = TextEditingController(text: local?.avaliacao.toString() ?? '4.5');
    _distancia = TextEditingController(text: local?.distancia.toString() ?? '1.0');
    _horario = TextEditingController(text: local?.horario ?? '09:00 - 18:00');
    _descricao = TextEditingController(text: local?.descricao ?? '');
    _cidade = cidades.contains(local?.cidade) ? local!.cidade : cidades.first;
    final coordenadas = _centroDaCidade(_cidade);
    _latitude = TextEditingController(
      text: local == null || local.latitude == 0 ? coordenadas.$1.toString() : local.latitude.toString(),
    );
    _longitude = TextEditingController(
      text: local == null || local.longitude == 0 ? coordenadas.$2.toString() : local.longitude.toString(),
    );
    _categoria = _categorias.contains(local?.categoria)
        ? local!.categoria
        : _categorias.first;
  }

  @override
  void dispose() {
    _nome.dispose();
    _avaliacao.dispose();
    _distancia.dispose();
    _horario.dispose();
    _descricao.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? value) =>
      value == null || value.trim().isEmpty ? 'Preencha este campo' : null;

  (double, double) _centroDaCidade(String cidade) => switch (cidade) {
        'Campinas' => (-22.9056, -47.0608),
        'Jundiaí' => (-23.1857, -46.8978),
        _ => (-23.5505, -46.6333),
      };

  String? _validarCoordenada(String? value, {required double minimo, required double maximo}) {
    final numero = double.tryParse((value ?? '').replaceAll(',', '.'));
    if (numero == null || numero < minimo || numero > maximo) {
      return 'Informe uma coordenada entre $minimo e $maximo';
    }
    return null;
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final local = widget.local;
    Navigator.of(context).pop(
      Local(
        id: local?.id ?? '',
        nome: _nome.text.trim(),
        categoria: _categoria,
        cidade: _cidade,
        avaliacao: double.tryParse(_avaliacao.text.replaceAll(',', '.')) ?? 0,
        distancia: double.tryParse(_distancia.text.replaceAll(',', '.')) ?? 0,
        horario: _horario.text.trim(),
        descricao: _descricao.text.trim(),
        favorito: local?.favorito ?? false,
        latitude: double.parse(_latitude.text.replaceAll(',', '.')),
        longitude: double.parse(_longitude.text.replaceAll(',', '.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.local == null ? 'Novo local' : 'Editar local'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: _obrigatorio),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: _categorias.map((item) => DropdownMenuItem(
                    value: item, child: Text(item))).toList(),
                  onChanged: (value) => setState(() => _categoria = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _cidade,
                  decoration: const InputDecoration(labelText: 'Cidade'),
                  items: cidades.map((item) => DropdownMenuItem(
                    value: item, child: Text(item))).toList(),
                  onChanged: (value) => setState(() => _cidade = value!),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextFormField(
                    controller: _latitude,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    validator: (value) => _validarCoordenada(
                      value, minimo: -90, maximo: 90),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(
                    controller: _longitude,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    validator: (value) => _validarCoordenada(
                      value, minimo: -180, maximo: 180),
                  )),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextFormField(
                    controller: _avaliacao,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Avaliação / 5'),
                    validator: _obrigatorio)),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(
                    controller: _distancia,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Distância (km)'),
                    validator: _obrigatorio)),
                ]),
                const SizedBox(height: 10),
                TextFormField(controller: _horario,
                  decoration: const InputDecoration(labelText: 'Horário'),
                  validator: _obrigatorio),
                const SizedBox(height: 10),
                TextFormField(controller: _descricao, minLines: 2, maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: _obrigatorio),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar')),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}