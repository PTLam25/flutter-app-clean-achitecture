import 'package:data_connection_checker/data_connection_checker.dart';

abstract class NetWorkInfo {
  // проверяем если ли у пользователя интернет
  Future<bool> get isConnected;
}

class NetWorkInfoImpl implements NetWorkInfo {
  final DataConnectionChecker connectionChecker;

  NetWorkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
