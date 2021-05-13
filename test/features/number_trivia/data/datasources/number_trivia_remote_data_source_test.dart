import 'dart:convert';

import 'package:flutter_app_clean_achitecture/core/error/exception.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientSuccess400() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer(
            (_) async => http.Response('Something went wrong', 404));
  }

  group(
    'getConcreteNumberTrivia',
    () {
      final testNumber = 1;
      final testNumberTriviaModel =
          NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

      test(
        '''should perform a GET request on a URL with number 
        being the endpoint and with application/json''',
        () async {
          // mock
          setUpMockHttpClientSuccess200();
          // call
          dataSource.getConcreteNumberTrivia(testNumber);

          // assert
          verify(mockHttpClient.get(
            'http://numbersapi.com/$testNumber',
            headers: {'Content-Type': 'application/json'},
          ));
        },
      );

      test(
        '''should return NumberTrivia when the response code is 200 (success)''',
        () async {
          // mock
          setUpMockHttpClientSuccess200();
          // call
          final result = await dataSource.getConcreteNumberTrivia(testNumber);

          // assert
          expect(result, equals(testNumberTriviaModel));
        },
      );

      test(
        '''should throw a ServerException when the response code is 404 or other''',
        () async {
          // mock
          setUpMockHttpClientSuccess400();
          // call
          final call = dataSource.getConcreteNumberTrivia;

          // assert
          expect(
              () => call(testNumber), throwsA(TypeMatcher<ServerException>()));
        },
      );
    },
  );

  group(
    'getRandomNumberTrivia',
        () {
      final testNumberTriviaModel =
      NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

      test(
        '''should perform a GET request on a URL with number 
        being the endpoint and with application/json''',
            () async {
          // mock
          setUpMockHttpClientSuccess200();
          // call
          dataSource.getRandomNumberTrivia();

          // assert
          verify(mockHttpClient.get(
            'http://numbersapi.com/random',
            headers: {'Content-Type': 'application/json'},
          ));
        },
      );

      test(
        '''should return NumberTrivia when the response code is 200 (success)''',
            () async {
          // mock
          setUpMockHttpClientSuccess200();
          // call
          final result = await dataSource.getRandomNumberTrivia();

          // assert
          expect(result, equals(testNumberTriviaModel));
        },
      );

      test(
        '''should throw a ServerException when the response code is 404 or other''',
            () async {
          // mock
          setUpMockHttpClientSuccess400();
          // call
          final call = dataSource.getRandomNumberTrivia;

          // assert
          expect(
                  () => call(), throwsA(TypeMatcher<ServerException>()));
        },
      );
    },
  );
}
