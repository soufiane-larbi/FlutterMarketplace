import 'package:get_it/get_it.dart';
import 'package:jibeex/services/analytics.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AnalyticsService());
}
