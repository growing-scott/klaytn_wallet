import 'dart:math';

class CaverHelper {

  fromPeb(String hex) {
    print(hex);
    hex = hex.replaceAll('0x', '');
    final pebValue = BigInt.parse(hex, radix: 16);
    final pebPow = pow(10, 18);
    return (pebValue / BigInt.from(pebPow));
  }

}