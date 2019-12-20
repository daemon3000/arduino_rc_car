import 'package:arduino_rc_car/bloc/bloc_base.dart';
import 'package:flutter/material.dart';

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  final Widget child;
  final T bloc;
  final bool autoDisposeBloc;

  BlocProvider({
    Key key,
    this.autoDisposeBloc = false,
    @required this.child,
    @required this.bloc
  }) : assert(child != null),
        assert(bloc != null),
        super(key: key);

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<_BlocProviderInherited<T>>();
    if(element != null) {
      _BlocProviderInherited<T> provider = context.getElementForInheritedWidgetOfExactType<_BlocProviderInherited<T>>().widget;
      return provider.bloc;
    }

    return null;
  }
}

class _BlocProviderState<T extends BlocBase> extends State<BlocProvider<T>> {
  @override
  void dispose() {
    if(widget.autoDisposeBloc) {
      widget.bloc?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _BlocProviderInherited<T>(
        child: widget.child,
        bloc: widget.bloc,
      ),
    );
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  final T bloc;

  _BlocProviderInherited({
    Key key,
    @required Widget child,
    @required this.bloc,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_BlocProviderInherited oldWidget) => false;
}