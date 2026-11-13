import 'dart:math';

final Random rng = Random();

int ri(int a, int b) => a + rng.nextInt(b - a + 1);
bool chance(double p) => rng.nextDouble() < p;
T pick<T>(List<T> l) => l[rng.nextInt(l.length)];
double rd(double a, double b) => a + rng.nextDouble() * (b - a);
int clampI(int v, int a, int b) => v < a ? a : (v > b ? b : v);
double clampD(double v, double a, double b) => v < a ? a : (v > b ? b : v);

T? weighted<T>(List<T> l, double Function(T) w) {
  if (l.isEmpty) return null;
  double total = 0;
  for (final x in l) {
    total += w(x);
  }
  if (total <= 0) return null;
  double r = rng.nextDouble() * total;
  for (final x in l) {
    r -= w(x);
    if (r <= 0) return x;
  }
  return l.last;
}

String fmt(num n) {
  final neg = n < 0;
  String s = n.abs().round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return (neg ? '-' : '') + b.toString();
}

Map<String, int> toIntMap(dynamic m) {
  final out = <String, int>{};
  if (m is Map) {
    m.forEach((k, v) => out[k.toString()] = (v as num).toInt());
  }
  return out;
}

Map<String, double> toDblMap(dynamic m) {
  final out = <String, double>{};
  if (m is Map) {
    m.forEach((k, v) => out[k.toString()] = (v as num).toDouble());
  }
  return out;
}

List<String> toStrList(dynamic l) {
  final out = <String>[];
  if (l is List) {
    for (final x in l) {
      out.add(x.toString());
    }
  }
  return out;
}
