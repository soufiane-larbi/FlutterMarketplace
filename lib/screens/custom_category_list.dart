import 'package:flutter/material.dart';
import 'package:jibeex/my_theme.dart';
import 'package:jibeex/ui_sections/drawer.dart';
import 'package:jibeex/custom/toast_component.dart';
import 'package:jibeex/screens/main.dart';
import 'package:jibeex/services/repo_lists.dart';
import 'package:toast/toast.dart';
import 'package:jibeex/screens/category_products.dart';
import 'package:jibeex/repositories/category_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:jibeex/helpers/shimmer_helper.dart';
import 'dart:async';
import 'package:jibeex/app_config.dart';

class CustomCategoryList extends StatefulWidget {
  @override
  _CustomCategoryListState createState() => _CustomCategoryListState();
}

class _CustomCategoryListState extends State<CustomCategoryList> {
  int _selected;
  String _title;
  ScrollController _scrollController;
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          brightness: Brightness.dark,
          leading: GestureDetector(
              onTap: () {
                setState(() {
                  //Main.currentPage = 3;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Main();
                        },
                        settings: RouteSettings(name: '/Home'),
                      ));
                });
              },
              child: Icon(Icons.arrow_back)),
          centerTitle: true,
          title: Text(
            "Categories",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        //drawer: MainDrawer(),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      //height: 2000,
                      child: buildMainCategories(),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                color: Colors.grey[100],
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width - 120,
                    height: 35,
                    color: Colors.blueGrey[700],
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return CategoryProducts(
                                        category_id: RepositoryLists
                                            .categoriesList[_selected].id,
                                        category_name: RepositoryLists
                                            .categoriesList[_selected].name,
                                      );
                                    },
                                    settings: RouteSettings(
                                        name:
                                            "/Categories/${RepositoryLists.categoriesList[_selected].name}"),
                                  ));
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text(
                                "Voir Touts",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              _title == null
                                  ? "Sous Categories"
                                  : _title.length > 20
                                      ? _title.substring(0, 20) + "..."
                                      : _title,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 123,
                    child:
                        _selected == null ? Container() : buildSubCategories(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 80),
                  ),
                ]),
              ),
            ),
          ],
        ));
  }

  buildMainCategories() {
    if (RepositoryLists.categoriesList.isEmpty) {
      return Container();
    } else if (RepositoryLists.categoriesList.isNotEmpty) {
      if (_selected == null) {
        setState(() {
          _selected = 0;
          _title = RepositoryLists.categoriesList[0].name;
        });
      }
      return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: RepositoryLists.categoriesList.length,
          itemExtent: 60,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selected = index;
                  _title = RepositoryLists.categoriesList[index].name;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selected == index
                      ? Colors.blueGrey[100]
                      : Colors.grey[200],
                  border: Border(
                    left: BorderSide(
                        width: index == _selected ? 5.0 : 0.0,
                        color: Colors.red[400]),
                  ),
                ),
                padding: EdgeInsets.only(left: index == _selected ? 0 : 5),
                child: Center(
                  child: Text(
                    RepositoryLists.categoriesList[index].name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          });
    }
  }

  buildSubCategories() {
    return FutureBuilder(
      future: CategoryRepository().getCategories(
          parent_id: RepositoryLists.categoriesList[_selected].id),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var subCategories = snapshot.data;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            itemCount: subCategories.categories.length,
            padding: EdgeInsets.all(5),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CategoryProducts(
                            category_id: subCategories.categories[index].id,
                            category_name: subCategories.categories[index].name,
                          );
                        },
                        settings: RouteSettings(
                            name:
                                "/Categories/${subCategories.categories[index].name}"),
                      ));
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/placeholder.png',
                          image: AppConfig.BASE_PATH +
                              subCategories.categories[index].icon,
                          fit: BoxFit.fill,
                        ),
                      )),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          subCategories.categories[index].name,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return ShimmerHelper().buildProductGridShimmer(
              scontroller: _scrollController, item_count: 2);
        }
      },
    );
  }
}
