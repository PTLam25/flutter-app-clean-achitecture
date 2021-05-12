import 'package:dartz/dartz.dart';
import 'package:flutter_app_clean_achitecture/core/error/failure.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';

// Реализация интерфейса Repository

class NumberTriviaREpositoryImpl implements NumberTriviaRepository {
  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number) {
    return null();
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() {
    return null();
  }
}
