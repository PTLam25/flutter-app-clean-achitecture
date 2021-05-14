# Чистая архитектура в Flutter
Чистая архитектура предложенная дядя Бобом, говорит, что мы все должны стремиться разделить код на независимые уровни и полагаться на абстракции, а не на конкретные реализации.

## Чистая архитектура
![alt text](http://i.imgur.com/JoYPXDr.png "diagram")

На картинке выше мы видим разные слови, черные горизонтальные стрелки ---> представляют поток зависимостей. Например, Entities ни от чего не зависят, Use Cases зависят только от Entities и т.д.


## Чистая архитектура в Flutter
![alt text](http://i.imgur.com/xxh5YSt.png "diagram")

В нашем приложения могут быть разные фичи (функционал приложения) и реализация каждой фичи должна быть разделенна на 3 слоя: **presentation**, **domain** and **data**.

![alt text](http://i.imgur.com/3OfzaKL.png "diagram")

Фичи хранится в папке features и там будет лежать логика касательно только данной фичи. Если есть переиспользуемая логика, то пихаем в папке core.


### Уровень presentation
Уровень presentation содержит в себе виджеты (то, что видит пользователь) и логику для отрисовки виджетов (state management).
Логика уровня presentation отвечает только:
 - отриисовку виджета взависимоси от состояния
 - за валидацию входных данных, а потом передает всю работу domain (аналог сервисам, в котором содержиться вся бизнес логика) и потом ждет готовые данные него.

![alt text](http://i.imgur.com/lscYVJR.png "diagram")

**Совет**: не стоит добавлять валидация ввода в класс Event, Event должен просто принимать данные и передавать их в блок. Логика валидации должны бать в классе Bloc!


### Уровень domain

Уровень domain содержит в себя всю бизнес-логику в (**use case** - аналог service) и работает с объектами бизнес логики (**entities**).

**use case** - это классы, которые инкапсулируют всю бизнес-логику конкретного варианта использования приложения.  
Например, для получения пользователей создаем отдельный класс GetUsers и там создаем метод для получения пользователей из репозиторий с уровня **data**.

**entities** - это объекты представления результата работы **use case**. Например, если у нас есть 2 **use case**: GetUser, SearchUser, то у нас должен для каждого отдельный entities: User, SearchResult.

**Уровень domain должен быть полностью независимым слоем от других. Поэтому это самый стабильный слой, который не зависит от изменений в других слоях, а также тестировать его без наличия репозитория, а через сырые данные. Так как мы не зависим от репозитория, а зависим от реализации и возвращаемых данных.**
Но ... Как уровень домена становится полностью независимым, когда он получает данные из репозитория, то есть из уровня данных?  
Вы видите этот причудливый красочный градиент для репозитория? Это означает, что он принадлежит одновременно обоим слоям. Мы можем добиться этого с помощью принципа SOLID **инверсии зависимостей** (реализация должна зависеть от абстракции).

![alt text](http://i.imgur.com/QX69spO.png "diagram")

Мы создаем абстрактный класс **Repository**(интерфейс), определяющий контракт о том, что **Repository** должен делать - это входит в уровень **domain**. Например, метод интерфейса GetUser говорить, что он возвращает пользователя, а как он это сделает уже будет реализованно в **data**.
Затем мы зависим от «контракта» репозитория, определенного в домене, зная, что фактическая реализация Repository на уровне **data** будет выполнять этот контракт. То есть на уровне **data** будет класс, который implements интерфейс Repository.

![alt text](http://i.imgur.com/SHuDUY1.png "diagram")


### Уровень data
Уровень **data** состоит из реализации **интерфейса Repository** в уровне **domain** (контракт поступает из уровня домена) и реализации получения данных из **источников данных**.
Это слой связывает приложения с внешним миром: REST API или же API телефона.
Источники данных двух типов:
1. один обычно предназначен для получения удаленных (API) данных,
2. а другой - для кэширования этих данных.

Для обеих источников данных тоже должен быть создан интерфей для взаимодействии с внешним миро, чтобы была на будущее возможность поменять ресурс внешнего мира, с которым работаем.

Реализация **repository** в data - это его мозг, где вы решаете, возвращать ли свежие или кешированные данные, когда их кэшировать и так далее. Например, если нет интернета, то вытягиваем данные из local storage, если нет - из АПИ.

Источники данных возвращают не **entities**, а **models**. Причина этого в том, что для преобразования необработанных данных (например, JSON) в объекты Dart требуется некоторый код преобразования JSON.  
Нам не нужен этот специфичный для JSON код внутри домена Entities - что, если мы решим переключиться на XML? Поэтому entities будут брать данные уже с готовых models, который отвечает за десириализация данных с источников.
Model будет наследоваться от Entities с дополнительной логикой для сериализации данных (обычно toJson, fromJson).

![alt text](http://i.imgur.com/EOMhrUp.png "diagram")

В datasources будет содержаться логика для API и локального storage(пакет shared_preferences):
![alt text](http://i.imgur.com/SAjqHOH.png "diagram")


# TEST DRIVEN DEVELOPMENT (TDD)
**Test driven development** - это когда сначало пишется тест, а потом уже код. Это следует принцип YAGNI (You are goint need it), когда мы через тест понимаем какой код нам нужно написать и что ожидать,
тем самым избавляемся от возможности написания лишнего кода.

Кратко суть TDD: начинаем писать тест, когда доходим до нереализованных классов, то реализуем классы и продолжаем писать тест для одного тесткейса, потом пишем логику и запускаем тест.  
Если тест прошел, делаем рефакторинг кода, и так дальше по тесткейсам.


## Зависимость для MOCK
### Prensentatnion
Bloc будет зависеть от Usecases в слое **domain** для теста, так как мы в Bloc logic вызываем методы Usecases. Поэтому для теста логики Bloc надо мочить usecase.

### Domain
Usecase зависит от интерфейса репозитория. Поэтому надо мочить интерфейс репозитория, который в слое **domain**. Тут не надо мочить имплементация репозитория, который находится в **data**, так как нам не важно логика его реализация, а важна что она возвращает.
Тем самым делая слой **domain** независимым. Если бы мы мочили реализацию, то при изменения кода в реализация, наш код теста был бы не валиданым.


## Пример
Пример: нам надо проверить класс реализующий функции запроса за данными во внеший АПИ NumberTriviaRemoteDataSourceImpl, который в своих методах использует client http/dio/GetConnect.
1. У нас еще нет класса NumberTriviaRemoteDataSourceImpl, пока есть только NumberTriviaRemoteDataSource, но мы уже пишем тест.
Сначала конечно мочим наш http client, чтобы контролировать результат возврата его функции для теста.
Потом инициализуем данные и нам сразу подсвечится красным, что нет класса NumberTriviaRemoteDataSourceImpl.
```dart
class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });
}
```

2. Создаим класс NumberTriviaRemoteDataSourceImpl и реализуем функции с возвратом null, так как тест просит только создания класса и все.
```dart
class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({@required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) {
    return null;
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() {
    return null;
  }
}
```

3. Видим, что код теста уже не подсвечивается красным, можем продолжить писать код теста.
Реализуем первую проверку, что мы отправляем запрос по нужно URL и с нужным headers.
Мы всегда должны писать код мочинга сразу, чтобы при любом тесте вызывался замоченный объект.
```
  group(
    'getConcreteNumberTrivia',
    () {
      final testNumber = 1;

      test(
        '''should perform a GET request on a URL with number 
        being the endpoint and with application/json''',
        () async {
          // mock
          when(mockHttpClient.get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(fixture('trivia.json'), 200));
          // call
          dataSource.getConcreteNumberTrivia(testNumber);

          // asert
          verify(mockHttpClient.get(
            'http://numbersapi.com/$testNumber',
            headers: {'Content-Type': 'application/json'},
          ));
        },
      );
    },
  );
```

4. Так как методы уже написанны, нам красного не подсвечат, но если запустить тест, то будет провал, так нет реализации метода getConcreteNumberTrivia.
Поэтому опять переключаемся на реализацию запроса с правильным URL и headers.
```dart
class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({@required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) {
    client.get(
      'http://numbersapi.com/$number',
      headers: {'Content-Type': 'application/json'},
    );
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() {
    return null;
  }
}
```
Запускаем тест и тест прошел, значит можно продолжить писать другие тесты.

5. Проверим, что метода getConcreteNumberTrivia вернет ожидаемый результат.
Для этого в тесте групп создаим ожидаемый результат testNumberTriviaModel и создадим новый testcase.
Мы могли добавить логику в первом тесте, но надо стараться разбивать тесты на мелькие тесткейсы и их тестировать:
```
group(
    'getConcreteNumberTrivia',
    () {
      final testNumber = 1;
      final testNumberTriviaModel =
          NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

      test(
        '''should return NumberTrivia when the response code is 200 (success)''',
            () async {
          // mock
          when(mockHttpClient.get(any, headers: anyNamed('headers')))
              .thenAnswer(
                  (_) async => http.Response(fixture('trivia.json'), 200));
          // call
          final result = await dataSource.getConcreteNumberTrivia(testNumber);

          // assert
          expect(result, equals(testNumberTriviaModel));
        },
      );
    },
  );
```
Запускаем тест и от отваливается, так как реализации еще нет.

6. Приступаем к реализации логики для теста:
```dart
  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    final response = await client.get(
      'http://numbersapi.com/$number',
      headers: {'Content-Type': 'application/json'},
    );

    return NumberTriviaModel.fromJson(json.decode(response.body));
  }
```
Запустили тест, тест прошел идем дальше.

7. Теперь нам надо проверить когда сервер возвращает статус 404.
Создаем другой тесткейс:
```
  test(
    '''should throw a ServerException when the response code is 404 or other''',
    () async {
      // mock
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer(
              (_) async => http.Response('Something went wrong', 404));
      // call
      final call = dataSource.getConcreteNumberTrivia;

      // assert
      expect(
          () => call(testNumber), throwsA(TypeMatcher<ServerException>()));
    },
  );
```
Запускаем тест и конечно отваливается. Приступим к реализации.

8. Добавим валидацию статуса:
```dart
  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    final response = await client.get(
      'http://numbersapi.com/$number',
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
```
Запускаем тест и проходит. Все мы закончили!


## Как мочить в тесте
При UNIT теста мокаем нижний уровень для текущего уровня теста. Например, если мы тестируем repositories в **data** слое, который вызывается datasources АПИ http client, то мы мокаем http client, тем самым контролируя результат возвращаемых его методов.
