import 'package:jibeex/my_theme.dart';
import 'package:jibeex/screens/cart.dart';
import 'package:jibeex/screens/category_list.dart';
import 'package:jibeex/screens/custom_category_list.dart';
import 'package:jibeex/screens/home.dart';
import 'package:jibeex/screens/profile.dart';
import 'package:jibeex/screens/filter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:jibeex/screens/common_webview_screen.dart';
import 'package:flutter/services.dart';
import 'package:jibeex/app_config.dart';

class Main extends StatefulWidget {
  int index;
  Main({this.index = -1});

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  int _currentIndex = 0;
  bool isPop = true;

  var _children;

  int getIndex() => widget.index < 0 ? _currentIndex : widget.index;

  void initState() {
    // TODO: implement initState
    //re appear statusbar in case it was not there in the previous page
    _currentIndex = getIndex();
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.initState();
    _children = [
      Home(update: (value) {
        setState(() => isPop = value);
      }),
      CustomCategoryList(),
      Filter(),
      Cart(has_bottomnav: true),
      10,
      Profile(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!isPop) {
          FocusScope.of(context).unfocus();
          setState(() {
            isPop = !isPop;
          });
          return !isPop;
        }
        return isPop;
      },
      child: Scaffold(
        extendBody: true,
        body: _children[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 55,
          padding: EdgeInsets.all(0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset(
                                "assets/home.png",
                                color: _currentIndex == 0
                                    ? Theme.of(context).accentColor
                                    : Colors.grey[700],
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Center(
                                  child: Text(
                                    "Accueil",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _currentIndex == 0
                                          ? Theme.of(context).accentColor
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset(
                                "assets/categories.png",
                                color: _currentIndex == 1
                                    ? Theme.of(context).accentColor
                                    : Colors.grey[700],
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Center(
                                  child: Text(
                                    "Catégories",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _currentIndex == 1
                                          ? Theme.of(context).accentColor
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Filter(
                            selected_filter: "brands",
                          );
                        },
                        settings: RouteSettings(name: "/Filter"),
                      ),
                    );
                  },
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blueGrey[700],
                      ),
                      width: 45,
                      height: 45,
                      child: Padding(
                        padding: EdgeInsets.all(7),
                        child: Image.asset(
                          "assets/square_logo.png",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentIndex = 3;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              "assets/cart.png",
                              color: _currentIndex == 3
                                  ? Theme.of(context).accentColor
                                  : Colors.grey[700],
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Center(
                                child: Text(
                                  "Panier",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _currentIndex == 3
                                        ? Theme.of(context).accentColor
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) {
                                  return CommonWebviewScreen(
                                    url: "${AppConfig.RAW_BASE_URL}/blog",
                                    page_name: "Blog",
                                    returnHome: true,
                                  );
                                },
                                settings: RouteSettings(name: '/Blog')),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/blog.png",
                              color: _currentIndex == 4
                                  ? Theme.of(context).accentColor
                                  : Colors.grey[700],
                              height: 22,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Center(
                                child: Text(
                                  "Blog",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _currentIndex == 4
                                        ? Theme.of(context).accentColor
                                        : Colors.grey[700],
                                  ),
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
        ),
      ),
    );
  }
}

// import 'package:jibeex/my_theme.dart';
// import 'package:jibeex/screens/cart.dart';
// import 'package:jibeex/screens/category_list.dart';
// import 'package:jibeex/screens/custom_category_list.dart';
// import 'package:jibeex/screens/home.dart';
// import 'package:jibeex/screens/profile.dart';
// import 'package:jibeex/screens/filter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'dart:ui';
// import 'package:jibeex/screens/common_webview_screen.dart';
// import 'package:flutter/services.dart';
// import 'package:jibeex/app_config.dart';

// class Main extends StatefulWidget {
//   int index;
//   Main({this.index = -1});

//   @override
//   _MainState createState() => _MainState();
// }

// class _MainState extends State<Main> {
//   int _currentIndex = 0;

//   var _children = [
//     Home(),
//     CustomCategoryList(),
//     Filter(),
//     Cart(has_bottomnav: true),
//     Profile(),
//   ];

//   int getIndex() => widget.index < 0 ? _currentIndex : widget.index;
//   void onTapped(int i) {
//     setState(() {
//       //if (widget.index < 0) {
//       _currentIndex = i;
//       //} else {
//       //  _currentIndex = widget.index;
//       //onTapped(widget.index);
//       //widget.index = -1;
//       //}
//     });
//   }

//   void initState() {
//     // TODO: implement initState
//     //re appear statusbar in case it was not there in the previous page
//     _currentIndex = getIndex();
//     SystemChrome.setEnabledSystemUIOverlays(
//         [SystemUiOverlay.top, SystemUiOverlay.bottom]);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       body: _children[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//             // boxShadow: [
//             //   BoxShadow(
//             //     color: Colors.grey.withOpacity(0.5),
//             //     spreadRadius: 5,
//             //     blurRadius: 7,
//             //     offset: Offset(0, 2),
//             //   ),
//             // ],
//             ),
//         height: 55,
//         padding: EdgeInsets.all(0.0),
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Expanded(
//               flex: 5,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 5,
//                       blurRadius: 7,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                   borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(100),
//                     bottomRight: Radius.circular(100),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: InkWell(
//                         onTap: () {
//                           onTapped(0);
//                         },
//                         child: Container(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Image.asset(
//                                 "assets/home.png",
//                                 color: _currentIndex == 0
//                                     ? Theme.of(context).accentColor
//                                     : Colors.grey[700],
//                                 height: 20,
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(2.0),
//                                 child: Center(
//                                   child: Text(
//                                     "Accueil",
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: _currentIndex == 0
//                                           ? Theme.of(context).accentColor
//                                           : Colors.grey[700],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: InkWell(
//                         onTap: () {
//                           onTapped(1);
//                         },
//                         child: Container(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Image.asset(
//                                 "assets/categories.png",
//                                 color: _currentIndex == 1
//                                     ? Theme.of(context).accentColor
//                                     : Colors.grey[700],
//                                 height: 20,
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(2.0),
//                                 child: Center(
//                                   child: Text(
//                                     "Catégories",
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: _currentIndex == 1
//                                           ? Theme.of(context).accentColor
//                                           : Colors.grey[700],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return Filter(
//                           selected_filter: "sellers",
//                         );
//                       },
//                       settings: RouteSettings(name: "/Filter"),
//                     ),
//                   );
//                 },
//                 child: Center(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           spreadRadius: 5,
//                           blurRadius: 7,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                       borderRadius: BorderRadius.circular(100),
//                       color: Colors.blueGrey[700],
//                     ),
//                     width: 45,
//                     height: 45,
//                     child: Padding(
//                       padding: EdgeInsets.all(7),
//                       child: Image.asset(
//                         "assets/square_logo.png",
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 5,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 5,
//                       blurRadius: 7,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(100),
//                     bottomLeft: Radius.circular(100),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: InkWell(
//                         onTap: () {
//                           onTapped(3);
//                         },
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             Image.asset(
//                               "assets/cart.png",
//                               color: _currentIndex == 3
//                                   ? Theme.of(context).accentColor
//                                   : Colors.grey[700],
//                               height: 20,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(2.0),
//                               child: Center(
//                                 child: Text(
//                                   "Panier",
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: _currentIndex == 3
//                                         ? Theme.of(context).accentColor
//                                         : Colors.grey[700],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) {
//                                   return CommonWebviewScreen(
//                                     url: "${AppConfig.RAW_BASE_URL}/blog",
//                                     page_name: "Blog",
//                                   );
//                                 },
//                                 settings: RouteSettings(name: '/Blog')),
//                           );
//                         },
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               "assets/blog.png",
//                               color: _currentIndex == 4
//                                   ? Theme.of(context).accentColor
//                                   : Colors.grey[700],
//                               height: 22,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(2.0),
//                               child: Center(
//                                 child: Text(
//                                   "Blog",
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: _currentIndex == 4
//                                         ? Theme.of(context).accentColor
//                                         : Colors.grey[700],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
