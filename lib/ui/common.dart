import 'package:flutter/material.dart';
import '../core/pixel.dart';
import '../core/sprites.dart';
import '../core/theme.dart';
import '../data/items.dart';
import '../game/game.dart';

final Game game = Game();

/// ينفذ فعلاً ويعرض نتيجته
void run(BuildContext context, String Function() f) {
  final r = f();
  game.changed();
  if (r.isNotEmpty) toast(context, r);
}

class ItemIcon extends StatelessWidget {
  final String id;
  final double size;
  const ItemIcon(this.id, {super.key, this.size = 34});
  @override
  Widget build(BuildContext context) {
    final it = item(id);
    final sp = itemSprites[it.icon] ?? itemSprites['gem']!;
    return Container(
      width: size + 8,
      height: size + 8,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF110D1E),
        border: Border.all(color: Color(tierColors[it.tier.clamp(0, 5)]), width: 2),
      ),
      child: SpriteIcon(sp, size: size, tint: tierColors[it.tier.clamp(0, 5)]),
    );
  }
}

class StatLine extends StatelessWidget {
  final String label, value;
  final Color color;
  const StatLine(this.label, this.value, {super.key, this.color = C.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(child: Text(label, style: ts(c: C.dim, s: 13))),
          Text(value, style: ts(c: color, b: true, s: 13)),
        ]),
      );
}

Widget personCard(Person p, List<Widget> buttons, {String? sub}) {
  const roles = {
    'father': 'الأب',
    'mother': 'الأم',
    'spouse': 'شريك الحياة',
    'child': 'ابن/ابنة',
    'sibling': 'أخ/أخت',
    'mate': 'رفيق',
    'candidate': 'معرفة'
  };
  return PixelPanel(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Portrait(p.look, size: 60),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: ts(s: 16, b: true)),
            Text('${roles[p.role] ?? p.role} · ${p.age} سنة', style: ts(c: C.dim, s: 12)),
            if (sub != null) Text(sub, style: ts(c: C.dim, s: 12)),
            const SizedBox(height: 4),
            PixelBar(value: p.bond / 100, color: C.red, label: 'التعلق ${p.bond}', height: 14),
          ]),
        ),
      ]),
      if (buttons.isNotEmpty) Wrap(children: buttons),
    ]),
  );
}
