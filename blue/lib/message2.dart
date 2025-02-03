// Receiver screen
import 'package:blue/measurement.dart';
import 'package:flutter/material.dart';

// Initialize AllBluetooth
void main() {
  runApp(const Message2());
}

class Message2 extends StatefulWidget {
  const Message2({super.key});

  @override
  State<Message2> createState() => _Message2State();
}

class _Message2State extends State<Message2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Now, Alice and Bob depart in space. \nAlice wants to send an arbitrary Quantum state \n|PSI>=A|0>+B|1>",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40), // Space between the text and the button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SenderScreen(
                            initialState: '',
                          )),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
