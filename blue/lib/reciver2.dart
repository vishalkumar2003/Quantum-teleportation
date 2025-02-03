import 'package:blue/bluetooth.dart';
import 'package:flutter/material.dart';

class ReceiverScreen2 extends StatefulWidget {
  final String data;
  const ReceiverScreen2({super.key, required this.data});

  @override
  State<ReceiverScreen2> createState() => _ReceiverScreen2State();
}

class _ReceiverScreen2State extends State<ReceiverScreen2> {
  final ValueNotifier<String?> _latestKetNotation =
      ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    allBluetooth.listenForData.listen((event) {
      if (event != null && _isValidKetNotation(event)) {
        _latestKetNotation.value = event;
      }
    });
  }

  bool _isValidKetNotation(String data) {
    // Valid ket notations
    final validKetNotations = ['|00>', '|11>', '|10>', '|01>'];
    return validKetNotations.contains(data);
  }

  @override
  void dispose() {
    super.dispose();
    allBluetooth.closeConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bob is receiving qubit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Blue container to display the latest ket notation
            ValueListenableBuilder<String?>(
              valueListenable: _latestKetNotation,
              builder: (context, ketNotation, child) {
                return Container(
                  color: Colors.blue,
                  width: double.infinity,
                  height: 100,
                  child: Center(
                    child: Text(
                      ketNotation ?? 'No data received',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text("Submit"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
