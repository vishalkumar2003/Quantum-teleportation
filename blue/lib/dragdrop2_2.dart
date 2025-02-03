import 'package:flutter/material.dart';
import 'dart:math';
import 'package:blue/bluetooth.dart';

class Drag2 extends StatefulWidget {
  final String data;
  const Drag2({super.key, required this.data});

  @override
  _Drag2State createState() => _Drag2State();
}

class _Drag2State extends State<Drag2> {
  List<List<String>> circuit = List.generate(3, (_) => List.filled(5, ''));
  int qubitCount = 3;
  double scale = 1.0;
  String currentState = '|00>'; // Default state

  @override
  void initState() {
    super.initState();
    // Listen for incoming circuit data from Alice
    allBluetooth.listenForData.listen((event) {
      if (event != null && event.startsWith('CIRCUIT:')) {
        // Parse the circuit data
        List<String> circuitData =
            event.replaceFirst('CIRCUIT:', '').split(',');
        setState(() {
          for (int i = 0; i < circuit.length; i++) {
            for (int j = 0; j < circuit[i].length; j++) {
              circuit[i][j] = circuitData[i * circuit[i].length + j];
            }
          }
        });
      }
    });
  }

  String generateRandomState() {
    // Randomly generate a 2-qubit state
    final random = Random();
    int state = random.nextInt(4); // 0, 1, 2, or 3

    // Convert to binary representation
    String binaryState = state.toRadixString(2).padLeft(2, '0');

    return '|$binaryState>';
  }

  void addGate(String gate, int qubit, int position) {
    setState(() {
      if (position < circuit[qubit].length) {
        if (gate == 'CNOT') {
          // Find adjacent qubit for CNOT control/target
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
        } else if (gate == 'M') {
          // When measurement gate is added, generate a random state
          circuit[qubit][position] = gate;
          currentState = generateRandomState();
        } else {
          circuit[qubit][position] = gate;
        }

        // Send circuit data to Alice
        sendCircuitToAlice();
      }
    });
  }

  void sendCircuitToAlice() {
    // Convert circuit to a comma-separated string
    List<String> flattenedCircuit = circuit.expand((row) => row).toList();
    String circuitData = 'CIRCUIT:' + flattenedCircuit.join(',');
    allBluetooth.sendMessage(circuitData);
  }

  void resetCircuit() {
    setState(() {
      circuit = List.generate(qubitCount, (_) => List.filled(5, ''));
      currentState = '|00>'; // Reset to default state
      sendCircuitToAlice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your playing as Alice'),
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
            child: Column(
              children: [
                Text("Applying CNOT Gate"),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DraggableGateItem(
                        gateName: 'CNOT',
                        gateSymbol: 'CNOT',
                        color: Colors.blue),
                  ],
                ),
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
                    painter: CircuitPainter(circuit: circuit, scale: scale),
                    child: Stack(
                      children: [
                        for (int i = 0; i < qubitCount; i++)
                          for (int j = 0; j < circuit[i].length; j++)
                            Positioned(
                              left: 120 * scale + j * 60.0 * scale,
                              top: i * 80.0 * scale,
                              child: DragTarget<String>(
                                builder:
                                    (context, candidateData, rejectedData) {
                                  return Container(
                                    width: 60 * scale,
                                    height: 80 * scale,
                                    color: Colors.transparent,
                                  );
                                },
                                onAccept: (data) {
                                  addGate(data, i, j);
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please share the outcome of the measurement with Bob'),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  currentState,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Drag2(data: widget.data)),
                );
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
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
      width: 80,
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

class CircuitPainter extends CustomPainter {
  final List<List<String>> circuit;
  final double scale;

  CircuitPainter({required this.circuit, this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2 * scale;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Calculate dimensions
    double gateSize = 40 * scale;
    double verticalSpacing = 80 * scale;
    double horizontalSpacing = 60 * scale;
    double leftPadding = 120 * scale;

    // Draw curly bracket
    drawSquareBracket(canvas, scale, verticalSpacing, leftPadding);

    // Draw qubit lines and labels
    for (int i = 0; i < circuit.length; i++) {
      // Determine the label (Alice or Bob)
      String label = i == 0 ? 'Bob' : 'Alice';

      // Draw the name label
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14 * scale,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      // Position the name label
      textPainter.paint(
          canvas,
          Offset(
              10 * scale,
              i * verticalSpacing +
                  (verticalSpacing - textPainter.height) / 2));

      // Draw the qubit number and state
      textPainter.text = TextSpan(
        text: 'q$i |0⟩',
        style: TextStyle(
          color: Colors.black,
          fontSize: 14 * scale,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      // Position the qubit number and state
      textPainter.paint(
          canvas,
          Offset(
              leftPadding - textPainter.width - 10 * scale,
              i * verticalSpacing +
                  (verticalSpacing - textPainter.height) / 2));
      // Draw qubit line
      canvas.drawLine(
        Offset(leftPadding, i * verticalSpacing + verticalSpacing / 2),
        Offset(leftPadding + circuit[i].length * horizontalSpacing,
            i * verticalSpacing + verticalSpacing / 2),
        paint,
      );
    }

    // Draw gates
    for (int i = 0; i < circuit.length; i++) {
      for (int j = 0; j < circuit[i].length; j++) {
        if (circuit[i][j].isNotEmpty) {
          drawGate(
              canvas,
              circuit[i][j],
              leftPadding + j * horizontalSpacing + horizontalSpacing / 2,
              i * verticalSpacing + verticalSpacing / 2,
              gateSize);
        }
      }
    }
    // Draw CNOT connections
    for (int j = 0; j < circuit[0].length; j++) {
      for (int controlQubit = 0;
          controlQubit < circuit.length;
          controlQubit++) {
        if (circuit[controlQubit][j] == 'CNOT_control') {
          // Find the target qubit
          for (int targetQubit = 0;
              targetQubit < circuit.length;
              targetQubit++) {
            if (circuit[targetQubit][j] == 'CNOT_target' &&
                (targetQubit - controlQubit).abs() == 1) {
              final cnotPaint = Paint()
                ..color = Colors.blue
                ..strokeWidth = 2 * scale;

              double x =
                  leftPadding + j * horizontalSpacing + horizontalSpacing / 2;
              double y1 = controlQubit * verticalSpacing + verticalSpacing / 2;
              double y2 = targetQubit * verticalSpacing + verticalSpacing / 2;

              // Draw vertical line for CNOT connection
              canvas.drawLine(Offset(x, y1), Offset(x, y2), cnotPaint);

              // Draw control point (filled circle)
              canvas.drawCircle(Offset(x, y1), 4 * scale, cnotPaint);

              // Draw target point (circle with plus)
              canvas.drawCircle(Offset(x, y2), 10 * scale,
                  cnotPaint..style = PaintingStyle.stroke);
              canvas.drawLine(Offset(x - 10 * scale, y2),
                  Offset(x + 10 * scale, y2), cnotPaint);
              canvas.drawLine(Offset(x, y2 - 10 * scale),
                  Offset(x, y2 + 10 * scale), cnotPaint);
            }
          }
        }
      }
    }
  }

  void drawSquareBracket(
      Canvas canvas, double scale, double verticalSpacing, double leftPadding) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4 * scale
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Adjust the left padding to add space between bracket and qubit lines
    double bracketStartY = verticalSpacing / 2; // Bob's qubit line
    double bracketEndY = verticalSpacing * 1.5; // Alice's first qubit line
    double bracketX = leftPadding - 70 * scale; // Adjusted for more space

    // Begin the curly bracket path
    path.moveTo(bracketX, bracketStartY); // Move to the start position

    // Draw the left vertical line of the curly bracket
    path.lineTo(bracketX, bracketEndY);

    // Draw the top horizontal line of the curly bracket
    path.moveTo(bracketX, bracketStartY);
    path.lineTo(
        bracketX + 20 * scale, bracketStartY); // Increased horizontal space

    // Draw the bottom horizontal line of the curly bracket
    path.moveTo(bracketX, bracketEndY);
    path.lineTo(
        bracketX + 20 * scale, bracketEndY); // Increased horizontal space

    // Draw the curly bracket path on the canvas
    canvas.drawPath(path, paint);
  }

  void drawGate(Canvas canvas, String gate, double x, double y, double size) {
    final paint = Paint();
    final textPainter = TextPainter(
      text: TextSpan(
        text: gate == 'CNOT_control' || gate == 'CNOT_target' ? '' : gate,
        style: TextStyle(
            color: Colors.white,
            fontSize: 14 * scale,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    switch (gate) {
      case 'H':
      case 'M':
      case 'X':
        paint.color = Colors.blue;
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: size, height: size),
            paint);
        break;
      case 'CNOT_control':
      case 'CNOT_target':
        // Don't draw anything here, it's handled in the main paint method
        return;
    }

    textPainter.paint(
        canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
