import 'package:jibeex/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:jibeex/screens/product_details.dart';
import 'package:jibeex/app_config.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:jibeex/repositories/product_repository.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'dart:ui';

class ProductCard extends StatefulWidget {
  int id;
  String image;
  String name;
  String main_price;
  String stroked_price;
  bool has_discount;
  String category;

  ProductCard({
    Key key,
    this.id,
    this.image,
    this.name,
    this.main_price,
    this.stroked_price,
    this.has_discount,
    this.category,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  TextEditingController sellerChatTitleController = TextEditingController();

  var _productDetails;
  fetchProductDetails() async {
    var productDetailsResponse =
        await ProductRepository().getProductDetails(id: widget.id);

    if (productDetailsResponse.detailed_products.length > 0) {
      _productDetails = productDetailsResponse.detailed_products[0];
      sellerChatTitleController.text =
          productDetailsResponse.detailed_products[0].name;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print((MediaQuery.of(context).size.width - 48) / 2);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ProductDetails(
                  id: widget.id,
                  category: widget.category,
                );
              },
              settings: RouteSettings(name: "/Products/${widget.name}"),
            ));
      },
      child: Card(
        elevation: 0.0,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.red,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: AppConfig.BASE_PATH + widget.image,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),

              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(6, 0, 3, 0),
                      child: Text(
                        widget.name,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 12,
                            height: 1.2,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: Column(
                        children: [
                          widget.has_discount
                              ? Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Text(
                                    widget.stroked_price,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: MyTheme.medium_grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.only(bottom: 6),
                                ),
                          Padding(
                            padding: EdgeInsets.all(0),
                            child: Text(
                              widget.main_price,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: MyTheme.accent_color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //buildRatingAndWishButtonRow(),
                  ],
                ),
              ),
              //),
            ]),
      ),
    );
  }

  buildRatingAndWishButtonRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            RatingBar(
              itemSize: 16.0,
              ignoreGestures: true,
              //initialRating: double.parse(_productDetails.rating.toString()),
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              ratingWidget: RatingWidget(
                full: Icon(FontAwesome.star, color: Colors.amber),
                half: Icon(FontAwesome.star, color: Colors.amber),
                empty: Icon(FontAwesome.star,
                    color: Color.fromRGBO(224, 224, 225, 1)),
              ),
              itemPadding: EdgeInsets.only(right: 1.0),
              onRatingUpdate: (rating) {
                //print(rating);
              },
            ),
            /*Container(
              width: 70,
              height: 17,
              child: Center(
                child: FlatButton(
                  height: 10,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      "Acheter",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () {
                    //onPressBuyNow(context);
                  },
                ),
              ),
            )*/
          ],
        ),
      ),
    );
  }
}
