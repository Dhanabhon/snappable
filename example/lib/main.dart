import 'package:flutter/material.dart';

import 'package:snappable/snappable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _snappableKey = GlobalKey<SnappableState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Snappable Demo'),
        ),
        body: Column(
          children: [
            Snappable(
              key: _snappableKey,
              snapOnTap: true,
              onSnapped: () => print("Snapped!"),
              child: Card(
                child: Container(
                  height: 300.0,
                  width: double.infinity,
                  color: Colors.deepPurple,
                  alignment: Alignment.center,
                  child: const Text(
                    'This will be snapped',
                    style: TextStyle(
                      color: Colors.white,
                    )
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  SnappableState? state = _snappableKey.currentState;
                  if (state!.isGone) {
                    state.reset();
                  } else {
                    state.snap();
                  }
                },
                child: const Text('Snap / Reverse'),
            ),
          ],
        ),
      ),
    );
  }
}
