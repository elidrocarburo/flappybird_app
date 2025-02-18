import 'package:flutter/material.dart';

class MyBird extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      // Define el tamaño del contenedor del pájaro
      height: 60,
      width: 60,
      // Carga la imagen del pájaro desde los assets
      child: Image.asset(
      'lib/images/bird.png'
      ),
    );
  }
}