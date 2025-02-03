import 'package:blue/Roleselection.dart';
import 'package:flutter/material.dart';
import 'package:all_bluetooth/all_bluetooth.dart'; // Import your Bluetooth library

// ignore: camel_case_types
class option4 extends StatefulWidget {
  final BluetoothDevice device; // Define the device parameter
  final String selectedoption;

  const option4(
      {super.key,
      required this.device,
      required this.selectedoption}); // Add device to constructor

  @override
  State<option4> createState() => _option4State();
}

// ignore: camel_case_types
class _option4State extends State<option4> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      'assets/2preview.png', // Replace with your image path
                      width: 180, // Set the desired width
                      height: 180, // Set the desired height
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 40), // Adds space between the container and the button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    // Navigate to the DragDropCircuitApp screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectionScreen(
                          data: widget.selectedoption,
                        ), // Pass the device parameter
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
