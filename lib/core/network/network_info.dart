import 'dart:io';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl({this.host = 'google.com'});

  final String host;

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (e) {
      print('Network check failed: $e'); // works in release mode too
      return false;
    }
  }
}
