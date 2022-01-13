import 'package:jibeex/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:jibeex/data_model/slider_response.dart';

class SlidersRepository {
  Future<SliderResponse> getSliders() async {
    final response = await http.get("${AppConfig.BASE_URL}/sliders");
    /*print(response.body.toString());
    print("sliders");*/
    return sliderResponseFromJson(response.body);
  }
}
