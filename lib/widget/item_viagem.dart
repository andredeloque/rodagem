import 'package:rodagem/models/register_viagens.dart';
import 'package:flutter/material.dart';

class ItemViagens extends StatelessWidget {
  RegisterViagens viagens;
  VoidCallback onTapItem;
  VoidCallback onPreddedRemover;

  ItemViagens({@required this.viagens, this.onTapItem, this.onPreddedRemover});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTapItem,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Image.network(
                  viagens.fotos[0],
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${viagens.empresa}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "R\$ ${viagens.valor}",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (this.onPreddedRemover != null)
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    padding: EdgeInsets.all(10),
                    onPressed: this.onPreddedRemover,
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
