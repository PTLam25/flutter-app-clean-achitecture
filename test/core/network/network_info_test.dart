import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_app_clean_achitecture/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker {}

void main() {
  NetWorkInfoImpl netWorkInfo;
  MockDataConnectionChecker mockDataConnectionChecker;

  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    netWorkInfo = NetWorkInfoImpl(mockDataConnectionChecker);
  });

  group(
    'isConnected',
    () {
      test(
        'should forward the call to DataConnectionChecker.hasConnection',
        () async {
          // arrange
          final testHasConnectionFuture = Future.value(true);
          // мочим вызов mockDataConnectionChecker.hasConnection и возвращаем при его вызове true
          when(mockDataConnectionChecker.hasConnection)
              .thenAnswer((_) => testHasConnectionFuture);

          // act
          final result = netWorkInfo.isConnected;

          // assert
          // чекаем что был вызов mockDataConnectionChecker.hasConnection один раз
          verify(mockDataConnectionChecker.hasConnection);
          // чекаем результат
          expect(result, testHasConnectionFuture);
        },
      );
    },
  );
}
