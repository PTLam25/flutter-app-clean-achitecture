import 'package:dartz/dartz.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// наследуемся от Mock и реализуем интерфейс NumberTriviaRepository,
// чтобы создать типа аналога реализации NumberTriviaRepository для теста
class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetRandomNumberTrivia useCase;
  MockNumberTriviaRepository mockNumberTriviaRepository;

  // setUp функция запускается перед каждым тестом для настройки данных
  setUp(() {
    // создаем фейк NumberTriviaRepository для теста
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    // создаем объект GetRandomNumberTrivia, но с фейковым NumberTriviaRepository
    useCase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  // типо получили данные с АПИ, ковертировали в NumberTrivia
  final testNumberTrivia = NumberTrivia(text: "test", number: 1);

  test('should get random trivia from the repository', () async {
    // условие выполнения тестируемой фукнции и его результат:
    // когда вызывается getRandomNumberTrivia,
    // то мы должны вернуть результат выполнения этой функции объект testNumberTrivia
    when(mockNumberTriviaRepository.getRandomNumberTrivia())
        .thenAnswer((_) async => Right(testNumberTrivia));

    // вызов функции для теста
    final result = await useCase(NoParams());

    // валидация
    expect(result, Right(testNumberTrivia));
    //  проверяем, что метод вызвался с тем данным
    verify(mockNumberTriviaRepository.getRandomNumberTrivia());
    // проверяем, что после вызова не было еще какие-то вызовы в mockNumberTriviaRepository
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
