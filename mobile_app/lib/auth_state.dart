import 'package:flutter/foundation.dart';
import 'api/api_service.dart';

/// Holds auth state and exposes login/logout to the widget tree.
class AuthState extends ChangeNotifier {
  final _api = ApiService.instance;

  bool _ready = false;
  bool get ready => _ready;

  bool get loggedIn => _api.hasToken;
  String? get role => _api.role;
  String? get email => _api.email;

  /// Load any stored tokens on startup.
  Future<void> bootstrap() async {
    await _api.loadTokens();
    _ready = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _api.login(email, password);
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await _api.register(email: email, password: password, name: name);
  }

  Future<void> logout() async {
    await _api.clearTokens();
    notifyListeners();
  }
}
