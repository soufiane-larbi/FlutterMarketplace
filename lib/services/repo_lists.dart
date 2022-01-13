import 'package:jibeex/repositories/product_repository.dart';
import 'package:jibeex/repositories/sliders_repository.dart';
import 'package:jibeex/repositories/category_repository.dart';
import 'package:jibeex/repositories/brand_repository.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';

import 'package:jibeex/screens/home.dart';

class RepositoryLists {
  static var carouselImageList = [];
  static List<dynamic> categoriesList = [];
  static List<dynamic> categoriesListShufled = [];
  static List<dynamic> featuredProductsList = [];
  static List<dynamic> bestSellingProductsList = [];
  static List<dynamic> brandsList = [];
  static List<dynamic> shopsList = [];
  static List<dynamic> products = [];
  static Map remoteConfigJson;
  static Map<int, List<dynamic>> productsList = {};
  static RemoteConfig remoteConfig;
  static var loadedBlocks = 0;

  static Future<bool> getRemoteConfig() async {
    try {
      remoteConfig = await RemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
            fetchTimeoutMillis: 10000, minimumFetchIntervalMillis: 3600000),
      );
      await remoteConfig.fetch(expiration: Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfigJson = json.decode(
        remoteConfig.getValue("Layout").asString(),
      );
      List<dynamic> temp = [];
      temp.addAll(remoteConfigJson['layout']);
      for (int i = 0; i < temp.length; i++) {
        if (temp[i]['ui'] == 'grid') {
          var productReponse = await ProductRepository()
              .getFilteredProducts(categories: temp[i]['id']);
          productsList[i] = productReponse.products;
        }
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  static fetchSlider() async {
    var sliderResponse = await SlidersRepository().getSliders();
    if (sliderResponse.sliders.length > 0) {
      sliderResponse.sliders.forEach((slider) {
        carouselImageList.add(slider.photo);
      });
      loadedBlocks++;
    }
  }

  static fetchCategory() async {
    var featuredCategoryResponse =
        await CategoryRepository().getMainCategories();
    categoriesList.addAll(featuredCategoryResponse.categories);
    categoriesListShufled.addAll(featuredCategoryResponse.categories);
    categoriesListShufled.shuffle();
    loadedBlocks++;
  }

  static fetchFeaturedProduct() async {
    var featuredProductResponse =
        await ProductRepository().getFeaturedProducts();
    featuredProductsList.addAll(featuredProductResponse.products);
    featuredProductsList.shuffle();
    loadedBlocks++;
  }

  static fetchBestSelling() async {
    var bestSellingResponse =
        await ProductRepository().getBestSellingProducts();
    bestSellingProductsList.addAll(bestSellingResponse.products);
    bestSellingProductsList.shuffle();
    loadedBlocks++;
  }

  static fetchBrands() async {
    var brandsResponse = await BrandRepository().getBrands();
    brandsList.addAll(brandsResponse.brands);
    brandsList.shuffle();
    loadedBlocks++;
  }

  static resetData() {
    loadedBlocks = 0;
    clearData();
    fetchData();
  }

  static clearData() {
    loadedBlocks = 0;
    carouselImageList.clear();
    categoriesList.clear();
    categoriesListShufled.clear();
    featuredProductsList.clear();
    bestSellingProductsList.clear();
    brandsList.clear();
    shopsList.clear();
    products.clear();
    remoteConfigJson.clear();
    productsList.clear();
  }

  static fetchData() async {
    fetchSlider();
    fetchCategory();
    fetchFeaturedProduct();
    fetchBestSelling();
    fetchBrands();
  }
}
