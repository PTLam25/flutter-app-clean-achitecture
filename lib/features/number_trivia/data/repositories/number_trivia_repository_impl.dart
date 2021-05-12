import 'package:dartz/dartz.dart';
import 'package:flutter_app_clean_achitecture/core/error/exception.dart';
import 'package:flutter_app_clean_achitecture/core/error/failure.dart';
import 'package:flutter_app_clean_achitecture/core/platform/network_info.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:meta/meta.dart';
// Реализация интерфейса Repository

// создали именной тип функции, чтобы не писать Future<NumberTrivia> Function()
typedef Future<NumberTrivia> _ConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetWorkInfo netWorkInfo;

  NumberTriviaRepositoryImpl({
    @required this.remoteDataSource,
    @required this.localDataSource,
    @required this.netWorkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return await _getTrivia(() {
      return remoteDataSource.getConcreteNumberTrivia(number);
    });
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() {
      return remoteDataSource.getRandomNumberTrivia();
    });
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
      _ConcreteOrRandomChooser getConcreteOrRandom) async {
    if (await netWorkInfo.isConnected) {
      try {
        // получаем данные
        final remoteTrivia = await getConcreteOrRandom();
        // кэшируем данные
        localDataSource.cacheNumberTrivia(remoteTrivia);
        // возвращаем результат
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
