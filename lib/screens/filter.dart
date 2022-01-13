import 'package:jibeex/my_theme.dart';
import 'package:jibeex/screens/seller_details.dart';
import 'package:flutter/material.dart';
import 'package:jibeex/ui_elements/product_card.dart';
import 'package:jibeex/ui_elements/shop_square_card.dart';
import 'package:jibeex/ui_elements/brand_square_card.dart';
import 'package:toast/toast.dart';
import 'package:jibeex/custom/toast_component.dart';
import 'package:jibeex/repositories/category_repository.dart';
import 'package:jibeex/repositories/brand_repository.dart';
import 'package:jibeex/repositories/shop_repository.dart';
import 'package:jibeex/helpers/reg_ex_inpur_formatter.dart';
import 'package:jibeex/repositories/product_repository.dart';
import 'package:jibeex/helpers/shimmer_helper.dart';
import 'package:jibeex/data_model/shop_response.dart';
import 'package:jibeex/data_model/brand_response.dart';
import 'package:jibeex/data_model/product_mini_response.dart';

class WhichFilter {
  String option_key;
  String name;

  WhichFilter(this.option_key, this.name);

  static List<WhichFilter> getWhichFilterList() {
    return <WhichFilter>[
      WhichFilter('product', 'Produit'),
      WhichFilter('sellers', 'Vendeur'),
      WhichFilter('brands', 'Marque'),
    ];
  }
}

class Filter extends StatefulWidget {
  Filter({
    Key key,
    this.selected_filter = "product",
    this.selected_category,
    this.showFilter = true,
  }) : super(key: key);
  final String selected_category;
  final String selected_filter;
  final bool showFilter;

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');

  ScrollController _productScrollController = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController _scrollController;
  WhichFilter _selectedFilter;
  String _givenSelectedFilterOptionKey; // may be it can come from another page
  var _selectedSort = "";
  List<WhichFilter> _which_filter_list = WhichFilter.getWhichFilterList();
  List<DropdownMenuItem<WhichFilter>> _dropdownWhichFilterItems;
  List<dynamic> _selectedCategories = [];
  List<dynamic> _selectedBrands = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = new TextEditingController();
  final TextEditingController _maxPriceController = new TextEditingController();

  //--------------------
  List<dynamic> _filterBrandList = List();
  List<dynamic> _filterCategoryList = List();

  //----------------------------------------
  String _searchKey = "";
  List<dynamic> _productList = [];
  int _productPage = 1;
  bool _showProductLoadingContainer = false;

  List<dynamic> _brandList = [];
  int _brandPage = 1;
  int _totalBrandData = 0;
  bool _showBrandLoadingContainer = false;

  List<dynamic> _shopList = [];
  int _shopPage = 1;
  int _totalShopData = 0;
  bool _showShopLoadingContainer = false;
  int _counter = 0;
  Map<int, dynamic> _searchList = {};
  //----------------------------------------

  fetchFilteredBrands() async {
    var filteredBrandResponse = await BrandRepository().getBrands();
    _filterBrandList.addAll(filteredBrandResponse.brands);
    setState(() {});
  }

  fetchFilteredCategories() async {
    var filteredCategoriesResponse =
        await CategoryRepository().getFilterPageCategories();
    _filterCategoryList.addAll(filteredCategoriesResponse.categories);
    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _productScrollController.dispose();
    super.dispose();
  }

  init() {
    _givenSelectedFilterOptionKey = widget.selected_filter;

    _dropdownWhichFilterItems =
        buildDropdownWhichFilterItems(_which_filter_list);
    _selectedFilter = _dropdownWhichFilterItems[0].value;

    for (int x = 0; x < _dropdownWhichFilterItems.length; x++) {
      if (_dropdownWhichFilterItems[x].value.option_key ==
          _givenSelectedFilterOptionKey) {
        _selectedFilter = _dropdownWhichFilterItems[x].value;
      }
    }

    fetchFilteredCategories();
    fetchFilteredBrands();

    //set scroll listeners

    _productScrollController.addListener(() async {
      if (_productScrollController.position.pixels ==
          _productScrollController.position.maxScrollExtent) {
        _productPage++;
        _brandPage++;
        _shopPage++;
        await search(same: true);
      }
    });
  }

  search({same = false}) async {
    if (same) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Chargement..."),
          duration: Duration(seconds: 1),
        ),
      );
    }

    _counter = same ? _searchList.length - 1 : _searchList.length;
    if (_selectedFilter.option_key == "sellers") {
      if (same) {
        List<Shop> temp = [];
        temp.addAll(_searchList[_counter]);
        temp.addAll(await onSearchShop());

        _searchList[_counter] = temp;
      } else {
        _searchList[_counter] = await onSearchShop();
      }
    } else if (_selectedFilter.option_key == "brands") {
      if (same) {
        List<Brands> temp = [];
        temp.addAll(_searchList[_counter]);
        temp.addAll(await onSearchBrand());
        _searchList[_counter] = temp;
      } else {
        _searchList[_counter] = await onSearchBrand();
      }
    } else {
      if (same) {
        List<Product> temp = [];
        temp.addAll(_searchList[_counter]);
        temp.addAll(await onSearchProduct());
        _searchList[_counter] = temp;
      } else {
        _searchList[_counter] = await onSearchProduct();
      }
    }
    setState(() {});
  }

  Future<List<Product>> onSearchProduct() async {
    var res = await ProductRepository().getFilteredProducts(
      page: _productPage,
      name: _searchController.text,
      sort_key: _selectedSort,
      brands: _selectedBrands.join(",").toString(),
      categories: widget.selected_category == null
          ? _selectedCategories.join(",").toString()
          : widget.selected_category,
      max: _maxPriceController.text.toString(),
      min: _minPriceController.text.toString(),
    );
    return res.products;
  }

  Future<List<Brands>> onSearchBrand() async {
    _showBrandLoadingContainer = false;
    var res = await BrandRepository()
        .getBrands(page: _brandPage, name: _searchController.text);
    return res.brands;
  }

  Future<List<Shop>> onSearchShop() async {
    _showShopLoadingContainer = false;
    var res = await ShopRepository()
        .getShops(page: _shopPage, name: _searchController.text);
    return res.shops;
  }

  List<DropdownMenuItem<WhichFilter>> buildDropdownWhichFilterItems(
      List which_filter_list) {
    List<DropdownMenuItem<WhichFilter>> items = List();
    for (WhichFilter which_filter_item in which_filter_list) {
      items.add(
        DropdownMenuItem(
          value: which_filter_item,
          child: Text(which_filter_item.name),
        ),
      );
    }
    return items;
  }

  Widget buildProductLoadingContainer() {
    return Container(
      height: _showProductLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
            false ? "Pas plus de produits" : "Chargement plus de produits..."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: buildFilterDrawer(),
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      body: Stack(overflow: Overflow.visible, children: [
        buildProductList(),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: buildAppBar(context),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: buildProductLoadingContainer(),
        ),
      ]),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        brightness: Brightness.dark,
        automaticallyImplyLeading: false,
        actions: [
          new Container(),
        ],
        backgroundColor: Colors.white,
        centerTitle: false,
        flexibleSpace: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: Column(
            children: [buildTopAppbar(context), buildBottomAppBar(context)],
          ),
        ));
  }

  Row buildBottomAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Visibility(
          visible: widget.showFilter,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                    vertical: BorderSide(color: MyTheme.light_grey, width: .5),
                    horizontal:
                        BorderSide(color: MyTheme.light_grey, width: 1))),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            height: 36,
            width: MediaQuery.of(context).size.width * .33,
            child: Center(
              child: new DropdownButton<WhichFilter>(
                icon: Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Icon(Icons.expand_more, color: Colors.black54),
                ),
                hint: Text(
                  "Produits",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
                iconSize: 14,
                underline: SizedBox(),
                value: _selectedFilter,
                items: _dropdownWhichFilterItems,
                onChanged: (WhichFilter selectedFilter) async {
                  _selectedFilter = selectedFilter;
                  setState(() {
                    _productPage = 1;
                    _shopPage = 1;
                    _brandPage = 1;
                  });
                  await search();
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.showFilter,
          child: GestureDetector(
            onTap: () {
              _selectedFilter.option_key == "product"
                  ? _scaffoldKey.currentState.openEndDrawer()
                  : ToastComponent.showDialog(
                      "Vous pouvez utiliser des filtres lors de la recherche de produits.",
                      context,
                      gravity: Toast.CENTER,
                      duration: Toast.LENGTH_LONG);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.symmetric(
                      vertical:
                          BorderSide(color: MyTheme.light_grey, width: .5),
                      horizontal:
                          BorderSide(color: MyTheme.light_grey, width: 1))),
              height: 36,
              width: MediaQuery.of(context).size.width * .34,
              child: Center(
                  child: Container(
                width: 50,
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 13,
                    ),
                    SizedBox(width: 2),
                    Text(
                      "Filtre",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _selectedFilter.option_key == "product"
                  ? showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            contentPadding: EdgeInsets.only(
                                top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(left: 24.0),
                                      child: Text(
                                        "Trier les produits par",
                                      )),
                                  RadioListTile(
                                    dense: true,
                                    value: "",
                                    groupValue: _selectedSort,
                                    activeColor: MyTheme.font_grey,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Défaut'),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSort = value;
                                      });
                                      Navigator.pop(context);
                                      search();
                                    },
                                  ),
                                  RadioListTile(
                                    dense: true,
                                    value: "price_high_to_low",
                                    groupValue: _selectedSort,
                                    activeColor: MyTheme.font_grey,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Prix ​​élevé à bas'),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSort = value;
                                      });
                                      Navigator.pop(context);
                                      search();
                                    },
                                  ),
                                  RadioListTile(
                                    dense: true,
                                    value: "price_low_to_high",
                                    groupValue: _selectedSort,
                                    activeColor: MyTheme.font_grey,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Prix ​​croissant'),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSort = value;
                                      });
                                      Navigator.pop(context);
                                      search();
                                    },
                                  ),
                                  RadioListTile(
                                    dense: true,
                                    value: "new_arrival",
                                    groupValue: _selectedSort,
                                    activeColor: MyTheme.font_grey,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Nouvelle arrivee'),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSort = value;
                                      });
                                      Navigator.pop(context);
                                      search();
                                    },
                                  ),
                                  RadioListTile(
                                    dense: true,
                                    value: "popularity",
                                    groupValue: _selectedSort,
                                    activeColor: MyTheme.font_grey,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Popularité'),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSort = value;
                                      });
                                      Navigator.pop(context);
                                      search();
                                    },
                                  ),
                                  RadioListTile(
                                    dense: true,
                                    value: "top_rated",
                                    groupValue: _selectedSort,
                                    activeColor: MyTheme.font_grey,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Les mieux notés'),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSort = value;
                                      });
                                      Navigator.pop(context);
                                      search();
                                    },
                                  ),
                                ],
                              );
                            }),
                            actions: [
                              FlatButton(
                                child: Text(
                                  "Fermer",
                                  style: TextStyle(color: MyTheme.medium_grey),
                                ),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                              ),
                            ],
                          ))
                  : ToastComponent.showDialog(
                      "Vous pouvez utiliser le tri lors de la recherche de produits.",
                      context,
                      gravity: Toast.CENTER,
                      duration: Toast.LENGTH_LONG);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.symmetric(
                      vertical:
                          BorderSide(color: MyTheme.light_grey, width: .5),
                      horizontal:
                          BorderSide(color: MyTheme.light_grey, width: 1))),
              height: 36,
              width: MediaQuery.of(context).size.width * .33,
              child: Center(
                  child: Container(
                width: 50,
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_vert,
                      size: 13,
                    ),
                    SizedBox(width: 2),
                    Text(
                      "Sorte",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ),
        )
      ],
    );
  }

  Row buildTopAppbar(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .6,
            child: Container(
              child: TextField(
                onTap: () {},
                controller: _searchController,
                onSubmitted: (txt) {
                  _searchKey = txt;
                  setState(() {});
                  setState(() {});
                },
                onChanged: (txt) {
                  setState(() {
                    _shopPage = 1;
                    _brandPage = 1;
                    _productPage = 1;
                  });
                  search();
                },
                decoration: InputDecoration(
                    hintText: "Cherche ici!",
                    hintStyle: TextStyle(
                        fontSize: 12.0, color: MyTheme.textfield_grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyTheme.white, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyTheme.white, width: 0.0),
                    ),
                    contentPadding: EdgeInsets.all(0.0)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 7.0),
            child: IconButton(
                icon: Icon(Icons.search, color: MyTheme.dark_grey),
                onPressed: () {
                  _searchKey = _searchController.text.toString();
                  setState(() {});
                }),
          ),
        ]);
  }

  Drawer buildFilterDrawer() {
    return Drawer(
      child: Container(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Container(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Échelle des prix",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            height: 30,
                            width: 100,
                            child: TextField(
                              controller: _minPriceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_amountValidator],
                              decoration: InputDecoration(
                                  hintText: "Minimum",
                                  hintStyle: TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(5.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 2.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(5.0),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(4.0)),
                            ),
                          ),
                        ),
                        Text(" - "),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            height: 30,
                            width: 100,
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_amountValidator],
                              decoration: InputDecoration(
                                  hintText: "Maximum",
                                  hintStyle: TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(5.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 2.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(5.0),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(4.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Catégories",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _filterCategoryList.length == 0
                        ? Container(
                            height: 100,
                            child: Center(
                              child: Text(
                                "Aucune catégorie disponible",
                                style: TextStyle(color: MyTheme.font_grey),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: buildFilterCategoryList(),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Marques",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _filterBrandList.length == 0
                        ? Container(
                            height: 100,
                            child: Center(
                              child: Text(
                                "Aucune marque disponible",
                                style: TextStyle(color: MyTheme.font_grey),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: buildFilterBrandsList(),
                          ),
                  ]),
                )
              ]),
            ),
            Container(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    color: Color.fromRGBO(234, 67, 53, 1),
                    shape: RoundedRectangleBorder(
                      side:
                          new BorderSide(color: MyTheme.light_grey, width: 2.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      "Supprimer",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      _minPriceController.clear();
                      _maxPriceController.clear();
                      _selectedCategories.clear();
                      _selectedBrands.clear();
                      setState(() {});
                      await search();
                      setState(() {});
                    },
                  ),
                  FlatButton(
                    color: Color.fromRGBO(52, 168, 83, 1),
                    child: Text(
                      "Appliquer",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      var min = _minPriceController.text.toString();
                      var max = _maxPriceController.text.toString();
                      bool apply = true;
                      if (min != "" && max != "") {
                        if (max.compareTo(min) < 0) {
                          ToastComponent.showDialog(
                              "Le prix minimum ne peut pas être supérieur au prix maximum",
                              context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_LONG);
                          apply = false;
                        }
                      }

                      if (apply) {
                        await search();

                        setState(() {});
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView buildFilterBrandsList() {
    return ListView(
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        ..._filterBrandList
            .map(
              (brand) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(brand.name),
                value: _selectedBrands.contains(brand.id),
                onChanged: (bool value) {
                  if (value) {
                    setState(() {
                      _selectedBrands.add(brand.id);
                    });
                  } else {
                    setState(() {
                      _selectedBrands.remove(brand.id);
                    });
                  }
                },
              ),
            )
            .toList()
      ],
    );
  }

  ListView buildFilterCategoryList() {
    return ListView(
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        ..._filterCategoryList
            .map(
              (category) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(category.name),
                value: _selectedCategories.contains(category.id),
                onChanged: (bool value) {
                  if (value) {
                    setState(() {
                      _selectedCategories.clear();
                      _selectedCategories.add(category.id);
                    });
                  } else {
                    setState(() {
                      _selectedCategories.remove(category.id);
                    });
                  }
                },
              ),
            )
            .toList()
      ],
    );
  }

  Container buildProductList() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: buildProductScrollableList(),
          )
        ],
      ),
    );
  }

  buildProductScrollableList() {
    if (_searchList[_counter] == null) {
      search();
      return Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top + 100,
        ),
        child: SingleChildScrollView(
            controller: _scrollController,
            child: ShimmerHelper().buildSquareGridShimmer(
                scontroller: _scrollController, cross: 2, item_count: 10)),
      );
    } else {
      //search(same: true);
      return RefreshIndicator(
        color: Colors.grey[100],
        backgroundColor: MyTheme.accent_color,
        onRefresh: () async {
          return true;
        },
        child: SingleChildScrollView(
          controller: _productScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Container(
            color: Colors.grey[100],
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top + 100,
                  //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                ),
                buildSearchResult(),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget buildSearchResult() {
    return GridView.builder(
      itemCount: _searchList[_counter].length,
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        mainAxisSpacing: _selectedFilter.option_key == 'product' ? 7 : 0,
        crossAxisSpacing: _selectedFilter.option_key == 'product' ? 7 : 0,
      ),
      padding: EdgeInsets.all(16),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (_selectedFilter.option_key == 'product') {
          return Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ProductCard(
                id: _searchList[_counter][index].id,
                image: _searchList[_counter][index].thumbnail_image,
                name: _searchList[_counter][index].name,
                main_price: _searchList[_counter][index].main_price,
                stroked_price: _searchList[_counter][index].stroked_price,
                has_discount: _searchList[_counter][index].has_discount),
          );
        } else if (_selectedFilter.option_key == 'brands') {
          return BrandSquareCard(
            id: _searchList[_counter][index].id,
            image: _searchList[_counter][index].logo,
            name: _searchList[_counter][index].name,
          );
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SellerDetails();
                    },
                    settings: RouteSettings(name: "/Seller Details"),
                  ));
            },
            child: ShopSquareCard(
              id: _searchList[_counter][index].id,
              image: _searchList[_counter][index].logo,
              name: _searchList[_counter][index].name,
            ),
          );
        }
      },
    );
  }
}
