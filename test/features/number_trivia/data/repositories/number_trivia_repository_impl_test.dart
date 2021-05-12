import 'package:dartz/dartz.dart';
import 'package:flutter_app_clean_achitecture/core/error/exception.dart';
import 'package:flutter_app_clean_achitecture/core/error/failure.dart';
import 'package:flutter_app_clean_achitecture/core/platform/network_info.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetWorkInfo extends Mock implements NetWorkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetWorkInfo mockNetWorkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetWorkInfo = MockNetWorkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      netWorkInfo: mockNetWorkInfo,
    );
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      setUp(
        () {
          when(mockNetWorkInfo.isConnected).thenAnswer((_) async => true);
        },
      );

      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      setUp(
        () {
          when(mockNetWorkInfo.isConnected).thenAnswer((_) async => false);
        },
      );

      body();
    });
  }

  group(
    'getConcreteNumberTrivia',
    () {
      final testNumber = 1;
      final testNumberTriviaModel = NumberTriviaModel(
        text: "test trivia",
        number: testNumber,
      );
      final NumberTrivia testNumberTrivia = testNumberTriviaModel;

      test(
        'should check if the device is online',
        () async {
          // arrange
          when(mockNetWorkInfo.isConnected).thenAnswer((_) async => true);

          // act
          repository.getConcreteNumberTrivia(testNumber);

          // assert
          // подтверждаем, что было вызов mockNetWorkInfo.isConnected при тесте выше
          verify(mockNetWorkInfo.isConnected);
        },
      );

      runTestOnline(
        () {
          setUp(
            () {
              when(mockNetWorkInfo.isConnected).thenAnswer((_) async => true);
            },
          );

          test(
            'should return remote data when the call to remote data source is successful',
            () async {
              // arrange
              when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                  .thenAnswer((_) async => testNumberTriviaModel);

              // act
              final result =
                  await repository.getConcreteNumberTrivia(testNumber);

              // assert
              // подтверждаем, что было repository.getConcreteNumberTrivia вызвался с аргументом testNumber при тесте
              verify(mockRemoteDataSource.getConcreteNumberTrivia(testNumber));
              // сравнивем результат
              expect(result, Right(testNumberTrivia));
            },
          );

          test(
            'should cache the data locally when the call to remote data source is successful',
            () async {
              // arrange
              when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                  .thenAnswer((_) async => testNumberTriviaModel);

              // act
              await repository.getConcreteNumberTrivia(testNumber);

              // assert
              // подтверждаем, что во время выполения теста repository.getConcreteNumberTrivia вызвался с аргументом testNumber при тесте
              verify(mockRemoteDataSource.getConcreteNumberTrivia(testNumber));
              // подтверждаем, что во время выполения теста закешировались данные
              verify(
                  mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel));
            },
          );

          test(
            'should return server failure when the call to remote data source is unsuccessful',
            () async {
              // arrange: когда вызывается mockRemoteDataSource.getConcreteNumberTrivia, то возвращаем ошибку
              when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                  .thenThrow(ServerException());

              // act
              final result =
                  await repository.getConcreteNumberTrivia(testNumber);

              // assert
              // подтверждаем, что было repository.getConcreteNumberTrivia вызвался с аргументом testNumber при тесте
              verify(mockRemoteDataSource.getConcreteNumberTrivia(testNumber));
              // подтверждаем, что не было никаких вызовов методов у mockLocalDataSource
              verifyZeroInteractions(mockLocalDataSource);
              // сравнивем результат
              expect(result, Left(ServerFailure()));
            },
          );
        },
      );

      runTestOffline(
        () {
          test(
            'should return last locally cached data when the cached data is present',
            () async {
              // arrange
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenAnswer((_) async => testNumberTriviaModel);

              // act
              final result =
                  await repository.getConcreteNumberTrivia(testNumber);

              // assert
              // подтверждаем, что небыло было взаимодействии с mockRemoteDataSource
              verifyZeroInteractions(mockRemoteDataSource);
              // подтверждаем, что было вызванно mockLocalDataSource.getLastNumberTrivia()
              verify(mockLocalDataSource.getLastNumberTrivia());
              expect(result, equals(Right(testNumberTrivia)));
            },
          );

          test(
            'should return CacheFailure when there is no cached data present',
            () async {
              // arrange
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenThrow(CacheException());

              // act
              final result =
                  await repository.getConcreteNumberTrivia(testNumber);

              // assert
              // подтверждаем, что небыло было взаимодействии с mockRemoteDataSource
              verifyZeroInteractions(mockRemoteDataSource);
              // подтверждаем, что было вызванно mockLocalDataSource.getLastNumberTrivia()
              verify(mockLocalDataSource.getLastNumberTrivia());
              expect(result, equals(Left(CacheFailure())));
            },
          );
        },
      );
    },
  );

  group(
    'getRandomNumberTrivia',
    () {
      final testNumberTriviaModel = NumberTriviaModel(
        text: "test trivia",
        number: 1,
      );
      final NumberTrivia testNumberTrivia = testNumberTriviaModel;

      test(
        'should check if the device is online',
        () async {
          // arrange
          when(mockNetWorkInfo.isConnected).thenAnswer((_) async => true);

          // act
          repository.getRandomNumberTrivia();

          // assert
          // подтверждаем, что было вызов mockNetWorkInfo.isConnected при тесте выше
          verify(mockNetWorkInfo.isConnected);
        },
      );

      runTestOnline(
        () {
          setUp(
            () {
              when(mockNetWorkInfo.isConnected).thenAnswer((_) async => true);
            },
          );

          test(
            'should return remote data when the call to remote data source is successful',
            () async {
              // arrange
              when(mockRemoteDataSource.getRandomNumberTrivia())
                  .thenAnswer((_) async => testNumberTriviaModel);

              // act
              final result = await repository.getRandomNumberTrivia();

              // assert
              // подтверждаем, что было repository.getConcreteNumberTrivia вызвался с аргументом testNumber при тесте
              verify(mockRemoteDataSource.getRandomNumberTrivia());
              // сравнивем результат
              expect(result, Right(testNumberTrivia));
            },
          );

          test(
            'should cache the data locally when the call to remote data source is successful',
            () async {
              // arrange
              when(mockRemoteDataSource.getRandomNumberTrivia())
                  .thenAnswer((_) async => testNumberTriviaModel);

              // act
              await repository.getRandomNumberTrivia();

              // assert
              // подтверждаем, что во время выполения теста repository.getConcreteNumberTrivia вызвался с аргументом testNumber при тесте
              verify(mockRemoteDataSource.getRandomNumberTrivia());
              // подтверждаем, что во время выполения теста закешировались данные
              verify(
                  mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel));
            },
          );

          test(
            'should return server failure when the call to remote data source is unsuccessful',
            () async {
              // arrange: когда вызывается mockRemoteDataSource.getConcreteNumberTrivia, то возвращаем ошибку
              when(mockRemoteDataSource.getRandomNumberTrivia())
                  .thenThrow(ServerException());

              // act
              final result = await repository.getRandomNumberTrivia();

              // assert
              // подтверждаем, что было repository.getConcreteNumberTrivia вызвался с аргументом testNumber при тесте
              verify(mockRemoteDataSource.getRandomNumberTrivia());
              // подтверждаем, что не было никаких вызовов методов у mockLocalDataSource
              verifyZeroInteractions(mockLocalDataSource);
              // сравнивем результат
              expect(result, Left(ServerFailure()));
            },
          );
        },
      );

      runTestOffline(
        () {
          test(
            'should return last locally cached data when the cached data is present',
            () async {
              // arrange
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenAnswer((_) async => testNumberTriviaModel);

              // act
              final result = await repository.getRandomNumberTrivia();

              // assert
              // подтверждаем, что небыло было взаимодействии с mockRemoteDataSource
              verifyZeroInteractions(mockRemoteDataSource);
              // подтверждаем, что было вызванно mockLocalDataSource.getLastNumberTrivia()
              verify(mockLocalDataSource.getLastNumberTrivia());
              expect(result, equals(Right(testNumberTrivia)));
            },
          );

          test(
            'should return CacheFailure when there is no cached data present',
            () async {
              // arrange
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenThrow(CacheException());

              // act
              final result = await repository.getRandomNumberTrivia();

              // assert
              // подтверждаем, что небыло было взаимодействии с mockRemoteDataSource
              verifyZeroInteractions(mockRemoteDataSource);
              // подтверждаем, что было вызванно mockLocalDataSource.getLastNumberTrivia()
              verify(mockLocalDataSource.getLastNumberTrivia());
              expect(result, equals(Left(CacheFailure())));
            },
          );
        },
      );
    },
  );


}
