import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class NumberTrivia extends Equatable {
  final String text;
  final int number;

  NumberTrivia({
    @required String text,
    @required int number,
  })  : this.text = text,
        this.number = number;

  @override
  List<Object> get props => [text, number];
}
