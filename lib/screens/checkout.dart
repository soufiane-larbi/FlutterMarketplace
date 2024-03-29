import 'package:flutter/material.dart';
import 'package:jibeex/my_theme.dart';
import 'package:jibeex/screens/order_list.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:jibeex/helpers/shared_value_helper.dart';
import 'package:jibeex/repositories/payment_repository.dart';
import 'package:jibeex/repositories/cart_repository.dart';
import 'package:jibeex/repositories/coupon_repository.dart';
import 'package:jibeex/helpers/shimmer_helper.dart';
import 'package:jibeex/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:jibeex/main.dart';

class Checkout extends StatefulWidget {
  List<int> owner_id;

  Checkout({Key key, this.owner_id}) : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  var _selected_payment_method = "";
  var _selected_payment_method_key = "";

  ScrollController _mainScrollController = ScrollController();
  TextEditingController _couponController = TextEditingController();
  var _paymentTypeList = [];
  bool _isInitial = true;
  var _totalString = 0.00;
  var _grandTotalValue = 0.00;
  var _subTotalString = 0.00;
  var _taxString = 0.00;
  var _shippingCostString = 0.00;
  var _discountString = 0.00;
  var _used_coupon_code = "";
  var _coupon_applied = false;
  final _priceFormat = NumberFormat.currency(
    decimalDigits: 2,
    locale: 'fr-FR',
    symbol: "",
    customPattern: "#,##0.00",
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*print("user data");
    print(is_logged_in.value);
    print(access_token.value);
    print(user_id.value);
    print(user_name.value);*/

    fetchAll();
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  fetchAll() {
    fetchList();

    if (is_logged_in.value == true) {
      fetchSummary();
    }
  }

  fetchList() async {
    var paymentTypeResponseList =
        await PaymentRepository().getPaymentResponseList();
    _paymentTypeList.addAll(paymentTypeResponseList);
    if (_paymentTypeList.length > 0) {
      _selected_payment_method = _paymentTypeList[0].payment_type;
      _selected_payment_method_key = _paymentTypeList[0].payment_type_key;
    }
    _isInitial = false;
    setState(() {});
  }

  fetchSummary() async {
    for (int i = 0; i < widget.owner_id.length; i++) {
      var cartSummaryResponse =
          await CartRepository().getCartSummaryResponse(widget.owner_id[i]);
      if (cartSummaryResponse != null) {
        _used_coupon_code = cartSummaryResponse.coupon_code;
        _couponController.text = _used_coupon_code;
        _coupon_applied = cartSummaryResponse.coupon_applied;
        _taxString += double.parse(cartSummaryResponse.tax
            .substring(0, cartSummaryResponse.tax.length - 6));
        _shippingCostString += double.parse(cartSummaryResponse.shipping_cost
            .substring(0, cartSummaryResponse.shipping_cost.length - 6));
        _discountString = double.parse(cartSummaryResponse.discount
            .substring(0, cartSummaryResponse.discount.length - 6));
        _grandTotalValue =
            _grandTotalValue + cartSummaryResponse.grand_total_value;

        setState(() {
          _subTotalString = _grandTotalValue - _shippingCostString - _taxString;
          _totalString = _grandTotalValue;
        });
      }
    }
  }

  reset() {
    _paymentTypeList.clear();
    _isInitial = true;
    _selected_payment_method = "";
    _selected_payment_method_key = "";
    setState(() {});

    reset_summary();
  }

  reset_summary() {
    _totalString = 0.00;
    _grandTotalValue = 0.00;
    _subTotalString = 0.00;
    _taxString = 0.00;
    _shippingCostString = 0.00;
    _discountString = 0.00;
    _used_coupon_code = "";
    _couponController.text = _used_coupon_code;
    _coupon_applied = false;

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) {
    reset();
    fetchAll();
  }

  onCouponApply() async {
    var coupon_code = _couponController.text.toString();
    if (coupon_code == "") {
      ToastComponent.showDialog("Entrer le code promotionnel", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }
    bool couponError = false;
    widget.owner_id.forEach(
      (owner) async {
        var couponApplyResponse =
            await CouponRepository().getCouponApplyResponse(owner, coupon_code);
        if (couponApplyResponse.result == false) {
          couponError = true;
          return;
        }
      },
    );

    if (couponError) {
      ToastComponent.showDialog("Coupon non valide", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }
    reset_summary();
    fetchSummary();
  }

  onCouponRemove() async {
    bool couponError = false;
    widget.owner_id.forEach(
      (owner) async {
        var couponRemoveResponse =
            await CouponRepository().getCouponRemoveResponse(owner);

        if (couponRemoveResponse.result == false) {
          couponError = true;
          return;
        }
      },
    );
    if (couponError) {
      ToastComponent.showDialog("Ereur", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    reset_summary();
    fetchSummary();
  }

  onPressPlaceOrder() {
    if (_selected_payment_method == "") {
      ToastComponent.showDialog(
          "Veuillez choisir une option pour payer", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }
    if (_selected_payment_method == "wallet_system") {
      pay_by_wallet();
    } else if (_selected_payment_method == "cash_payment") {
      pay_by_cod();
    }
  }

  pay_by_wallet() async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromWallet(
            widget.owner_id[0], _selected_payment_method_key, _grandTotalValue);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return OrderList(from_checkout: true);
          },
          settings: RouteSettings(name: "/Cart"),
        ));
  }

  pay_by_cod() async {
    bool paymentError = false;
    widget.owner_id.forEach(
      (owner) async {
        var orderCreateResponse = await PaymentRepository()
            .getOrderCreateResponseFromCod(owner, _selected_payment_method_key);

        if (orderCreateResponse.result == false) {
          paymentError = true;
          return;
        }
      },
    );
    if (paymentError) {
      ToastComponent.showDialog("Erreur de payment", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      Navigator.of(context).pop();
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return OrderList(from_checkout: true);
          },
          settings: RouteSettings(name: "/Cart"),
        ));
  }

  onPaymentMethodItemTap(index) {
    if (_selected_payment_method != _paymentTypeList[index].payment_type) {
      setState(() {
        _selected_payment_method = _paymentTypeList[index].payment_type;
        _selected_payment_method_key = _paymentTypeList[index].payment_type_key;
      });
    }
  }

  onPressDetails() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                child: Container(
                  height: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            //width: 120,
                            child: Text(
                              "Sous Total",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Spacer(),
                          Text(
                            _priceFormat.format(_subTotalString) + ' DA',
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 0.35,
                      ),
                      Row(
                        children: [
                          Container(
                            // width: 120,
                            child: Text(
                              "Tax",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Spacer(),
                          Text(
                            _priceFormat.format(_taxString) + ' DA',
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 0.35,
                      ),
                      Row(
                        children: [
                          Container(
                            //width: 120,
                            child: Text(
                              "Frais de livraison",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Spacer(),
                          Text(
                            _priceFormat.format(_shippingCostString) + ' DA',
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 0.35,
                      ),
                      Row(
                        children: [
                          Container(
                            //width: 120,
                            child: Text(
                              "Remise",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Spacer(),
                          Text(
                            _priceFormat.format(_discountString) + ' DA',
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.red,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              //width: 120,
                              child: Text(
                                "Total",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: MyTheme.font_grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Spacer(),
                            Text(
                              _priceFormat.format(_totalString) + " DA",
                              style: TextStyle(
                                  color: MyTheme.accent_color,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                FlatButton(
                  child: Text(
                    "Fermer",
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        bottomNavigationBar: buildBottomAppBar(context),
        body: Stack(
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
                        padding: const EdgeInsets.all(16.0),
                        child: buildPaymentMethodList(),
                      ),
                      Container(
                        height: 140,
                      )
                    ]),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  /*border: Border(
                    top: BorderSide(color: MyTheme.light_grey,width: 1.0),
                  )*/
                ),
                height: 140,
                //color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: buildApplyCouponRow(context),
                      ),
                      Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: MyTheme.soft_accent_color),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  "Montant total",
                                  style: TextStyle(
                                      color: MyTheme.font_grey, fontSize: 14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    onPressDetails();
                                  },
                                  child: Text(
                                    "Voir les détails",
                                    style: TextStyle(
                                      color: MyTheme.font_grey,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                    _priceFormat.format(_totalString) + ' DA',
                                    style: TextStyle(
                                        color: MyTheme.accent_color,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Row buildApplyCouponRow(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: (MediaQuery.of(context).size.width - 32) * (2 / 3),
          child: TextFormField(
            controller: _couponController,
            readOnly: _coupon_applied,
            autofocus: false,
            decoration: InputDecoration(
                hintText: "Code de réduction",
                hintStyle:
                    TextStyle(fontSize: 14.0, color: MyTheme.textfield_grey),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.textfield_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    bottomLeft: const Radius.circular(8.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.medium_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    bottomLeft: const Radius.circular(8.0),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 16.0)),
          ),
        ),
        !_coupon_applied
            ? Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: FlatButton(
                  minWidth: MediaQuery.of(context).size.width,
                  //height: 50,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(8.0),
                    bottomRight: const Radius.circular(8.0),
                  )),
                  child: Text(
                    "APPLIQUER",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponApply();
                  },
                ),
              )
            : Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: FlatButton(
                  minWidth: MediaQuery.of(context).size.width,
                  //height: 50,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(8.0),
                    bottomRight: const Radius.circular(8.0),
                  )),
                  child: Text(
                    "Supprimer",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponRemove();
                  },
                ),
              )
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      brightness: Brightness.dark,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "Paiement",
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildPaymentMethodList() {
    if (_isInitial && _paymentTypeList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_paymentTypeList.length > 0) {
      return SingleChildScrollView(
        child: ListView.builder(
          itemCount: _paymentTypeList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: buildPaymentMethodItemCard(index),
            );
          },
        ),
      );
    } else if (!_isInitial && _paymentTypeList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            "Aucun mode de paiement n'est ajouté",
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  GestureDetector buildPaymentMethodItemCard(index) {
    return GestureDetector(
      onTap: () {
        onPaymentMethodItemTap(index);
      },
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              side: _selected_payment_method ==
                      _paymentTypeList[index].payment_type
                  ? BorderSide(color: MyTheme.accent_color, width: 2.0)
                  : BorderSide(color: MyTheme.light_grey, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: 100,
                      height: 100,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child:
                              /*Image.asset(
                          _paymentTypeList[index].image,
                          fit: BoxFit.fitWidth,
                        ),*/
                              FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder.png',
                            image: _paymentTypeList[index].image,
                            fit: BoxFit.fitWidth,
                          ))),
                  Container(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            _paymentTypeList[index].title,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: buildPaymentMethodCheckContainer(_selected_payment_method ==
                _paymentTypeList[index].payment_type),
          )
        ],
      ),
    );
  }

  Container buildPaymentMethodCheckContainer(bool check) {
    return check
        ? Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0), color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(FontAwesome.check, color: Colors.white, size: 10),
            ),
          )
        : Container();
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Container(
        color: Colors.transparent,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
              minWidth: MediaQuery.of(context).size.width,
              height: 50,
              color: MyTheme.accent_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Text(
                "VALIDER LA COMMANDE",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                onPressPlaceOrder();
                MyApp.analytics.logEcommercePurchase(
                  value: _totalString,
                  currency: "DA",
                  shipping: _shippingCostString,
                  tax: _taxString,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
