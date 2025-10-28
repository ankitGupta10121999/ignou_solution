import 'package:uuid/uuid.dart';

class CommonUtils {
  static final Uuid _uuid = Uuid();

  static String generateUuid() {
    return _uuid.v4();
  }

  static int getCurrentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}
