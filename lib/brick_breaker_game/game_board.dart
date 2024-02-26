import 'dart:async';
import 'dart:math';

import 'cover_screen.dart';
import 'game_over_screen.dart';
import 'my_ball.dart';
import 'player.dart';
import 'package:flutter/material.dart';

class GameBoardBrickBreaker extends StatefulWidget {
  const GameBoardBrickBreaker({super.key});

  @override
  State<GameBoardBrickBreaker> createState() => _GameBoardBrickBreakerState();
}

enum Direction { up, down, left, right }

class _GameBoardBrickBreakerState extends State<GameBoardBrickBreaker> {
  List randomList = [];

  //game settings
  bool isGameStarted = false;
  bool isGameOver = false;
  bool youWin = false;
  double playerWidth = 0.4;

  //ball variables
  double ballX = 0;
  double ballY = 0;
  double ballXIncrement = 0.01;
  double ballYIncrement = 0.01;
  Direction ballXDirection = Direction.left;
  Direction ballYDirection = Direction.down;

  //player variables
  double playerX = -0.2;

  //brick variables
  double brickX = 0;
  double brickY = -0.98;
  double brickHeight = 0.02;
  double brickWidth = 0.2;
  bool isBrickBroken = false;

  //score point variables
  int ScorePoint = 0;

  //Timer variables
  int timers = 0;

  updateDirection() {
    //ball hits player
    if (ballY >= 0.95 && ballX >= playerX && ballX <= playerX + playerWidth) {
      ballYDirection = Direction.up;
    }
    //ball hits top of screen
    else if (ballY <= -1) {
      ballYDirection = Direction.down;
    }
    //ball hits left
    if (ballX <= -1) {
      ballXDirection = Direction.left;
    }
    //ball hits right
    else if (ballX >= 1) {
      ballXDirection = Direction.right;
    }
  }

  moveBall() {
    //move left and right
    if (ballXDirection == Direction.left) {
      ballX += ballXIncrement;
    } else if (ballXDirection == Direction.right) {
      ballX -= ballXIncrement;
    }
    //move up and down
    if (ballYDirection == Direction.down) {
      ballY += ballYIncrement;
    } else if (ballYDirection == Direction.up) {
      ballY -= ballYIncrement;
    }
  }

  moveLeft() {
    if (!(playerX <= -1)) {
      playerX -= 0.2;
    }
  }

  moveRight() {
    if (!(playerX + playerWidth >= 1)) {
      playerX += 0.2;
    }
  }

  void startGame() {
    isGameOver = false;
    isGameStarted = true;
    ScorePoint = 0;
    timers = 0;
    Random random = Random();
    randomList.clear();
    while (randomList.length < 20) {
      for (int i = 1; i < 21; i++) {
        List<Map<String, dynamic>> list = [];
        while (list.length < 10) {
          int randomNumber = random.nextInt(16) + 1;
          if (!list.any((item) => item['item'] == randomNumber)) {
            list.add({
              'item': randomNumber,
              "isBrickBroken": false,
              "count": random.nextInt(2)
            });
          }
        }
        randomList.add({"row$i": list});
      }
    }
    Timer.periodic(const Duration(seconds: 1), (timer) {
      timers++;
    });

    Timer.periodic(const Duration(milliseconds: 15), (timer) {
      moveBall();
      updateDirection();
      checkForBrokenBricks();
      if (isAllBrickBroken()) {
        youWin = true;
        isGameStarted = false;
      }
      if (isPlayerDead()) {
        timer.cancel();
        isGameOver = true;
        isGameStarted = false;
        ballX = 0;
        ballY = 0;
        playerWidth = 0.4;
        playerX = -0.2;
      }

      setState(() {});
    });
  }

  bool isPlayerDead() {
    if (ballY >= 0.98) {
      return true;
    }
    return false;
  }

  void checkForBrokenBricks() {
    for (int i = 1; i <= randomList.length; i++) {
      for (int j = 1; j <= randomList[i - 1]['row$i'].length; j++) {
        if (ballX >=
                -1 +
                    randomList[i - 1]['row$i'][j - 1]['item'] * 0.125 -
                    0.125 &&
            ballX <= -1 + randomList[i - 1]['row$i'][j - 1]['item'] * 0.125 &&
            ballY <= -0.98 + 2 * i * 0.025 &&
            randomList[i - 1]['row$i'][j - 1]['isBrickBroken'] == false) {
          if (randomList[i - 1]['row$i'][j - 1]['count'] == 1) {
            randomList[i - 1]['row$i'][j - 1]['count'] -= 1;
          } else {
            randomList[i - 1]['row$i'][j - 1]['isBrickBroken'] = true;
            ScorePoint++;
          }
          double leftSideDist = (-1 +
                  randomList[i - 1]['row$i'][j - 1]['item'] * 0.125 -
                  0.125 -
                  ballX)
              .abs();
          double rightSideDist =
              (-1 + randomList[i - 1]['row$i'][j - 1]['item'] * 0.125 - ballX)
                  .abs();
          double bottomSideDist =
              (-0.98 - 0.025 + (i - 1) * (2 * 0.025) + 2 * 0.025 - ballY).abs();
          double topSideDist =
              (-0.98 - 0.025 + (i - 1) * (2 * 0.025) - ballY).abs();

          String min =
              findMin(leftSideDist, rightSideDist, topSideDist, bottomSideDist);

          switch (min) {
            case 'left':
              ballXDirection = Direction.left;
              break;
            case 'right':
              ballXDirection = Direction.right;
              break;
            case 'up':
              ballYDirection = Direction.up;
              break;
            case 'down':
              ballYDirection = Direction.down;
              break;
          }
        }
      }
    }
  }

  String findMin(double l, double r, double u, double d) {
    List<double> myList = [l, r, u, d];
    double currMin = l;
    for (int i = 0; i < myList.length; i++) {
      if (myList[i] < currMin) {
        currMin = myList[i];
      }
    }
    if (currMin == l) {
      return 'left';
    } else if (currMin == r) {
      return 'right';
    } else if (currMin == u) {
      return 'up';
    } else {
      return 'down';
    }
  }

  bool isAllBrickBroken() {
    return randomList.every((row) {
      List<Map<String, dynamic>> rowList = row.values.first;
      return rowList.every((brick) => brick["isBrickBroken"] == true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGameStarted ? null : startGame,
      child: Scaffold(
        backgroundColor: Colors.deepOrange[100],
        body: SafeArea(
            child: Stack(
          children: [
            //tap to play the game
            CoverScreen(isGameStarted: isGameStarted),
            //game Over
            youWin
                ? Container(
                    alignment: const Alignment(0, -0.3),
                    child: const Text(
                      "Y O U  W I N",
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  )
                : GameOverScreen(isGameOver: isGameOver),
            //ball
            MyBall(ballX: ballX, ballY: ballY),
            //player
            Player(playerX: playerX, playerWidth: playerWidth),
            //controls
            if (isGameStarted) ...{
              Container(
                alignment: const Alignment(1, 0.5),
                child: IconButton(
                  iconSize: 72,
                  padding: const EdgeInsets.only(right: 5),
                  onPressed: moveRight,
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ),
              Container(
                alignment: const Alignment(-1, 0.5),
                child: IconButton(
                  iconSize: 72,
                  padding: const EdgeInsets.only(left: 15),
                  onPressed: moveLeft,
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              ),
            },
            //Brick
            isGameStarted
                ? Container(
                    alignment: const Alignment(-1, -0.98),
                    child: Column(
                      children: [
                        for (int i = 1; i <= randomList.length; i++) ...{
                          Row(
                            children: [
                              for (int j = 1; j <= 16; j++) ...{
                                if (randomList[i - 1]['row$i'].any((item) =>
                                    item['item'] == j &&
                                    item['isBrickBroken'] == false)) ...{
                                  Container(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.025,
                                    width: MediaQuery.sizeOf(context).width *
                                        0.0625,
                                    decoration: BoxDecoration(
                                        color: randomList[i - 1]['row$i'].any(
                                                (item) =>
                                                    item['item'] == j &&
                                                    item['count'] == 0)
                                            ? Colors.deepOrange
                                            : Colors.orangeAccent,
                                        border: Border.all(
                                            width: 0.5, color: Colors.black87),
                                        borderRadius: BorderRadius.circular(2)),
                                  ),
                                } else ...{
                                  SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.025,
                                    width: MediaQuery.sizeOf(context).width *
                                        0.0625,
                                  )
                                }
                              }
                            ],
                          ),
                        }
                      ],
                    ))
                : const SizedBox(),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 350),
                child: Text(
                  ScorePoint.toString(),
                  style: const TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.black12),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 470),
                child: Text(
                  '${timers.toString()} Seconds',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black12),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
