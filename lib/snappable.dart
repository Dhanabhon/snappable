import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:image/image.dart' as image;

class Snappable extends StatefulWidget {
  /// Widget to be snapped
  final Widget child;
  /// Direction and range of snap effect
  /// (Where and how far will particles go)
  final Offset offset;
  /// Duration of whole snap animation
  final Duration duration;
  /// How much can particle be randomized,
  /// For example if [offset] is (100, 100) and [randomDislocationOffset] is (10,10),
  /// Each layer can be moved to maximum between 90 and 110.
  final Offset randomDislocationOffset;

  /// Number of layers of images,
  /// The more of them the better effect but the more heavy it is for CPU
  final int numberOfBuckets;

  /// Quick helper to snap widgets when touched
  /// If true wraps the widget in [GestureDetector] and starts [snap] when tapped
  /// Defaults to false
  final bool snapOnTap;

  /// Function that gets called when snap ends
  final VoidCallback onSnapped;

  const Snappable({
    Key? key,
    required this.child,
    this.offset = const Offset(64.0, -32.0),
    this.duration = const Duration(milliseconds: 5000),
    this.randomDislocationOffset = const Offset(64.0, 32.0),
    this.numberOfBuckets = 16,
    this.snapOnTap = false,
    required this.onSnapped,
  }) : super(key: key);

  @override
  State<Snappable> createState() => SnappableState();
}

class SnappableState extends State<Snappable> with SingleTickerProviderStateMixin {
  static const double _singleLayerAnimationLength = 0.6;
  static const double _lastLayerAnimationStart = 1.0 - _singleLayerAnimationLength;

  /// Main snap effect controller
  late AnimationController _animationController;

  bool get isGone => _animationController.isCompleted;

  /// Key to get image of a [widget.child]
  final GlobalKey _globalKey = GlobalKey();

  /// Layers of image
  List<Uint8List>? _layers;

  /// Values from -1 to 1 to dislocate the layers a bit
  late List<double> _randoms;

  /// Size of child widget
  late Size size;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onSnapped();
      }
    });
  }

  @override
  void didUpdateWidget(covariant Snappable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.duration = widget.duration;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.snapOnTap ? () => isGone ? reset() : snap() : null,
      child: Stack(
        children: [
          if(_layers != null) ..._layers!.map(_imageToWidget),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_animationController.isDismissed) {
                return child!;
              } else {
                return const SizedBox();
              }
            },
            child: RepaintBoundary(
              key: _globalKey,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageToWidget(Uint8List layer) {
    // get layer's index in the list
    int index = _layers!.indexOf(layer);

    // Based on index, calculate when this layer should start and end
    double animationStart = (index / _layers!.length) * _lastLayerAnimationStart;
    double animationEnd = animationStart + _singleLayerAnimationLength;

    // Create interval animation using only part of whole animation
    CurvedAnimation animation = CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          animationStart,
          animationEnd,
          curve: Curves.easeOut,
        ),
    );

    Offset randomOffset = widget.randomDislocationOffset.scale(
        _randoms[index], _randoms[index]
    );

    Animation<Offset> offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.offset + randomOffset,
    ).animate(animation);

    return AnimatedBuilder(
      animation: _animationController,
      child: Image.memory(layer),
      builder: (context, child) {
        return Transform.translate(
          offset: offsetAnimation.value,
          child: Opacity(
            opacity: math.cos(animation.value * math.pi / 2.0),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> snap() async {
    // Get image from child
    final fullImage = await _getImageFromWidget();

    // Create an image every bucket
    List<image.Image> _images = List<image.Image>.generate(widget.numberOfBuckets, (index) => image.Image(fullImage!.width, fullImage.height));

    // For every line of pixels
    for (int y = 0; y < fullImage!.height; y++) {
      // Generate weight list of probabilities determining
      // to which bucket should given pixels go
      List<int> weights = List.generate(widget.numberOfBuckets, (bucket) => _gauss(y / fullImage.height, bucket / widget.numberOfBuckets));
      int sumOfWeights = weights.fold(0, (previousValue, element) => previousValue+ element);

      // For every pixel in a line
      for (int x = 0; x < fullImage.width; x++) {
        // Get the pixel from fullImage
        int pixel = fullImage.getPixel(x, y);
        // Choose a bucket for a pixel
        int imageIndex = _pickABucket(weights, sumOfWeights);
        // Set the pixel from chosen bucket
        _images[imageIndex].setPixel(x, y, pixel);
      }
    }

    _layers = await compute<List<image.Image>, List<Uint8List>>(_encodeImages, _images);

    // Prepare random dislocations and set state
    setState(() {
      _randoms = List.generate(widget.numberOfBuckets, (index) => (math.Random().nextDouble() - 0.5) * 2.0);
    });
  }

  /// Gets an Image from a [child] and caches [size] for later us
  Future<image.Image?> _getImageFromWidget() async {
    RenderRepaintBoundary? boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    // Cache image for later
    size = boundary!.size;
    var img = await boundary.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData?.buffer.asUint8List();
    return image.decodeImage(pngBytes!);
  }

  int _gauss(double center, double value) => (1000 * math.exp(-(math.pow((value - center), 2) / 0.14))).round();

  /// Returns index of a randomly chosen bucket
  int _pickABucket(List<int> weights, int sumOfWeights) {
    int rand = math.Random().nextInt(sumOfWeights);
    int chosenImage = 0;
    for (int i = 0; i < widget.numberOfBuckets; i++) {
      if (rand < weights[i]) {
        chosenImage = i;
        break;
      }
      rand -= weights[i];
    }
    return chosenImage;
  }

  /// This is slow! Run it in separate isolate
  List<Uint8List> _encodeImages(List<image.Image> images) {
    return images.map((img) => Uint8List.fromList(image.encodePng(img))).toList();
  }

  void reset() {
    setState(() {
      _layers = null;
      _animationController.reset();
    });
  }
}



