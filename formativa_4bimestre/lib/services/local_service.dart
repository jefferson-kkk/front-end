import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/local.dart';

class LocalService {
  LocalService({FirebaseFirestore? firestore})
      : _locais = (firestore ?? FirebaseFirestore.instance).collection('locais');

  final CollectionReference<Map<String, dynamic>> _locais;

  Stream<List<Local>> listarLocais() {
    return _locais.snapshots().map(
          (snapshot) => snapshot.docs
              .map((document) => Local.fromMap(document.id, document.data()))
              .toList(),
        );
  }

  Future<void> adicionar(Local local) async {
    await _locais.add(local.toMap());
  }

  Future<void> atualizar(Local local) async {
    await _locais.doc(local.id).update(local.toMap());
  }

  Future<void> excluir(String id) async {
    await _locais.doc(id).delete();
  }

  Future<void> alterarFavorito(String id, bool favorito) async {
    await _locais.doc(id).update({'favorito': favorito});
  }
}