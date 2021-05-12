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
Логика уровня presentation отвечает только за валидацию входных данных, а потом передает всю работу domain (аналог сервисам, в котором содержиться вся бизнес логика) и потом ждет готовые данные него.

![alt text](http://i.imgur.com/lscYVJR.png "diagram")


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