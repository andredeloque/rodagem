import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterViagens {
  String _id;
  String _cep;
  String _cidade;
  String _estado;
  String _empresa;
  String _peso;
  String _valor;
  String _descricao;
  String _dataPartida;
  String _dataChegada;
  List<String> _fotos;

  RegisterViagens();

  RegisterViagens.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    this.id = documentSnapshot.documentID;
    this.cep = documentSnapshot["cep"];
    this.cidade = documentSnapshot["cidade"];
    this.estado = documentSnapshot["estado"];
    this.dataPartida = documentSnapshot["dataPartida"];
    this.dataChegada = documentSnapshot["dataChegada"];
    this.empresa = documentSnapshot["empresa"];
    this.peso = documentSnapshot["peso"];
    this.valor = documentSnapshot["valor"];
    this.descricao = documentSnapshot["descricao"];
    this.fotos = List<String>.from(documentSnapshot["fotos"]);
  }

  RegisterViagens.gerarId() {
    Firestore db = Firestore.instance;
    CollectionReference arrendamento = db.collection("minhas_viagens");
    this.id = arrendamento.document().documentID;
    this.fotos = [];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": this.id,
      "cep": this.cep,
      "cidade": this.cidade,
      "estado": this.estado,
      "dataPartida": this.dataPartida,
      "dataChegada": this.dataChegada,
      "empresa": this.empresa,
      "peso": this.peso,
      "valor": this.valor,
      "descricao": this.descricao,
      "fotos": this.fotos
    };
    return map;
  }

  List<String> get fotos => _fotos;

  set fotos(List<String> value) {
    _fotos = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get valor => _valor;

  set valor(String value) {
    _valor = value;
  }

  String get peso => _peso;

  set peso(String value) {
    _peso = value;
  }

  String get empresa => _empresa;

  set empresa(String value) {
    _empresa = value;
  }

  String get estado => _estado;

  set estado(String value) {
    _estado = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get cep => _cep;

  set cep(String value) {
    _cep = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get dataChegada => _dataChegada;

  set dataChegada(String value) {
    _dataChegada = value;
  }

  String get dataPartida => _dataPartida;

  set dataPartida(String value) {
    _dataPartida = value;
  }
}
