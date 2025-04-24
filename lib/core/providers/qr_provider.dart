import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrProvider extends ChangeNotifier {
  bool _isScanning = false;
  String? _qrData;
  String? _error;
  bool _isLoading = false;

  bool get isScanning => _isScanning;
  String? get qrData => _qrData;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> startScanning() async {
    _isScanning = true;
    _error = null;
    notifyListeners();
  }

  Future<void> stopScanning() async {
    _isScanning = false;
    notifyListeners();
  }

  Future<bool> scanQrCode(Barcode barcode) async {
    try {
      _qrData = barcode.rawValue;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}