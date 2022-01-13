import 'package:jibeex/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:jibeex/data_model/category_response.dart';

class CategoryRepository {
  Future<CategoryResponse> getCategories({parent_id = 0}) async {
    final response = await http
        .get("${AppConfig.BASE_URL}/categories?parent_id=${parent_id}");
    //.timeout(const Duration(seconds: 7));
    print("${AppConfig.BASE_URL}/categories?parent_id=${parent_id}");
    print(response.body.toString());
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getFeturedCategories() async {
    final response =
        await http.get("${AppConfig.BASE_URL}/categories/featured");
    //.timeout(const Duration(seconds: 7));
    //print(response.body.toString());
    //print("--featured cat--");
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getTopCategories() async {
    final response = await http.get("${AppConfig.BASE_URL}/categories/top");
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getMainCategories() async {
    final response = await http.get("${AppConfig.BASE_URL}/categories");
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryResponse> getFilterPageCategories() async {
    final response = await http.get("${AppConfig.BASE_URL}/filter/categories");
    //.timeout(const Duration(seconds: 7));
    return categoryResponseFromJson(response.body);
  }
}
