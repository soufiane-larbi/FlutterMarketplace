import 'package:jibeex/app_config.dart';
import 'package:jibeex/my_theme.dart';
import 'package:jibeex/social_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jibeex/custom/input_decorations.dart';
import 'package:jibeex/custom/intl_phone_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:jibeex/addon_config.dart';
import 'package:jibeex/screens/registration.dart';
import 'package:jibeex/screens/main.dart';
import 'package:jibeex/screens/password_forget.dart';
import 'package:jibeex/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:jibeex/repositories/auth_repository.dart';
import 'package:jibeex/helpers/auth_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:jibeex/helpers/shared_value_helper.dart';
import 'package:jibeex/repositories/profile_repositories.dart';

class Login extends StatefulWidget {
  static bool isPopProfile = false;
  bool iswindow;
  Login({bool isProfile = false, this.iswindow = false}) {
    Login.isPopProfile = isProfile;
  }

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _loading = false;
  String _login_by = "email"; //phone or email
  String initialCountry = 'DZ';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'DZ', dialCode: "+213");
  String _phone = "";
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      // you can add extras if you require
    ],
  );
  GoogleSignInAccount _currentUser;
  String ContactText;

  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    try {
      _googleSignIn.disconnect();
    } catch (error) {
      print(error);
    }
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressedLogin() async {
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog("Entrez l'e-mail", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog("Entrez le numéro de téléphone", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (password == "") {
      ToastComponent.showDialog("Entrer le mot de passe", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }
    ToastComponent.showDialog("Verification...", context,
        gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    var loginResponse = await AuthRepository()
        .getLoginResponse(_login_by == 'email' ? email : _phone, password);

    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      AuthHelper().setUserData(loginResponse);
      //go back
      if (Login.isPopProfile) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Main(index: 5); //show profile
              },
              settings: RouteSettings(name: '/Profile'),
            ));
      } else {
        Navigator.pop(context,
            [loginResponse.user.name, _login_by]); //return to the previous page
      }
      // push notification starts
      final FirebaseMessaging _fcm = FirebaseMessaging();
      if (Platform.isIOS) {
        _fcm.requestNotificationPermissions(IosNotificationSettings());
      }
      String fcmToken = await _fcm.getToken();

      if (fcmToken != null) {
        print("--fcm token--");
        print(fcmToken);
        if (is_logged_in.value == true) {
          // update device token
          var deviceTokenUpdateResponse =
              await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
        }
      }
      //push norification ends
    }
  }

  onPressedFacebookLogin() async {
    final facebookLogin = FacebookLogin();
    final facebookLoginResult = await facebookLogin.logIn(['email']);

    /*print(facebookLoginResult.accessToken);
    print(facebookLoginResult.accessToken.token);
    print(facebookLoginResult.accessToken.expires);
    print(facebookLoginResult.accessToken.permissions);
    print(facebookLoginResult.accessToken.userId);
    print(facebookLoginResult.accessToken.isValid());

    print(facebookLoginResult.errorMessage);
    print(facebookLoginResult.status);*/

    final token = facebookLoginResult.accessToken.token;

    /// for profile details also use the below code
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    final profile = json.decode(graphResponse.body);
    //print(profile);
    /*from profile you will get the below params
    {
     "name": "Iiro Krankka",
     "first_name": "Iiro",
     "last_name": "Krankka",
     "email": "iiro.krankka\u0040gmail.com",
     "id": "<user id here>"
    }*/

    var loginResponse = await AuthRepository().getSocialLoginResponse(
        profile['name'], profile['email'], profile['id'].toString());

    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      AuthHelper().setUserData(loginResponse);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Main();
            },
            settings: RouteSettings(name: '/Home'),
          ));
    }
  }

  onPressedGoogleLogin() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        // you can add extras if you require
      ],
    );
    _googleSignIn.signIn().then((GoogleSignInAccount acc) async {
      GoogleSignInAuthentication auth = await acc.authentication;
      print(acc.id);
      print(acc.email);
      print(acc.displayName);
      print(acc.photoUrl);
      setState(() {
        _loading = false;
      });
      acc.authentication.then((GoogleSignInAuthentication auth) async {
        print(auth.idToken);
        print(auth.accessToken);

        //---------------------------------------------------
        var loginResponse = await AuthRepository().getSocialLoginResponse(
            acc.displayName, acc.email, auth.accessToken);

        if (loginResponse.result == false) {
          ToastComponent.showDialog(loginResponse.message, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        } else {
          ToastComponent.showDialog(loginResponse.message, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        }
        AuthHelper().setUserData(loginResponse);
        if (Login.isPopProfile) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Main(index: 4);
                },
                settings: RouteSettings(name: '/Profile'),
              ));
        } else {
          Navigator.pop(context, [acc.displayName, "google"]);
        } //-------------------------------
      });
    });
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _screen_width = MediaQuery.of(context).size.width;
    return widget.iswindow
        ? body(_screen_width)
        : Scaffold(
            backgroundColor: Colors.white,
            body: body(_screen_width),
          );
  }

  Widget body(_screen_width) {
    return Stack(
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Image.asset(
              "assets/splash_login_registration_background_image.png"),
        ),
        Container(
          width: double.infinity,
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: widget.iswindow
                    ? EdgeInsets.all(0)
                    : const EdgeInsets.only(top: 40.0, bottom: 15),
                child: Container(
                  width: widget.iswindow ? 60 : 120,
                  height: widget.iswindow ? 60 : 120,
                  child: Image.asset('assets/login_registration_form_logo.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  "Se connecter à " + AppConfig.app_name,
                  style: TextStyle(
                      color: MyTheme.accent_color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                width: _screen_width * (3 / 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        _login_by == "email" ? "Email" : "Phone",
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_login_by == "email")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 36,
                              child: TextField(
                                controller: _emailController,
                                autofocus: false,
                                decoration:
                                    InputDecorations.buildInputDecoration_1(
                                        hint_text: "johndoe@example.com"),
                              ),
                            ),
                            AddonConfig.otp_addon_installed
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _login_by = "phone";
                                      });
                                    },
                                    child: Text(
                                      "ou, Connectez-vous avec un numéro de téléphone",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 36,
                              child: CustomInternationalPhoneNumberInput(
                                onInputChanged: (PhoneNumber number) {
                                  print(number.phoneNumber);
                                  setState(() {
                                    _phone = number.phoneNumber;
                                  });
                                },
                                onInputValidated: (bool value) {
                                  print(value);
                                },
                                selectorConfig: SelectorConfig(
                                  selectorType: PhoneInputSelectorType.DIALOG,
                                ),
                                ignoreBlank: false,
                                autoValidateMode: AutovalidateMode.disabled,
                                selectorTextStyle:
                                    TextStyle(color: MyTheme.font_grey),
                                textStyle: TextStyle(color: MyTheme.font_grey),
                                initialValue: phoneCode,
                                textFieldController: _phoneNumberController,
                                formatInput: true,
                                keyboardType: TextInputType.numberWithOptions(
                                    signed: true, decimal: true),
                                inputDecoration:
                                    InputDecorations.buildInputDecoration_phone(
                                        hint_text: "01710 333 558"),
                                onSaved: (PhoneNumber number) {
                                  print('On Saved: $number');
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _login_by = "email";
                                });
                              },
                              child: Text(
                                "ou, Connectez-vous avec un e-mail",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "Mot de passe",
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 36,
                            child: TextField(
                              controller: _passwordController,
                              autofocus: false,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration:
                                  InputDecorations.buildInputDecoration_1(
                                      hint_text: "• • • • • • • •"),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return PasswordForget();
                                      },
                                      settings: RouteSettings(
                                          name: '/Forget Password'),
                                    ));
                              },
                              child: Text(
                                "Mot de Passe Oublié?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: FlatButton(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 40,
                        color: Colors.blueGrey[600],
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0))),
                        child: Text(
                          "Connexion",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          onPressedLogin();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Nouveau sur Jibeex?",
                              style: TextStyle(
                                  color: MyTheme.medium_grey, fontSize: 14),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return Registration();
                                      },
                                      settings:
                                          RouteSettings(name: '/Registration'),
                                    ));
                              },
                              child: Text(
                                "Crée un Compte",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                    fontSize: 14),
                              ),
                            ),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                      child: Divider(
                        height: 1.0,
                      ),
                    ),
                    Visibility(
                      visible: SocialConfig.allow_google_login ||
                          SocialConfig.allow_facebook_login,
                      child: Center(
                          child: Text(
                        "Connectez-vous avec",
                        style:
                            TextStyle(color: MyTheme.medium_grey, fontSize: 14),
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 7),
                            height: 47,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0))),
                              color: Colors.red[500],
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                });
                                onPressedGoogleLogin();
                                setState(() {
                                  _loading = true;
                                });
                              },
                              child: Stack(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 23,
                                      height: 23,
                                      child:
                                          Image.asset("assets/google_logo.png"),
                                    ),
                                  ),
                                  Center(
                                    //alignment: Alignment.center,
                                    child: Text(
                                      "Continue Avec Google",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0))),
                              color: Colors.blue[600],
                              onPressed: () {
                                onPressedFacebookLogin();
                              },
                              child: Stack(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 23,
                                      height: 23,
                                      child: Image.asset(
                                          "assets/facebook_logo.png"),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "Continue Avec Facebook",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
        ),
        Visibility(
          visible: _loading,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]),
            ),
          ),
        ),
      ],
    );
  }
}
