import 'package:jibeex/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jibeex/helpers/shared_value_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:jibeex/data_model/clubpoint_response.dart';
import 'package:jibeex/data_model/clubpoint_to_wallet_response.dart';

class ClubpointRepository {
  Future<ClubpointResponse> getClubPointListResponse(
      {@required page = 1}) async {
    final response = await http.get(
      "${AppConfig.BASE_URL}/clubpoint/get-list/${user_id.value}?page=$page",
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.value}"
      },
    );
    print(response.body.toString());
    return clubpointResponseFromJson(response.body);
  }

  Future<ClubpointToWalletResponse> getClubpointToWalletResponse(
      @required int id) async {
    var post_body = jsonEncode({
      "id": "${id}",
      "user_id": "${user_id.value}",
    });
    final response =
        await http.post("${AppConfig.BASE_URL}/clubpoint/convert-into-wallet",
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${access_token.value}"
            },
            body: post_body);

    return clubpointToWalletResponseFromJson(response.body);
  }
}
