import 'package:flutter/foundation.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0;

  double get balance => _balance;

  void addAmount(int amount) {
    _balance += amount;
    notifyListeners();
  }

  void updateBalance(double newBalance) {
    _balance = newBalance >= 0 ? newBalance : 0;
    notifyListeners();
  }
}
