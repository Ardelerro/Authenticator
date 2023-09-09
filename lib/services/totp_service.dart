import "package:crypto/crypto.dart";


class TOTPService{

  static const int _timeStepInSeconds = 30;
  static const int _digits = 6;

  String generateTOTP(String key) {
    key = key.toUpperCase();
    List<int> keyBytes = base32Decode(key);
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ (_timeStepInSeconds * 1000);
    List<int> timeBytes = _intToBytes(currentTime);
    
    Hmac hmacSha1 = Hmac(sha1, keyBytes);
    Digest hmacDigest = hmacSha1.convert(timeBytes);
    
    int offset = hmacDigest.bytes[hmacDigest.bytes.length - 1] & 0x0F;
    int truncatedHash = (hmacDigest.bytes[offset] & 0x7F) << 24 |
                        (hmacDigest.bytes[offset + 1] & 0xFF) << 16 |
                        (hmacDigest.bytes[offset + 2] & 0xFF) << 8 |
                        (hmacDigest.bytes[offset + 3] & 0xFF);
    
    String otp = (truncatedHash % 1000000).toString().padLeft(_digits, '0');
    return otp;
  }

  List<int> _intToBytes(int value) {
    final bytes = <int>[];
    while (value != 0) {
      bytes.insert(0, value & 0xFF);
      value >>= 8;
    }
    while (bytes.length < 8) {
      bytes.insert(0, 0);
    }
    return bytes;
  }

  List<int> base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final map = <String, int>{};
    for (var i = 0; i < alphabet.length; i++) {
      map[alphabet[i]] = i;
    }
    
    final output = <int>[];
    var bits = 0;
    var value = 0;
    for (var char in input.runes) {
      final charValue = String.fromCharCode(char);
      if (map.containsKey(charValue)) {
        value = (value << 5) | map[charValue]!;
        bits += 5;
        if (bits >= 8) {
          output.add(value >> (bits - 8));
          bits -= 8;
        }
      }
    }
    return output;
  }
  
  static int getTimeStep(){
    return _timeStepInSeconds;
  }

}