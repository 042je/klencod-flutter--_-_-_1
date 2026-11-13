import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/pixel.dart';
import '../core/util.dart';
import '../data/cultivation.dart';
import '../data/events.dart';
import '../data/extras_data.dart';
import '../data/techniques.dart';
import '../data/items.dart';
import '../data/world.dart';

class Person {
  String name;
  bool male;
  int age;
  int seed;
  String role; // father mother spouse child candidate
  int bond;
  bool alive;
  int talent;
  int skill;
  Person(this.name, this.male, this.age, this.seed, this.role,
      {this.bond = 20, this.alive = true, this.talent = 5, this.skill = 0});
  Look get look => Look.fromSeed(seed, !male);
  Map<String, dynamic> toJson() => {
        'n': name,
        'm': male,
        'a': age,
        's': seed,
        'r': role,
        'b': bond,
        'l': alive,
        't': talent,
        'k': skill
      };
  static Person fromJson(Map j) => Person(
      j['n'] as String, j['m'] as bool, j['a'] as int, j['s'] as int, j['r'] as String,
      bond: j['b'] as int,
      alive: j['l'] as bool,
      talent: j['t'] as int,
      skill: j['k'] as int);
}

class JobDef {
  final String id, name, desc;
  final int salary, needStat; // الراتب الشهري الأساسي
  final String stat; // str wis cha luck
  const JobDef(this.id, this.name, this.desc, this.salary, this.stat, this.needStat);
}

const List<JobDef> jobs = [
  JobDef('none', 'بلا مهنة', 'تعيش على ما تجد.', 0, 'str', 0),
  JobDef('farmer', 'مزارع', 'راتب ضعيف + مؤونة مجانية.', 30, 'str', 4),
  JobDef('guard', 'حارس', 'أجر ثابت وحماية للعائلة.', 45, 'str', 6),
  JobDef('hunter', 'صائد وحوش', 'غنائم أكثر من الصيد.', 50, 'str', 7),
  JobDef('explorer', 'مستكشف', 'يكتشف الأماكن المخفية أسرع.', 40, 'luck', 6),
  JobDef('blacksmith', 'حداد', 'ينتج أسلحة ودروعاً بأسعار أفضل.', 55, 'str', 8),
  JobDef('merchant', 'تاجر', 'أرباح بيع أعلى وأسعار شراء أرخص.', 60, 'cha', 8),
  JobDef('apothecary', 'صيدلي', 'صناعة الحبوب بنجاح أعلى.', 65, 'wis', 9),
  JobDef('weaponsmith', 'صانع أسلحة', 'أعلى أجر بين الحرفيين.', 70, 'str', 10),
  JobDef('treasure', 'باحث عن الكنوز', 'دخل متقلب قد يكون ضخماً.', 35, 'luck', 8),
];
JobDef jobOf(String id) => jobs.firstWhere((j) => j.id == id, orElse: () => jobs[0]);

class HomeDef {
  final String id, name;
  final int price, upkeep, heal;
  final double cult;
  const HomeDef(this.id, this.name, this.price, this.upkeep, this.heal, this.cult);
}

const List<HomeDef> homes = [
  HomeDef('shack', 'كوخ', 0, 0, 4, 1.0),
  HomeDef('cottage', 'بيت ريفي', 800, 5, 8, 1.1),
  HomeDef('courtyard', 'بيت بفناء', 5000, 20, 12, 1.25),
  HomeDef('manor', 'قصر عائلي', 30000, 80, 18, 1.4),
  HomeDef('cave', 'مسكن كهف روحي', 20000, 40, 10, 1.8),
];
HomeDef homeOf(String id) => homes.firstWhere((h) => h.id == id, orElse: () => homes[0]);

class SectDef {
  final String id, name, region, desc;
  final int needRealm;
  const SectDef(this.id, this.name, this.region, this.desc, this.needRealm);
}

const List<SectDef> sectDefs = [
  SectDef('azure', 'طائفة السحاب الأزرق', 'azure_peaks', 'فنون السيف والنهج القويم.', 1),
  SectDef('bloodmoon', 'طائفة القمر الدامي', 'bloodmoon_valley', 'قوة سريعة بثمن باهظ.', 1),
  SectDef('verdant', 'وادي الحبوب الأخضر', 'verdant_valley', 'خبراء الحبوب والأعشاب.', 1),
];
const List<String> sectRanks = ['تلميذ خارجي', 'تلميذ داخلي', 'تلميذ أساسي', 'شيخ'];

const List<String> maleNames = [
  'لين فنغ', 'هان بو', 'وي شين', 'تشن لو', 'جيانغ مو', 'شو يان', 'باي هوا', 'مو تشينغ'
];
const List<String> femaleNames = [
  'لين شياو', 'مي لان', 'يوي تشينغ', 'شين رو', 'هوا ليان', 'سو مين', 'تشو ايرين'
];
const List<String> perkIds = ['wealth', 'body', 'insight', 'life', 'luck', 'memory'];
const Map<String, String> perkNames = {
  'wealth': 'إرث الثروة: +300 فضة عند البداية',
  'body': 'ذاكرة الجسد: +2 لكل صفة أساسية',
  'insight': 'البصيرة: +10% سرعة تدريب',
  'life': 'عمر أطول: +3 سنوات',
  'luck': 'حظ القدر: +2 حظ',
  'memory': 'ذاكرة الزراعة: تبدأ بمستوى أعلى',
};

class Game extends ChangeNotifier {
  // ---------- ميتا (تبقى بين الحيوات) ----------
  int echo = 0;
  Map<String, int> perks = {};
  Set<String> knowledge = {};
  List<Map<String, dynamic>> lives = [];
  int rootEl = 0, purity = 1;
  bool haptics = true;

  // ---------- الحياة الحالية ----------
  String name = '';
  bool male = true;
  Look look = const Look();
  int age = 16, month = 1, ap = 3, startAge = 16, generation = 1;
  int health = 100, mood = 70;
  int str = 5, wis = 5, cha = 5, luck = 5;
  int silver = 100;
  int realm = 0, sub = 1;
  double xp = 0;
  int toxin = 0, bonusLife = 0, baseLife = 72;
  String job = 'none';
  int jobMonths = 0;
  String regionId = 'riverbend';
  Map<String, int> inv = {};
  String weapon = '', armor = '';
  String home = 'shack';
  String sect = '';
  int sectRank = 0, sectContrib = 0;
  List<Person> people = [];
  Set<String> flags = {};
  Set<String> found = {'riverbend', 'stonebridge', 'greenshade'};
  Map<String, int> siteCd = {};
  List<String> log = [];
  List<String> decisions = [];
  Map<String, int> stat = {}; // إحصاءات: kills, hunts ...
  bool dead = false;
  String deathCause = '';
  bool started = false;
  Map<String, int> ex = {}; // حالة الأنظمة الإضافية (أليفة، فريق، مهارات، فرن...)

  Ev? pending;

  // ---------- مشتقات ----------
  int get gi => globalIdx(realm, sub);
  int get lifespan => baseLife + realms[realm].life + bonusLife;
  int lv(String k) => ex[k] ?? 0;
  int get petOn => lv('pet_on');
  PetDef? get activePet => petOn == 0 ? null : petDefs[petOn - 1];
  int get maxHealth {
    int turtle = 0;
    final p = activePet;
    if (p != null && p.id == 'turtle') turtle = 5 * lv('pet_turtle');
    return max(40, 100 + str + turtle - (agePenalty(age, lifespan) * 100).round());
  }

  double get skillMul {
    double m = 0;
    for (final t in techs.values) {
      final l = lv('sk_${t.id}');
      if (l > 0 && !t.passive) m += 0.05 * (1 + t.tier) * l;
    }
    return 1 + min(m, 3.0);
  }

  double get petMul {
    final p = activePet;
    if (p == null) return 1;
    final l = lv('pet_${p.id}');
    return p.id == 'tiger' ? 1 + 0.06 * l : 1 + 0.02 * l;
  }

  List<Person> get mates => people.where((p) => p.role == 'mate' && p.alive).toList();
  double get teamPower {
    double s = 0;
    for (final p in mates) {
      s += (6 + p.skill * 4) * powerScale(p.skill ~/ 3) * (p.talent == 1 ? 1.2 : 1.0);
    }
    return s;
  }

  String addXp(double g) => _addXp(g);
  int get maxAp => 3;
  RegionDef get here => region(regionId);
  String get season => ['الربيع', 'الصيف', 'الخريف', 'الشتاء'][((month - 1) ~/ 3) % 4];
  String get dateStr => 'العمر $age · الشهر $month ($season)';
  Person? get spouse {
    for (final p in people) {
      if (p.role == 'spouse' && p.alive) return p;
    }
    return null;
  }

  List<Person> get children =>
      people.where((p) => p.role == 'child' && p.alive).toList();
  List<Person> get candidates => people.where((p) => p.role == 'candidate').toList();
  int get weaponAtk =>
      weapon.isEmpty ? 0 : (item(weapon).atk * (1 + 0.12 * lv('wplus'))).round();
  int get armorDef => armor.isEmpty ? 0 : item(armor).def;
  bool knows(String k) => knowledge.contains(k);
  int perk(String k) => perks[k] ?? 0;
  int count(String id) => inv[id] ?? 0;

  double get cultMul {
    double m = homeOf(home).cult * (1 + perk('insight') * 0.1);
    if (sect.isNotEmpty) m *= 1.1;
    if (flags.contains('heavenly_breath')) m *= 1.25;
    if (count('spirit_gourd') > 0) m *= 1.08;
    final pt = activePet;
    if (pt != null && pt.id == 'bird') m *= 1 + 0.03 * lv('pet_bird');
    m *= 1 - toxin / 200;
    return m;
  }

  double get power =>
      (8 + str * 1.5 + weaponAtk) * powerScale(gi) * (1 + armorDef * 0.02) * skillMul * petMul +
      teamPower;

  // ---------- مساعدات ----------
  void say(String s) {
    log.insert(0, '[$age/$month] $s');
    if (log.length > 80) log.removeLast();
  }

  void addItem(String id, [int n = 1]) {
    inv[id] = (inv[id] ?? 0) + n;
    if (inv[id]! <= 0) inv.remove(id);
  }

  bool takeItem(String id, [int n = 1]) {
    if ((inv[id] ?? 0) < n) return false;
    inv[id] = inv[id]! - n;
    if (inv[id]! <= 0) inv.remove(id);
    return true;
  }

  void changeHealth(int d) {
    health = clampI(health + d, 0, maxHealth);
    if (health <= 0) die('إصابات قاتلة');
  }

  void changeMood(int d) => mood = clampI(mood + d, 0, 100);
  void gainBond(Person p, int d) => p.bond = clampI(p.bond + d, 0, 100);

  void changed() => notifyListeners();

  // ---------- بدء حياة ----------
  void newGame(String nm, bool isMale, Look lk, Map<String, int> alloc,
      {bool keepMeta = false}) {
    if (!keepMeta) {
      echo = 0;
      perks = {};
      knowledge = {};
      lives = [];
      rootEl = rng.nextInt(5);
      purity = ri(1, 5);
    }
    name = nm;
    male = isMale;
    look = lk;
    _resetLife();
    str = 3 + (alloc['str'] ?? 0) + perk('body') * 2;
    wis = 3 + (alloc['wis'] ?? 0) + perk('body') * 2;
    cha = 3 + (alloc['cha'] ?? 0) + perk('body') * 2;
    luck = 3 + (alloc['luck'] ?? 0) + perk('body') * 2 + perk('luck') * 2;
    silver += perk('wealth') * 300;
    baseLife += perk('life') * 3;
    sub = 1 + perk('memory') * 2;
    _makeParents();
    for (final k in knowledge) {
      if (k == 'lotus') found.add('lotus_cave');
      if (k == 'void_gate_path') found.add('void_wastes');
    }
    started = true;
    say('بدأت حياة جديدة باسم $name في ${here.name}.');
    save();
    notifyListeners();
  }

  void _resetLife() {
    age = 16;
    startAge = 16;
    month = 1;
    ap = 3;
    health = 100;
    mood = 70;
    silver = 100;
    realm = 0;
    sub = 1;
    xp = 0;
    toxin = 0;
    bonusLife = 0;
    baseLife = ri(68, 78);
    job = 'none';
    jobMonths = 0;
    regionId = 'riverbend';
    inv = {'ration': 3, 'heal_pill': 1, 'qi_pill': 2};
    weapon = '';
    armor = '';
    home = 'shack';
    sect = '';
    sectRank = 0;
    sectContrib = 0;
    people = [];
    flags = {};
    found = {'riverbend', 'stonebridge', 'greenshade'};
    siteCd = {};
    log = [];
    decisions = [];
    stat = {};
    final ld = ex['ld'], ds = ex['ds'];
    ex = {};
    if (ld != null) ex['ld'] = ld;
    if (ds != null) ex['ds'] = ds;
    dead = false;
    deathCause = '';
    pending = null;
    generation = 1;
  }

  void _makeParents() {
    people.add(Person(pick(maleNames), true, ri(38, 46), rng.nextInt(99999), 'father',
        bond: 60, talent: ri(3, 7)));
    people.add(Person(pick(femaleNames), false, ri(36, 44), rng.nextInt(99999), 'mother',
        bond: 65, talent: ri(3, 7)));
  }

  // ---------- الزمن ----------
  void nextMonth() {
    if (dead || pending != null) return;
    ap = maxAp;
    month++;
    if (month > 12) {
      month = 1;
      _yearly();
      if (dead) {
        save();
        notifyListeners();
        return;
      }
    }
    // دخل ومصاريف
    final j = jobOf(job);
    if (j.id != 'none') {
      jobMonths++;
      int pay = (j.salary * (1 + 0.12 * min(10, jobMonths ~/ 12))).round();
      if (j.id == 'treasure') pay = ri(0, j.salary * 5);
      silver += pay;
      if (j.id == 'farmer') addItem('ration', 2);
    }
    if (sect.isNotEmpty) silver += 20 * (sectRank + 1);
    // دخل الأبناء البالغين
    for (final c in children) {
      if (c.age >= 16) silver += 10 + c.skill ~/ 4;
    }
    final up = homeOf(home).upkeep + children.length * 3 + (spouse != null ? 6 : 0);
    silver -= up;
    if (silver < 0) {
      silver = 0;
      changeMood(-8);
      say('ضاقت بك الحال وعجزت عن سداد النفقات.');
    }
    // طعام
    if (!takeItem('ration')) {
      changeHealth(-6);
      changeMood(-4);
      say('لا طعام لديك! اشترِ مؤونة.');
    } else {
      changeHealth(homeOf(home).heal);
    }
    toxin = max(0, toxin - 2);
    changeMood(mood < 60 ? 2 : -1);
    siteCd.updateAll((k, v) => max(0, v - 1));
    // حمل
    final sp = spouse;
    if (sp != null && sp.age < 45 && children.length < 5 && chance(0.05 + cha * 0.002)) {
      final c = Person(
          chance(0.5) ? pick(maleNames) : pick(femaleNames), chance(0.5), 0,
          rng.nextInt(99999), 'child',
          bond: 80, talent: clampI(((sp.talent + str + wis) / 3).round() + ri(-2, 3), 1, 10));
      c.male = !femaleNames.contains(c.name);
      people.add(c);
      say('رُزقتَ بمولود جديد: ${c.name}!');
      changeMood(15);
    }
    if (!dead) _rollEvent();
    if (!dead) save();
    notifyListeners();
  }

  void _yearly() {
    age++;
    for (final p in people) {
      if (!p.alive) continue;
      p.age++;
      if (p.role == 'child' && p.age <= 16) {
        p.skill = min(100, p.skill + p.talent);
      }
      if (p.role != 'candidate' && p.age > 62 && chance((p.age - 62) * 0.03)) {
        p.alive = false;
        say('رحل ${p.name} عن الدنيا عن عمر ${p.age}.');
        changeMood(-20);
      }
    }
    people.removeWhere((p) => p.role == 'candidate' && chance(0.3));
    // شيخوخة
    if (age >= lifespan) {
      if (chance(0.35 + 0.2 * (age - lifespan))) {
        die('الشيخوخة');
        return;
      }
    } else if (age >= lifespan - 3) {
      say('تشعر بدنو الأجل... بقي لك ${lifespan - age} سنوات.');
    }
    if (age == lifespan ~/ 2) say('بلغت منتصف عمرك الجسدي.');
  }

  // ---------- الأحداث ----------
  void _rollEvent() {
    if (!chance(0.8)) return;
    final e = weighted<Ev>(allEvents.where((e) => e.cond(this)).toList(), (e) => e.w);
    if (e != null) pending = e;
  }

  String chooseEvent(int i) {
    final e = pending;
    if (e == null) return '';
    final c = e.ch[i];
    pending = null;
    final r = c.run(this);
    decisions.add('${e.title}: ${c.t}');
    if (decisions.length > 40) decisions.removeAt(0);
    say(r);
    save();
    notifyListeners();
    return r;
  }

  // ---------- أنشطة (تكلف نقطة فعل) ----------
  bool useAp() {
    if (ap <= 0) return false;
    ap--;
    return true;
  }

  String meditate() {
    if (!useAp()) return 'لا نقاط فعل. انتقل للشهر التالي.';
    final base = (8 + wis) * gainScale(gi) * here.density * 8;
    final root = realm == 0 ? 0.8 : (0.8 + purity * 0.1);
    double g = base * root * cultMul;
    if (chance(0.15)) {
      g *= 1.6;
      say('حالة صفاء نادرة تضاعف تقدمك!');
    }
    return _addXp(g);
  }

  String _addXp(double g) {
    xp += g;
    String msg = 'اكتسبت ${fmt(g)} خبرة زراعية.';
    while (sub < realms[realm].subs && xp >= xpNeed(realm, sub)) {
      xp -= xpNeed(realm, sub);
      sub++;
      str += 1;
      msg += '\nتقدمت إلى ${realms[realm].name} - ${subName(realm, sub)}!';
      say('تقدمت إلى ${realms[realm].name} - ${subName(realm, sub)}.');
    }
    if (sub >= realms[realm].subs && realm < 8) {
      final cap = xpNeed(realm, sub);
      if (xp > cap) xp = cap;
    }
    return msg;
  }

  String trainBody() {
    if (!useAp()) return 'لا نقاط فعل.';
    if (health < 25) {
      ap++;
      return 'جسدك منهك. استرح أولاً.';
    }
    changeHealth(-6);
    final r = chance(0.7) ? 1 : 0;
    str += r;
    changeMood(-2);
    return r == 1 ? 'تدريبك أثمر: القوة +1' : 'تدربت بجهد دون تقدم ملحوظ.';
  }

  String study() {
    if (!useAp()) return 'لا نقاط فعل.';
    final r = chance(0.6 + luck * 0.01) ? 1 : 0;
    wis += r;
    changeMood(-1);
    return r == 1 ? 'تعلمت شيئاً جديداً: الحكمة +1' : 'قراءة بلا فائدة تُذكر.';
  }

  String socialize() {
    if (!useAp()) return 'لا نقاط فعل.';
    final r = chance(0.55 + luck * 0.01) ? 1 : 0;
    cha += r;
    changeMood(6);
    // تعرّف على شخص
    if (age >= 17 && candidates.length < 4 && chance(0.4) && spouse == null) {
      final m = chance(0.5);
      final p = Person(m ? pick(maleNames) : pick(femaleNames), m, age + ri(-3, 3),
          rng.nextInt(99999), 'candidate',
          bond: 15, talent: ri(2, 9));
      people.add(p);
      return 'تعرفت على ${p.name}. (راجع تبويب العائلة)';
    }
    return r == 1 ? 'اكتسبت أصدقاء: السحر +1' : 'قضيت وقتاً ممتعاً.';
  }

  String workExtra() {
    if (!useAp()) return 'لا نقاط فعل.';
    final j = jobOf(job);
    final g = 25 + j.salary ~/ 2 + ri(0, 30);
    silver += g;
    changeMood(-3);
    return 'عملت ساعات إضافية وكسبت $g فضة.';
  }

  String rest() {
    if (!useAp()) return 'لا نقاط فعل.';
    changeHealth(25 + homeOf(home).heal);
    changeMood(10);
    return 'استرحت واستعدت عافيتك.';
  }

  String gather() {
    if (!useAp()) return 'لا نقاط فعل.';
    final h = here.herbs;
    if (h.isEmpty) {
      silver += 8;
      return 'لا أعشاب هنا. وجدت بعض الأشياء الصغيرة (+8 فضة).';
    }
    final id = pick(h);
    final n = ri(1, 3) + (job == 'farmer' || job == 'apothecary' ? 1 : 0) + (count('herb_basket') > 0 ? 2 : 0);
    addItem(id, n);
    String extra = '';
    if (count('iron_pickaxe') > 0) {
      final o = ri(1, 3);
      addItem('iron_ore', o);
      extra = ' + $o خام حديد';
    }
    return 'جمعت $n × ${item(id).name}$extra.';
  }

  /// قتال تلقائي ضد قوة معينة. يعيد true عند الفوز.
  bool _duel(int level, double mul) {
    final e = 20 * powerScale(level) * mul;
    final p = power * (0.75 + rng.nextDouble() * 0.5);
    return p >= e * (0.75 + rng.nextDouble() * 0.5) * 0.9;
  }

  static const Map<String, String> _drop = {
    'wolf': 'wolf_pelt',
    'boar': 'boar_tusk',
    'bandit': 'iron_ore',
    'bandit_archer': 'cloth',
    'ghost': 'ghost_dust',
    'skeleton': 'bone_shard',
    'spirit_wolf': 'spirit_fang',
    'shadow': 'shadow_essence',
    'golem': 'ancient_gear',
    'cultivator': 'beast_core_1',
    'cultivator_mage': 'beast_core_1',
    'skeleton_guard': 'bone_shard',
  };

  String hunt() {
    if (health < 30) return 'صحتك لا تسمح بالقتال. استرح.';
    if (!useAp()) return 'لا نقاط فعل.';
    final r = here;
    if (r.enemies.isEmpty) {
      ap++;
      return 'لا وحوش في هذه المنطقة.';
    }
    final e = pick(r.enemies);
    final win = _duel(r.level, 1.0);
    stat['hunts'] = (stat['hunts'] ?? 0) + 1;
    if (win) {
      int s = 8 + r.level * 7 + (job == 'hunter' ? 10 : 0);
      if (activePet != null && activePet!.id == 'fox') s += s * lv('pet_fox') ~/ 20;
      silver += s;
      String d = '';
      final id = _drop[e];
      if (id != null && chance(0.75)) {
        addItem(id);
        d = ' + ${item(id).name}';
      }
      xp += xpNeed(realm, sub) * 0.01;
      return 'هزمت العدو وكسبت $s فضة$d.';
    }
    final dmg = ri(12, 30);
    changeHealth(-dmg);
    return 'خسرت المعركة وفقدت $dmg من صحتك.';
  }

  String exploreSite(SiteDef s) {
    if (realm < s.minRealm) return 'تحتاج مرحلة ${realms[s.minRealm].name} على الأقل.';
    if ((siteCd[s.id] ?? 0) > 0) return 'الموقع هادئ الآن. عُد بعد ${siteCd[s.id]} أشهر.';
    if (health < 40) return 'صحتك ضعيفة للمخاطرة.';
    if (!useAp()) return 'لا نقاط فعل.';
    int wins = 0;
    for (final w in s.waves) {
      if (_duel(s.level, 0.45 + 0.35 * w.length)) {
        wins++;
        changeHealth(-ri(3, 10));
      } else {
        break;
      }
    }
    bool boss = wins == s.waves.length;
    if (boss && s.boss.isNotEmpty) {
      boss = _duel(s.level, 2.0);
    }
    if (!boss) {
      final dmg = ri(15, 35) + (s.lethal ? 20 : 0);
      siteCd[s.id] = 3;
      changeHealth(-dmg);
      if (dead) return '';
      return 'انهزمت في ${s.name} وفقدت $dmg من الصحة.';
    }
    siteCd[s.id] = max(1, s.cooldown ~/ 10);
    final got = <String>[];
    s.loot.forEach((id, p) {
      double pr = p;
      if (id == 'moon_lotus' && s.id == 'lotus_deep') pr = p;
      if (chance(pr)) {
        addItem(id);
        got.add(item(id).name);
      }
    });
    if (s.id == 'lotus_deep') {
      if (knows('lotus') || chance(0.15)) {
        addItem('dawn_lotus');
        got.add('لوتس الفجر');
      }
      knowledge.add('lotus');
    }
    if (s.id == 'void_gate') {
      flags.add('void_gate');
      knowledge.add('void_gate_seen');
    }
    final sv = s.silver > 0 ? s.silver : 40 + s.level * 20;
    silver += sv;
    stat['sites'] = (stat['sites'] ?? 0) + 1;
    return 'انتصرت في ${s.name}! +$sv فضة${got.isEmpty ? '' : '\nغنائم: ${got.join('، ')}'}';
  }

  String explore() {
    if (!useAp()) return 'لا نقاط فعل.';
    final extra = (job == 'explorer' ? 0.15 : 0) + (luck * 0.01);
    for (final e in edgesOf(regionId)) {
      final o = otherEnd(e, regionId);
      if (!found.contains(o) && region(o).hidden == false && chance(0.5 + extra)) {
        found.add(o);
        return 'اكتشفت طريقاً إلى ${region(o).name}!';
      }
    }
    for (final e in edgesOf(regionId)) {
      final o = otherEnd(e, regionId);
      if (!found.contains(o) && region(o).hidden && chance(0.12 + extra)) {
        found.add(o);
        return 'عثرت على ممر مخفي يؤدي إلى ${region(o).name}!';
      }
    }
    if (chance(0.4)) {
      final s = 10 + ri(0, 40);
      silver += s;
      return 'وجدت صرّة قديمة فيها $s فضة.';
    }
    if (chance(0.25)) {
      addItem('treasure_map');
      return 'عثرت على خريطة كنز!';
    }
    return 'لم تجد شيئاً مميزاً.';
  }

  String digTreasure() {
    if (count('treasure_map') < 1) return 'لا تملك خريطة كنز.';
    if (!useAp()) return 'لا نقاط فعل.';
    takeItem('treasure_map');
    final r = rng.nextDouble() + luck * 0.01 + (job == 'treasure' ? 0.1 : 0);
    if (r > 0.9) {
      addItem('ancient_codex');
      silver += 500;
      return 'كنز عظيم! مخطوطة قديمة و500 فضة.';
    }
    if (r > 0.45) {
      final s = ri(100, 400);
      silver += s;
      return 'وجدت كنزاً صغيراً: $s فضة.';
    }
    return 'الخريطة كانت قديمة. لا شيء.';
  }

  // ---------- سفر ----------
  int travelMonths(String to) {
    final d = travelDays(regionId, to);
    return d < 0 ? 99 : max(1, (d / 3).ceil());
  }

  String travel(String to) {
    if (to == regionId) return 'أنت هنا بالفعل.';
    if (!found.contains(to)) return 'لا تعرف الطريق.';
    final m = travelMonths(to);
    if (m > 20) return 'لا طريق.';
    final cost = m * 6;
    if (silver < cost) return 'تحتاج $cost فضة للسفر.';
    if (region(to).level > gi + 12) {
      return 'المنطقة أخطر من أن تذهب إليها الآن.';
    }
    silver -= cost;
    regionId = to;
    for (int i = 0; i < m; i++) {
      nextMonthSilent();
      if (dead || pending != null) break;
    }
    notifyListeners();
    return 'وصلت إلى ${region(to).name} بعد $m شهر.';
  }

  void nextMonthSilent() {
    // شهر يمر أثناء السفر
    final keep = ap;
    nextMonth();
    ap = keep;
  }

  // ---------- زراعة: اختراق ----------
  double btChance() {
    final r = realms[realm];
    double c = r.baseChance + wis * 0.01 + purity * 0.03 - toxin * 0.002;
    if (flags.contains('mind_calm')) c += 0.05;
    return clampD(c, 0.1, 0.95);
  }

  String breakthrough() {
    final r = realms[realm];
    if (realm >= 8) return 'أنت في عالم الخلود.';
    if (sub < r.subs) return 'لم تبلغ ذروة هذه المرحلة بعد.';
    if (xp < xpNeed(realm, sub)) return 'تحتاج مزيداً من الخبرة الزراعية.';
    for (final e in r.need.entries) {
      if (count(e.key) < e.value) {
        return 'ينقصك: ${item(e.key).name} × ${e.value}';
      }
    }
    if (here.density < r.densityMin) return 'المكان فقير بالطاقة الروحية. اذهب إلى مكان أغنى.';
    if (realm == 7) {
      if (!knows('void_gate_path')) {
        return 'لا تعرف الطريق إلى ما بعد الحدود. أسرار الحيوات السابقة تحمل الجواب.';
      }
      if (!flags.contains('void_gate')) return 'يجب أن تعبر البوابة الفارغة أولاً.';
    }
    if (!useAp()) return 'لا نقاط فعل.';
    r.need.forEach((k, v) => takeItem(k, v));
    if (chance(btChance())) {
      realm++;
      sub = 1;
      xp = 0;
      health = maxHealth;
      str += 3;
      wis += 3;
      stat['bt'] = (stat['bt'] ?? 0) + 1;
      final msg = 'نجح الاختراق! أصبحت في مرحلة ${realms[realm].name}.';
      say(msg);
      if (realm == 1) say('انكشف جذرك الروحي: ${rootNames[rootEl]} (${purityNames[purity]}).');
      if (realm == 8) {
        knowledge.add('immortal');
        say('بلغت الخلود. سجلك خالد في مرآة الأقدار.');
      }
      return msg;
    }
    xp *= 0.6;
    changeHealth(-30);
    return 'فشل الاختراق! خسرت جزءاً من خبرتك وأُصبت بجروح.';
  }

  // ---------- أغراض ----------
  String useItem(String id) {
    final it = item(id);
    if (count(id) < 1) return 'لا تملكه.';
    final fx = it.fx;
    if (it.kind == IK.book) {
      if (flags.contains(it.tech)) return 'تعلّمت هذه التقنية من قبل.';
      takeItem(id);
      flags.add(it.tech);
      if (techs[it.tech] != null && lv('sk_${it.tech}') == 0) ex['sk_${it.tech}'] = 1;
      wis += 1;
      return 'تعلّمت من ${it.name}: الحكمة +1 وفعّلت التقنية.';
    }
    if (fx.isEmpty) return 'لا يمكن استخدامه مباشرة.';
    if (fx.keys.any((k) => k.startsWith('bt'))) {
      return 'تُستخدم هذه الحبة عند الاختراق تلقائياً.';
    }
    takeItem(id);
    final b = <String>[];
    if (fx['heal'] != null) {
      changeHealth(fx['heal']!);
      b.add('صحة');
    }
    if (fx['healPct'] != null) {
      changeHealth(maxHealth * fx['healPct']! ~/ 100);
      b.add('صحة');
    }
    if (fx['xpPct'] != null) {
      final g = xpNeed(realm, sub) * fx['xpPct']! / 100 * cultMulPill();
      b.add(_addXp(g));
    }
    if (fx['body'] != null) {
      str += fx['body']!;
      b.add('قوة +${fx['body']}');
    }
    if (fx['detox'] != null) {
      toxin = max(0, toxin - fx['detox']!);
      b.add('تنقية');
    }
    if (fx['life'] != null) {
      bonusLife += fx['life']!;
      b.add('عمر +${fx['life']} سنوات');
    }
    if (fx['cure'] != null) {
      flags.remove('sick');
      b.add('شفاء من المرض');
    }
    if (fx['qi'] != null) b.add('طاقة');
    if (fx['tox'] != null) {
      toxin = min(100, toxin + fx['tox']!);
      if (toxin > 80) changeHealth(-10);
    }
    return 'استخدمت ${it.name}: ${b.join('، ')}';
  }

  double cultMulPill() => 1 - toxin / 200;

  String equip(String id) {
    final it = item(id);
    if (count(id) < 1) return 'لا تملكه.';
    takeItem(id);
    if (it.kind == IK.weapon) {
      if (weapon.isNotEmpty) addItem(weapon);
      weapon = id;
      ex['wplus'] = 0;
    } else if (it.kind == IK.armor) {
      if (armor.isNotEmpty) addItem(armor);
      armor = id;
    } else {
      addItem(id);
      return 'لا يمكن تجهيزه.';
    }
    return 'جهّزت ${it.name}.';
  }

  int buyPrice(String id) {
    double m = region(regionId).cheap[id] ?? 1.0;
    m *= (job == 'merchant' ? 0.9 : 1.0);
    return max(1, (item(id).price * m).round());
  }

  int sellPrice(String id) {
    final f = job == 'merchant' ? 0.68 : 0.5;
    return max(1, (item(id).price * f).round());
  }

  String buy(String id, [int n = 1]) {
    final p = buyPrice(id) * n;
    if (silver < p) return 'فضتك لا تكفي.';
    silver -= p;
    addItem(id, n);
    return 'اشتريت ${item(id).name}.';
  }

  String sell(String id, [int n = 1]) {
    if (!item(id).tradable || item(id).price == 0) return 'لا يُباع.';
    if (!takeItem(id, n)) return 'لا تملك الكمية.';
    silver += sellPrice(id) * n;
    return 'بعت ${item(id).name} بـ${sellPrice(id) * n} فضة.';
  }

  // ---------- صناعة ----------
  static const Map<String, Map<String, int>> recipes = {
    'heal_pill': {'qi_grass': 2, 'frostmint': 1},
    'qi_pill': {'qi_grass': 3, 'fire_berry': 1},
    'antidote_pill': {'frostmint': 4},
    'detox_pill': {'jade_moss': 3, 'frostmint': 2},
    'body_pill': {'blood_ginseng': 1, 'fire_berry': 2},
    'foundation_pill': {'moon_lotus': 1, 'blood_ginseng': 2, 'beast_core_1': 2},
    'core_pill': {'soul_flower': 2, 'beast_core_2': 3},
    'longevity_pill': {'ghost_orchid': 2, 'moon_lotus': 1},
    'nascent_pill': {'soul_flower': 2, 'beast_core_3': 2, 'cold_jade': 1},
    'sword_0': {'iron_ore': 6},
    'spear_0': {'iron_ore': 6},
    'dagger_0': {'iron_ore': 4},
    'bow_0': {'cloth': 3, 'wolf_pelt': 2},
    'sword_1': {'iron_ore': 12, 'beast_core_1': 1},
    'spear_1': {'iron_ore': 12, 'beast_core_1': 1},
    'sword_2': {'spirit_iron': 8, 'beast_core_2': 2},
    'leather_armor': {'wolf_pelt': 6, 'cloth': 2},
    'iron_plate': {'iron_ore': 16, 'wolf_pelt': 2},
  };

  /// الحبوب تُصنع في فرن الصقل، والأسلحة والدروع عند الحداد.
  static bool isGearRecipe(String id) => item(id).isGear;

  int smithFee(String id) =>
      ((20 + item(id).tier * 40) * (job == 'blacksmith' || job == 'weaponsmith' ? 0.8 : 1.0)).round();

  double smithBonus() {
    double b = 0;
    if (job == 'blacksmith' || job == 'weaponsmith') b += 0.15;
    if (regionId == 'blackiron') b += 0.1;
    return b;
  }

  String craft(String id) {
    final rc = recipes[id];
    if (rc == null) return 'وصفة غير معروفة.';
    final gear = isGearRecipe(id);
    if (gear && !here.market) return 'تحتاج حداداً: اذهب إلى قرية أو مدينة فيها سوق.';
    for (final e in rc.entries) {
      if (count(e.key) < e.value) return 'ينقصك: ${item(e.key).name} × ${e.value}';
    }
    if (gear && silver < smithFee(id)) return 'أجر الحداد ${smithFee(id)} فضة.';
    if (!useAp()) return 'لا نقاط فعل.';
    rc.forEach((k, v) => takeItem(k, v));
    double c = 0.55 + wis * 0.02;
    if (gear) {
      silver -= smithFee(id);
      c += smithBonus();
    } else {
      c += lv('furnace') * 0.04;
      if (job == 'apothecary') c += 0.15;
      if (flags.contains('herb_mastery')) c += 0.08;
    }
    if (item(id).tier >= 2) c -= 0.1;
    if (chance(clampD(c, 0.2, 0.95))) {
      int n = (id == 'qi_pill' || id == 'heal_pill') ? 2 : 1;
      if (!gear && chance(0.05 * lv('furnace'))) n *= 2;
      addItem(id, n);
      return 'نجحت الصناعة: ${item(id).name} × $n';
    }
    return 'فشلت الصناعة وتلفت المواد.';
  }

  // ---------- مهنة وبيت ----------
  String takeJob(String id) {
    final j = jobOf(id);
    final v = {'str': str, 'wis': wis, 'cha': cha, 'luck': luck}[j.stat] ?? 0;
    if (v < j.needStat) return 'تحتاج ${_statName(j.stat)} ${j.needStat} على الأقل.';
    job = id;
    jobMonths = 0;
    return 'أصبحت ${j.name}.';
  }

  static String _statName(String s) =>
      {'str': 'القوة', 'wis': 'الحكمة', 'cha': 'السحر', 'luck': 'الحظ'}[s] ?? s;
  static String statName(String s) => _statName(s);

  String buyHome(HomeDef h) {
    if (home == h.id) return 'تسكنه بالفعل.';
    if (h.id == 'cave' && realm < 1) return 'تحتاج استشعار الطاقة أولاً.';
    if (silver < h.price) return 'فضتك لا تكفي.';
    silver -= h.price;
    home = h.id;
    return 'انتقلت للسكن في ${h.name}.';
  }

  // ---------- الطائفة ----------
  String joinSect(SectDef s) {
    if (sect.isNotEmpty) return 'أنت في طائفة بالفعل.';
    if (regionId != s.region) return 'اذهب إلى ${region(s.region).name} للانضمام.';
    if (realm < s.needRealm) return 'تحتاج مرحلة ${realms[s.needRealm].name}.';
    sect = s.id;
    sectRank = 0;
    sectContrib = 0;
    return 'انضممت إلى ${s.name}.';
  }

  String leaveSect() {
    sect = '';
    sectRank = 0;
    sectContrib = 0;
    changeMood(-5);
    return 'غادرت الطائفة.';
  }

  String sectMission() {
    if (sect.isEmpty) return 'لست في طائفة.';
    if (health < 30) return 'صحتك ضعيفة.';
    if (!useAp()) return 'لا نقاط فعل.';
    final win = _duel(max(1, gi ~/ 2 + 2), 0.8);
    if (win) {
      final c = 10 + sectRank * 5;
      sectContrib += c;
      silver += 30;
      while (sectRank < 3 && sectContrib >= (sectRank + 1) * 60) {
        sectRank++;
        say('رُقّيت إلى ${sectRanks[sectRank]}!');
      }
      return 'أنجزت المهمة: +$c مساهمة.';
    }
    changeHealth(-ri(8, 20));
    return 'فشلت المهمة وأُصبت.';
  }

  // ---------- العائلة ----------
  String gift(Person p) {
    if (silver < 50) return 'تحتاج 50 فضة للهدية.';
    silver -= 50;
    gainBond(p, ri(6, 12) + cha ~/ 3);
    return 'أهديت ${p.name} هدية. (التعلق ${p.bond})';
  }

  String chat(Person p) {
    if (!useAp()) return 'لا نقاط فعل.';
    gainBond(p, ri(4, 9) + cha ~/ 4);
    changeMood(4);
    return 'قضيت وقتاً مع ${p.name}. (التعلق ${p.bond})';
  }

  String propose(Person p) {
    if (spouse != null) return 'أنت متزوج بالفعل.';
    if (p.bond < 60) return 'تعلقها بك لا يكفي بعد (60 مطلوب).';
    if (silver < 300) return 'مراسم الزفاف تكلف 300 فضة.';
    silver -= 300;
    if (chance(0.5 + (p.bond - 60) * 0.01 + cha * 0.01)) {
      p.role = 'spouse';
      p.bond = min(100, p.bond + 10);
      people.removeWhere((x) => x.role == 'candidate' && x != p && chance(0.5));
      changeMood(25);
      return 'وافق! تزوجت من ${p.name}.';
    }
    p.bond -= 15;
    return 'رفض ${p.name} عرضك. (خسرت المال)';
  }

  String teachChild(Person c, String what) {
    if (!useAp()) return 'لا نقاط فعل.';
    final g = ri(3, 8) + c.talent ~/ 2;
    c.skill = min(100, c.skill + g);
    gainBond(c, 4);
    return 'علّمت ${c.name} ($what). المهارة +$g';
  }

  // ---------- الموت والحيوات ----------
  void die(String cause) {
    if (dead) return;
    dead = true;
    deathCause = cause;
    pending = null;
    final gain = 2 +
        realm * 4 +
        sub ~/ 2 +
        children.length +
        silver ~/ 2000 +
        (age - startAge) ~/ 10 +
        (stat['sites'] ?? 0);
    echoGain = gain;
    echo += gain;
    lives.add({
      'name': name,
      'age': age,
      'realm': realms[realm].name,
      'sub': subName(realm, sub),
      'silver': silver,
      'cause': cause,
      'children': children.length,
      'job': jobOf(job).name,
      'decisions': decisions.length > 5 ? decisions.sublist(decisions.length - 5) : List<String>.from(decisions),
      'gain': gain,
    });
    say('انتهت الحياة: $cause.');
    save();
  }

  int echoGain = 0;

  List<Person> get heirs =>
      people.where((p) => p.role == 'child' && p.alive && p.age >= 16).toList();

  /// العودة عبر مرآة الأقدار
  void rewind() {
    final nm = name, ml = male, lk = look;
    newGame(nm, ml, lk, {'str': 4, 'wis': 4, 'cha': 4, 'luck': 4}, keepMeta: true);
  }

  /// الاستمرار بوريث
  void continueAs(Person c) {
    final inherit = silver ~/ 2;
    final oldInv = Map<String, int>.from(inv);
    final oldHome = home;
    final fam = people.where((p) => p.alive && p != c && p.role != 'candidate').toList();
    final sp = people.where((p) => p.role == 'spouse' && p.alive).toList();
    name = c.name;
    male = c.male;
    look = c.look;
    age = c.age;
    startAge = c.age;
    health = 100;
    mood = 60;
    silver = inherit;
    inv = oldInv;
    home = oldHome;
    str = 3 + c.talent + c.skill ~/ 20;
    wis = 3 + c.talent + c.skill ~/ 20;
    cha = 4 + c.talent ~/ 2;
    luck = 3 + ri(0, 4);
    realm = 0;
    sub = 1 + c.skill ~/ 40;
    xp = 0;
    toxin = 0;
    bonusLife = 0;
    baseLife = ri(68, 78) + perk('life') * 3;
    job = 'none';
    jobMonths = 0;
    weapon = '';
    armor = '';
    sect = '';
    dead = false;
    deathCause = '';
    pending = null;
    generation++;
    final parents = <Person>[];
    for (final s in sp) {
      s.role = chance(0.5) ? 'mother' : 'father';
      s.role = s.male ? 'father' : 'mother';
      parents.add(s);
    }
    people = [...parents];
    for (final f in fam) {
      if (f.role == 'child') {
        f.role = 'sibling';
        people.add(f);
      } else if (f.role == 'mate') {
        people.add(f);
      }
    }
    flags = {};
    decisions = [];
    say('الجيل $generation: تولّى $name إرث العائلة.');
    save();
    notifyListeners();
  }

  bool buyPerk(String id) {
    final lv = perk(id);
    if (lv >= 5) return false;
    final cost = 5 + 3 * lv;
    if (echo < cost) return false;
    echo -= cost;
    perks[id] = lv + 1;
    save();
    notifyListeners();
    return true;
  }

  int perkCost(String id) => 5 + 3 * perk(id);

  // ---------- الحفظ ----------
  Map<String, dynamic> toJson() => {
        'v': 1,
        'echo': echo,
        'perks': perks,
        'know': knowledge.toList(),
        'lives': lives,
        'root': rootEl,
        'pur': purity,
        'name': name,
        'male': male,
        'look': look.toJson(),
        'age': age,
        'month': month,
        'ap': ap,
        'sa': startAge,
        'gen': generation,
        'hp': health,
        'mood': mood,
        'st': [str, wis, cha, luck],
        'silver': silver,
        'realm': realm,
        'sub': sub,
        'xp': xp,
        'tox': toxin,
        'bl': bonusLife,
        'base': baseLife,
        'job': job,
        'jm': jobMonths,
        'reg': regionId,
        'inv': inv,
        'w': weapon,
        'ar': armor,
        'home': home,
        'sect': sect,
        'sr': sectRank,
        'sc': sectContrib,
        'people': people.map((p) => p.toJson()).toList(),
        'flags': flags.toList(),
        'found': found.toList(),
        'cd': siteCd,
        'log': log,
        'dec': decisions,
        'stat': stat,
        'ex': ex,
        'dead': dead,
        'cause': deathCause,
        'hap': haptics,
      };

  void fromJson(Map<String, dynamic> j) {
    echo = j['echo'] as int;
    perks = toIntMap(j['perks']);
    knowledge = toStrList(j['know']).toSet();
    lives = (j['lives'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    rootEl = j['root'] as int;
    purity = j['pur'] as int;
    name = j['name'] as String;
    male = j['male'] as bool;
    look = Look.fromJson(j['look']);
    age = j['age'] as int;
    month = j['month'] as int;
    ap = j['ap'] as int;
    startAge = j['sa'] as int;
    generation = j['gen'] as int;
    health = j['hp'] as int;
    mood = j['mood'] as int;
    final st = j['st'] as List;
    str = st[0] as int;
    wis = st[1] as int;
    cha = st[2] as int;
    luck = st[3] as int;
    silver = j['silver'] as int;
    realm = j['realm'] as int;
    sub = j['sub'] as int;
    xp = (j['xp'] as num).toDouble();
    toxin = j['tox'] as int;
    bonusLife = j['bl'] as int;
    baseLife = j['base'] as int;
    job = j['job'] as String;
    jobMonths = j['jm'] as int;
    regionId = j['reg'] as String;
    inv = toIntMap(j['inv']);
    weapon = j['w'] as String;
    armor = j['ar'] as String;
    home = j['home'] as String;
    sect = j['sect'] as String;
    sectRank = j['sr'] as int;
    sectContrib = j['sc'] as int;
    people = (j['people'] as List).map((e) => Person.fromJson(e as Map)).toList();
    flags = toStrList(j['flags']).toSet();
    found = toStrList(j['found']).toSet();
    siteCd = toIntMap(j['cd']);
    log = toStrList(j['log']);
    decisions = toStrList(j['dec']);
    stat = toIntMap(j['stat']);
    ex = toIntMap(j['ex']);
    dead = j['dead'] as bool;
    deathCause = j['cause'] as String;
    haptics = (j['hap'] ?? true) as bool;
    pending = null;
    started = true;
  }

  Future<void> save([String slot = 'save_auto']) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(slot, jsonEncode(toJson()));
    } catch (_) {}
  }

  Future<bool> load([String slot = 'save_auto']) async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = p.getString(slot);
      if (s == null) return false;
      fromJson(jsonDecode(s) as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasSave(String slot) async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getString(slot) != null;
    } catch (_) {
      return false;
    }
  }

  /// الأهداف
  List<List<dynamic>> goals() => [
        ['تجاوز مرحلة صقل الجسد', realm >= 1],
        ['اختر مهنة', job != 'none'],
        ['تزوّج', spouse != null || people.any((p) => p.role == 'spouse')],
        ['أنجب طفلاً', people.any((p) => p.role == 'child')],
        ['انضم إلى طائفة', sect.isNotEmpty],
        ['بلغ تأسيس الأساس', realm >= 3],
        ['بلغ تكوين النواة', realm >= 4],
        ['اجمع 10,000 فضة', silver >= 10000],
        ['اهزم 5 مواقع خطرة', (stat['sites'] ?? 0) >= 5],
        ['بلغ الخلود', realm >= 8],
      ];
}
