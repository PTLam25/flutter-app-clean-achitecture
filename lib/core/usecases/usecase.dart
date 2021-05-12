import 'package:dartz/dartz.dart';
import 'package:flutter_app_clean_achitecture/core/error/failure.dart';

// Абстракный класс (интерфейс) UseCase, чтобы быть уверенными, что все UseCase соблюдают одинаковый интерфейс.
// Мы создали generic UseCase<Type, Params>, чтобы в нем можно было указать результат возврата и параметр в функции call, тем самым сделав его универсальным
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
