import 'package:blue/Roleselection.dart';
import 'package:flutter/material.dart';
import 'package:all_bluetooth/all_bluetooth.dart'; // Import the Bluetooth package

// ignore: camel_case_types
class option2 extends StatefulWidget {
  final BluetoothDevice device; // Add the device property
  final String selectedoption;
  const option2({Key? key, required this.device, required this.selectedoption})
      : super(key: key); // Update constructor to accept device

  @override
  State<option2> createState() => _option2State();
}

// ignore: camel_case_types
class _option2State extends State<option2> {
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
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/4preview.png', // Replace with your image path
                          width: 180, // Set the desired width
                          height: 180, // Set the desired height
                        ),
                        Text(widget.selectedoption)
                      ],
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
                    // Navigate to the DragDropCircuitApp with the device
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectionScreen(
                          data: widget.selectedoption,
                        ),
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
