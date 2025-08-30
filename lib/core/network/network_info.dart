import 'dart:io';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl({this.host = 'example.com'});

  final String host;

  @override
  Future<bool> get isConnected async {
    try {
      final List<InternetAddress> result = await InternetAddress.lookup(host);
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException {
      return false;
    }
  }
}
