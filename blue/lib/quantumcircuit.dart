import 'package:flutter/foundation.dart';

class QuantumCircuitState extends ChangeNotifier {
  static final QuantumCircuitState _instance = QuantumCircuitState._internal();

  factory QuantumCircuitState() {
    return _instance;
  }

  QuantumCircuitState._internal();

  List<List<String>> _sharedCircuit =
      List.generate(3, (_) => List.filled(5, ''));

  List<List<String>> get sharedCircuit => _sharedCircuit;

  void updateCircuit(List<List<String>> newCircuit, {bool isAlice = false}) {
    // If changes are made by Bob, update Alice's circuit lines
    if (!isAlice) {
      _sharedCircuit[0] = newCircuit[0];
    }

    // If changes are made by Alice, update Bob's circuit lines
    if (isAlice) {
      _sharedCircuit[1] = newCircuit[1];
      _sharedCircuit[2] = newCircuit[2];
    }

    notifyListeners();
  }
}
