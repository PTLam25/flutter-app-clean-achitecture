import 'package:dartz/dartz.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// наследуемся от Mock и реализуем интерфейс NumberTriviaRepository,
// чтобы создать типа аналога реализации NumberTriviaRepository для теста
class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetConcreteNumberTrivia useCase;
  MockNumberTriviaRepository mockNumberTriviaRepository;

  // setUp функция запускается перед каждым тестом для настройки данных
  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    useCase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  // типо получили данные с АПИ, ковертировали в NumberTrivia
  final testNumber = 1;
  final testText = "test";
  final testNumberTrivia = NumberTrivia(text: testText, number: testNumber);

  test('should get trivia for the number from the repository', () async {
    // условие выполнения тестируемой фукнции и его результат:
    // когда вызывается getConcreteNumberTrivia с любым типом данных,
    // то мы должны вернуть результат выполнения этой функции объект testNumberTrivia
    when(mockNumberTriviaRepository.getConcreteNumberTrivia(any))
        .thenAnswer((_) async => Right(testNumberTrivia));

    // вызов функции для теста
    final result = await useCase(Params(number: testNumber));

    // валидация
    expect(result, Right(testNumberTrivia));
    //  проверяем, что метод вызвался с тем данным
    verify(mockNumberTriviaRepository.getConcreteNumberTrivia(testNumber));
    // проверяем, что после вызова не было еще какие-то вызовы в mockNumberTriviaRepository
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
