import 'package:blue/Roleselection.dart';
import 'package:flutter/material.dart';
import 'package:all_bluetooth/all_bluetooth.dart'; // Import your Bluetooth library

// ignore: camel_case_types
class option3 extends StatefulWidget {
  final BluetoothDevice device; // Add this line to define the device parameter
  final String selectedoption;
  const option3(
      {super.key,
      required this.device,
      required this.selectedoption}); // Add device to constructor

  @override
  State<option3> createState() => _option3State();
}

// ignore: camel_case_types
class _option3State extends State<option3> {
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
                          'assets/1preview.png', // Replace with your image path
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
                    // Navigate to DragDropCircuitApp with the device parameter
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectionScreen(
                          data: widget.selectedoption,
                        ), // Pass the device here
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
