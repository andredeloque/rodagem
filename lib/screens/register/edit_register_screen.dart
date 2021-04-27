import 'dart:convert';
import 'dart:io';
import 'package:brasil_fields/formatter/real_input_formatter.dart';
import 'package:brasil_fields/formatter/telefone_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commons/commons.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:rodagem/models/register_viagens.dart';

class EditRegisterScreen extends StatefulWidget {
  RegisterViagens viagens;
  EditRegisterScreen(this.viagens);

  @override
  _EditRegisterScreebState createState() => _EditRegisterScreebState();
}

class _EditRegisterScreebState extends State<EditRegisterScreen> {
  RegisterViagens _viagens;

  BuildContext _dialogContext;

  final _formKey = GlobalKey<FormState>();

  final _cepController = TextEditingController();
  final _propriedadeController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _hectaresController = TextEditingController();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _telefoneController = TextEditingController();

  List<File> _listaImagens = List();

  List<String> listaUrlImagens;

  String _idUsuarioLogado;

  _recuperarCep() async {
    String cepDigitado = _cepController.text;

    String url = "https://viacep.com.br/ws/${cepDigitado}/json/";

    http.Response response;

    response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> retorno = json.decode(response.body);
      _cidadeController.text = retorno["localidade"];
      _estadoController.text = retorno["uf"];
    } else if (response.statusCode == 400) {
      warningDialog(
        context,
        "CEP incorreto ou inexistente.",
        title: "Atenção!",
        neutralText: "OK",
      );
    }
  }

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
                Text("Salvando viagens"),
              ],
            ),
          );
        });
  }

  _selecionarIamgem() async {
    File imagemSelecionada;

    imagemSelecionada =
        //   (await ImagePicker().getImage(source: ImageSource.gallery)) as File;
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      setState(() {
        _listaImagens.add(imagemSelecionada);
      });
    }
  }

  _recuperarDadosViagem() async {
    _cepController.text = _viagens.cep;
    _cidadeController.text = _viagens.cidade;
    _estadoController.text = _viagens.estado;
    _propriedadeController.text = _viagens.propriedade;
    _hectaresController.text = _viagens.hectares;
    _valorController.text = _viagens.valor;
    _telefoneController.text = _viagens.telefone;
    _descricaoController.text = _viagens.descricao;
    listaUrlImagens = _viagens.fotos;
  }

  _salvarViagens() async {
    _abrirDialog(_dialogContext);

    await _uploadImagens();

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    String idUsuarioLogado = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    db
        .collection("minhas_viagens")
        .document(idUsuarioLogado)
        .collection("viagens")
        .document(_viagens.id)
        .updateData(_viagens.toMap())
        .then((_) {
      db
          .collection("viagens")
          .document(_viagens.id)
          .setData(_viagens.toMap())
          .then((_) {
        Navigator.pop(_dialogContext);
        Navigator.pop(context);
      });
    });
  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();

    for (var imagem in _listaImagens) {
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference arquivo = pastaRaiz
          .child("minhas_viagens")
          .child(_viagens.id)
          .child(nomeImagem);

      StorageUploadTask uploadTask = arquivo.putFile(imagem);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      String url = await taskSnapshot.ref.getDownloadURL();
      _viagens.fotos.add(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _viagens = widget.viagens;
    _recuperarDadosViagem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Viagem"),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      FormField<List>(
                        initialValue: _listaImagens,
                        //não precisa de uma nova imagem pra atualizar Viagem
                        validator: (imagens) {
                          /*if (imagens.length == 0) {
                            return "Selecione uma imagem";
                          }*/
                          return null;
                        },
                        builder: (state) {
                          return Column(
                            children: [
                              Container(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _listaImagens.length + 1,
                                    itemBuilder: (context, indice) {
                                      if (indice == _listaImagens.length) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              _selecionarIamgem();
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey[400],
                                              radius: 50,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_a_photo,
                                                    size: 40,
                                                    color: Colors.grey[100],
                                                  ),
                                                  Text(
                                                    "Adicionar",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[100]),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      if (_listaImagens.length > 0) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.file(
                                                                _listaImagens[
                                                                    indice]),
                                                            FlatButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _listaImagens
                                                                      .removeAt(
                                                                          indice);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                });
                                                              },
                                                              child: Text(
                                                                  "Excluir"),
                                                              textColor:
                                                                  Colors.red,
                                                            ),
                                                          ],
                                                        ),
                                                      ));
                                            },
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundImage: FileImage(
                                                  _listaImagens[indice]),
                                              child: Container(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 0.4),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return Container();
                                    }),
                              ),
                              if (state.hasError)
                                Container(
                                  child: Text(
                                    "${state.errorText}",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onSaved: (cep) {
                          _viagens.cep = cep;
                        },
                        controller: _cepController,
                        keyboardType: TextInputType.number,
                        validator: (text) {
                          if (text.isEmpty) return "Digite o CEP";
                        },
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            onPressed: _recuperarCep,
                            splashColor: Colors.grey,
                          ),
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "cep",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onSaved: (cidade) {
                          _viagens.cidade = cidade;
                        },
                        enabled: false,
                        controller: _cidadeController,
                        keyboardType: TextInputType.text,
                        validator: (text) {
                          if (text.isEmpty) return "Digite a cidade";
                        },
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "cidade",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onSaved: (estado) {
                          _viagens.estado = estado;
                        },
                        enabled: false,
                        controller: _estadoController,
                        keyboardType: TextInputType.text,
                        validator: (text) {
                          if (text.isEmpty) return "Digite o estado";
                        },
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "estado",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onSaved: (propriedade) {
                          _viagens.propriedade = propriedade;
                        },
                        controller: _propriedadeController,
                        keyboardType: TextInputType.text,
                        validator: (text) {
                          if (text.isEmpty) return "Digite o nome da empresa";
                        },
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "nome da propriedade",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onSaved: (hectares) {
                          _viagens.hectares = hectares;
                        },
                        controller: _hectaresController,
                        keyboardType: TextInputType.number,
                        validator: (text) {
                          if (text.isEmpty) return "Digite o peso da carga";
                        },
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "peso",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      //teste
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onSaved: (valor) {
                          String moedaBD = valor;
                          moedaBD = moedaBD.replaceAll(".", "");
                          moedaBD = moedaBD.replaceAll(",", ".");
                          //double valorDouble = double.parse(moedaBD);
                          _viagens.valor = moedaBD;
                        },
                        controller: _valorController,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          //RealInputFormatter(centavos: true),
                        ],
                        validator: (text) {
                          if (text.isEmpty) return "Digite a data de partida";
                        },
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "data de partida",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      //teste
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onSaved: (valor) {
                          String moedaBD = valor;
                          moedaBD = moedaBD.replaceAll(".", "");
                          moedaBD = moedaBD.replaceAll(",", ".");
                          //double valorDouble = double.parse(moedaBD);
                          _viagens.valor = moedaBD;
                        },
                        controller: _valorController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          RealInputFormatter(centavos: true),
                        ],
                        validator: (text) {
                          if (text.isEmpty) return "Digite o valor da carga";
                        },
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "valor da carga",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onSaved: (descricao) {
                          _viagens.descricao = descricao;
                        },
                        maxLines: 50,
                        minLines: 1,
                        controller: _descricaoController,
                        keyboardType: TextInputType.text,
                        validator: (text) {
                          if (text.isEmpty) return "Digite a descrição";
                        },
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "descrição",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 10),
                        child: RaisedButton(
                          child: Text(
                            "Atualizar",
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          textColor: Colors.white,
                          color: Color.fromARGB(255, 0, 100, 0),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();

                              _dialogContext = context;

                              _salvarViagens();
                            }
                          },
                          padding: EdgeInsets.fromLTRB(122, 16, 122, 16),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ],
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
