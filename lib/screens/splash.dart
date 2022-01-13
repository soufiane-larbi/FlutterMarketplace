import 'dart:ui';
import 'package:jibeex/services/repo_lists.dart';
import 'package:jibeex/app_config.dart';
import 'package:jibeex/screens/main.dart';
import 'package:jibeex/screens/network_error.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _netSlow = false;

  @override
  void initState() {
    FirebaseAnalytics().setCurrentScreen(screenName: '/Splash');
    //on Splash Screen hide statusbar
    RepositoryLists.fetchSlider();
    RepositoryLists.fetchCategory();
    RepositoryLists.fetchFeaturedProduct();
    RepositoryLists.fetchBestSelling();
    RepositoryLists.fetchBrands();

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
    _initPackageInfo();
    Timer(Duration(seconds: 5), () {
      setState(() {
        _netSlow = true;
      });
    });
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  Future<void> _initPackageInfo() async {
    AppConfig.packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: RepositoryLists.getRemoteConfig(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data) {
            return Main();
          } else {
            return NetworkEror();
          }
        } else {
          return splashScreen();
        }
      },
    );
  }

  splashScreen() {
    return Scaffold(
      body: InkWell(
        //onTap: widget.onClick,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Hero(
                    tag: "backgroundImageInSplash",
                    child: Container(
                      child: Image.asset(
                          "assets/splash_login_registration_background_image.png"),
                    ),
                  ),
                  radius: 140,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Hero(
                                tag: "splashscreenImage",
                                child: Container(
                                  child: Image.asset(
                                      "assets/splash_screen_logo.png"),
                                ),
                              ),
                              radius: 60,
                            ),
                          ),
                          AppConfig.packageInfo != null
                              ? Text(
                                  "V " + AppConfig.packageInfo.version,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      color: Colors.white),
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                          ),
                          Text(
                            AppConfig.copyright_text,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 13.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          _netSlow
                              ? Container(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 3,
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: 7,
                          ),
                          _netSlow
                              ? Text(
                                  "L'nternet est lent, Veuillez patienter...",
                                  style: TextStyle(color: Colors.white),
                                )
                              : Container(),
                        ],
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
