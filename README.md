# snappable
### This repository forked from [link](https://github.com/MarcinusX/snappable) and [link](https://github.com/igorczapski/snappable)
Thanos effect library in Flutter

Check out [blog post](https://fidev.io/thanos) describing the package on [Fidev](https://fidev.io).

## Examples
![Example 1](https://user-images.githubusercontent.com/16286046/62490322-51313680-b7c9-11e9-91f2-1363c292f544.gif)
![Example 2](https://user-images.githubusercontent.com/16286046/62490326-52626380-b7c9-11e9-9ed3-5545e3175cb6.gif)
![Example 3](https://user-images.githubusercontent.com/16286046/62490340-5bebcb80-b7c9-11e9-8bcf-e94c18f25f1b.gif)

## Getting Started

### Install the Snappable package
This will add a line like this to your package's pubspec.yaml (and run an implicit `flutter pub get`):
```yaml
dependencies:
  snappable:
    git: https://github.com/Dhanabhon/snappable.git
```
Alternatively, your editor might support `flutter pub get`. Check the docs for your editor to learn more.

### Import it
```dart
import 'package:snappable/snappable.dart';
```

### Wrap any widget in Snappable
```dart
@override
Widget build(BuildContext context) {
  return Snappable(
    child: Text('This will be snapped'),
  );
}
```
#### Snap with a Key
```dart

class MyWidget extends StatelessWidget {
  final key = GlobalKey<SnappableState>();
  @override
  Widget build(BuildContext context) {
    return Snappable(
      key: key,
      child: Text('This will be snapped'),
    );
  }
  
  void snap() {
    key.currentState.snap();
  }
}
```
Undo by `currentState.reset()`.
#### or snap by tap
```dart

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Snappable(
      snapOntap: true,
      child: Text('This will be snapped'),
    );
  }
}
```
Undo by tapping again.

### Callback for when the snap ends
 ```dart
 
 class MyWidget extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
     return Snappable(
       onSnapped: () => print("Snapped!"),
       child: Text('This will be snapped'),
     );
   }
 }
 ```
