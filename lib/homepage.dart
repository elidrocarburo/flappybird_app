import 'dart:async';
import 'package:flappybird_app/barrier.dart';
import 'package:flappybird_app/bird.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // variables bird y el valor de su posición inicial
  static double birdY= 0;
  double initialPos = birdY;
  double height = 0;

  // variables para el cálculo del salto (cuando salte y no volvamos a presionar, que este se caiga, y qué tanto salta)
  double time= 0;
  double gravity= -4.9; //how strong the gravity is
  double velocity = 3.5; //how strong the jump is
  
  // variables de altura y ancho del pájaro y de las barreras (las tuberías)
  static double birdWidth = 0.08;
  static double birdHeight = 0.8;
  static double barrierWidth = 0.5;
  static double barrierHeight = 0.6;

  // variables para las barreras (el tubo superior e inferior)
  static double barrierXuno = 1;
  double barrierXdos = barrierXuno + 1.5;

  // variable para la puntuación
  int puntuacion = 0;
  // game settings
  bool gameHasStarted = false;

  // método para verificar la puntuación, en caso de que no detecte si el pájaro pasó por
  // una de las barreras, en ese caso, suma uno al contador puntuacion
  void _checkScore() {
    if ((barrierXuno < -birdWidth / 2 && barrierXuno > -birdWidth / 2 - 0.05) ||
        (barrierXdos < -birdWidth / 2 && barrierXdos > -birdWidth / 2 - 0.05)) {
      setState(() {
        puntuacion++;
      });
    }
  }

  // método para iniciar el juego: cuando el juego detecte que ya inició, empezará a correr
  // el tiempo el cual el pájaro empieza saltar
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 60), (timer) {
      //a real physical jump is the same as an upside down parabola
      //this is a simple quadratic equation
      time += 0.05;
      height = gravity * time * time + velocity * time;

      // movimiento de los obstáculos
      setState(() {
        birdY = initialPos - height;
        if (barrierXuno < -2) {
          barrierXuno += 3.5;
        } else {
          barrierXuno -= 0.05;
        }

        if (barrierXdos < -2) {
          barrierXdos += 3.5;
        } else {
          barrierXdos -= 0.05;
        }
      });

      //check score
      _checkScore();

      //check if bird is dead
      if (birdIsDead() || birdY > 1) {
        timer.cancel();
        gameHasStarted = false;
        _showDialog();
      }

    });
  }


// método que sirve para devolver los valores iniciales cuando detecte que se perdió y regrese a
// la pantalla de inicio
void resetGame() {
  Navigator.pop(context);
  setState(() {
    birdY= 0;
    barrierXuno = 1;
    barrierXdos = barrierXuno + 1.5;
    gameHasStarted = false;
    time = 0;
    initialPos = birdY;
    puntuacion = 0;
  });
}

// método para mostrar el cuadro de 'game over' y permitir al jugador 
// regresar a la pantalla de inicio y vuelva a jugar
void _showDialog() {
  showDialog(
    context: context, 
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.brown,
        title: Center(
          child: Text(
            'G A M E  O V E R',
            style: TextStyle(color: Colors.white),
          )
        ),
        actions: [
          GestureDetector(
            onTap: resetGame,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: EdgeInsets.all(7),
                color: Colors.white,
                child: Text(
                  'P L A Y  A G A I N',
                  style: TextStyle(color: Colors.brown),
                )
              )
            )
          )
        ]
      );
    });
}

// método para hacer que el pájaro salte
void jump() {
  setState((){
    time = 0;
    initialPos = birdY;
  });
}

bool birdIsDead () {
    // Definir los límites del pájaro
    double birdLeft = -birdWidth / 2;
    double birdRight = birdWidth / 2;
    double birdTop = birdY - birdHeight / 2;
    double birdBottom = birdY + birdHeight / 2;

    // Función para verificar colisión con un obstáculo
    bool collisionWithBarrier(double barrierX, double barrierY) {
      double barrierLeft = barrierX - barrierWidth / 2;
      double barrierRight = barrierX + barrierWidth / 2;
      double barrierTop = barrierY - barrierHeight / 2;
      double barrierBottom = barrierY + barrierHeight / 2;

      return birdRight > barrierLeft &&
          birdLeft < barrierRight &&
          birdBottom > barrierTop &&
          birdTop < barrierBottom;
    }

    // Verificar colisión con cada obstáculo
    if (collisionWithBarrier(barrierXuno, -1.1) || // Obstáculo superior 1
        collisionWithBarrier(barrierXuno, 1.1) ||  // Obstáculo inferior 1
        collisionWithBarrier(barrierXdos, -1.1) || // Obstáculo superior 2
        collisionWithBarrier(barrierXdos, 1.1)) {  // Obstáculo inferior 2
      return true; // Hay colisión
    }

    return false; // No hay colisión
  }

  @override
  // widget para la detección de toques en pantalla: para iniciar el juego
  // y para que el pájaro empiece a saltar cada que hagamos un tap
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      // todo este scaffold sirve para la parte del fondo del juego
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  // este hijo se encarga de crear el fondo del cielo con el pájaro
                  AnimatedContainer(
                    alignment: Alignment(0, birdY),
                    duration: Duration(milliseconds: 0),
                    color: Colors.blue,
                    child: MyBird(),
                  ),
                  // este contenedor se encarga de acomodar el texto de 'presione para jugar'
                  // en texto blanclo
                  Container(
                    alignment: Alignment(-0.3, -0.3),
                    child: gameHasStarted
                        ? Text("")
                        : Text(
                            "T A P  T O  P L A Y",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  // se encarga de llamar a la clase MyBarrier y poder dibujar las tuberías
                  AnimatedContainer(
                    alignment: Alignment(barrierXuno, -1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(
                      size: 200.0,
                    ),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXuno, 1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(
                      size: 200.0,
                    ),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXdos, 1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(
                      size: 150.0,
                    ),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXdos, -1.1),
                    duration: Duration(milliseconds: 0),
                    child: MyBarrier(
                      size: 250.0,
                    ),
                  ),
                  // se encarga de imprimir y actualizar en una esquina la puntuación
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Text(
                      'Score: $puntuacion',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // contenedor para dibujar el pasto
            Container(
              height: 15,
              color: Colors.green,
            ),
            // de igual manera, dibuja la tierra de nuestro piso
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}