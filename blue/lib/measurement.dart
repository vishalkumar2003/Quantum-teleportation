import 'package:blue/bluetooth.dart';
import 'package:flutter/material.dart';

// Replace with the actual Bluetooth package import
class SenderScreen extends StatefulWidget {
  final String initialState;

  const SenderScreen({super.key, required this.initialState});

  @override
  State<SenderScreen> createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  final List<String> _ketNotations = ['|00>', '|11>', '|10>', '|01>'];
  late String _selectedKetNotation; // Default selected ket notation

  final messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _selectedKetNotation = widget.initialState;
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _selectedKetNotation;
    if (message.isNotEmpty) {
      allBluetooth.sendMessage(message); // Send message via Bluetooth
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('You are playing as Alice'),
        actions: [
          ElevatedButton(
            onPressed: () {
              allBluetooth.closeConnection(); // Close Bluetooth connection
            },
            child: const Text("CLOSE"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Dropdown to select ket notation
            DropdownButton<String>(
              value: _selectedKetNotation,
              items: _ketNotations.map((ket) {
                return DropdownMenuItem<String>(
                  value: ket,
                  child: Text(ket),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKetNotation = value!;
                });
              },
              isExpanded: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  height: 40,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      _selectedKetNotation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FloatingActionButton(
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 70,
            ),
            Image.asset('assets/circuit1.png', height: 100),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
