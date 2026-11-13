import 'dart:math';
import 'package:flutter/material.dart';
import 'sprites.dart';

final Paint _p = Paint()..isAntiAlias = false;

void _rect(Canvas c, double x, double y, double w, double h, int col,
    [int alpha = 255]) {
  _p.color = Color(col).withAlpha(alpha);
  c.drawRect(Rect.fromLTWH(x, y, w, h), _p);
}

/// يرسم Sprite من شبكة نصية. [tint] يستبدل الحرف m.
void paintSprite(Canvas c, Sprite s, double x, double y, double px,
    {bool flip = false, int alpha = 255, int? tint, int? flash}) {
  for (int j = 0; j < s.h; j++) {
    final row = s.rows[j];
    int i = 0;
    while (i < row.length) {
      final ch = row[i];
      if (ch == '.') {
        i++;
        continue;
      }
      int k = i;
      while (k + 1 < row.length && row[k + 1] == ch) {
        k++;
      }
      int col;
      if (ch == 'm' && tint != null) {
        col = tint;
      } else {
        col = s.pal[ch] ?? kPal[ch] ?? 0xFFFF00FF;
      }
      if (flash != null) col = flash;
      final len = k - i + 1;
      final dx = flip ? (s.w - i - len) : i;
      _rect(c, x + dx * px, y + j * px, len * px + 0.6, px + 0.6, col, alpha);
      i = k + 1;
    }
  }
}

// ---------------- المظهر البشري ----------------
const List<int> kSkins = [0xFFF2C9A0, 0xFFD9A577, 0xFFB57F55, 0xFF8A5A3C];
const List<int> kHairs = [
  0xFF1B1B2B,
  0xFF5A3A22,
  0xFFD8D8E8,
  0xFFB8462E,
  0xFF2E5CD0,
  0xFFE8C766
];
const List<int> kRobes = [
  0xFF3A6EA5,
  0xFF8E3B3B,
  0xFF3F7F5A,
  0xFF6A4C93,
  0xFF8A7440,
  0xFF2C2C3A,
  0xFFD8D8E8
];

class Look {
  final int skin, hair, robe, style;
  final bool female;
  const Look(
      {this.skin = 0,
      this.hair = 0,
      this.robe = 0,
      this.style = 0,
      this.female = false});

  Map<String, dynamic> toJson() =>
      {'s': skin, 'h': hair, 'r': robe, 'st': style, 'f': female};
  static Look fromJson(dynamic j) {
    if (j is! Map) return const Look();
    return Look(
        skin: (j['s'] ?? 0) as int,
        hair: (j['h'] ?? 0) as int,
        robe: (j['r'] ?? 0) as int,
        style: (j['st'] ?? 0) as int,
        female: (j['f'] ?? false) as bool);
  }

  static Look fromSeed(int seed, bool female) {
    final r = Random(seed);
    return Look(
        skin: r.nextInt(kSkins.length),
        hair: r.nextInt(kHairs.length),
        robe: r.nextInt(kRobes.length),
        style: r.nextInt(3),
        female: female);
  }
}

class _W {
  final Canvas c;
  final double x, y, px;
  final int dir;
  _W(this.c, this.x, this.y, this.px, this.dir);
  void r(double ux, double uy, double uw, double uh, int col, [int a = 255]) {
    final left = dir > 0 ? ux : -ux - uw;
    _rect(c, x + left * px, y + uy * px, uw * px, uh * px, col, a);
  }
}

/// يرسم شخصية بشرية بالبكسل. (x,y) = موضع القدمين.
void paintHuman(Canvas c, double x, double y, double px, Look look,
    {int dir = 1,
    double walk = 0,
    double atk = -1,
    String weapon = 'sword',
    bool crouch = false,
    int alpha = 255,
    int? glow,
    int? flash,
    int? robeOverride}) {
  final w = _W(c, x, y, px, dir);
  final skin = flash ?? kSkins[look.skin % kSkins.length];
  final hair = flash ?? kHairs[look.hair % kHairs.length];
  final robe = flash ?? (robeOverride ?? kRobes[look.robe % kRobes.length]);
  final dark = flash ?? 0xFF1A1426;
  final trim = flash ?? 0xFFE8C766;
  if (glow != null) {
    _rect(c, x - 9 * px, y - 26 * px, 18 * px, 28 * px, glow, 38);
  }
  final cr = crouch ? 3.0 : 0.0;
  // ظل
  _rect(c, x - 6 * px, y - 0.5 * px, 12 * px, 1.2 * px, 0xFF000000, 70);
  // الساقان
  final s1 = sin(walk) * 2.2;
  w.r(-3 + s1, -6 + cr, 2.4, 6 - cr, dark, alpha);
  w.r(0.6 - s1, -6 + cr, 2.4, 6 - cr, 0xFF2C2440, alpha);
  // الذراع الخلفية
  w.r(-5, -14 + cr, 2, 6, robe, alpha);
  // الجسم
  w.r(-3.5, -15 + cr, 7, 10, robe, alpha);
  w.r(-3.5, -8 + cr, 7, 1.2, trim, alpha); // حزام
  if (look.female) {
    w.r(-4.5, -7 + cr, 9, 3, robe, alpha);
  }
  // الرأس
  w.r(-3, -22 + cr, 6, 6.5, skin, alpha);
  w.r(-3.5, -23 + cr, 7, 2.5, hair, alpha);
  if (look.style == 1 || look.female) {
    w.r(-4, -22 + cr, 2, 7, hair, alpha); // شعر طويل
  }
  if (look.style == 2) {
    w.r(-1, -25 + cr, 3, 2.5, hair, alpha); // عقدة شعر
  }
  w.r(1, -19.5 + cr, 1.2, 1.2, dark, alpha); // عين
  // الذراع الأمامية + السلاح
  double hx = 3, hy = -12.0 + cr;
  double ang;
  if (atk >= 0) {
    if (weapon == 'spear' || weapon == 'dagger') {
      hx += sin(atk * pi) * 5;
      ang = -0.05;
    } else if (weapon == 'bow' || weapon == 'staff') {
      hx += sin(atk * pi) * 2;
      ang = weapon == 'bow' ? -1.57 : -0.6 + atk * 0.9;
    } else {
      ang = -1.9 + atk * 3.0;
    }
  } else {
    ang = weapon == 'spear' ? -0.9 : (weapon == 'bow' ? -1.57 : -0.7);
  }
  w.r(hx - 1, hy, 2.2, 2.2, skin, alpha);
  w.r(1.5, -14 + cr, 2.6, 4, robe, alpha);
  _paintWeapon(w, weapon, hx, hy + 1, ang, alpha);
}

void _paintWeapon(_W w, String type, double hx, double hy, double ang, int a) {
  void line(double len, int col, {double th = 1.2, double from = 0}) {
    for (double i = from; i < len; i += 1) {
      w.r(hx + cos(ang) * i, hy + sin(ang) * i, th, th, col, a);
    }
  }

  switch (type) {
    case 'none':
      break;
    case 'spear':
      line(15, 0xFF9A6B3A);
      w.r(hx + cos(ang) * 15, hy + sin(ang) * 15 - 0.6, 3, 2, 0xFFE8EEF8, a);
      break;
    case 'dagger':
      line(3, 0xFF7A4B2A);
      line(8, 0xFFD6E0F0, from: 3);
      break;
    case 'bow':
      for (double i = -7; i <= 7; i += 1) {
        final bx = hx + 2 + (i * i) * -0.05 + 2.4;
        w.r(bx, hy + i - 1, 1.2, 1.2, 0xFF8A5A2A, a);
      }
      w.r(hx + 1.2, hy - 7, 0.8, 14, 0xFFEFF3FF, 160);
      break;
    case 'staff':
      line(13, 0xFF6B4A8F);
      w.r(hx + cos(ang) * 13 - 1, hy + sin(ang) * 13 - 1.5, 3, 3, 0xFF7FE8FF, a);
      break;
    default:
      line(2.5, 0xFF7A4B2A);
      line(11, 0xFFD6E0F0, from: 2.5);
      w.r(hx + cos(ang) * 2.5 - 0.6, hy + sin(ang) * 2.5 - 1.5, 1.2, 3.4,
          0xFFE8C766, a);
  }
}

// ---------------- الخلفيات (طبقات Parallax) ----------------
class Biome {
  final int sky1, sky2, far, mid, ground, top, accent;
  final String kind; // tree pine pagoda pillar crystal house dead drip
  final bool night;
  const Biome(this.sky1, this.sky2, this.far, this.mid, this.ground, this.top,
      this.accent, this.kind,
      {this.night = false});
}

const Map<String, Biome> biomes = {
  'plains': Biome(0xFF6FB6E8, 0xFFCDEBFF, 0xFF7C9CC0, 0xFF3F7F4A, 0xFF5B4630,
      0xFF4FA64F, 0xFFE8C766, 'tree'),
  'village': Biome(0xFF77BDEB, 0xFFF4E7C8, 0xFF8AA6C4, 0xFF8A5A3C, 0xFF5B4630,
      0xFF58A850, 0xFFD9534F, 'house'),
  'city': Biome(0xFF5A8FC4, 0xFFE8D9BC, 0xFF8892A8, 0xFF6B6F85, 0xFF4A4258,
      0xFF8C86A0, 0xFFE8C766, 'house'),
  'forest': Biome(0xFF2B5D56, 0xFF7FBF98, 0xFF2F6E5A, 0xFF1C4A34, 0xFF3A2A1E,
      0xFF2F7F3C, 0xFF9CE88A, 'pine'),
  'mountain': Biome(0xFF4C6FA8, 0xFFBFD8F0, 0xFF8C9BB8, 0xFF5E6E90, 0xFF4A4A5C,
      0xFF9AA3B8, 0xFFFFFFFF, 'pagoda'),
  'cave': Biome(0xFF120E1E, 0xFF2A2142, 0xFF2D2644, 0xFF3C3158, 0xFF2A2238,
      0xFF4A3F6E, 0xFF7FE8FF, 'drip',
      night: true),
  'ruins': Biome(0xFFC8905A, 0xFFF5D9A0, 0xFFB08A6A, 0xFF8C6A4A, 0xFF6B5238,
      0xFFA88A60, 0xFFE8C766, 'pillar'),
  'swamp': Biome(0xFF2A2440, 0xFF5E6E5A, 0xFF3C4A48, 0xFF2A3A32, 0xFF2A2A22,
      0xFF4A5A3A, 0xFFB07CFF, 'dead',
      night: true),
  'snow': Biome(0xFF8AA6D0, 0xFFE8F2FF, 0xFFA0B4D4, 0xFF7C90B4, 0xFF9AA8C4,
      0xFFEAF2FF, 0xFF7FE8FF, 'crystal'),
  'void': Biome(0xFF0A0614, 0xFF3A1A5A, 0xFF2A1646, 0xFF4A2A78, 0xFF1A1030,
      0xFF7A4AC0, 0xFFE07CFF, 'crystal',
      night: true),
  'sect': Biome(0xFF4A78C0, 0xFFFFE8C0, 0xFF8AA0C8, 0xFFB04A4A, 0xFF4A3A3A,
      0xFFB8A888, 0xFFE8C766, 'pagoda'),
};

int _hash(int n) {
  int x = n * 374761393 + 668265263;
  x = (x ^ (x >> 13)) * 1274126177;
  return (x ^ (x >> 16)) & 0x7fffffff;
}

int _mix(int a, int b, double t) {
  int ch(int s) {
    final ca = (a >> s) & 255, cb = (b >> s) & 255;
    return (ca + (cb - ca) * t).round();
  }

  return 0xFF000000 | (ch(16) << 16) | (ch(8) << 8) | ch(0);
}

/// u = حجم البكسل على الشاشة، groundY = ارتفاع سطح الأرض بالبكسل الحقيقي
void paintBackground(
    Canvas c, Size size, Biome b, double camX, double u, double groundY,
    {double t = 0}) {
  // السماء (حزم)
  const bands = 8;
  final bh = groundY / bands;
  for (int i = 0; i < bands; i++) {
    _rect(c, 0, i * bh, size.width, bh + 1, _mix(b.sky1, b.sky2, i / (bands - 1)));
  }
  if (b.night) {
    for (int i = 0; i < 28; i++) {
      final h = _hash(i + 77);
      final sx = (h % 1000) / 1000 * size.width;
      final sy = ((h >> 10) % 1000) / 1000 * groundY * 0.7;
      final tw = ((sin(t * 2 + i) + 1) * 60 + 100).round();
      _rect(c, sx, sy, u, u, 0xFFFFFFFF, tw);
    }
  } else {
    _rect(c, size.width * 0.78, groundY * 0.12, u * 9, u * 9, 0xFFFFF4C0, 220);
  }
  // الجبال البعيدة
  final colW = u * 4;
  for (double sx = 0; sx < size.width + colW; sx += colW) {
    final wx = sx / u + camX * 0.15;
    final hgt = (16 + 9 * sin(wx * 0.035) + 5 * sin(wx * 0.09 + 1.3)).floorToDouble();
    _rect(c, sx, groundY - hgt * u, colW + 0.6, hgt * u, b.far);
  }
  // الطبقة الوسطى
  const spacing = 46.0;
  final mcam = camX * 0.45;
  final first = (mcam / spacing).floor() - 1;
  final last = ((mcam + size.width / u) / spacing).ceil() + 1;
  for (int i = first; i <= last; i++) {
    final h = _hash(i);
    final wx = i * spacing + (h % 20);
    _feature(c, b, wx, groundY, u, (wx - mcam) * u, h);
  }
  // الأرض
  _rect(c, 0, groundY, size.width, size.height - groundY, b.ground);
  _rect(c, 0, groundY, size.width, u * 3, b.top);
  _rect(c, 0, groundY + u * 3, size.width, u, _mix(b.top, b.ground, 0.5));
  // بلاطات الأرض
  final tileW = 8 * u;
  final off = -((camX * u) % (tileW * 2));
  for (double sx = off; sx < size.width + tileW; sx += tileW) {
    final idx = ((sx - off) / tileW).round() + (camX / 16).floor();
    final h = _hash(idx);
    _rect(c, sx + (h % 5) * u, groundY + (5 + (h >> 4) % 6) * u, 2 * u, u,
        _mix(b.ground, 0xFF000000, 0.25));
    if (h % 3 == 0) {
      _rect(c, sx + 3 * u, groundY + 13 * u, u, u, _mix(b.ground, 0xFFFFFFFF, 0.15));
    }
    // عشب أمامي
    if (h % 4 == 0) {
      _rect(c, sx + 2 * u, groundY - 2 * u, u, 2 * u, b.top);
      _rect(c, sx + 4 * u, groundY - u, u, u, b.top);
    }
  }
}

void _feature(Canvas c, Biome b, double wx, double gy, double u, double sx,
    int h) {
  final dk = _mix(b.mid, 0xFF000000, 0.25);
  switch (b.kind) {
    case 'tree':
    case 'pine':
      final th = 22.0 + (h % 12);
      _rect(c, sx - u, gy - 8 * u, 3 * u, 8 * u, 0xFF4A3322);
      if (b.kind == 'pine') {
        for (int k = 0; k < 4; k++) {
          final ww = (14 - k * 3).toDouble();
          _rect(c, sx - ww * u / 2 + u, gy - (8 + k * 6) * u - 6 * u, ww * u, 6 * u,
              k.isEven ? b.mid : dk);
        }
      } else {
        _rect(c, sx - 8 * u, gy - th * u, 18 * u, 11 * u, b.mid);
        _rect(c, sx - 5 * u, gy - (th + 5) * u, 12 * u, 6 * u, dk);
      }
      break;
    case 'house':
      _rect(c, sx - 8 * u, gy - 12 * u, 17 * u, 12 * u, 0xFFD9C8A8);
      _rect(c, sx - 10 * u, gy - 18 * u, 21 * u, 6 * u, b.accent);
      _rect(c, sx - 2 * u, gy - 8 * u, 4 * u, 8 * u, 0xFF4A3322);
      _rect(c, sx + 4 * u, gy - 9 * u, 3 * u, 3 * u, 0xFFFFE9A0);
      break;
    case 'pagoda':
      for (int k = 0; k < 3; k++) {
        final ww = (18 - k * 4).toDouble();
        _rect(c, sx - ww * u / 2, gy - (10 + k * 10) * u, ww * u, 4 * u, b.accent);
        _rect(c, sx - (ww - 5) * u / 2, gy - (6 + k * 10) * u, (ww - 5) * u, 6 * u,
            b.mid);
      }
      break;
    case 'pillar':
      final ph = 14.0 + (h % 16);
      _rect(c, sx, gy - ph * u, 5 * u, ph * u, b.mid);
      _rect(c, sx - u, gy - ph * u, 7 * u, 2 * u, dk);
      if (h % 3 == 0) _rect(c, sx + 8 * u, gy - 5 * u, 6 * u, 5 * u, dk);
      break;
    case 'crystal':
      final ch = 14.0 + (h % 18);
      _rect(c, sx, gy - ch * u, 4 * u, ch * u, b.mid);
      _rect(c, sx + u, gy - (ch + 3) * u, 2 * u, 3 * u, b.accent);
      _rect(c, sx + 5 * u, gy - ch * 0.6 * u, 3 * u, ch * 0.6 * u, dk);
      break;
    case 'dead':
      _rect(c, sx, gy - 20 * u, 3 * u, 20 * u, dk);
      _rect(c, sx - 5 * u, gy - 16 * u, 6 * u, 2 * u, dk);
      _rect(c, sx + 3 * u, gy - 12 * u, 6 * u, 2 * u, dk);
      break;
    case 'drip':
      final dh = 10.0 + (h % 22);
      _rect(c, sx, 0, 5 * u, dh * u, b.mid);
      _rect(c, sx + u, dh * u, 3 * u, 3 * u, b.mid);
      _rect(c, sx + 12 * u, gy - 8 * u, 6 * u, 8 * u, dk);
      if (h % 2 == 0) _rect(c, sx + 14 * u, gy - 11 * u, 2 * u, 3 * u, b.accent, 200);
      break;
  }
}

// ---------------- ودجات مساعدة ----------------
class SpriteIcon extends StatelessWidget {
  final Sprite sprite;
  final double size;
  final int? tint;
  const SpriteIcon(this.sprite, {super.key, this.size = 32, this.tint});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SpritePainter(sprite, tint)),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final Sprite s;
  final int? tint;
  _SpritePainter(this.s, this.tint);
  @override
  void paint(Canvas canvas, Size size) {
    final px = min(size.width / s.w, size.height / s.h);
    final ox = (size.width - s.w * px) / 2;
    final oy = (size.height - s.h * px) / 2;
    paintSprite(canvas, s, ox, oy, px, tint: tint);
  }

  @override
  bool shouldRepaint(covariant _SpritePainter old) =>
      old.s != s || old.tint != tint;
}

/// صورة شخصية (Portrait)
class Portrait extends StatelessWidget {
  final Look look;
  final double size;
  final int? robe;
  const Portrait(this.look, {super.key, this.size = 56, this.robe});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: const Color(0xFF2A2342),
          border: Border.all(color: const Color(0xFF9D86F0), width: 2)),
      child: ClipRect(
        child: CustomPaint(painter: _PortraitPainter(look, robe)),
      ),
    );
  }
}

class _PortraitPainter extends CustomPainter {
  final Look look;
  final int? robe;
  _PortraitPainter(this.look, this.robe);
  @override
  void paint(Canvas canvas, Size size) {
    final px = size.width / 13;
    paintHuman(canvas, size.width / 2, 24.5 * px, px, look,
        weapon: 'none', robeOverride: robe);
  }

  @override
  bool shouldRepaint(covariant _PortraitPainter old) => true;
}

/// مشهد ثابت/متحرك: خلفية + شخصية تقف
class SceneView extends StatefulWidget {
  final String biome;
  final Look look;
  final String weapon;
  final double height;
  const SceneView(
      {super.key,
      required this.biome,
      required this.look,
      this.weapon = 'sword',
      this.height = 150});
  @override
  State<SceneView> createState() => _SceneViewState();
}

class _SceneViewState extends State<SceneView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 40))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRect(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ScenePainter(
              _c, biomes[widget.biome] ?? biomes['plains']!, widget.look, widget.weapon),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final Animation<double> anim;
  final Biome b;
  final Look look;
  final String weapon;
  _ScenePainter(this.anim, this.b, this.look, this.weapon)
      : super(repaint: anim);
  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value * 40;
    final u = size.height / 56;
    final groundY = size.height - 14 * u;
    paintBackground(canvas, size, b, t * 6, u, groundY, t: t);
    final walk = t * 5;
    paintHuman(canvas, size.width / 2, groundY + 2 * u, u * 1.05, look,
        weapon: weapon, walk: sin(t * 0.8) > 0.2 ? walk : 0);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) =>
      old.b != b || old.look != look || old.weapon != weapon;
}
