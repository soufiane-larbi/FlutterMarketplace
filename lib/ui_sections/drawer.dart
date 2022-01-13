//Translated

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:jibeex/screens/main.dart';
import 'package:jibeex/screens/profile.dart';
import 'package:jibeex/screens/order_list.dart';
import 'package:jibeex/screens/wishlist.dart';
import 'package:jibeex/screens/login.dart';
import 'package:jibeex/screens/messenger_list.dart';
import 'package:jibeex/screens/wallet.dart';
import 'package:jibeex/helpers/shared_value_helper.dart';
import 'package:jibeex/app_config.dart';
import 'package:jibeex/helpers/auth_helper.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key key,
  }) : super(key: key);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  onTapLogout(context) async {
    AuthHelper().clearUserData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Main();
        },
        settings: RouteSettings(name: '/Home'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              is_logged_in.value == true
                  ? ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          AppConfig.BASE_PATH + "${avatar_original.value}",
                        ),
                      ),
                      title: Text("${user_name.value}"),
                      subtitle:
                          user_email.value != "" && user_email.value != null
                              ? Text("${user_email.value}")
                              : Text("${user_phone.value}"))
                  : Text('Pas connecté',
                      style: TextStyle(
                          color: Color.fromRGBO(153, 153, 153, 1),
                          fontSize: 14)),
              Divider(),
              ListTile(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  leading: Image.asset("assets/home.png",
                      height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                  title: Text('Accueil',
                      style: TextStyle(
                          color: Color.fromRGBO(153, 153, 153, 1),
                          fontSize: 14)),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Main();
                          },
                          settings: RouteSettings(name: '/Home'),
                        ));
                  }),
              is_logged_in.value == true
                  ? ListTile(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      leading: Image.asset("assets/profile.png",
                          height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                      title: Text('Profil',
                          style: TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 14)),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Profile(show_back_button: true);
                              },
                              settings: RouteSettings(name: '/Profile'),
                            ));
                      })
                  : Container(),
              is_logged_in.value == true
                  ? ListTile(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      leading: Image.asset("assets/order.png",
                          height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                      title: Text('Ordres',
                          style: TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 14)),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return OrderList(from_checkout: false);
                              },
                              settings: RouteSettings(name: "/Cart"),
                            ));
                      })
                  : Container(),
              is_logged_in.value == true
                  ? ListTile(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      leading: Image.asset("assets/heart.png",
                          height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                      title: Text('Liste de souhaits',
                          style: TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 14)),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Wishlist();
                              },
                              settings: RouteSettings(name: '/Wishlist'),
                            ));
                      })
                  : Container(),
              (is_logged_in.value == true)
                  ? ListTile(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      leading: Image.asset("assets/chat.png",
                          height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                      title: Text('Messages',
                          style: TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 14)),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MessengerList();
                              },
                              settings: RouteSettings(name: '/MessengerList'),
                            ));
                      })
                  : Container(),
              is_logged_in.value == true
                  ? ListTile(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      leading: Image.asset("assets/wallet.png",
                          height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                      title: Text('Portefeuille',
                          style: TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 14)),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Wallet();
                              },
                              settings: RouteSettings(name: '/Wallet'),
                            ));
                      })
                  : Container(),
              Divider(height: 24),
              is_logged_in.value == false
                  ? ListTile(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      leading: Image.asset("assets/login.png",
                          height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                      title: Text('S\'identifier',
                          style: TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 14)),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Login();
                              },
                              settings: RouteSettings(name: '/Login'),
                            ));
                      })
                  : Container(),
              is_logged_in.value == true
                  ? ListTile(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      leading: Image.asset("assets/logout.png",
                          height: 16, color: Color.fromRGBO(153, 153, 153, 1)),
                      title: Text('Se déconnecter',
                          style: TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 14)),
                      onTap: () {
                        onTapLogout(context);
                      })
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
