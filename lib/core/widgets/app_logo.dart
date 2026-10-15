import 'package:flutter/material.dart';

/// The TubeFlow logo (rounded red square with a play + upload mark).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon/logo.png',
      width: size,
      height: size,
      semanticLabel: 'TubeFlow logo',
    );
  }
}

/// App bar title: logo + app name.
class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: 28),
        SizedBox(width: 10),
        Text('TubeFlow'),
      ],
    );
  }
}
