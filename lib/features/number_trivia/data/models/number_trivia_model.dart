import 'package:flutter_app_clean_achitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:meta/meta.dart';

class NumberTrivialModel extends NumberTrivia {
  NumberTrivialModel({
    @required String text,
    @required int number,
  }) : super(text: text, number: number);

  factory NumberTrivialModel.fromJson(Map<String, dynamic> json) {
    return NumberTrivialModel(
        text: json['text'], number: (json['number'] as num).toInt());
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'number': number};
  }
}
