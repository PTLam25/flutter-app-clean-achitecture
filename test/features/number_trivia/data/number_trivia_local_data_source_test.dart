import 'dart:convert';

import 'package:flutter_app_clean_achitecture/core/error/exception.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group(
    'getLastNumberTrivia',
    () {
      final testNumberTriviaModel = NumberTriviaModel.fromJson(
          json.decode(fixture('trivia_cached.json')));

      test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
          // arrange: mock mockSharedPreferences.getString
          when(mockSharedPreferences.getString(any))
              .thenReturn(fixture('trivia_cached.json'));

          // act
          final result = await dataSource.getLastNumberTrivia();

          // assert
          // проверяем, что mockSharedPreferences.getString вызвался с аргументом CACHED_NUMBER_TRIVIA
          verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
          expect(result, equals(testNumberTriviaModel));
        },
      );

      test(
        'should throw a CacheException when there is not a cached value',
        () async {
          // arrange: mock mockSharedPreferences.getString
          when(mockSharedPreferences.getString(any)).thenReturn(null);

          // act
          final call = dataSource.getLastNumberTrivia;

          // assert
          // проверяем, что при вызове dataSource.getLastNumberTrivia вернеться ошибка
          expect(() => call(), throwsA(TypeMatcher<CacheException>()));
        },
      );
    },
  );

  group(
    'cacheNumberTrivia',
    () {
      final testNumberTriviaModel =
          NumberTriviaModel(number: 1, text: "text trivia");

      test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
          // act
          dataSource.cacheNumberTrivia(testNumberTriviaModel);

          final expectedJsonString =
              json.encode(testNumberTriviaModel.toJson());
          // assert
          // проверяем, что mockSharedPreferences.setString вызвался с ожидаемыми аргументами
          verify(mockSharedPreferences.setString(
              CACHED_NUMBER_TRIVIA, expectedJsonString));
        },
      );
    },
  );
}
