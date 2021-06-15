import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rodagem/models/register_viagem.dart';

class DetailScreen extends StatefulWidget {
  RegisterViagem viagem;
  String typeUser;

  DetailScreen(this.viagem, this.typeUser);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  RegisterViagem _viagem;

  String _idUsuarioLogado;
  String _typeUser;
  Map<String, dynamic> dadosViagemMotorista;
  Map<String, dynamic> dadosViagem;

  DocumentSnapshot documentSnapshotMotorista;
  DocumentSnapshot documentSnapshotTransportadora;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  List<Widget> _getListaImagens() {

    List<String> listaUrlImagens = _viagem.fotos;

    return listaUrlImagens.map((url) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.fitWidth
          ),
        ),
      );
    }).toList();

  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
  }

  _receberViagem() {

    String statusPagamento = "Viagem Paga";
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {"statusPagamento": statusPagamento};

    db
        .collection("viagens")
        .document(_viagem.id)
        .updateData(dadosAtualizar)
        .then((_) {
      refreshViagem();
      //Navigator.of(context).pushReplacementNamed('/base');
    });
  }

  _verificarStatusPagamentoMotorista() async {
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshotVigemMotorista = await db
        .collection("minhas_viagens")
        .document(_idUsuarioLogado)
        .collection("viagens")
        .document(_viagem.id)
        .get();

    documentSnapshotMotorista = snapshotVigemMotorista;
    dadosViagemMotorista = snapshotVigemMotorista.data;

  }

  _verificarStatusPagamentoViagem() async {
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshotViagem = await db
        .collection("viagens")
        .document(_viagem.id)
        .get();

    documentSnapshotTransportadora = snapshotViagem;
    dadosViagem = snapshotViagem.data;
  }

  _atualizarStatusPagamento() async {

    if(dadosViagem['statusPagamento'] != dadosViagemMotorista['statusPagamento']) {
      String statusPagamento = "Viagem Paga";
      Firestore db = Firestore.instance;

      Map<String, dynamic> dadosAtualizar = {"statusPagamento": statusPagamento};

      db
          .collection("minhas_viagens")
          .document(_idUsuarioLogado)
          .collection("viagens")
          .document(_viagem.id)
          .updateData(dadosAtualizar)
          .then((_) {
            refreshViagem();
      });
    }
  }

  _recuperarDados() {

    if(_typeUser == "motorista") {
      RegisterViagem registerViagemMotorista = RegisterViagem.fromDocumentSnapshot(documentSnapshotMotorista);
      _viagem = registerViagemMotorista;
    } else
    if(_typeUser == "transportadora") {
      RegisterViagem registerViagem = RegisterViagem.fromDocumentSnapshot(documentSnapshotTransportadora);
      _viagem = registerViagem;
    }

  }

  Future<Null> refreshViagem() async {
    _refreshIndicatorKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    await _verificarStatusPagamentoMotorista();

    await _verificarStatusPagamentoViagem();

    setState(() {
      _recuperarDados();
    });

    return null;
  }

  _initialize() async {
      _viagem = widget.viagem;
      _typeUser = widget.typeUser;

      await _recuperarDadosUsuario();

      await _verificarStatusPagamentoMotorista();

      await _verificarStatusPagamentoViagem();

      if(_typeUser == "motorista") {
        _atualizarStatusPagamento();
      }

  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viagem"),
      ),
      body: RefreshIndicator(
      key: _refreshIndicatorKey,
        child: Stack(
          children: [
            ListView(
              children: [
                SizedBox(
                  height: 250,
                  child: Carousel(
                    images: _getListaImagens(),
                    dotSize: 8,
                    dotBgColor: Colors.transparent,
                    dotColor: Colors.white,
                    autoplay: false,
                    dotIncreasedColor: Colors.greenAccent,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("R\$ ${_viagem.valor}",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green
                        ),
                      ),
                      Text("${_viagem.statusPagamento}",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: _viagem.statusPagamento == "Sem Pagamento" ? Colors.red : Colors.green
                        ),
                      ),
                      Text("${_viagem.empresa}",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text("${_viagem.cidade} - ${_viagem.estado}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
                      Text("Data Partida",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("${_viagem.dataPartida}",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
                      Text("Data Chegada",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("${_viagem.dataChegada}",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
                      Text("Produto",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("${_viagem.produto}",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
                      Text("Peso",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("${_viagem.peso}",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                if(_typeUser == "transportadora" && _viagem.statusPagamento == "Sem Pagamento")...[
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 0, 100, 0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: AutoSizeText(
                                "Receber Viagem",
                                maxLines: 2,
                                minFontSize: 10,
                                maxFontSize: 32,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            _receberViagem();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,)
                ]
              ],
            ),
          ],
        ),
        onRefresh: refreshViagem,
      ),
    );
  }
}
