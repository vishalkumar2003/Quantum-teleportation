import 'package:blue/decisionFalse.dart';
import 'package:blue/decisionTrue.dart';
import 'package:flutter/material.dart';

class Drag22 extends StatefulWidget {
  final String initialQubit;
  final String getdata;
  const Drag22({super.key, required this.initialQubit, required this.getdata});

  @override
  _Drag22State createState() => _Drag22State();
}

class _Drag22State extends State<Drag22> {
  List<List<String>> circuit = List.generate(3, (_) => List.filled(5, ''));
  int qubitCount = 3;
  double scale = 1.0;
  late String displayedQubit;

  @override
  void initState() {
    super.initState();
    displayedQubit = widget.initialQubit;
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
        } else {
          circuit[qubit][position] = gate;
        }
      }
    });
  }

  void resetCircuit() {
    setState(() {
      circuit = List.generate(qubitCount, (_) => List.filled(5, ''));
    });
  }

  bool isCircuitValid() {
    // Define the mapping for each case based on the getdata value
    final caseMap = {
      '|𝜙+⟩': {
        '|00>': ['I'],
        '|01>': ['X'],
        '|10>': ['Z'],
        '|11>': ['ZX']
      },
      '|𝜙−⟩': {
        '|00>': ['IZ'],
        '|01>': ['XZ'],
        '|10>': ['X'],
        '|11>': ['I']
      },
      '|𝜓+⟩': {
        '|00>': ['X'],
        '|01>': ['I'],
        '|10>': ['ZX'],
        '|11>': ['Z']
      },
      '|𝜓−⟩': {
        '|00>': ['XZ'],
        '|01>': ['IZ'],
        '|10>': ['I'],
        '|11>': ['X']
      }
    };

    // Get the current case's data based on getdata
    final caseData = caseMap[widget.getdata];
    if (caseData == null) {
      // If getdata does not match any case, navigate to FalseScreen
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FalseScreen()));
      return false;
    }

    // Get the required gates for the current displayed qubit
    final requiredGates = caseData[displayedQubit];
    if (requiredGates == null) {
      // If displayed qubit does not match any state, navigate to FalseScreen
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FalseScreen()));
      return false;
    }

    // Validate the circuit
    for (int i = 0; i < circuit.length; i++) {
      for (int j = 0; j < circuit[i].length; j++) {
        final currentGate = circuit[i][j];

        // Ignore empty slots
        if (currentGate.isNotEmpty) {
          // Check if the gate matches any of the required gates
          if (!requiredGates.contains(currentGate)) {
            // Navigate to FalseScreen if any gate is incorrect
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FalseScreen()));
            return false;
          }
        }
      }
    }

    // Navigate to TrueScreen if all validations pass
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TrueScreen()));
    return true;
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
          // Qubit Display Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Center(
              child: Text(
                'Current Qubit: $displayedQubit,',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            height: 40,
            color: Colors.grey[200],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Drag22GateItem(
                    gateName: 'I', gateSymbol: 'I', color: Colors.blue),
                Drag22GateItem(
                    gateName: 'X', gateSymbol: 'X', color: Colors.blue),
                Drag22GateItem(
                    gateName: 'Z', gateSymbol: 'Z', color: Colors.blue),
                Drag22GateItem(
                    gateName: 'ZX', gateSymbol: 'ZX', color: Colors.blue),
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
                    painter:
                        Drag22CircuitPainter(circuit: circuit, scale: scale),
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
            const Center(
                child: Text(
                    "Upon measuring her qubits, Alice seems to have obtained the state 0 as output to her qubit and 1 as the output for the entangled qubit.\n Now, you may kindly apply appropriate gates to teleport the quantum state.")),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                if (isCircuitValid()) {
                  // Navigate to TrueScreen when circuit is valid
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrueScreen()),
                  );
                } else {
                  // Navigate to FalseScreen when circuit is invalid
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FalseScreen()),
                  );
                }
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}

class Drag22GateItem extends StatelessWidget {
  final String gateName;
  final String gateSymbol;
  final Color color;

  const Drag22GateItem({
    Key? key,
    required this.gateName,
    required this.gateSymbol,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: gateName,
      feedback: Drag22GateItemWidget(
          gateName: gateName, gateSymbol: gateSymbol, color: color),
      childWhenDragging: Drag22GateItemWidget(
          gateName: gateName,
          gateSymbol: gateSymbol,
          color: color.withOpacity(0.5)),
      child: Drag22GateItemWidget(
          gateName: gateName, gateSymbol: gateSymbol, color: color),
    );
  }
}

class Drag22GateItemWidget extends StatelessWidget {
  final String gateName;
  final String gateSymbol;
  final Color color;

  const Drag22GateItemWidget({
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

class Drag22CircuitPainter extends CustomPainter {
  final List<List<String>> circuit;
  final double scale;

  Drag22CircuitPainter({required this.circuit, this.scale = 1.0});

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

    // Draw gate background
    switch (gate) {
      case 'I':
      case 'Z':
      case 'ZX':
      case 'X':
        paint.color = Colors.blue;
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: size, height: size),
            paint);
        textPainter.paint(canvas,
            Offset(x - textPainter.width / 2, y - textPainter.height / 2));
        break;
      case 'CNOT_control':
      case 'CNOT_target':
        // Don't draw anything here, it's handled in the main paint method
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
