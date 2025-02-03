// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:math';
import 'package:blue/bluetooth.dart';
import 'package:blue/recivier.dart';
import 'package:flutter/material.dart';

class DragDrop2_1 extends StatefulWidget {
  final String getdata;
  DragDrop2_1({super.key, required this.getdata});

  @override
  _DragDrop2_1State createState() => _DragDrop2_1State();
}

class _DragDrop2_1State extends State<DragDrop2_1> {
  List<List<String>> circuit = List.generate(3, (_) => List.filled(5, ''));
  int qubitCount = 3;
  double scale = 1.0;
  String currentState = '|00>';
  final messageListener = ValueNotifier(<String>[]);

  @override
  void initState() {
    super.initState();
    allBluetooth.listenForData.listen((event) {
      if (event != null) {
        messageListener.value = [
          ...messageListener.value,
          event,
        ];
        if (event.startsWith('CIRCUIT:')) {
          updateCircuitFromMessage(event);
        }
      }
    });
  }

  void updateCircuitFromMessage(String event) {
    List<String> circuitData = event.replaceFirst('CIRCUIT:', '').split(',');
    setState(() {
      for (int i = 0; i < circuit.length; i++) {
        for (int j = 0; j < circuit[i].length; j++) {
          circuit[i][j] = circuitData[i * circuit[i].length + j];
        }
      }
    });
  }

  void addGate(String gate, int qubit, int position) {
    setState(() {
      if (position < circuit[qubit].length) {
        if (gate == 'CNOT') {
          addCNOTGate(qubit, position);
        } else if (gate == 'M') {
          circuit[qubit][position] = gate;
          currentState = generateRandomState();
        } else {
          circuit[qubit][position] = gate;
        }
        sendCircuitToBob();
      }
    });
  }
  void addCNOTGate(int qubit, int position) {
    for (int i = 0; i < circuit.length; i++) {
      if (i != qubit && circuit[i][position].isEmpty) {
        if (i == (qubit + 1) % circuit.length ||
            i == (qubit - 1 + circuit.length) % circuit.length) {
          circuit[qubit][position] = 'CNOT_control';
          circuit[i][position] = 'CNOT_target';
          break;
        }
      }
    }
  }

  String generateRandomState() {
    final random = Random();
    int state = random.nextInt(4);
    String binaryState = state.toRadixString(2).padLeft(2, '0');
    return '|$binaryState>';
  }

  void sendCircuitToBob() {
    List<String> flattenedCircuit = circuit.expand((row) => row).toList();
    String circuitData = 'CIRCUIT:' + flattenedCircuit.join(',');
    allBluetooth.sendMessage(circuitData);
  }

  void resetCircuit() {
    setState(() {
      circuit = List.generate(qubitCount, (_) => List.filled(5, ''));
      sendCircuitToBob();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your playing as Bob'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetCircuit,
            tooltip: 'Reset Circuit',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            color: Colors.grey[200],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DraggableGateItem(
                    gateName: 'H', gateSymbol: 'H', color: Colors.blue),
                DraggableGateItem(
                    gateName: 'X', gateSymbol: 'X', color: Colors.blue),
                DraggableGateItem(
                    gateName: 'CNOT', gateSymbol: 'CNOT', color: Colors.blue),
                DraggableGateItem(
                    gateName: 'M', gateSymbol: 'M', color: Colors.blue),
              ],
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(10.0),
              minScale: 0.5,
              maxScale: 4.0,
              onInteractionUpdate: (details) {
                setState(() {
                  scale = details.scale;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.white,
                  child: CustomPaint(
                    painter: CircuitPainter(
                      circuit: circuit,
                      getdata: widget.getdata,
                      scale: scale,
                    ),
                    child: buildDragTargets(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReceiverScreen(
                        data: widget.getdata,
                      )),
            );
          },
          child: const Text("Next"),
        ),
      ),
    );
  }

  Widget buildDragTargets() {
    return Stack(
      children: [
        for (int i = 0; i < qubitCount; i++)
          for (int j = 0; j < circuit[i].length; j++)
            Positioned(
              left: 150 * scale + j * 60.0 * scale,
              top: i * 100.0 * scale,
              child: DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 60 * scale,
                    height: 100 * scale,
                    color: Colors.transparent,
                  );
                },
                onAccept: (data) {
                  addGate(data, i, j);
                },
              ),
            ),
      ],
    );
  }
}

class DraggableGateItem extends StatelessWidget {
  final String gateName;
  final String gateSymbol;
  final Color color;

  const DraggableGateItem({
    Key? key,
    required this.gateName,
    required this.gateSymbol,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: gateName,
      feedback:
          GateItem(gateName: gateName, gateSymbol: gateSymbol, color: color),
      childWhenDragging: GateItem(
          gateName: gateName,
          gateSymbol: gateSymbol,
          color: color.withOpacity(0.5)),
      child: GateItem(gateName: gateName, gateSymbol: gateSymbol, color: color),
    );
  }
}

class GateItem extends StatelessWidget {
  final String gateName;
  final String gateSymbol;
  final Color color;

  const GateItem({
    Key? key,
    required this.gateName,
    required this.gateSymbol,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          gateSymbol,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

void drawSquareBracket(
    Canvas canvas, double scale, double verticalSpacing, double leftPadding) {
  final paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 4 * scale
    ..style = PaintingStyle.stroke;

  final path = Path();

  double bracketStartY = verticalSpacing / 2;
  double bracketEndY = verticalSpacing * 2 - verticalSpacing / 2;
  double bracketX = leftPadding - 90 * scale;

  path.moveTo(bracketX, bracketStartY);
  path.lineTo(bracketX, bracketEndY);

  path.moveTo(bracketX, bracketStartY);
  path.lineTo(bracketX + 20 * scale, bracketStartY);

  path.moveTo(bracketX, bracketEndY);
  path.lineTo(bracketX + 20 * scale, bracketEndY);

  canvas.drawPath(path, paint);
}

class CircuitPainter extends CustomPainter {
  final List<List<String>> circuit;
  final double scale;
  final String getdata;

  CircuitPainter({
    required this.circuit,
    required this.getdata,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2 * scale;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    double gateSize = 40 * scale;
    double verticalSpacing = 100 * scale;
    double horizontalSpacing = 60 * scale;
    double leftPadding = 150 * scale;

    drawSquareBracket(canvas, scale, verticalSpacing, leftPadding);

    for (int i = 0; i < circuit.length; i++) {
      String name = (i == 0) ? 'Bob      ' : 'Alice      ';
      String label = '$name (q$i) $getdata';

      canvas.drawLine(
        Offset(leftPadding, i * verticalSpacing + verticalSpacing / 2),
        Offset(leftPadding + circuit[i].length * horizontalSpacing,
            i * verticalSpacing + verticalSpacing / 2),
        linePaint,
      );

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14 * scale,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftPadding - 120 * scale,
          i * verticalSpacing + (verticalSpacing - textPainter.height) / 2,
        ),
      );
    }

    for (int i = 0; i < circuit.length; i++) {
      for (int j = 0; j < circuit[i].length; j++) {
        if (circuit[i][j].isNotEmpty) {
          drawGate(canvas, circuit[i][j], leftPadding + j * horizontalSpacing,
              i * verticalSpacing + verticalSpacing / 2, gateSize);
        }
      }
    }

    for (int j = 0; j < circuit[0].length; j++) {
      for (int controlQubit = 0;
          controlQubit < circuit.length;
          controlQubit++) {
        if (circuit[controlQubit][j] == 'CNOT_control') {
          for (int targetQubit = 0;
              targetQubit < circuit.length;
              targetQubit++) {
            if (circuit[targetQubit][j] == 'CNOT_target' &&
                (targetQubit - controlQubit).abs() == 1) {
              final cnotPaint = Paint()
                ..color = Colors.blue
                ..strokeWidth = 2 * scale;

              double controlY =
                  controlQubit * verticalSpacing + verticalSpacing / 2;
              double targetY =
                  targetQubit * verticalSpacing + verticalSpacing / 2;
              double x = leftPadding + j * horizontalSpacing;

              canvas.drawLine(
                Offset(x, controlY),
                Offset(x, targetY),
                cnotPaint,
              );

              canvas.drawCircle(
                Offset(x, controlY),
                5 * scale,
                cnotPaint,
              );

              canvas.drawCircle(
                Offset(x, targetY),
                5 * scale,
                cnotPaint,
              );
              break;
            }
          }
        }
      }
    }
  }

  void drawGate(Canvas canvas, String gate, double x, double y, double size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y), width: size, height: size),
      paint,
    );

    textPainter.text = TextSpan(
      text: gate,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12 * scale,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(CircuitPainter oldDelegate) {
    return oldDelegate.circuit != circuit ||
        oldDelegate.scale != scale ||
        oldDelegate.getdata != getdata;
  }
}
