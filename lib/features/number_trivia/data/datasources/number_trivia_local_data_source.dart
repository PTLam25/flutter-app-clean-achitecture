import 'package:flutter_app_clean_achitecture/features/number_trivia/data/models/number_trivia_model.dart';

// интерфейс для работы с внешним АПИ и локальным АПИ
abstract class NumberTriviaLocalDataSource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}