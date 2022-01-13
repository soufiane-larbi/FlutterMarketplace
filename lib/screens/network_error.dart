import 'package:flutter/material.dart';
import 'splash.dart';
import 'package:jibeex/services/repo_lists.dart';

class NetworkEror extends StatefulWidget {
  @override
  _nameState createState() => _nameState();
}

class _nameState extends State<NetworkEror> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(
            height: 140,
          ),
          Container(
            height: 200,
            child: Image.asset('assets/net_error.png'),
          ),
          SizedBox(
            height: 20,
          ),
          Text("Problème de connexion Internet, Veuillez réessayer."),
          SizedBox(
            height: 5,
          ),
          RaisedButton(
            elevation: 0.0,
            color: Colors.grey[200],
            child: Text("Réessayer"),
            onPressed: () {
              RepositoryLists.clearData();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return Splash();
              }));
            },
          )
        ]),
      ),
    );
  }
}
