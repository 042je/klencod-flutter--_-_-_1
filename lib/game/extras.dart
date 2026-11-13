import 'dart:math';
import '../core/util.dart';
import '../data/cultivation.dart';
import '../data/extras_data.dart';
import '../data/items.dart';
import '../data/techniques.dart';
import 'game.dart';

/// أنظمة إضافية: الفرن، الأليفة، الفريق، المهارات، الفانون، الحملة، المكافأة اليومية
extension Extras on Game {
  // ---------------- فرن الصقل ----------------
  int get furnaceLv => lv('furnace');
  int get furnaceCost => 300 * (furnaceLv + 1) * (furnaceLv + 1);

  String upgradeFurnace() {
    if (furnaceLv >= 10) return 'فرن الصقل في أقصى مستوى.';
    final c = furnaceCost;
    if (silver < c) return 'تحتاج $c فضة.';
    silver -= c;
    ex['furnace'] = furnaceLv + 1;
    return 'ارتقى فرن الصقل إلى المستوى $furnaceLv: حبوب أنجح ومضاعفة نادرة للإنتاج.';
  }

  /// تحسين السلاح عند الحداد (يتطلب سوقاً/حداداً)
  String enhanceWeapon() {
    if (!here.market) return 'تحتاج حداداً: اذهب إلى قرية أو مدينة فيها سوق.';
    if (weapon.isEmpty) return 'جهّز سلاحاً أولاً.';
    final plus = lv('wplus');
    if (plus >= 10) return 'السلاح في أقصى تحسين.';
    final mat = plus < 4 ? 'iron_ore' : 'spirit_iron';
    final n = plus < 4 ? 2 * (plus + 1) : plus - 2;
    final cost = (50 * (plus + 1) * (job == 'blacksmith' || job == 'weaponsmith' ? 0.8 : 1.0)).round();
    if (silver < cost) return 'أجر الحداد $cost فضة.';
    if (count(mat) < n) return 'ينقصك: ${item(mat).name} × $n';
    silver -= cost;
    takeItem(mat, n);
    final ch = 0.9 - 0.07 * plus + smithBonus();
    if (chance(clampD(ch, 0.1, 0.97))) {
      ex['wplus'] = plus + 1;
      return 'نجح الحداد! ${item(weapon).name} +${plus + 1}';
    }
    if (plus >= 7 && chance(0.5)) {
      ex['wplus'] = plus - 1;
      return 'فشل التحسين وتراجع مستوى السلاح إلى +${plus - 1}.';
    }
    return 'فشل التحسين وضاعت المواد.';
  }

  // ---------------- الحيوانات الأليفة ----------------
  String hatchEgg() {
    if (!takeItem('pet_egg')) return 'لا تملك بيضة روحية.';
    final d = pick(petDefs);
    final k = 'pet_${d.id}';
    if (lv(k) == 0) {
      ex[k] = 1;
      if (petOn == 0) ex['pet_on'] = petDefs.indexOf(d) + 1;
      return 'فقست البيضة عن ${d.name}!';
    }
    ex[k] = min(10, lv(k) + 1);
    return 'فقست البيضة عن ${d.name} (تملكه)، فارتقى مستواه إلى ${lv(k)}.';
  }

  String feedPet(PetDef d) {
    final k = 'pet_${d.id}';
    if (lv(k) == 0) return 'لا تملكه.';
    if (lv(k) >= 10) return 'في أقصى مستوى.';
    final c = 60 * lv(k);
    if (silver < c) return 'تحتاج $c فضة.';
    if (!takeItem('ration', 2)) return 'تحتاج مؤونتين لإطعامه.';
    silver -= c;
    ex[k] = lv(k) + 1;
    return 'ارتقى ${d.name} إلى المستوى ${lv(k)}.';
  }

  String setPet(PetDef d) {
    if (lv('pet_${d.id}') == 0) return 'لا تملكه.';
    ex['pet_on'] = petDefs.indexOf(d) + 1;
    return 'رافقك ${d.name}.';
  }

  // ---------------- المهارات ----------------
  List<TechDef> get learnedSkills =>
      techs.values.where((t) => lv('sk_${t.id}') > 0).toList();

  int skillCost(TechDef t) => 200 * lv('sk_${t.id}') * (1 + t.tier);

  String upgradeSkill(TechDef t) {
    final l = lv('sk_${t.id}');
    if (l == 0) return 'لم تتعلمها بعد (اشترِ كتابها).';
    if (l >= 5) return 'المهارة في أقصى إتقان.';
    final c = skillCost(t);
    if (silver < c) return 'تحتاج $c فضة.';
    silver -= c;
    ex['sk_${t.id}'] = l + 1;
    return 'ارتقت ${t.name} إلى الإتقان ${l + 1}.';
  }

  // ---------------- الفريق ----------------
  int get recruitCost => 400 + 200 * mates.length;

  String recruit() {
    if (mates.length >= 3) return 'الفريق ممتلئ (3).';
    final gw = lv('good_$regionId');
    if (gw < 20) return 'تحتاج ودّ الفانين 20 في ${here.name} (ساعدهم أولاً).';
    final c = recruitCost;
    if (silver < c) return 'تحتاج $c فضة.';
    silver -= c;
    ex['good_$regionId'] = gw - 10;
    final m = chance(0.5);
    final cls = rng.nextInt(4);
    final p = Person(m ? pick(maleNames) : pick(femaleNames), m, ri(18, 30),
        rng.nextInt(99999), 'mate',
        bond: 50, talent: cls, skill: 1);
    people.add(p);
    return 'انضم ${p.name} (${mateClasses[cls]}) إلى فريقك!';
  }

  String trainMate(Person p) {
    if (p.skill >= 30) return 'في أقصى مستوى.';
    final c = 100 * p.skill;
    if (silver < c) return 'تحتاج $c فضة.';
    silver -= c;
    p.skill++;
    return 'ارتقى ${p.name} إلى المستوى ${p.skill}.';
  }

  String dismissMate(Person p) {
    people.remove(p);
    return 'ودّعت ${p.name}.';
  }

  // ---------------- أراضي الفانين ----------------
  int get goodwill => lv('good_$regionId');

  int get _monthIdx => age * 12 + month;

  /// طلب الفانين لهذا الشهر (ثابت داخل الشهر)
  Map<String, dynamic> mortalRequest() {
    final seed = _monthIdx * 31 + regionId.codeUnits.fold<int>(0, (a, b) => a + b);
    final r = Random(seed);
    final type = r.nextInt(3);
    final pool = here.herbs.isEmpty ? ['ration', 'cloth'] : [...here.herbs, 'ration'];
    final id = pool[r.nextInt(pool.length)];
    final n = 2 + r.nextInt(3);
    final reward = 25 + here.level * 12 + r.nextInt(30);
    if (type == 0) {
      return {
        'type': 0,
        'item': id,
        'n': n,
        'reward': reward,
        'text': 'يحتاج القرويون $n × ${item(id).name} لموسم الشتاء. هل تساعدهم؟'
      };
    }
    if (type == 1) {
      return {
        'type': 1,
        'item': '',
        'n': 0,
        'reward': reward + 20,
        'text': 'وحش يهدد حقولهم. هل تطرده؟ (يكلف فعلاً)'
      };
    }
    return {
      'type': 2,
      'item': 'heal_pill',
      'n': 1,
      'reward': reward,
      'text': 'مريض في القرية يحتاج حبة شفاء. هل تعطيه واحدة؟'
    };
  }

  bool get mortalDone => lv('mdone_$regionId') == _monthIdx;

  String mortalHelp() {
    if (!here.market) return 'لا فانين هنا.';
    if (mortalDone) return 'ساعدتهم هذا الشهر بالفعل. عُد الشهر القادم.';
    final q = mortalRequest();
    final type = q['type'] as int;
    if (type == 0 || type == 2) {
      final id = q['item'] as String;
      final n = q['n'] as int;
      if (count(id) < n) return 'ينقصك: ${item(id).name} × $n';
      takeItem(id, n);
    } else {
      if (health < 30) return 'صحتك لا تسمح.';
      if (!useAp()) return 'لا نقاط فعل.';
      final win = power * (0.8 + rng.nextDouble() * 0.4) >= 18 * powerScale(here.level);
      if (!win) {
        changeHealth(-ri(10, 25));
        return 'فشلت في طرد الوحش وأُصبت.';
      }
    }
    final reward = q['reward'] as int;
    silver += reward;
    final k = 'good_$regionId';
    ex[k] = min(100, lv(k) + ri(8, 12));
    ex['mdone_$regionId'] = _monthIdx;
    changeMood(8);
    String extra = '';
    if (lv(k) >= 50 && lv('gift_$regionId') == 0) {
      ex['gift_$regionId'] = 1;
      addItem('pet_egg');
      extra = '\nأهداك كبيرهم بيضة روحية تقديراً لك!';
    }
    return 'ساعدت الفانين فنالوا ودّك (${lv(k)}). كافأوك بـ$reward فضة.$extra';
  }

  String mortalAsk() {
    if (!here.market) return 'لا فانين هنا.';
    if (goodwill < 15) return 'لا يثقون بك بعد (الودّ 15 مطلوب). ساعدهم أولاً.';
    ex['good_$regionId'] = goodwill - 15;
    final pool = here.herbs.isEmpty ? ['qi_grass'] : here.herbs;
    final id = pick(pool);
    final n = ri(3, 6);
    addItem(id, n);
    addItem('ration', 2);
    return 'منحك الفانون $n × ${item(id).name} ومؤونة.';
  }

  // ---------------- الحملة (معارك المراحل) ----------------
  int get stage => max(1, lv('stage'));

  static const List<List<String>> _foes = [
    ['ذئب الغابة', 'wolf', 'زعيم: ملك الذئاب'],
    ['خنزير بري', 'boar', 'زعيم: سيد الخنازير'],
    ['قاطع طريق', 'human', 'زعيم: كبير القطاع'],
    ['شبح حائر', 'ghost', 'زعيم: لورد الأشباح'],
    ['هيكل متمرد', 'human', 'زعيم: فارس العظام'],
    ['حارس حجري', 'golem', 'زعيم: العملاق الحجري'],
    ['مزارع شرير', 'human', 'زعيم: شيخ الظلال'],
  ];

  double stageEnemyPower(int st) {
    final boss = st % 10 == 0;
    return 12 * powerScale((st - 1) ~/ 3) * (1 + (st % 3) * 0.08) * (boss ? 1.8 : 1.0);
  }

  BattleInfo campaign({bool farm = false}) {
    if (health < 25) return const BattleInfo(err: 'صحتك ضعيفة جداً. استرح أو تناول حبة شفاء.');
    if (farm && stage <= 1) return const BattleInfo(err: 'لا مراحل سابقة للتكرار.');
    if (!useAp()) return const BattleInfo(err: 'لا نقاط فعل. انتقل للشهر التالي.');
    final st = farm ? stage - 1 : stage;
    final boss = st % 10 == 0;
    final foe = _foes[(st - 1) % _foes.length];
    final ep = stageEnemyPower(st);
    final pp = power * (0.85 + rng.nextDouble() * 0.3);
    final win = pp >= ep;
    String rw = '';
    if (win) {
      final mul = (boss ? 3 : 1) * (farm ? 0.6 : 1.0);
      final s = ((15 + st * 5) * mul).round();
      silver += s;
      rw = '+$s فضة';
      if (chance(0.45)) {
        const herbs = ['qi_grass', 'frostmint', 'fire_berry', 'jade_moss'];
        final id = st > 20 ? 'blood_ginseng' : pick(herbs);
        addItem(id);
        rw += ' + ${item(id).name}';
      }
      if (st % 5 == 0) {
        addItem('qi_pill');
        rw += ' + حبة جمع الطاقة';
      }
      if (boss) {
        final core = st >= 40 ? 'beast_core_2' : 'beast_core_1';
        addItem(core);
        rw += ' + ${item(core).name}';
        if (!farm && chance(0.2)) {
          addItem('pet_egg');
          rw += ' + بيضة روحية!';
        }
      }
      if (!farm) {
        ex['stage'] = stage + 1;
        if (stage > lv('best')) ex['best'] = stage;
      }
      final xpG = addXp(xpNeed(realm, sub) * 0.01 * (1 + st / 20));
      if (xpG.contains('تقدمت')) rw += '\n$xpG';
      for (final m in mates) {
        if (m.talent == 2) changeHealth(m.skill * 2);
      }
      changeHealth(-ri(2, 8));
    } else {
      changeHealth(-ri(10, 22));
      rw = 'هُزمت! قوّ فريقك أو معداتك ثم أعد المحاولة.';
    }
    stat['camp'] = (stat['camp'] ?? 0) + 1;
    return BattleInfo(
        win: win,
        boss: boss,
        stage: st,
        name: boss ? foe[2] : foe[0],
        kind: foe[1],
        rewards: rw,
        power: pp,
        epower: ep);
  }

  // ---------------- المكافأة اليومية ----------------
  int get _today => DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  bool get dailyReady => lv('ld') < _today;
  int get dailyDay {
    final prev = lv('ld');
    if (prev == _today) return lv('ds');
    if (prev == _today - 1) return lv('ds') + 1 > 7 ? 1 : lv('ds') + 1;
    return 1;
  }

  String claimDaily() {
    if (!dailyReady) return 'استلمت مكافأة اليوم. عُد غداً!';
    final d = dailyDay;
    ex['ld'] = _today;
    ex['ds'] = d;
    switch (d) {
      case 1:
        final s = 100 * (1 + realm);
        silver += s;
        return 'اليوم 1: $s فضة';
      case 2:
        addItem('qi_pill', 2);
        return 'اليوم 2: حبتا جمع الطاقة';
      case 3:
        addItem('heal_pill', 3);
        return 'اليوم 3: 3 حبوب شفاء';
      case 4:
        addItem('body_pill');
        return 'اليوم 4: حبة صقل الجسد';
      case 5:
        final s = 400 * (1 + realm);
        silver += s;
        return 'اليوم 5: $s فضة';
      case 6:
        addItem('beast_core_1', 2);
        return 'اليوم 6: نواتا وحش';
      default:
        addItem('pet_egg');
        return 'اليوم 7: بيضة روحية!';
    }
  }
}
