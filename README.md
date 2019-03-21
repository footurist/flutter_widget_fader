# widget_fader

Cross-fades widgets in both directions, automatically or not.

## Installation

Add ``widget_fader: ^0.0.5`` in your ``pubspec.yaml`` dependencies. And import it:
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
    fadeDuration: 1000,
    pauseDuration: 2000,
);
```

## Future functionality

* swipe to fade


