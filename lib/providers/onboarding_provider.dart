import 'package:flutter/foundation.dart';
import '../repositories/local_storage.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._storage, {required bool initiallySeen})
      : _seen = initiallySeen;

  final LocalStorage _storage;
  bool _seen;

  bool get seen => _seen;

  Future<void> setSeen(bool value) async {
    _seen = value;
    await _storage.setOnboardingSeen(value);
    notifyListeners();
  }
}
