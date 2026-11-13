class RegionDef {
  final String id, name, kingdom, icon, biome, desc;
  final int level;
  final double density, danger, mx, my;
  final bool market, hidden;
  final List<String> herbs, enemies, sells;
  final Map<String, double> cheap;
  final String sect;
  const RegionDef(this.id, this.name, this.kingdom, this.icon, this.biome,
      this.level, this.density, this.danger, this.mx, this.my, this.desc,
      {this.market = false,
      this.hidden = false,
      this.herbs = const [],
      this.enemies = const [],
      this.sells = const [],
      this.cheap = const {},
      this.sect = ''});
}

class EdgeDef {
  final String a, b;
  final int days;
  const EdgeDef(this.a, this.b, this.days);
}

class SiteDef {
  final String id, name, region, desc, biome;
  final int level;
  final List<List<String>> waves;
  final String boss;
  final Map<String, double> loot;
  final bool hidden, lethal;
  final int cooldown, minRealm, silver;
  const SiteDef(this.id, this.name, this.region, this.desc, this.biome,
      this.level, this.waves,
      {this.boss = '',
      this.loot = const {},
      this.hidden = false,
      this.lethal = false,
      this.cooldown = 30,
      this.minRealm = 0,
      this.silver = 0});
}

const List<String> kingdomIds = ['dawnreach', 'ashenhold', 'silverfjord'];
const Map<String, String> kingdomNames = {
  'dawnreach': 'مملكة فجر الحدود',
  'ashenhold': 'مملكة الرماد',
  'silverfjord': 'مملكة الفيورد الفضي',
};
const Map<String, String> kingdomDesc = {
  'dawnreach': 'مملكة زراعية عريقة يحكمها ملك عجوز وتتنازعها العشائر.',
  'ashenhold': 'مملكة محاربين وحدّادين، تحدّها أراضي الطوائف الدموية.',
  'silverfjord': 'مملكة تجار وموانئ ومحاليل أعشاب، تقدّس الثروة.',
};

const List<String> _basicShop = [
  'ration', 'roast_meat', 'heal_pill', 'qi_grass', 'cloth', 'cloth_robe',
  'sword_0', 'spear_0', 'dagger_0', 'bow_0', 'staff_0',
];

const List<RegionDef> regions = [
  RegionDef('riverbend', 'قرية ضفة النهر', 'dawnreach', 'village', 'village',
      0, 0.5, 0.08, 0.17, 0.72, 'قرية صغيرة على ضفة نهر هادئ. منها تبدأ الحكايات.',
      market: true,
      herbs: ['qi_grass', 'frostmint'],
      enemies: ['boar', 'bandit'],
      sells: ['ration', 'roast_meat', 'heal_pill', 'qi_grass', 'frostmint',
        'cloth', 'cloth_robe', 'sword_0', 'dagger_0', 'iron_ore'],
      cheap: {'ration': 0.7, 'qi_grass': 0.8}),
  RegionDef('stonebridge', 'مدينة الجسر الحجري', 'dawnreach', 'town', 'city',
      2, 0.4, 0.15, 0.34, 0.62, 'مدينة تجارية على نهر عريض. فيها الحانات والحرفيون.',
      market: true,
      herbs: ['qi_grass', 'jade_moss'],
      enemies: ['bandit', 'bandit_archer'],
      sells: [..._basicShop, 'frostmint', 'fire_berry', 'jade_moss', 'iron_ore',
        'leather_armor', 'jade_pendant', 'book_wind_step', 'book_herb_mastery',
        'treasure_map', 'body_pill', 'antidote_pill', 'herb_basket', 'iron_pickaxe'],
      cheap: {'iron_ore': 0.9}),
  RegionDef('greenshade', 'غابة الظل الأخضر', 'dawnreach', 'forest', 'forest',
      3, 0.7, 0.45, 0.22, 0.48, 'غابة كثيفة تعيش فيها الذئاب وقطاع الطرق.',
      herbs: ['qi_grass', 'fire_berry', 'jade_moss', 'blood_ginseng'],
      enemies: ['wolf', 'boar', 'bandit']),
  RegionDef('dawncrown', 'العاصمة تاج الفجر', 'dawnreach', 'capital', 'city',
      6, 0.6, 0.1, 0.42, 0.84, 'عاصمة المملكة. أسواقها الكبرى ومزاداتها لا تنام.',
      market: true,
      sells: [..._basicShop, 'leather_armor', 'iron_plate', 'spirit_robe',
        'jade_pendant', 'wind_charm', 'ward_talisman', 'sword_1', 'spear_1',
        'dagger_1', 'bow_1', 'staff_1', 'body_pill', 'big_xp_pill',
        'book_sword_wave', 'book_flame_palm', 'book_stone_skin',
        'book_hidden_breath', 'book_cloud_leap', 'book_spring_heal',
        'book_qi_shield', 'book_mind_calm', 'foundation_pill', 'detox_pill',
        'spirit_gourd', 'pet_egg'],
      cheap: {'cloth': 0.9}),
  RegionDef('azure_peaks', 'جبال السحاب الأزرق', 'dawnreach', 'sect', 'mountain',
      8, 1.6, 0.35, 0.14, 0.22, 'قمم تغطيها الغيوم. فيها طائفة السحاب الأزرق.',
      herbs: ['moon_lotus', 'cold_jade'],
      enemies: ['cultivator', 'cultivator_mage', 'wolf'],
      sect: 'azure'),
  RegionDef('lotus_cave', 'كهف اللوتس', 'dawnreach', 'cave', 'cave',
      5, 1.9, 0.5, 0.07, 0.5, 'كهف مخفي تتفتح فيه زهرة الفجر مرة في العمر.',
      hidden: true, enemies: ['skeleton', 'ghost']),
  RegionDef('fang_plain', 'مرعى الأنياب', 'dawnreach', 'plain', 'plains',
      6, 0.8, 0.55, 0.5, 0.56, 'سهل واسع تجوبه الوحوش الروحية.',
      herbs: ['qi_grass', 'blood_ginseng', 'fire_berry'],
      enemies: ['spirit_wolf', 'boar', 'wolf']),
  RegionDef('blackiron', 'مدينة الحديد الأسود', 'ashenhold', 'town', 'city',
      5, 0.5, 0.25, 0.58, 0.36, 'مدينة المناجم والمطارق. أرخص خام وأفضل الحدادين.',
      market: true,
      enemies: ['bandit', 'skeleton'],
      sells: [..._basicShop, 'iron_ore', 'spirit_iron', 'sword_1', 'spear_1',
        'dagger_1', 'bow_1', 'iron_plate', 'sword_2', 'spear_2',
        'book_dragon_thrust', 'ancient_gear', 'ward_talisman', 'beast_core_1'],
      cheap: {'iron_ore': 0.55, 'spirit_iron': 0.8, 'sword_1': 0.85, 'spear_1': 0.85}),
  RegionDef('bloodmoon_valley', 'وادي القمر الدامي', 'ashenhold', 'sect', 'ruins',
      9, 1.5, 0.6, 0.72, 0.16, 'وادٍ أحمر تسكنه طائفة القمر الدامي.',
      herbs: ['blood_ginseng', 'ghost_orchid'],
      enemies: ['cultivator', 'skeleton', 'shadow'],
      sect: 'bloodmoon'),
  RegionDef('ashen_temple', 'أطلال معبد الرماد', 'ashenhold', 'ruin', 'ruins',
      12, 1.3, 0.7, 0.54, 0.12, 'معبد قديم دفنته العواصف. فيه ما لم يُحكَ.',
      hidden: true, enemies: ['skeleton', 'skeleton_guard', 'golem']),
  RegionDef('ghostmire', 'مستنقع الأشباح', 'ashenhold', 'swamp', 'swamp',
      7, 1.0, 0.6, 0.45, 0.42, 'ضباب دائم وأصوات من العدم.',
      herbs: ['ghost_orchid', 'jade_moss', 'moon_lotus'],
      enemies: ['ghost', 'shadow', 'skeleton']),
  RegionDef('silver_harbor', 'ميناء الفضة', 'silverfjord', 'town', 'city',
      4, 0.45, 0.2, 0.82, 0.56, 'ميناء صاخب تُباع فيه كل سلعة في العالم.',
      market: true,
      enemies: ['bandit', 'bandit_archer'],
      sells: [..._basicShop, 'frostmint', 'fire_berry', 'blood_ginseng',
        'moon_lotus', 'spirit_rice', 'wolf_pelt', 'ancient_codex',
        'treasure_map', 'wind_charm', 'qi_bead', 'longevity_pill',
        'book_soul_sense', 'book_heavenly_breath', 'book_shadow_cloak',
        'body_pill', 'detox_pill', 'beast_core_1', 'beast_core_2'],
      cheap: {'spirit_rice': 0.8, 'cloth': 0.8}),
  RegionDef('verdant_valley', 'وادي الحبوب الأخضر', 'silverfjord', 'sect', 'forest',
      10, 1.4, 0.3, 0.9, 0.32, 'وادٍ مليء بالحقول الروحية ومعامل الحبوب.',
      herbs: ['moon_lotus', 'soul_flower', 'blood_ginseng', 'frostmint'],
      enemies: ['cultivator_mage', 'boar'],
      sect: 'verdant',
      market: true,
      sells: ['qi_grass', 'frostmint', 'moon_lotus', 'blood_ginseng',
        'heal_pill', 'qi_pill', 'body_pill', 'antidote_pill', 'detox_pill',
        'foundation_pill', 'soul_flower', 'longevity_pill'],
      cheap: {'moon_lotus': 0.7, 'qi_pill': 0.7, 'foundation_pill': 0.85}),
  RegionDef('frostspire', 'قلعة الجليد', 'silverfjord', 'tower', 'snow',
      14, 1.8, 0.75, 0.86, 0.1, 'قلعة جليدية قديمة تعلو الغيوم.',
      herbs: ['cold_jade', 'star_silver'], enemies: ['shadow', 'golem', 'cultivator_mage']),
  RegionDef('void_wastes', 'أرض البوابة الفارغة', 'silverfjord', 'void', 'void',
      20, 3.0, 0.9, 0.66, 0.9, 'أرض محرّمة تتشقق فيها السماء. لا يعود منها إلا القلة.',
      hidden: true, enemies: ['shadow', 'golem', 'ghost']),
];

const List<EdgeDef> edges = [
  EdgeDef('riverbend', 'stonebridge', 2),
  EdgeDef('riverbend', 'greenshade', 2),
  EdgeDef('stonebridge', 'greenshade', 2),
  EdgeDef('stonebridge', 'dawncrown', 3),
  EdgeDef('stonebridge', 'fang_plain', 3),
  EdgeDef('greenshade', 'azure_peaks', 4),
  EdgeDef('greenshade', 'lotus_cave', 2),
  EdgeDef('azure_peaks', 'dawncrown', 6),
  EdgeDef('dawncrown', 'fang_plain', 3),
  EdgeDef('dawncrown', 'silver_harbor', 6),
  EdgeDef('fang_plain', 'blackiron', 3),
  EdgeDef('fang_plain', 'ghostmire', 3),
  EdgeDef('blackiron', 'ghostmire', 2),
  EdgeDef('blackiron', 'bloodmoon_valley', 4),
  EdgeDef('blackiron', 'ashen_temple', 4),
  EdgeDef('bloodmoon_valley', 'ashen_temple', 3),
  EdgeDef('ghostmire', 'silver_harbor', 5),
  EdgeDef('silver_harbor', 'verdant_valley', 3),
  EdgeDef('silver_harbor', 'frostspire', 5),
  EdgeDef('verdant_valley', 'frostspire', 3),
  EdgeDef('silver_harbor', 'void_wastes', 4),
];

final Map<String, RegionDef> regionMap = {for (final r in regions) r.id: r};
RegionDef region(String id) => regionMap[id] ?? regions.first;

List<EdgeDef> edgesOf(String id) =>
    edges.where((e) => e.a == id || e.b == id).toList();
String otherEnd(EdgeDef e, String id) => e.a == id ? e.b : e.a;

int travelDays(String a, String b) {
  // أقصر مسار (Dijkstra مبسط)
  final dist = <String, int>{a: 0};
  final done = <String>{};
  while (true) {
    String? cur;
    int best = 1 << 30;
    dist.forEach((k, v) {
      if (!done.contains(k) && v < best) {
        best = v;
        cur = k;
      }
    });
    if (cur == null) return -1;
    if (cur == b) return best;
    done.add(cur!);
    for (final e in edgesOf(cur!)) {
      final o = otherEnd(e, cur!);
      final nd = best + e.days;
      if (!dist.containsKey(o) || nd < dist[o]!) dist[o] = nd;
    }
  }
}

const List<SiteDef> sites = [
  SiteDef('stone_arena', 'حلبة الجسر الحجري', 'stonebridge',
      'نزالات مأجورة أمام الجمهور. أجر مقابل الدم.', 'city', 2,
      [['bandit'], ['bandit', 'bandit_archer']],
      silver: 120, cooldown: 7),
  SiteDef('wolf_den', 'وكر الذئاب', 'greenshade',
      'وكر مظلم تعوي فيه الذئاب.', 'forest', 3,
      [['wolf', 'wolf'], ['wolf', 'wolf', 'boar']],
      boss: 'alpha_wolf',
      loot: {'wolf_pelt': 1.0, 'beast_core_1': 0.5, 'spirit_fang': 0.2}, cooldown: 25),
  SiteDef('bandit_camp', 'معسكر قطاع الطرق', 'greenshade',
      'معسكر محصّن يقوده زعيم قاسٍ.', 'forest', 3,
      [['bandit', 'bandit'], ['bandit', 'bandit_archer', 'bandit']],
      boss: 'bandit_chief',
      loot: {'iron_ore': 0.9, 'treasure_map': 0.3, 'sword_1': 0.1},
      silver: 200, cooldown: 30),
  SiteDef('lotus_deep', 'عمق كهف اللوتس', 'lotus_cave',
      'حارس حجري يحرس بحيرة اللوتس.', 'cave', 5,
      [['skeleton', 'skeleton'], ['ghost', 'skeleton', 'ghost']],
      boss: 'stone_guardian',
      loot: {'moon_lotus': 0.8, 'beast_core_1': 0.6}, hidden: true, cooldown: 60),
  SiteDef('bandit_hideout', 'مخبأ المهرّبين', 'silver_harbor',
      'مستودع سري تحت الميناء.', 'cave', 4,
      [['bandit', 'bandit_archer'], ['bandit', 'bandit', 'bandit_archer']],
      boss: 'smuggler_boss',
      loot: {'treasure_map': 0.5, 'ancient_codex': 0.2}, silver: 400, cooldown: 30),
  SiteDef('fang_nest', 'عرين الأنياب', 'fang_plain',
      'عرين الذئاب الروحية.', 'plains', 6,
      [['spirit_wolf', 'spirit_wolf'], ['spirit_wolf', 'boar', 'spirit_wolf']],
      boss: 'spirit_wolf_king',
      loot: {'spirit_fang': 1.0, 'beast_core_2': 0.35, 'wolf_pelt': 1.0}, cooldown: 30),
  SiteDef('iron_mine', 'منجم الحديد المهجور', 'blackiron',
      'منجم ابتلعته الظلمات. الهياكل ما زالت تحفر.', 'cave', 5,
      [['skeleton', 'skeleton'], ['skeleton_guard', 'skeleton']],
      boss: 'iron_golem',
      loot: {'iron_ore': 1.0, 'spirit_iron': 0.5, 'ancient_gear': 0.3}, cooldown: 30),
  SiteDef('ghost_hollow', 'جوف المستنقع', 'ghostmire',
      'قلب الضباب حيث يسكن لورد الأشباح.', 'swamp', 7,
      [['ghost', 'ghost'], ['ghost', 'shadow', 'ghost']],
      boss: 'wraith_lord',
      loot: {'ghost_dust': 1.0, 'ghost_orchid': 0.5, 'shadow_essence': 0.3},
      cooldown: 35),
  SiteDef('azure_trial', 'ساحة محنة السحاب', 'azure_peaks',
      'ساحة تُجرى فيها محن التلاميذ.', 'mountain', 8,
      [['cultivator', 'cultivator'], ['cultivator_mage', 'cultivator']],
      loot: {'beast_core_2': 0.4, 'moon_lotus': 0.3}, silver: 800, cooldown: 30, minRealm: 1),
  SiteDef('blood_pit', 'حفرة الدم', 'bloodmoon_valley',
      'حيث يُصقل المتدرّبون بالدم.', 'ruins', 9,
      [['cultivator', 'shadow'], ['cultivator', 'skeleton', 'cultivator_mage']],
      boss: 'blood_elder',
      loot: {'beast_core_2': 0.6, 'shadow_essence': 0.4}, lethal: true, cooldown: 40, minRealm: 1),
  SiteDef('verdant_garden', 'الحديقة المحرّمة', 'verdant_valley',
      'حديقة أعشاب نادرة يحرسها عملاق نباتي.', 'forest', 10,
      [['boar', 'cultivator_mage'], ['golem', 'cultivator_mage']],
      boss: 'vine_titan',
      loot: {'soul_flower': 0.35, 'moon_lotus': 0.8, 'blood_ginseng': 1.0}, cooldown: 45, minRealm: 2),
  SiteDef('ashen_crypt', 'سرداب المعبد', 'ashen_temple',
      'سرداب مليء بالحراس الأبديين.', 'ruins', 12,
      [['skeleton_guard', 'skeleton_guard'], ['golem', 'skeleton_guard']],
      boss: 'ash_lich',
      loot: {'ancient_gear': 1.0, 'ancient_codex': 0.6, 'beast_core_3': 0.2},
      hidden: true, lethal: true, cooldown: 50, minRealm: 3),
  SiteDef('frost_floors', 'طوابق قلعة الجليد', 'frostspire',
      'طوابق متراكبة من الجليد والظلال.', 'snow', 14,
      [['shadow', 'shadow'], ['golem', 'cultivator_mage', 'shadow']],
      boss: 'frost_sovereign',
      loot: {'cold_jade': 1.0, 'star_silver': 0.5, 'beast_core_3': 0.4},
      lethal: true, cooldown: 60, minRealm: 4),
  SiteDef('void_gate', 'البوابة الفارغة', 'void_wastes',
      'صدع في السماء. خلفه الطريق إلى ما بعد الحدود.', 'void', 20,
      [['shadow', 'shadow', 'ghost'], ['golem', 'shadow', 'golem']],
      boss: 'void_warden',
      loot: {'star_silver': 1.0, 'beast_core_3': 1.0},
      hidden: true, lethal: true, cooldown: 120, minRealm: 7),
];

final Map<String, SiteDef> siteMap = {for (final s in sites) s.id: s};
List<SiteDef> sitesIn(String regionId) =>
    sites.where((s) => s.region == regionId).toList();
