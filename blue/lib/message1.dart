import 'package:blue/measurement.dart';
import 'package:flutter/material.dart';
import 'package:all_bluetooth/all_bluetooth.dart';

// Initialize AllBluetooth
final allBluetooth = AllBluetooth();

void main() {
  runApp(const KetNotationApp());
}

class KetNotationApp extends StatelessWidget {
  const KetNotationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Message1(),
    );
  }
}

class Message1 extends StatefulWidget {
  const Message1({super.key});

  @override
  State<Message1> createState() => _Message1State();
}

class _Message1State extends State<Message1> {
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
