import 'package:arduino_rc_car/bloc/bloc_base.dart';
import 'package:arduino_rc_car/bloc/bloc_provider.dart';
import 'package:flutter/material.dart';

class MultiBlocProviderItem<T extends BlocBase> {
  MultiBlocProviderItem(this.bloc, [this.autoDisposeBloc = false]);

  final T bloc;
  final bool autoDisposeBloc;

  BlocProvider<T> build(BuildContext context, Widget child) {
    return BlocProvider<T>(
      bloc: bloc,
      child: child,
      autoDisposeBloc: autoDisposeBloc
    );
  }
}

class MultiBlocProvider extends StatelessWidget {
  MultiBlocProvider({
    Key key,
    @required this.child,
    @required this.items
  }) : super(key: key);

  final Widget child;
  final List<MultiBlocProviderItem> items;

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (int i = items.length - 1; i >= 0; i--) {
      tree = items[i].build(context, tree);
    }

    return tree;
  }
}