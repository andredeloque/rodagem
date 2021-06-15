import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _nickController = TextEditingController();
  File _imagem;
  String _idUsuarioLogado;
  bool _subindoImagem = false;
  String _urlImagemRecuperada;

  BuildContext _dialogContext;

  _abrirDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text("Salvando perfil"),
              ],
            ),
          );
        });
  }

  Future _recuperarImagem(String origemImagem) async {
    File imagemSelecionada;

    switch (origemImagem) {
      case "camera":
        imagemSelecionada =
            await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        imagemSelecionada =
            await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = imagemSelecionada;
      if (_imagem != null) {
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo =
        pastaRaiz.child("perfil").child(_idUsuarioLogado + ".jpg");

    StorageUploadTask task = arquivo.putFile(_imagem);

    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore(url);
    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarNomeFirestore() {
    _abrirDialog(_dialogContext);

    String nome = _nickController.text;
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {"nick": nome};

    db
        .collection("users")
        .document(_idUsuarioLogado)
        .updateData(dadosAtualizar)
        .then((_) {
      Navigator.pop(_dialogContext);
      Navigator.pop(context);
    });
  }

  _atualizarUrlImagemFirestore(String url) {
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {"urlImagem": url};

    db
        .collection("users")
        .document(_idUsuarioLogado)
        .updateData(dadosAtualizar);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data;

    _nickController.text = dados["nick"];

    if (dados["urlImagem"] != null) {
      setState(() {
        _urlImagemRecuperada = dados["urlImagem"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Perfil"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: _subindoImagem
                      ? CircularProgressIndicator()
                      : Container(),
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundImage: _urlImagemRecuperada != null
                      ? NetworkImage(_urlImagemRecuperada)
                      : null,
                  backgroundColor: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          _recuperarImagem("camera");
                        },
                        child: Text("Câmera")),
                    FlatButton(
                        onPressed: () {
                          _recuperarImagem("galeria");
                        },
                        child: Text("Galeria")),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: TextFormField(
                    controller: _nickController,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.green,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Apelido",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    textColor: Colors.white,
                    color: Color.fromARGB(255, 0, 100, 0),
                    onPressed: () {
                      _dialogContext = context;

                      _atualizarNomeFirestore();
                    },
                    padding: EdgeInsets.fromLTRB(132, 16, 132, 16),
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
