import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/pixel.dart';
import 'package:my_app/data/items.dart';
import 'package:my_app/game/extras.dart';
import 'package:my_app/game/game.dart';

Game fresh() {
  final g = Game();
  g.newGame('اختبار', true, const Look(), {'str': 3, 'wis': 3, 'cha': 3, 'luck': 3});
  return g;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('بدء لعبة جديدة يعطي والدين وحالة ابتدائية', () {
    final g = fresh();
    expect(g.age, 16);
    expect(g.people.where((p) => p.role == 'father' || p.role == 'mother').length, 2);
    expect(g.dead, false);
  });

  test('التأمل يستهلك نقطة فعل ويزيد الخبرة', () {
    final g = fresh();
    final before = g.xp + g.sub * 1000;
    g.meditate();
    expect(g.ap, 2);
    expect(g.xp + g.sub * 1000 > before, true);
  });

  test('الشهر التالي يعيد نقاط الفعل ويمرر الزمن', () {
    final g = fresh();
    g.ap = 0;
    g.nextMonth();
    if (g.pending == null && !g.dead) {
      expect(g.ap, 3);
      expect(g.month, 2);
    }
  });

  test('الموت يسجّل حياة ويمنح أصداء والعودة تبدأ حياة جديدة', () {
    final g = fresh();
    g.die('اختبار');
    expect(g.dead, true);
    expect(g.lives.length, 1);
    final echo = g.echo;
    expect(echo > 0, true);
    g.rewind();
    expect(g.dead, false);
    expect(g.age, 16);
    expect(g.echo, echo);
    expect(g.lives.length, 1);
  });

  test('الحفظ والاسترجاع عبر JSON', () {
    final g = fresh();
    g.silver = 1234;
    g.ex['pet_fox'] = 3;
    final j = g.toJson();
    final g2 = Game();
    g2.fromJson(j);
    expect(g2.silver, 1234);
    expect(g2.lv('pet_fox'), 3);
    expect(g2.name, 'اختبار');
  });

  test('كل وصفة تشير إلى عناصر موجودة', () {
    Game.recipes.forEach((id, mats) {
      expect(items.containsKey(id), true, reason: id);
      for (final m in mats.keys) {
        expect(items.containsKey(m), true, reason: m);
      }
    });
  });

  test('الاختراق يرفض عند نقص الشروط', () {
    final g = fresh();
    expect(g.breakthrough().isNotEmpty, true);
    expect(g.realm, 0);
  });

  test('المكافأة اليومية تُستلم مرة واحدة', () {
    final g = fresh();
    expect(g.dailyReady, true);
    g.claimDaily();
    expect(g.dailyReady, false);
  });

  test('الحداد للأسلحة والفرن للحبوب', () {
    final g = fresh();
    g.addItem('iron_ore', 10);
    g.silver = 500;
    expect(Game.isGearRecipe('sword_0'), true);
    expect(Game.isGearRecipe('qi_pill'), false);
    g.regionId = 'greenshade'; // بلا سوق ولا حداد
    expect(g.craft('sword_0').contains('حداد'), true);
  });
}
