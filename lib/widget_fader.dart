library widget_fader;

import "dart:async";

import "package:flutter/material.dart";

import "package:carousel_slider/carousel_slider.dart";
import "package:rxdart/rxdart.dart";

/// (Automatically) cross-fades between [children] in both directions.
/// 
/// The [children] expand to fill the stack they're in.
/// Provides an optional [cover] that partially covers
/// the [children].
/// 
/// All time parameters are in milliseconds.
class WidgetFader extends StatefulWidget {
  WidgetFader({
    @required this.children,
    this.fadeDuration = 750,
    this.pauseDuration = 750,
    this.onTouchPauseDuration = 2000,
    this.reverse = false,
    this.auto = true,
    this.cover,
    this.startIndex = 0,
    /// Number of pages to simulate infinite backward scrolling.
    this.fakeInfinitePageCount = 10000
  });

  final List<Widget> children;
  /// A widget on the front to partially cover the [children].
  final Widget cover;
  final int fadeDuration;
  final int pauseDuration;
  final int onTouchPauseDuration;
  final bool reverse;
  final bool auto;
  final int startIndex;
  /// The number of pages used to simulate infinite backward scroll.
  final int fakeInfinitePageCount;
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
  CarouselSlider _carouselSlider;
  List<AnimationController> _controllers;
  List<Animation> _animations;
  Map<String, StreamSubscription> _subscriptions = {};

  void initState() { 
    super.initState();

    _init();
    _listen();
  }

  void _init() {
    _initAnimation();
    _initCarouselSlider();
  }

  void _initCarouselSlider() => _carouselSlider = CarouselSlider(
    realPage: widget.fakeInfinitePageCount,
    autoPlay: widget.auto,
    autoPlayAnimationDuration: Duration(milliseconds: widget.fadeDuration),
    autoPlayInterval: Duration(milliseconds: widget.pauseDuration),
    pauseAutoPlayOnTouch: Duration(milliseconds: widget.onTouchPauseDuration),
    reverse: widget.reverse,
    height: double.infinity,
    viewportFraction: 1.0,
    items: List.generate(
      widget.children.length, 
      (i) => Container(color: [Colors.amber, Colors.green, Colors.red][i % 3].withAlpha(0))
    ),
  );

  void _initAnimation() {
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
    _controllers[0].value = 1.0;
  }

  void _listen() {
    _carouselSlider.pageController.addListener(_setOpacities);
    _subscriptions["nextPageMode"] = widget._nextPageMode.listen(
      (mode) => _nextPage(mode)
    );
  }

  void _nextPage(String mode) {
    var params = [
      Duration(milliseconds: widget.fadeDuration),
      Curves.easeInOut
    ];

    if (mode == "next")
      _carouselSlider.nextPage(duration: params[0], curve: params[1]);
    else _carouselSlider.previousPage(duration: params[0], curve: params[1]);
  }

  void _setOpacities() {
    final currentUncappedPage = _getCurrentUncappedPage();
    final currentPageProgress = currentUncappedPage % 1;
    final currentPage = _capPage(currentUncappedPage.round());

    var otherPage;

    if (currentPageProgress < 0.5) {
      otherPage = _capPage(currentPage + 1);
      _controllers[currentPage].value = 1 - currentPageProgress;
      _controllers[otherPage].value = currentPageProgress;
    } else {
      otherPage = _capPage(currentPage - 1);
      _controllers[currentPage].value = currentPageProgress;
      _controllers[otherPage].value = 1 - currentPageProgress;
    }
  }

  double _getCurrentUncappedPage() {
    final controller = _carouselSlider.pageController;
    final double offset = controller.page - _carouselSlider.realPage;


    return offset;
  }

  int _capPage(int page) {
    page = page % widget.children.length;

    return (page < 0)? page += widget.children.length: page;
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
      fit: StackFit.expand,
      children: <Widget>[
        Stack(
          fit: StackFit.expand,
          children: _buildChildren(),
        ),
        _carouselSlider,
        widget.cover?? Container(),
      ],
    );
  }

  @override
  void dispose() {
    _controllers.forEach((c) => c.dispose());
    _subscriptions.forEach((str, sub) => sub.cancel());
    widget._dispose();

    super.dispose();
  }
}