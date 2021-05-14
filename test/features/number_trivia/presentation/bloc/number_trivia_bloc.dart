import 'package:dartz/dartz.dart';
import 'package:flutter_app_clean_achitecture/core/error/failure.dart';
import 'package:flutter_app_clean_achitecture/core/presentation/utils/input_converter.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(
    () {
      mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
      mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
      mockInputConverter = MockInputConverter();
      bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter,
      );
    },
  );

  // тестим первоначальное значение
  test(
    'initialState should be Empty',
    () {
      expect(bloc.initialState, equals(Empty()));
    },
  );

  group(
    'GetTriviaForConcreteNumber',
    () {
      final testNumberString = '1';
      final testNumberParsed = 1;
      final testNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);
      void setUpMockInputConverterSuccess() => when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Right(testNumberParsed));
      test(
        // проверяем что вызовется правильно mockInputConverter.stringToUnsignedInteger
        'should call the the InputConverter to validate and convert the string to an usnigned integer',
        () async {
          // initiate
          setUpMockInputConverterSuccess();
          // act
          bloc.dispatch(GetTriviaForConcreteNumber(testNumberString));
          // подожди пока вызовется перед тем как перейти к сравнению теста
          await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
          // assert
          verify(mockInputConverter.stringToUnsignedInteger(testNumberString));
        },
      );

      test(
        // проверяем что вызовется правильно mockInputConverter.stringToUnsignedInteger
        'should emit [Error] when the input is invalid',
        () async {
          // initiate
          when(mockInputConverter.stringToUnsignedInteger(any))
              .thenReturn(Left(InvalidInputFailure()));
          // assert later
          final expected = [
            Empty(),
            Error(message: INVALID_INPUT_FAILURE_MESSAGE),
          ];
          bloc.dispatch(GetTriviaForConcreteNumber(testNumberString));
          // act
          expectLater(bloc.state, emitsInOrder(expected));
        },
      );

      test(
        'should get data from the concrete use case',
        () async {
          // initiate
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Right(testNumberTrivia));
          // act
          final expected = [
            Empty(),
            Error(message: INVALID_INPUT_FAILURE_MESSAGE),
          ];
          bloc.dispatch(GetTriviaForConcreteNumber(testNumberString));
          // assert
          await untilCalled(mockGetConcreteNumberTrivia(any));
          // assert
          verify(mockGetConcreteNumberTrivia(Params(number: testNumberParsed)));
        },
      );

      test(
        'should emit [Loading, Loaded] when data is gotten successfully',
            () async {
          // initiate
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Right(testNumberTrivia));
          // assert later
          final expected = [
            Empty(),
            Loading(),
            Loaded(trivia: testNumberTrivia),
          ];
          expectLater(bloc.state, emitsInOrder(expected));
          // act
          bloc.dispatch(GetTriviaForConcreteNumber(testNumberString));
        },
      );

      test(
        'should emit [Loading, Error] when getting data fails',
            () async {
          // initiate
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(ServerFailure()));
          // assert later
          final expected = [
            Empty(),
            Loading(),
            Error(message: SERVER_FAILURE_MESSAGE),
          ];
          expectLater(bloc.state, emitsInOrder(expected));
          // act
          bloc.dispatch(GetTriviaForConcreteNumber(testNumberString));
        },
      );

      test(
        'should emit [Loading, Error] with a proper message for error when getting data fails',
            () async {
          // initiate
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Left(CacheFailure()));
          // assert later
          final expected = [
            Empty(),
            Loading(),
            Error(message: CACHE_FAILURE_MESSAGE),
          ];
          expectLater(bloc.state, emitsInOrder(expected));
          // act
          bloc.dispatch(GetTriviaForConcreteNumber(testNumberString));
        },
      );
    },
  );

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test(
      'should get data from the random use case',
          () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // act
        bloc.dispatch(GetTriviaForRandomNumber());
        await untilCalled(mockGetRandomNumberTrivia(any));
        // assert
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
          () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.dispatch(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
          () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.dispatch(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
          () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.dispatch(GetTriviaForRandomNumber());
      },
    );
  });
}
