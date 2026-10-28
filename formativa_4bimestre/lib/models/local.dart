class Local {
  const Local({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.cidade,
    required this.avaliacao,
    required this.distancia,
    required this.horario,
    required this.descricao,
    required this.favorito,
    this.latitude = 0,
    this.longitude = 0,
  });

  final String id;
  final String nome;
  final String categoria;
  final String cidade;
  final double avaliacao;
  final double distancia;
  final String horario;
  final String descricao;
  final bool favorito;
  final double latitude;
  final double longitude;

  factory Local.fromMap(String id, Map<String, dynamic> data) {
    return Local(
      id: id,
      nome: data['nome'] as String? ?? '',
      categoria: data['categoria'] as String? ?? '',
      cidade: data['cidade'] as String? ?? '',
      avaliacao: _number(data['avaliacao']),
      distancia: _number(data['distancia']),
      horario: data['horario'] as String? ?? '',
      descricao: data['descricao'] as String? ?? '',
      favorito: data['favorito'] as bool? ?? false,
      latitude: _number(data['latitude']),
      longitude: _number(data['longitude']),
    );
  }

  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'categoria': categoria,
        'cidade': cidade,
        'avaliacao': avaliacao,
        'distancia': distancia,
        'horario': horario,
        'descricao': descricao,
        'favorito': favorito,
          'latitude': latitude,
          'longitude': longitude,
      };

        Local copyWith({bool? favorito, double? latitude, double? longitude}) => Local(
        id: id,
        nome: nome,
        categoria: categoria,
        cidade: cidade,
        avaliacao: avaliacao,
        distancia: distancia,
        horario: horario,
        descricao: descricao,
        favorito: favorito ?? this.favorito,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
}