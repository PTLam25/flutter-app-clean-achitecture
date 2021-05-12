import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app_clean_achitecture/core/error/failure.dart';
import 'package:flutter_app_clean_achitecture/core/usecases/usecase.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:meta/meta.dart';

class GetConcreteNumberTrivia implements UseCase<NumberTrivia, Params> {
  // use case когда пользователь запрашивает данные номера

  // зависим от интерфейса, чтобы можно было вызывать любую реализацию при изменение
  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async {
    return await repository.getConcreteNumberTrivia(params.number);
  }
}

class Params extends Equatable {
  // создали отдельный класс аргумент для use case GetConcreteNumberTrivia,
  // чтобы быть более конкретным, что мы не просто передаем число, а аргмуент для этого use case
  final int number;

  Params({@required this.number});

  @override
  List<Object> get props => [number];
}
