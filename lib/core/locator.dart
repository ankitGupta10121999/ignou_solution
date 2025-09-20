import 'package:get_it/get_it.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/firestore_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => FirestoreService());
}
