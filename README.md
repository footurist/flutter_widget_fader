# widget_fader

Cross-fades widgets in both directions.
Supports:
* Infinite cross-fading in both directions
* Swipe to fade
* Fading via the functions next() and previous()

## Example

<iframe src="https://giphy.com/embed/jlcmSkvhF8jOjsg014" width="270" height="480" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/jlcmSkvhF8jOjsg014">via GIPHY</a></p>
<!-- <img src="assets/widgetFaderExample.gif" width="270" height="480" /> -->

## Installation

Add ``widget_fader: ^0.0.6`` in your ``pubspec.yaml`` dependencies. And import it:
```dart
import 'package:widget_fader/widget_fader.dart';
```

## How to use

```dart
List<Widget> _buildWidgetFaderChildren() {
    var assetPath = "assets/widgetFader";

    return List.generate(
      3, 
      (i) => Container(
        child: Image.asset(
          assetPath + i.toString() + ".jpg",
          fit: BoxFit.cover,
        ),
      )
    );
}

WidgetFader _buildWidgetFader() => WidgetFader(
    children: _buildWidgetFaderChildren(),
    fadeDuration: 750,
    pauseDuration: 750,
    cover: Column(
      children: <Widget>[
        Expanded(child: Container()),
        Container(
          height: 150,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/widgetFaderCover.jpg"),
              fit: BoxFit.cover
            )
          ),
        )
      ],
    ),
);
```

## Future functionality

* Got any ideas? Make a feature request at the repo or contact me.
* Rotation
* Scaling


