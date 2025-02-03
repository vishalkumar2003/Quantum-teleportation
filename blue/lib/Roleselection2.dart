import 'package:all_bluetooth/all_bluetooth.dart';
import 'package:blue/bluetooth.dart';
import 'package:blue/dragdrop2_2.dart';
import 'package:blue/reciver2.dart';
import 'package:flutter/material.dart';

class SelectionScreen2 extends StatefulWidget {
  final BluetoothDevice device; // Add the device property
  final String selectedoption;
  const SelectionScreen2({super.key,required this.device, required this.selectedoption});
  @override
  _SelectionScreen2State createState() => _SelectionScreen2State();
}
class _SelectionScreen2State extends State<SelectionScreen2> {
  String? _selectedRole; // Track the current device's selected role
  String? _receivedRole; // Track the received role from the other device
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenForBluetoothMessages(); // Start listening for Bluetooth messages
  }

  // Function to send the selected role to the other device
  void _sendBluetoothMessage(String role) {
    allBluetooth.sendMessage(role);
  }

  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // Function to listen for messages from the other device
  void _listenForBluetoothMessages() {
    allBluetooth.listenForData.listen((data) {
      List<String> parts = data!.split(':');
      setState(() {
        _receivedRole = data;
        _receivedRole = parts[0]; // Update with the received role
      });
    });
  }

  // Function to handle the selection of the Sender role
  void _onSenderSelected() {
    setState(() {
      _selectedRole = "Alice";
      _sendBluetoothMessage("Alice");
      _validateRoles(); // Validate the roles after selecting
    });
  }

  // Function to handle the selection of the Receiver role
  void _onReceiverSelected() {
    setState(() {
      _selectedRole = "Bob";
      _sendBluetoothMessage("Bob");
      _validateRoles(); // Validate the roles after selecting
    });
  }

  // Function to validate that the roles on both devices are different
  void _validateRoles() {
    if (_receivedRole == null) {
      // If the other device hasn't selected a role yet, do nothing
      return;
    }

    if (_selectedRole == _receivedRole) {
      // Show an error if both devices have selected the same role
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Error: Both devices selected the same role. Please select different roles.')),
      );
    } else {
      // Navigate to the appropriate screen based on the selected role
      if (_selectedRole == "Alice") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Drag2(data: widget.selectedoption)),
        );
      } else if (_selectedRole == "Bob") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiverScreen2(data: '',),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role selection screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Row(
              children: [
                const Text(
                  "You need to play this game as a Alice or Bob",
                  style: TextStyle(fontSize: 18),
                ),
                Text(widget.selectedoption)
              ],
            )),
            ElevatedButton(
              onPressed: _onSenderSelected, // Handle Sender button press
              child: const Text('Alice'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _onReceiverSelected();
              }, // Handle Receiver button press
              child: const Text('Bob'),
            ),
          ],
        ),
      ),
    );
  }
}
