import 'package:flutter/material.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_app_clean_achitecture/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:flutter_app_clean_achitecture/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(child: buildBody(context)),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      builder: (_) => serviceLocator<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is Empty) {
                    return MessageDisplay(message: 'Start searching');
                  } else if (state is Loading) {
                    return LoadingWidget(message: 'Loading');
                  } else if (state is Loaded) {
                    return TriviaDisplay(numberTrivia: state.trivia);
                  } else if (state is Error) {
                    return MessageDisplay(message: state.message);
                  } else {
                    return MessageDisplay(message: 'Unexpected event');
                  }
                },
              ),
              SizedBox(height: 20),
              TriviaControls(),
            ],
          ),
        ),
      ),
    );
  }
}
