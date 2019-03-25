# widget_fader

Cross-fades widgets in both directions.
Supports:
* Infinite cross-fading in both directions
* Swipe to fade
* Fading via the functions next() and previous()

## Installation

Add ``widget_fader: ^0.0.6`` in your ``pubspec.yaml`` dependencies. And import it:
```dart
import 'package:widget_fader/widget_fader.dart';
```

## How to use

```dart
WidgetFader(
    children: List.generate(
        3, 
        (i) => Container(
            color: [Colors.red, Colors.green, Colors.blue][i]
        )
    ),
    reverse: true,
    fadeDuration: 750,
    pauseDuration: 750,
);
```

## Future functionality

* Got any ideas? Make a feature request at the repo or contact me.


