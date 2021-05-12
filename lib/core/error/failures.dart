import 'package:equatable/equatable.dart';

// абстракный класс ошибки для приложения
abstract class Failure extends Equatable {
  final List properties;

  Failure([properties = const <dynamic>[]]) : this.properties = properties;

  @override
  List<Object> get props => [properties];
}
