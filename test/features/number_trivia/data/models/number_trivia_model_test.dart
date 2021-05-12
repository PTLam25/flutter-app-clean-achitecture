import 'dart:convert';

import 'package:flutter_app_clean_achitecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final testNumberTriviaModel =
      NumberTrivialModel(number: 1, text: "Test Text");

  test('should be a subclass of NumberTrivia entity', () async {
    // assert
    expect(testNumberTriviaModel, isA<NumberTrivia>());
  });

  group(
    'fromJson',
    () {
      test(
        'should return a valid model when the JSON number is an integer',
        () async {
          // 1) инциализация
          final Map<String, dynamic> jsonMap =
              json.decode(fixture('trivia.json'));
          // 2) вызов функции
          final result = NumberTrivialModel.fromJson(jsonMap);
          // 3) валидация
          expect(result, testNumberTriviaModel);
        },
      );

      test(
        'should return a valid model when the JSON number is regarded as a double',
        () async {
          // 1) инциализация
          final Map<String, dynamic> jsonMap =
              json.decode(fixture('trivia_double.json'));
          // 2) вызов функции
          final result = NumberTrivialModel.fromJson(jsonMap);
          // 3) валидация
          expect(result, testNumberTriviaModel);
        },
      );
    },
  );

  group(
    'toJson',
    () {
      test(
        'should return a JSON map containing the proper data',
        () async {
          // 2) вызов функции
          final result = testNumberTriviaModel.toJson();
          // 3) валидация
          final expectedMap = {"text": "Test Text", "number": 1};
          expect(result, expectedMap);
        },
      );
    },
  );
}
