library widget_fader;

import "dart:async";

import "package:flutter/material.dart";

import "package:rxdart/rxdart.dart";

/// (Automatically) cross-fades between [children] in both directions.
/// 
/// The [children] expand to fill the stack they're in.
/// Provides an optional [cover] that partially covers
/// the [children].
class WidgetFader extends StatefulWidget {
  WidgetFader({
    @required List<Widget> children,
    this.fadeDuration = 750,
    this.pauseDuration = 750,
    this.reverse = false,
    this.auto = true,
    this.cover,
    this.startIndex = 0
  }):
    this.children = children,
    this._maxIndex = children.length - 1;

  final List<Widget> children;
  /// A widget on the front to partially cover the [children].
  final Widget cover;
  /// Changes require recreating the state to take effect.
  final int fadeDuration;
  final int pauseDuration;
  final bool reverse;
  final bool auto;
  final int startIndex;
  final int _maxIndex;
  final _nextPageMode = BehaviorSubject<String>();

  void next() => _nextPageMode.add("next");
  void previos() => _nextPageMode.add("previous");

  @override
  State<StatefulWidget> createState() {
    return _WidgetFaderState();
  }

  void _dispose() => _nextPageMode.close();
}

class _WidgetFaderState extends State<WidgetFader> with TickerProviderStateMixin {
  List<Widget> _children;
  List<AnimationController> _controllers;
  List<Animation> _animations;
  Timer _autoTimer;
  int _currentPage;
  StreamSubscription _nextPageModeSubscription;
  bool _reverse;

  void initState() { 
    super.initState();

    _init();
    _listen();
    _loop(); 
  }
  
  void _init() {
    _controllers = List.generate(
      widget.children.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.fadeDuration)
      )
    );
    _animations = List.generate(
      widget.children.length,
      (i) => Tween(begin: 0.0, end: 1.0).animate(_controllers[i])
    );
    _currentPage = widget.startIndex;
    _children = _buildChildren();
    _reverse = widget.reverse;
  }
  
  void _listen() {
    widget._nextPageMode.listen(_nextPage);
  }

  void _loop() {
    if (widget.auto) {
      _play();
      _autoTimer = Timer.periodic(
        Duration(milliseconds: widget.fadeDuration + widget.pauseDuration),
        (_) => _play()
      );
    }
  }

  int _calcNextPage(int page) {
    if (_reverse) {
      page--;

      if (page < 0) page = widget._maxIndex;
    } else {
      page++;
      
      if (page > widget._maxIndex) page = 0;
    }

    return page;
  }

  void _nextPage(String mode) {
    if (!widget.auto) {
      if (mode == "next") {
        _reverse = false;
        _play();
      } else if (mode == "previous") {
        _reverse = true;
        _play();
      }
      _reverse = widget.reverse;
    }
  }

  void _play() {
    _controllers[_currentPage].value = 1.0;
    _controllers[_currentPage].reverse();
    _controllers[_calcNextPage(_currentPage)].forward();
    _currentPage = _calcNextPage(_currentPage);
  }

  List<Widget> _buildChildren() => List.generate(
    3, (i) => FadeTransition(
      opacity: _animations[i],
      child: widget.children[i],
    )
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Stack(
          fit: StackFit.expand,
          children: _children,
        ),
        widget.cover?? Container()
      ],
    );
  }

  @override
  void dispose() {
    _controllers.forEach((c) => c.dispose());
    _autoTimer.cancel();
    _nextPageModeSubscription?.cancel();
    widget._dispose();

    super.dispose();
  }
}