//Translated
import 'package:jibeex/app_config.dart';
import 'package:jibeex/helpers/shared_value_helper.dart';
import 'package:jibeex/helpers/shimmer_helper.dart';
import 'package:jibeex/my_theme.dart';
import 'package:jibeex/repositories/cart_repository.dart';
import 'package:jibeex/screens/login.dart';
import 'package:jibeex/screens/shipping_info.dart';
import 'package:jibeex/ui_sections/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Cart extends StatefulWidget {
  final bool has_bottomnav;
  Cart({Key key, this.has_bottomnav}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _mainScrollController = ScrollController();
  List<int> _chosenOwnerId = [];
  var _shopList = [];
  bool _isInitial = true;
  var _cartTotal = 0.00;
  var _cartTotalString = ". . .";
  final _priceFormat = NumberFormat.currency(
    decimalDigits: 2,
    locale: 'fr-FR',
    symbol: " ",
    customPattern: "#,###.00",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: MainDrawer(),
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: Container(
          color: Colors.grey[100],
          child: Stack(
            children: [
              RefreshIndicator(
                color: MyTheme.accent_color,
                backgroundColor: Colors.white,
                onRefresh: _onRefresh,
                displacement: 0,
                child: CustomScrollView(
                  controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildCartSellerList(),
                        ),
                        Container(
                          height: widget.has_bottomnav ? 100 : 50,
                        )
                      ]),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: buildBottomContainer(),
              )
            ],
          ),
        ));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      brightness: Brightness.dark,
      backgroundColor: Colors.grey[100],
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          _scaffoldKey.currentState.openDrawer();
        },
        child: Builder(
          builder: (context) => Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 0.0),
            child: Container(
              child: Image.asset(
                'assets/hamburger.png',
                height: 16,
                color: MyTheme.dark_grey,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        "Panier",
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Container buildBottomContainer() {
    return Container(
      height: widget.has_bottomnav ? 175 : 120,
      decoration: BoxDecoration(
          // color: Colors.white,
          ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: MyTheme.soft_accent_color),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Montant total",
                        style:
                            TextStyle(color: MyTheme.font_grey, fontSize: 14),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text("$_cartTotalString",
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: MyTheme.textfield_grey, width: 0),
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(5.0),
                          bottomLeft: const Radius.circular(5.0),
                          topRight: const Radius.circular(0.0),
                          bottomRight: const Radius.circular(0.0),
                        )),
                    child: FlatButton(
                      minWidth: MediaQuery.of(context).size.width,
                      //height: 50,
                      color: MyTheme.light_grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                        topLeft: const Radius.circular(5.0),
                        bottomLeft: const Radius.circular(5.0),
                        topRight: const Radius.circular(0.0),
                        bottomRight: const Radius.circular(0.0),
                      )),
                      child: Text(
                        "Mettre à jour",
                        style: TextStyle(
                            color: MyTheme.medium_grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        onPressUpdate();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 32) * (2 / 3),
                    height: 40,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: MyTheme.textfield_grey, width: 0),
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(0.0),
                          bottomLeft: const Radius.circular(0.0),
                          topRight: const Radius.circular(5.0),
                          bottomRight: const Radius.circular(5.0),
                        )),
                    child: FlatButton(
                      minWidth: MediaQuery.of(context).size.width,
                      //height: 50,
                      color: Colors.red[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                        topLeft: const Radius.circular(0.0),
                        bottomLeft: const Radius.circular(0.0),
                        topRight: const Radius.circular(5.0),
                        bottomRight: const Radius.circular(5.0),
                      )),
                      child: Text(
                        "PASSER AU PAIEMENT",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        onPressProceedToShipping();
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  buildCartSellerItemCard(seller_index, item_index) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: MyTheme.light_grey, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0.0,
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Container(
            width: 100,
            height: 100,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/placeholder.png',
                  image: AppConfig.BASE_PATH +
                      _shopList[seller_index]
                          .cart_items[item_index]
                          .product_thumbnail_image,
                  fit: BoxFit.fitWidth,
                ))),
        Container(
          width: 170,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shopList[seller_index]
                          .cart_items[item_index]
                          .product_name,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w400),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _priceFormat.format(_shopList[seller_index]
                                        .cart_items[item_index]
                                        .price *
                                    _shopList[seller_index]
                                        .cart_items[item_index]
                                        .quantity) +
                                ' DA',
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          height: 28,
                          child: InkWell(
                            onTap: () {},
                            child: IconButton(
                              onPressed: () {
                                onPressDelete(_shopList[seller_index]
                                    .cart_items[item_index]
                                    .id);
                              },
                              icon: Icon(
                                Icons.delete_forever_outlined,
                                color: MyTheme.medium_grey,
                                size: 24,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Icon(
                    Icons.add,
                    color: MyTheme.accent_color,
                    size: 18,
                  ),
                  shape: CircleBorder(
                    side: new BorderSide(color: MyTheme.light_grey, width: 1.0),
                  ),
                  color: Colors.white,
                  onPressed: () {
                    onQuantityIncrease(seller_index, item_index);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  _shopList[seller_index]
                      .cart_items[item_index]
                      .quantity
                      .toString(),
                  style: TextStyle(color: MyTheme.accent_color, fontSize: 16),
                ),
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Icon(
                    Icons.remove,
                    color: MyTheme.accent_color,
                    size: 18,
                  ),
                  height: 30,
                  shape: CircleBorder(
                    side: new BorderSide(color: MyTheme.light_grey, width: 1.0),
                  ),
                  color: Colors.white,
                  onPressed: () {
                    onQuantityDecrease(seller_index, item_index);
                  },
                ),
              )
            ],
          ),
        )
      ]),
    );
  }

  SingleChildScrollView buildCartSellerItemList(seller_index) {
    return SingleChildScrollView(
      child: ListView.builder(
        itemCount: _shopList[seller_index].cart_items.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: buildCartSellerItemCard(seller_index, index),
          );
        },
      ),
    );
  }

  buildCartSellerList() {
    if (is_logged_in.value == false) {
      return Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Container(
              height: 50,
              child: Center(
                  child: Text(
                "Veuillez vous connecter pour voir les articles du panier",
                style: TextStyle(color: MyTheme.font_grey),
              ))),
        ),
        FlatButton(
          minWidth: MediaQuery.of(context).size.width,
          height: 40,
          color: Colors.blueGrey[600],
          shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5.0))),
          child: Text(
            "S'identifier",
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            //onPressedLogin();
            //..if (_login) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Login();
                },
                settings: RouteSettings(name: '/Login'),
              ),
            ).then((value) => onPopped(value));
            // }
          },
        ),
      ]);
    } else if (_isInitial && _shopList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_shopList.length > 0) {
      return SingleChildScrollView(
        child: ListView.builder(
          itemCount: _shopList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.storefront),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(
                              _shopList[index].name,
                              style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              partialTotalString(index),
                              style: TextStyle(
                                  color: MyTheme.accent_color, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildCartSellerItemList(index),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else if (!_isInitial && _shopList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            "Le panier est vide",
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  confirmDelete(cart_id) async {
    var cartDeleteResponse =
        await CartRepository().getCartDeleteResponse(cart_id);

    if (cartDeleteResponse.result == true) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(cartDeleteResponse.message),
        ),
      );
      reset();
      fetchData();
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(cartDeleteResponse.message),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  fetchData() async {
    var cartResponseList =
        await CartRepository().getCartResponseList(user_id.value);

    if (cartResponseList != null && cartResponseList.length > 0) {
      _shopList = cartResponseList;
      cartResponseList.forEach((cart) {
        _chosenOwnerId.add(cart.owner_id);
      });
    }
    _isInitial = false;
    getSetCartTotal();
    setState(() {});
  }

  getSetCartTotal() {
    _cartTotal = 0.00;
    if (_shopList.length > 0) {
      _shopList.forEach((shop) {
        if (shop.cart_items.length > 0) {
          shop.cart_items.forEach((cart_item) {
            _cartTotal +=
                (cart_item.price + cart_item.tax) * cart_item.quantity;
            _cartTotalString =
                "${_priceFormat.format(_cartTotal)} ${cart_item.currency_symbol}";
          });
        }
      });
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*print("user data");
    print(is_logged_in.value);
    print(access_token.value);
    print(user_id.value);
    print(user_name.value);*/

    if (is_logged_in.value == true) {
      fetchData();
    }
  }

  onPopped(value) async {
    reset();
    fetchData();
  }

  onPressDelete(cart_id) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  "Êtes-vous sûr de supprimer cet élément",
                  maxLines: 3,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
                ),
              ),
              actions: [
                FlatButton(
                  child: Text(
                    "Annuler",
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                FlatButton(
                  color: MyTheme.soft_accent_color,
                  child: Text(
                    "Confirmer",
                    style: TextStyle(color: MyTheme.dark_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    confirmDelete(cart_id);
                  },
                ),
              ],
            ));
  }

  onPressProceedToShipping() {
    process(mode: "proceed_to_shipping");
  }

  onPressUpdate() {
    process(mode: "update");
  }

  onQuantityDecrease(seller_index, item_index) {
    if (_shopList[seller_index].cart_items[item_index].quantity >
        _shopList[seller_index].cart_items[item_index].lower_limit) {
      _shopList[seller_index].cart_items[item_index].quantity--;
      getSetCartTotal();
      setState(() {});
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            "Cannot order less than ${_shopList[seller_index].cart_items[item_index].lower_limit} item(s) of this",
          ),
        ),
      );
    }
  }

  onQuantityIncrease(seller_index, item_index) {
    if (_shopList[seller_index].cart_items[item_index].quantity <
        _shopList[seller_index].cart_items[item_index].upper_limit) {
      _shopList[seller_index].cart_items[item_index].quantity++;
      getSetCartTotal();
      setState(() {});
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            "Cannot order more than ${_shopList[seller_index].cart_items[item_index].upper_limit} item(s) of this",
          ),
        ),
      );
    }
  }

  partialTotalString(index) {
    var partialTotal = 0.00;
    var partialTotalString = "";
    if (_shopList[index].cart_items.length > 0) {
      _shopList[index].cart_items.forEach((cart_item) {
        partialTotal += (cart_item.price + cart_item.tax) * cart_item.quantity;
        partialTotalString =
            "${_priceFormat.format(partialTotal)} ${cart_item.currency_symbol}";
      });
    }

    return partialTotalString;
  }

  process({mode}) async {
    var cart_ids = [];
    var cart_quantities = [];
    if (_shopList.length > 0) {
      _shopList.forEach((shop) {
        if (shop.cart_items.length > 0) {
          shop.cart_items.forEach((cart_item) {
            cart_ids.add(cart_item.id);
            cart_quantities.add(cart_item.quantity);
          });
        }
      });
    }

    if (cart_ids.length == 0) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Le panier est vide"),
        ),
      );

      return;
    }

    var cart_ids_string = cart_ids.join(',').toString();
    var cart_quantities_string = cart_quantities.join(',').toString();

    print(cart_ids_string);
    print(cart_quantities_string);

    var cartProcessResponse = await CartRepository()
        .getCartProcessResponse(cart_ids_string, cart_quantities_string);

    if (cartProcessResponse.result == false) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(cartProcessResponse.message),
        ),
      );
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(cartProcessResponse.message),
        ),
      );

      if (mode == "update") {
        reset();
        fetchData();
      } else if (mode == "proceed_to_shipping") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ShippingInfo(
                owner_id: _chosenOwnerId,
              );
            },
            settings: RouteSettings(name: '/Shipping Info'),
          ),
        ).then(
          (value) {
            onPopped(value);
          },
        );
      }
    }
  }

  reset() {
    _chosenOwnerId = [];
    _shopList = [];
    _isInitial = true;
    _cartTotal = 0.00;
    _cartTotalString = ". . .";

    setState(() {});
  }

  void _handleSellerRadioValueChange(value) {
    setState(() {
      _chosenOwnerId = value;
    });
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }
}
