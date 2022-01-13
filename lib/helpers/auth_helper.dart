import 'package:jibeex/helpers/shared_value_helper.dart';

class AuthHelper {
  setUserData(loginResponse, {photo = null}) {
    if (loginResponse.result == true) {
      is_logged_in.value = true;
      access_token.value = loginResponse.access_token;
      user_id.value = loginResponse.user.id;
      user_name.value = loginResponse.user.name;
      user_email.value = loginResponse.user.email;
      user_phone.value = photo == null ? loginResponse.user.phone : photo;
      avatar_original.value =
          photo == null ? loginResponse.user.avatar_original : photo;
    }
  }

  clearUserData() {
    is_logged_in.value = false;
    access_token.value = "";
    user_id.value = 0;
    user_name.value = "";
    user_email.value = "";
    user_phone.value = "";
    avatar_original.value = "";
  }
}
