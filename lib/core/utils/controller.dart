import 'package:flutter/material.dart';

base class StateController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @protected
  void startLoading() {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
  }

  @protected
  void stopLoading() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  @mustCallSuper
  void init() {}

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
  }
}
