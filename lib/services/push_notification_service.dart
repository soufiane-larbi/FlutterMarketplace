import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jibeex/screens/category_products.dart';
import 'package:jibeex/screens/product_details.dart';
import 'package:jibeex/helpers/shared_value_helper.dart';
import 'package:jibeex/repositories/profile_repositories.dart';
import 'package:one_context/one_context.dart';
import 'package:jibeex/custom/toast_component.dart';
import 'package:toast/toast.dart';

final FirebaseMessaging _fcm = FirebaseMessaging();

class PushNotificationService {
  Future initialise() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      print("--fcm token--");
      print(fcmToken);
      if (is_logged_in.value == true) {
        // update device token
        var deviceTokenUpdateResponse =
            await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
      }
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        OneContext().showDialog(
          // barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Fermer'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text('Ouvrir'),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (message['data']['item_type'] == 'product') {
                    OneContext().push(
                      MaterialPageRoute(
                        builder: (_) {
                          return ProductDetails(
                            id: int.parse(message['data']['item_type_id']),
                          );
                        },
                        settings: RouteSettings(
                            name:
                                "/Products/Push/${message['data']['item_type_id']}"),
                      ),
                    );
                  }
                  if (message['data']['item_type'] == 'category') {
                    OneContext().push(
                      MaterialPageRoute(
                        builder: (_) {
                          return CategoryProducts(
                            category_id:
                                int.parse(message['data']['item_type_id']),
                            category_name: message['notification']['title'],
                          );
                        },
                        settings: RouteSettings(
                            name:
                                "/Categories/Push/${message['data']['item_type_id']}"),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('ffffffffffffffffffff');
        print("onLaunch: $message");
        _serialiseAndNavigate(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('ggggggggggggggggggggg');
        print("onResume: $message");
        _serialiseAndNavigate(message);
      },
    );
  }

  void _serialiseAndNavigate(Map<String, dynamic> message) {
    print(message.toString());
    print('hridoy');
    if (message['data']['item_type'] == 'product') {
      OneContext().push(MaterialPageRoute(builder: (_) {
        return ProductDetails(
          id: int.parse(message['data']['item_type_id']),
        );
      }));
    }
    // If there's no view it'll just open the app on the first view
  }
}
