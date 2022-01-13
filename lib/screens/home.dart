import 'package:jibeex/my_theme.dart';
import 'package:jibeex/screens/filter.dart';
import 'package:jibeex/screens/flash_deal_list.dart';
import 'package:jibeex/screens/main.dart';
import 'package:jibeex/screens/todays_deal_products.dart';
import 'package:jibeex/screens/top_selling_products.dart';
import 'package:jibeex/screens/login.dart';
import 'package:jibeex/screens/category_products.dart';
import 'package:jibeex/services/repo_lists.dart';
import 'package:jibeex/screens/custom_category_list.dart';
import 'package:jibeex/ui_sections/drawer.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:jibeex/repositories/product_repository.dart';
import 'package:jibeex/app_config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:jibeex/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:jibeex/ui_elements/product_card.dart';
import 'package:jibeex/helpers/shimmer_helper.dart';
import 'package:jibeex/helpers/shared_value_helper.dart';
import 'dart:async';
import 'product_details.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jibeex/data_model/product_mini_response.dart';
import 'brand_products.dart';
import 'package:jibeex/screens/profile_window.dart';
import 'package:jibeex/helpers/auth_helper.dart';
import 'package:jibeex/main.dart';

class Home extends StatefulWidget {
  Home({
    Key key,
    this.title,
    this.show_back_button = false,
    @required this.update,
  }) : super(key: key);
  final String title;
  Function update;
  bool show_back_button;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _current_slider = 0;
  List _sliderCategoris = ["214", "117", "115", "238"];
  ScrollController _featuredProductScrollController;
  ScrollController _scrollController = ScrollController();
  int _pageNumber = 0;
  bool _init = true;
  int _lastpage = 2;
  int _timerCount = 0;
  bool _onSearch = false;
  bool _searching = false;
  bool _netError = false;
  List<dynamic> _allProducts = [];
  List<int> _allProductsPages = [];
  Map<int, ProductMiniResponse> _searchList = {};
  AnimationController pirated_logo_controller;
  Animation pirated_logo_animation;
  int _counter = -1;
  List<dynamic> _layout = [];
  Map<String, List<dynamic>> repoFormat = {
    'featured_products': RepositoryLists.featuredProductsList,
    'best_selling': RepositoryLists.bestSellingProductsList,
  };
  FocusNode _searchBarFocus = FocusNode();

  final _searchcontroller = TextEditingController();
  search() async {
    _counter++;
    setState(() {
      _searching = true;
    });
    _searchList[_counter] = await ProductRepository()
        .getFilteredProducts(name: _searchcontroller.text);
    setState(() {
      _searching = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // In initState()
    //fetchData();
    //ReposioryLists.fetchData();
    getProducts();
    netError();
    _init = false;
    _layout.addAll(RepositoryLists.remoteConfigJson['layout']);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _pageNumber++;
        if (_pageNumber < _lastpage) {
          getProducts();
          setState(() {});
        }
      }
    });
    _searchBarFocus.addListener(() {
      if (!_searchBarFocus.hasFocus) {
        setState(() {
          _searchcontroller.clear();
          _searchList.clear();
          _onSearch = false;
        });
      }
    });
    if (!AppConfig.updatedAlert) {
      Timer(
        Duration(seconds: 3),
        () {
          try {
            if (RepositoryLists.remoteConfig.getValue('Build').asInt() >
                int.parse(AppConfig.packageInfo.buildNumber)) {
              AppConfig.updatedAlert = true;
              updateAvailable();
            }
          } catch (error) {
            print(error);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pirated_logo_controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_netError) {
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
            FlatButton(
              color: Colors.grey[200],
              child: Text("Réessayer"),
              onPressed: () {
                refresh();
                setState(() {});
              },
            )
          ]),
        ),
      );
    } else {
      final double statusBarHeight = MediaQuery.of(context).padding.top;
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: buildAppBar(statusBarHeight, context),
        drawer: MainDrawer(),
        body: GestureDetector(
          onTap: () {
            _searchcontroller.clear();
            _searchList.clear();
            _onSearch = false;
            widget.update(true);
            setState(
              () {},
            );
          },
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () {
                  return refresh();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            4.0,
                            0.0,
                            0.0,
                          ),
                          child: buildHomeCarouselSlider(context),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Center(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: RepositoryLists.carouselImageList.map(
                                (url) {
                                  int index = RepositoryLists.carouselImageList
                                      .indexOf(url);
                                  return Container(
                                    width:
                                        _current_slider == index ? 21.0 : 7.0,
                                    height: 7.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      //shape: BoxShape,
                                      borderRadius: BorderRadius.circular(4.0),
                                      color: _current_slider == index
                                          ? Colors.blueGrey[300]
                                          : Colors.blueGrey[200],
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          8.0,
                          4.0,
                          8.0,
                          0.0,
                        ),
                        child: buildHomeMenuRow(context),
                      ),
                      Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _layout.map((lay) {
                            int index = _layout.indexOf(lay);
                            return getLayoutList(
                                ui: lay['ui'],
                                index: index,
                                repo: lay['repo'],
                                title: lay['name'],
                                banner: lay['banner'],
                                id: lay['id']);
                          }).toList(),
                        ),
                      ),
                      buildGridAllProducts(),
                      _pageNumber > _lastpage
                          ? Container(
                              color: Colors.red[100],
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                                  child: Text(
                                    "Pas Plus Produits",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          0.0,
                          80.0,
                          0.0,
                          0.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                curve: Curves.easeInToLinear,
                duration: Duration(milliseconds: 450),
                height: _onSearch ? MediaQuery.of(context).size.height : 0,
                color: Colors.white,
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: _searchList[_counter] != null &&
                          _searchList[_counter].meta.to != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children:
                              (_searchList[_counter].products as List<dynamic>)
                                  .map((list) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ProductDetails(id: list.id);
                                }));
                              },
                              child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  alignment: Alignment.centerLeft,
                                  height: 47,
                                  child: Row(
                                    children: [
                                      Text(
                                        list.name.length > 45
                                            ? list.name.substring(0, 45) + '...'
                                            : list.name,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Image.network(
                                            AppConfig.BASE_PATH +
                                                list.thumbnail_image),
                                      )
                                    ],
                                  )),
                            );
                          }).toList(),
                        )
                      : Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(top: 50),
                                  child: _searchList[_counter] != null
                                      ? Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 70,
                                                width: 70,
                                                child: Image.asset(
                                                  'assets/search_broken.png',
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Aucun produit correspondant pour ',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  Text(
                                                    _searchcontroller.text +
                                                        '.',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                ),
                              )
                            ],
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  Future refresh() async {
    setState(() {
      _netError = false;
      _timerCount = 0;
    });
    RepositoryLists.resetData();
    _allProducts.clear();
    getProducts();
    _pageNumber = 0;
    _lastpage = 1;
    netError();
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _timerCount++;
      if (_timerCount <= 4) {
        if (_timerCount == 6 && RepositoryLists.loadedBlocks < 5) {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text("La connexion internet est très lente"),
            ),
          );
        }
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  netError() {
    Timer(Duration(seconds: 10), () {
      if (RepositoryLists.loadedBlocks < 5) {
        setState(() {
          _netError = true;
        });
      }
    });
  }

  Widget getLayoutList({ui, repo, title, banner, index, id}) {
    if (ui == 'list') {
      if (repo.contains('categories')) {
        return buildCustomGridCategory();
      } else {
        return buildListProducts(repoFormat[repo], title: title);
      }
    }
    if (ui == 'grid') {
      List<dynamic> l = [];
      try {
        l.addAll(RepositoryLists.productsList[index]);
        return buildGridProducts(repo: l, title: title, id: id);
      } catch (error) {
        print('Error: ' + error.toString());
        return Container();
      }
    }
    if (ui == 'help') {
      return buildCategoriesHelp();
    }
    if (ui == 'image') {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Filter(
                  showFilter: false,
                  selected_category: repo,
                );
              },
              settings: RouteSettings(name: '/Category:' + repo),
            ),
          );
        },
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/placeholder.png',
          height: 160,
          image: banner,
          fit: BoxFit.cover,
        ),
      );
    }
    if (ui == 'brand') {
      return buildGridBrands(RepositoryLists.brandsList);
    }
    if (ui == 'sponsor') {
      return Container(); //TODO
    }
    return Container();
  }

  updateAvailable() async {
    Widget cancelButton = TextButton(
      child: Text("Anuller"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Installer"),
      onPressed: () async {
        const url =
            'https://drive.google.com/file/d/101CBLm82M_h_5LenzIWiN8icC5my64WK/view';
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          ToastComponent.showDialog(
              "Login to google dirve first then retry.", context,
              gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Mise à jour disponible!"),
      content: Text(
          "Une version plus récente est disponible pour le téléchargement"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  sponsoredVendor() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(5),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(60),
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            // gradient: LinearGradient(
            //   List: [
            //     Colors.blueGrey[700].withOpacity(0.95),
            //     Colors.blueGrey[300].withOpacity(0.9),
            //   ],
            //   begin: Alignment.bottomLeft,
            //   end: Alignment.centerRight,
            // ),
          ),
          child: Container(
            margin: EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Demo Jibeex Store",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
                Expanded(
                  child: Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 120,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded oneGridLongCategory({String name, banner, color, id}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return CategoryProducts(
                    category_id: id,
                    category_name: name,
                  );
                },
                settings: RouteSettings(name: '/Categories'),
              ));
        },
        child: Card(
          elevation: 0.0,
          color: color,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.length > 13 ? name.substring(0, 13) + '..' : name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text('Nouvelle Arrivage'),
                    Expanded(
                      child: Icon(
                        Icons.storefront,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Expanded(child: Container()),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: AppConfig.BASE_PATH + banner,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded oneGridSmallCategory({String name, banner, color, id}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return CategoryProducts(
                    category_id: id,
                    category_name: name,
                  );
                },
                settings: RouteSettings(name: '/Categories'),
              ));
        },
        child: Card(
          elevation: 0.0,
          color: color,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: AppConfig.BASE_PATH + banner,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Text(
                  name.length > 14 ? name.substring(0, 13) + '..' : name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildCustomGridCategory() {
    if (RepositoryLists.categoriesListShufled.isEmpty) {
      return ShimmerHelper().buildCategoryGridShimmer(
        scontroller: _featuredProductScrollController,
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.only(right: 4, left: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        height: 215,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(right: 8, left: 8),
              height: 35,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Top Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) {
                  //         return Filter(selected_filter: ,);
                  //       }),
                  //     );
                  //   },
                  //   child: Text(
                  //     "Clique pour Voirs Plus ",
                  //   ),
                  // ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Row(
                children: [
                  oneGridLongCategory(
                    name: RepositoryLists.categoriesListShufled[0].name,
                    id: RepositoryLists.categoriesListShufled[0].id,
                    banner: RepositoryLists.categoriesListShufled[0].banner,
                    color: Colors.red[50].withOpacity(0.8),
                  ),
                  oneGridLongCategory(
                    name: RepositoryLists.categoriesListShufled[1].name,
                    id: RepositoryLists.categoriesListShufled[1].id,
                    banner: RepositoryLists.categoriesListShufled[1].banner,
                    color: Colors.blue[50].withOpacity(0.8),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 12,
              child: Row(
                children: [
                  oneGridSmallCategory(
                    name: RepositoryLists.categoriesListShufled[2].name,
                    id: RepositoryLists.categoriesListShufled[2].id,
                    banner: RepositoryLists.categoriesListShufled[2].banner,
                    color: Colors.green[50].withOpacity(0.8),
                  ),
                  oneGridSmallCategory(
                    name: RepositoryLists.categoriesListShufled[3].name,
                    id: RepositoryLists.categoriesListShufled[3].id,
                    banner: RepositoryLists.categoriesListShufled[3].banner,
                    color: Colors.indigo[50].withOpacity(0.8),
                  ),
                  oneGridSmallCategory(
                    name: RepositoryLists.categoriesListShufled[4].name,
                    id: RepositoryLists.categoriesListShufled[4].id,
                    banner: RepositoryLists.categoriesListShufled[4].banner,
                    color: Colors.yellow[50].withOpacity(0.8),
                  ),
                  oneGridSmallCategory(
                    name: RepositoryLists.categoriesListShufled[5].name,
                    id: RepositoryLists.categoriesListShufled[5].id,
                    banner: RepositoryLists.categoriesListShufled[5].banner,
                    color: Colors.brown[50].withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  buildGridProducts({List repo, title, id}) {
    if (repo.isEmpty) {
      return ShimmerHelper().buildProductGridShimmer(
          scontroller: _featuredProductScrollController);
    } else if (repo.isNotEmpty) {
      //snapshot.hasData
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.only(right: 4, left: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(right: 8, left: 8),
              height: 35,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) {
                              return Filter(
                                showFilter: false,
                                selected_category: id,
                              );
                            },
                            settings: RouteSettings(name: "/P-${title}")),
                      );
                    },
                    child: Text(
                      "Voirs Plus ",
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              // 2
              //addAutomaticKeepAlives: true,
              itemCount: repo.length > 9 ? 9 : repo.length,
              controller: _featuredProductScrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.75),
              //crossAxisSpacing: 10,
              //mainAxisSpacing: 10,
              //childAspectRatio: 0.618),
              padding: EdgeInsets.all(5),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // 3
                return ProductCard(
                  category: id,
                  id: repo[index].id,
                  image: repo[index].thumbnail_image,
                  name: repo[index].name,
                  main_price: repo[index].main_price,
                  stroked_price: repo[index].stroked_price,
                  has_discount: repo[index].has_discount,
                );
              },
            ),
          ],
        ),
      );
    }
  }

  buildListProducts(List repo, {title}) {
    if (repo.isEmpty) {
      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
        ],
      );
    } else if (repo.isNotEmpty) {
      return Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 4.0, left: 4),
        child: Container(
          margin: EdgeInsets.only(top: 4, left: 4, right: 0, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 8, left: 8),
                height: 35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Spacer(),
                    Icon(
                      Icons.keyboard_arrow_left_rounded,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ),
              Container(
                height: 155,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: repo.length > 10 ? 10 : repo.length,
                  itemExtent: 115,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      id: repo[index].id,
                      image: repo[index].thumbnail_image,
                      name: repo[index].name,
                      main_price: repo[index].main_price,
                      stroked_price: repo[index].stroked_price,
                      has_discount: repo[index].has_discount,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  buildHomeMenuRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CustomCategoryList(
                        //is_top_category: true,
                        );
                  },
                  settings: RouteSettings(name: '/Categories'),
                ));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red[500],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        "assets/top_categories.png",
                        color: Colors.white,
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Catégories",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(132, 132, 132, 1),
                        fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Filter(
                      showFilter: false,
                      selected_filter: "brands",
                    );
                  },
                  settings: RouteSettings(name: '/Brands'),
                ));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green[600].withGreen(420),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        "assets/brands.png",
                        color: Colors.white,
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Marques",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(132, 132, 132, 1),
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return TopSellingProducts();
                  },
                  settings: RouteSettings(name: '/Top Selling'),
                ));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber[500],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        "assets/top_sellers.png",
                        color: Colors.white,
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Top Ventes",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(132, 132, 132, 1),
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return TodaysDealProducts();
                  },
                  settings: RouteSettings(name: '/Today\'s Deals'),
                ));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepOrange[400].withAlpha(485),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        "assets/todays_deal.png",
                        color: Colors.white,
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Offre du jour",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return FlashDealList();
                  },
                  settings: RouteSettings(name: '/Flash Deals'),
                ));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[600],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        "assets/flash_deal.png",
                        color: Colors.white,
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Offre éclair",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        )
      ],
    );
  }

  buildHomeCarouselSlider(context) {
    if (RepositoryLists.carouselImageList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Shimmer.fromColors(
          baseColor: MyTheme.shimmer_base,
          highlightColor: MyTheme.shimmer_highlighted,
          child: Container(
            height: 120,
            width: double.infinity,
            color: Colors.white,
          ),
        ),
      );
    } else if (RepositoryLists.carouselImageList.isNotEmpty) {
      return CarouselSlider(
        options: CarouselOptions(
            aspectRatio: 2.67,
            viewportFraction: 0.94,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.fastLinearToSlowEaseIn,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _current_slider = index;
              });
            }),
        items: RepositoryLists.carouselImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(right: 3.0, left: 3.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Filter(
                                    showFilter: false,
                                    selected_category:
                                        _sliderCategoris[_current_slider],
                                  );
                                },
                                settings: RouteSettings(name: '/Categories'),
                              ));
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/placeholder_rectangle.png',
                              image: AppConfig.BASE_PATH + i,
                              fit: BoxFit.fill,
                            )),
                      )),
                ],
              );
            },
          );
        }).toList(),
      );
    } else {
      return Container();
    }
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      brightness: Brightness.dark,
      backgroundColor: Colors.blueGrey[700],
      leading: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState.openDrawer();
        },
        child: _onSearch
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _searchcontroller.clear();
                    _onSearch = false;
                    widget.update(true);
                    _searchList.clear();
                  });
                },
              )
            : Container(
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                child: Image.asset(
                  'assets/hamburger.png',
                  color: Colors.white,
                ),
              ),
      ),
      title: Container(
        //alignment: Alignment.centerLeft,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: buildHomeSearchBox(context),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GestureDetector(
            onTap: () async {
              var result = await buildProfileWindow();
              if (result != null) {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text("Bienvenu(e) ${result[0]}"),
                    duration: Duration(seconds: 3),
                  ),
                );
                MyApp.analytics.logEvent(
                  name: 'login_method',
                  parameters: {
                    'method': result[1],
                  },
                );
              }
              setState(() {});
            },
            child: Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 270),
                curve: Curves.decelerate,
                width: _onSearch ? 0 : 40,
                height: _onSearch ? 0 : 40,
                child: is_logged_in.value == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(100.0)),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/placeholder.png',
                          image:
                              AppConfig.BASE_PATH + "${avatar_original.value}",
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          color: Colors.blue[100],
                          child: Image.asset(
                            "assets/profile.png",
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildGridBrands(repo) {
    if (repo.isEmpty) {
      return ShimmerHelper().buildProductGridShimmer(
          scontroller: _featuredProductScrollController);
    } else if (repo.isNotEmpty) {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.only(right: 4, left: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(right: 8, left: 8),
              height: 35,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Top Marques",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) {
                              return Filter(
                                selected_filter: 'brands',
                                showFilter: false,
                              );
                            },
                            settings: RouteSettings(name: '/Filter')),
                      );
                    },
                    child: Text(
                      "Voirs Plus ",
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              // 2
              //addAutomaticKeepAlives: true,
              itemCount: repo.length > 8 ? 8 : repo.length,
              controller: _featuredProductScrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              //crossAxisSpacing: 10,
              //mainAxisSpacing: 10,
              //childAspectRatio: 0.618),
              padding: EdgeInsets.all(5),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0.0,
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return BrandProducts(
                              id: repo[index].id,
                              brand_name: repo[index].name,
                            );
                          },
                          settings: RouteSettings(
                              name: '/Category:' + repo[index].name),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 4, right: 4, bottom: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              child: Image.network(
                                  AppConfig.BASE_PATH + repo[index].logo),
                            ),
                          ),
                          Text(
                            repo[index].name,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
  }

  buildHomeSearchBox(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 10,
          child: TextField(
            toolbarOptions: ToolbarOptions(
                copy: true, paste: true, cut: true, selectAll: true),
            textAlignVertical: TextAlignVertical.center,
            onTap: () {
              widget.update(false);
              _searchList.clear();
              _onSearch = true;
              setState(
                () {},
              );
            },
            onChanged: (txt) {
              search();
            },
            focusNode: _searchBarFocus,
            controller: _searchcontroller,
            autofocus: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Chercher!",
              hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[600],
                size: 20,
              ),
              contentPadding: EdgeInsets.only(bottom: 10),
            ),
          ),
        ),
        _searching && _onSearch
            ? Container(
                padding: EdgeInsets.only(right: 12),
                height: 15,
                width: 27,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]),
                  strokeWidth: 2,
                ),
              )
            : Container(),
      ],
    );
  }

  getProducts() async {
    var res;
    if (_allProductsPages.isEmpty) {
      res = await ProductRepository().getFilteredProducts();
      for (int i = 1; i <= res.meta.lastPage; i++) {
        _allProductsPages.add(i);
      }
      _allProductsPages.shuffle();
      _lastpage = _allProductsPages.length;
    }
    res = await ProductRepository()
        .getFilteredProducts(page: _allProductsPages[_pageNumber]);
    _allProducts.addAll(res.products);
    if (_pageNumber > 1) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Chargement des produits"),
        ),
      );
    }
  }

  buildGridAllProducts() {
    if (_allProducts.isNotEmpty) {
      return Container(
        padding: EdgeInsets.only(
          top: 18,
        ),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(left: 16),
              //height: 23,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Touts les Produits",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Container(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    mainAxisSpacing: 7,
                    crossAxisSpacing: 7),
                // controller: _scrollController,
                itemCount: _allProducts.length,
                padding: EdgeInsets.all(16),
                //controller: _featuredProductScrollController,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: ProductCard(
                        id: _allProducts[index].id,
                        image: _allProducts[index].thumbnail_image,
                        name: _allProducts[index].name,
                        main_price: _allProducts[index].main_price,
                        stroked_price: _allProducts[index].stroked_price,
                        has_discount: _allProducts[index].has_discount),
                  );
                },
              ),
            )
          ],
        ),
      );
    } else {
      return ShimmerHelper().buildProductGridShimmer(
          scontroller: _featuredProductScrollController, item_count: 2);
    }
  }

  Widget buildCategoriesHelp() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.grey[100],
      child: Container(
        height: 285,
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.only(right: 4, left: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(right: 8, left: 8),
              height: 35,
              alignment: Alignment.centerLeft,
              child: Text(
                "Pour Vous Aider à Choisir",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              height: 250,
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/smartphone.gif',
                          height: 250,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 1),
                              decoration: BoxDecoration(
                                color: Colors.indigo[100],
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/refrigerator.gif',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(top: 1),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/refrigerator.gif',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/smartphone.gif',
                          height: 250,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildProfileWindow() {
    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: is_logged_in.value == false
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(bottom: 5, top: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                Icons.close_fullscreen,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                            ),
                          ),
                          Container(
                            width: 45,
                            height: 45,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100.0)),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/placeholder.png',
                                image:
                                    AppConfig.BASE_PATH + avatar_original.value,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${user_name.value}",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: MyTheme.font_grey,
                                    fontWeight: FontWeight.w600),
                              ),
                              user_email.value != "" && user_email.value != null
                                  ? Text(
                                      "${user_email.value}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: MyTheme.medium_grey,
                                      ),
                                    )
                                  : Text(
                                      "${user_phone.value}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: MyTheme.medium_grey,
                                      ),
                                    ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                Icons.logout,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
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
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
              content: is_logged_in.value == false
                  ? Container(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 0),
                            width: 400,
                            height: 550,
                            child: Login(
                              iswindow: true,
                            ),
                          ),
                          Container(
                            height: 50,
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(
                                Icons.close_fullscreen,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 300,
                      child: ProfileWindow(),
                    ),
              contentPadding: EdgeInsets.all(0),
              titlePadding: EdgeInsets.all(8),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }
}
