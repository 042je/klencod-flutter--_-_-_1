import '../core/util.dart';
import '../game/game.dart';
import 'cultivation.dart';
import 'items.dart';

class Ch {
  final String t;
  final String Function(Game) run;
  const Ch(this.t, this.run);
}

class Ev {
  final String id, title, text, icon;
  final bool Function(Game) cond;
  final double w;
  final List<Ch> ch;
  const Ev(this.id, this.title, this.text, this.cond, this.ch,
      {this.w = 1, this.icon = 'scroll'});
}

String _gain(Game g, int s, [String extra = '']) {
  g.silver += s;
  return 'ربحت $s فضة. $extra';
}

final List<Ev> allEvents = [
  Ev('festival', 'مهرجان الحصاد',
      'القرية تحتفل بالحصاد. الجميع يدعوك للمشاركة في المسابقات والغناء.',
      (g) => g.here.id == 'riverbend' || g.here.id == 'stonebridge',
      [
        Ch('شارك في المسابقة', (g) {
          if (g.cha + ri(0, 6) > 9) {
            g.changeMood(15);
            return _gain(g, 80, 'وفزت بإعجاب الجميع.');
          }
          g.changeMood(3);
          return 'خسرت المسابقة لكنك استمتعت.';
        }),
        Ch('ساعد الفلاحين', (g) {
          g.str += 1;
          g.addItem('ration', 3);
          return 'ساعدت في الحصاد: القوة +1 ومؤونة مجانية.';
        }),
        Ch('ابقَ في البيت', (g) {
          g.changeMood(-2);
          return 'قضيت اليوم وحيداً.';
        }),
      ]),
  Ev('merchant', 'تاجر متجوّل',
      'تاجر عجوز يعرض عليك حزمة أعشاب نادرة بسعر مغرٍ مقابل 60 فضة.',
      (g) => g.silver >= 20,
      [
        Ch('اشترِ (60 فضة)', (g) {
          if (g.silver < 60) return 'لا تملك المال الكافي.';
          g.silver -= 60;
          g.addItem('blood_ginseng', 2);
          g.addItem('moon_lotus', chance(0.3) ? 1 : 0);
          return 'اشتريت أعشاباً ثمينة.';
        }),
        Ch('ساوم', (g) {
          if (g.cha + ri(0, 8) > 11) {
            g.addItem('blood_ginseng', 2);
            g.silver -= 25;
            return 'نجحت المساومة! دفعت 25 فضة فقط.';
          }
          return 'رفض التاجر وغادر غاضباً.';
        }),
        Ch('تجاهله', (g) => 'واصلت طريقك.'),
      ],
      w: 1.2),
  Ev('wolves', 'ذئاب في الطريق',
      'ذئاب جائعة تعترض طريقك بين القرى.',
      (g) => g.gi < 12,
      [
        Ch('قاتل', (g) {
          if (g.power > 20 * 1.2 + ri(0, 10)) {
            g.addItem('wolf_pelt', 2);
            return 'هزمت الذئاب وجمعت جلودها.';
          }
          g.changeHealth(-ri(12, 28));
          return 'أصابتك الذئاب بجروح قبل أن تهرب.';
        }),
        Ch('اهرب', (g) {
          if (g.luck + ri(0, 8) > 9) return 'نجوت بذكاء.';
          g.changeHealth(-ri(5, 15));
          return 'نجوت لكن مع بعض الجروح.';
        }),
      ],
      w: 1.0),
  Ev('mentor', 'العجوز مو',
      'عجوز غريب على ضفة النهر يعرض أن يعلّمك أسرار تنفس الطاقة.',
      (g) => !g.flags.contains('mentor') && g.realm == 0,
      [
        Ch('اقبل التعليم', (g) {
          g.flags.add('mentor');
          g.wis += 2;
          g.xp += xpNeed(g.realm, g.sub) * 0.6;
          return 'تعلمت أساسيات التنفس الروحي: الحكمة +2 وخبرة زراعية كبيرة.';
        }),
        Ch('اعتذر بأدب', (g) => 'رحل العجوز مبتسماً.'),
      ],
      w: 3,
      icon: 'book'),
  Ev('sick', 'حمّى غامضة',
      'شعرت بحمّى شديدة. يقول الناس إن وباءً بدأ ينتشر.',
      (g) => !g.flags.contains('sick'),
      [
        Ch('استخدم حبة ترياق', (g) {
          if (g.takeItem('antidote_pill')) return 'شُفيت فوراً.';
          g.flags.add('sick');
          g.changeHealth(-15);
          return 'لا تملك ترياقاً! ستحتاج للعلاج (حبة ترياق).';
        }),
        Ch('اشرب أعشاباً بلدية', (g) {
          if (g.takeItem('frostmint', 2)) {
            return 'نعناع الصقيع خفّض الحمّى.';
          }
          g.changeHealth(-20);
          return 'لم تنفع الأعشاب. مرضت أياماً.';
        }),
        Ch('اصبر', (g) {
          g.changeHealth(-ri(15, 30));
          return 'عانيت أسابيع من المرض.';
        }),
      ],
      w: 0.8),
  Ev('bandits', 'قطاع الطرق',
      'مجموعة قطاع طرق تطلب منك إتاوة: 100 فضة.',
      (g) => g.silver > 50,
      [
        Ch('ادفع', (g) {
          final p = g.silver < 100 ? g.silver : 100;
          g.silver -= p;
          return 'دفعت $p فضة ومضيت.';
        }),
        Ch('قاتل', (g) {
          if (g.power > 28 + ri(0, 12)) {
            return _gain(g, ri(60, 160), 'هرب القطاع.');
          }
          g.changeHealth(-ri(15, 30));
          g.silver = (g.silver * 0.7).round();
          return 'هزموك وأخذوا بعض مالك.';
        }),
        Ch('تفاوض', (g) {
          if (g.cha + ri(0, 8) > 12) return 'أقنعتهم بتركك مقابل وعد.';
          g.silver = (g.silver * 0.85).round();
          return 'ضحكوا منك وأخذوا بعض المال.';
        }),
      ],
      w: 0.9),
  Ev('romance', 'لقاء مصادفة',
      'التقيت بشخص جذّاب أثناء السوق. تبادلتما حديثاً طويلاً.',
      (g) => g.age >= 17 && g.spouse == null && g.candidates.length < 4,
      [
        Ch('تعرّف عليه', (g) {
          final m = !g.male;
          g.people.add(Person(m ? pick(maleNames) : pick(femaleNames), m, g.age + ri(-2, 3),
              rng.nextInt(99999), 'candidate',
              bond: 25, talent: ri(3, 9)));
          g.changeMood(10);
          return 'أصبح لديك معرفة جديدة. (راجع تبويب العائلة)';
        }),
        Ch('أكمل طريقك', (g) => 'مضى اللقاء كحلم عابر.'),
      ],
      w: 1.3,
      icon: 'gem'),
  Ev('child_sick', 'مرض الطفل',
      'أحد أبنائك أصيب بحمّى شديدة.',
      (g) => g.children.isNotEmpty,
      [
        Ch('اشترِ دواء (80 فضة)', (g) {
          if (g.silver < 80) return 'لا مال كافٍ! تألم الطفل أياماً.';
          g.silver -= 80;
          for (final c in g.children) {
            g.gainBond(c, 4);
          }
          return 'تعافى الطفل سريعاً.';
        }),
        Ch('استخدم حبة شفاء', (g) {
          if (g.takeItem('heal_pill')) return 'شُفي الطفل وازداد تعلقه بك.';
          return 'لا تملك حبة شفاء.';
        }),
        Ch('انتظر', (g) {
          g.changeMood(-10);
          return 'تعافى الطفل ببطء، وأنت قلق.';
        }),
      ],
      w: 1.2,
      icon: 'pill'),
  Ev('spouse_gift', 'طلب الزوج/ة',
      'شريك حياتك يلمّح أنه يريد هدية للمناسبة.',
      (g) => g.spouse != null,
      [
        Ch('اشترِ هدية (100 فضة)', (g) {
          if (g.silver < 100) return 'لا مال كافٍ.';
          g.silver -= 100;
          g.gainBond(g.spouse!, 12);
          g.changeMood(8);
          return 'سعد شريكك كثيراً.';
        }),
        Ch('اعتذر', (g) {
          g.gainBond(g.spouse!, -8);
          return 'خاب أمل شريكك قليلاً.';
        }),
      ],
      w: 1.2),
  Ev('quarrel', 'شجار عائلي',
      'اندلع خلاف بين أفراد العائلة حول المال.',
      (g) => g.people.where((p) => p.alive && p.role != 'candidate').length >= 3,
      [
        Ch('حكّم بالعدل', (g) {
          g.changeMood(3);
          return 'هدأت الأمور بحكمتك.';
        }),
        Ch('أنفق للترضية (150 فضة)', (g) {
          if (g.silver < 150) return 'لا مال كافٍ.';
          g.silver -= 150;
          g.changeMood(8);
          return 'ساد الوئام.';
        }),
        Ch('اترك الأمر', (g) {
          g.changeMood(-10);
          return 'توترت الأجواء في البيت.';
        }),
      ],
      w: 0.8),
  Ev('cave', 'كهف مجهول',
      'وجدت مدخل كهف يلمع من داخله ضوء خافت.',
      (g) => g.here.herbs.isNotEmpty,
      [
        Ch('ادخل', (g) {
          final r = rng.nextDouble() + g.luck * 0.01;
          if (r > 0.7) {
            g.addItem('beast_core_1');
            g.addItem('qi_grass', 3);
            return 'وجدت نواة وحش وأعشاباً!';
          }
          if (r > 0.3) return _gain(g, ri(20, 80));
          g.changeHealth(-ri(10, 25));
          return 'سقط عليك حجر وأصبت.';
        }),
        Ch('تجاهله', (g) => 'قررت ألا تغامر.'),
      ],
      w: 1.0),
  Ev('sect_recruit', 'مبعوث طائفة',
      'مبعوث من إحدى الطوائف لاحظ موهبتك ويعرض اختبارك للانضمام.',
      (g) => g.realm >= 1 && g.sect.isEmpty,
      [
        Ch('اجتز الاختبار', (g) {
          if (g.wis + ri(0, 6) > 11) {
            g.sect = 'azure';
            g.sectRank = 0;
            return 'نجحت وانضممت إلى طائفة السحاب الأزرق!';
          }
          return 'فشلت في الاختبار.';
        }),
        Ch('ارفض', (g) => 'فضّلت الحرية.'),
      ],
      w: 1.5,
      icon: 'talisman'),
  Ev('tax', 'جابي الضرائب', 'مندوب الملك يطالبك بالضريبة السنوية.',
      (g) => g.silver > 200 && g.month == 12,
      [
        Ch('ادفع', (g) {
          final t = (g.silver * 0.1).round();
          g.silver -= t;
          return 'دفعت $t فضة.';
        }),
        Ch('تهرّب', (g) {
          if (g.luck + ri(0, 8) > 11) return 'نجحت في التهرب!';
          final t = (g.silver * 0.2).round();
          g.silver -= t;
          return 'اكتُشف أمرك وغُرّمت $t فضة.';
        }),
      ],
      w: 3),
  Ev('spirit_rain', 'مطر روحي',
      'هطل مطر مضيء يحمل طاقة روحية كثيفة.',
      (g) => g.realm >= 0,
      [
        Ch('تأمل تحت المطر', (g) {
          final x = xpNeed(g.realm, g.sub) * 0.3;
          g.xp += x;
          return 'استفدت من الطاقة: خبرة زراعية +${fmt(x)}';
        }),
        Ch('اجمع ماء المطر', (g) {
          g.addItem('qi_grass', 2);
          return 'جمعت ماءً روحياً وتحوّل إلى أعشاب.';
        }),
      ],
      w: 0.7,
      icon: 'gem'),
  Ev('auction', 'مزاد خاص',
      'أُقيم مزاد صغير يعرض صندوقاً مغلقاً بسعر 500 فضة.',
      (g) => g.silver >= 300 && g.here.market,
      [
        Ch('زايد (500 فضة)', (g) {
          if (g.silver < 500) return 'لا تملك المبلغ.';
          g.silver -= 500;
          final r = rng.nextDouble() + g.luck * 0.015;
          if (r > 0.85) {
            g.addItem('foundation_pill');
            return 'في الصندوق حبة تأسيس!';
          }
          if (r > 0.45) {
            g.addItem('beast_core_2');
            return 'في الصندوق نواة وحش متوسطة.';
          }
          return 'الصندوق شبه فارغ... خسرت.';
        }),
        Ch('اكتفِ بالمشاهدة', (g) => 'شاهدت المزاد بتسلية.'),
      ],
      w: 0.7),
  Ev('inner_demon', 'شيطان القلب',
      'أثناء التأمل ظهر في ذهنك صوت مرعب يعرض عليك طريقاً مختصراً.',
      (g) => g.realm >= 2,
      [
        Ch('قاوم بصفاء الذهن', (g) {
          if (g.wis + ri(0, 10) > 14 || g.flags.contains('mind_calm')) {
            g.wis += 1;
            g.xp += xpNeed(g.realm, g.sub) * 0.4;
            return 'انتصرت على شيطانك: الحكمة +1 وخبرة كبيرة.';
          }
          g.changeHealth(-25);
          g.toxin += 10;
          return 'انحرفت طاقتك وأُصبت.';
        }),
        Ch('اقبل العرض', (g) {
          g.xp += xpNeed(g.realm, g.sub) * 0.8;
          g.toxin += 25;
          g.changeMood(-15);
          return 'تقدمت سريعاً لكن سمّية الطاقة ارتفعت.';
        }),
      ],
      w: 1.0,
      icon: 'gem'),
  Ev('stranger', 'الغريب وي لان',
      'غريب غامض يحدّق بك في الحانة ثم يقول: «لقد رأيتك من قبل... في عمر آخر».',
      (g) => g.lives.isNotEmpty && g.age >= 22 && !g.flags.contains('stranger'),
      [
        Ch('اسأله عن المرآة', (g) {
          g.flags.add('stranger');
          g.knowledge.add('stranger');
          if (g.lives.length >= 2) {
            g.knowledge.add('void_gate_path');
            g.found.add('void_wastes');
            return 'كشف لك سرّ البوابة الفارغة! (معرفة دائمة: طريق تجاوز الحدود)';
          }
          return 'قال: «عُد حين تموت مرة أخرى... وسأخبرك المزيد».';
        }),
        Ch('تجاهله', (g) => 'ابتسم وغادر.'),
      ],
      w: 4,
      icon: 'scroll'),
  Ev('mirror_whisper', 'همس المرآة',
      'شعرت بشظية دافئة في صدرك: ذكريات حيواتك السابقة تتلألأ.',
      (g) => g.lives.isNotEmpty && !g.flags.contains('mw'),
      [
        Ch('استدعِ الذكرى', (g) {
          g.flags.add('mw');
          final x = xpNeed(g.realm, g.sub) * 0.7;
          g.xp += x;
          g.wis += 1;
          return 'استعدت خبرات قديمة: الحكمة +1 وخبرة زراعية.';
        }),
        Ch('كتم الذكرى', (g) => 'تركت الماضي خلفك.'),
      ],
      w: 3,
      icon: 'gem'),
  Ev('loan', 'صديق يطلب قرضاً',
      'صديق قديم يطلب 100 فضة قرضاً ويعد بالسداد.',
      (g) => g.silver >= 150,
      [
        Ch('أقرضه', (g) {
          g.silver -= 100;
          if (chance(0.6)) {
            g.silver += 150;
            return 'سدّد الصديق دينه مع الفائدة.';
          }
          return 'اختفى الصديق مع المال.';
        }),
        Ch('اعتذر', (g) => 'خسرت صديقاً لكن حفظت مالك.'),
      ],
      w: 0.8),
  Ev('treasure_map', 'خريطة ممزقة',
      'وجدت جزءاً من خريطة كنز في كتاب مستعمل.',
      (g) => true,
      [
        Ch('احتفظ بها', (g) {
          g.addItem('treasure_map');
          return 'أصبحت لديك خريطة كنز.';
        }),
        Ch('بعها (40 فضة)', (g) => _gain(g, 40)),
      ],
      w: 0.7),
  Ev('beast_tide', 'موجة وحوش',
      'وحوش مذعورة تهاجم المزارع المجاورة.',
      (g) => g.gi >= 6,
      [
        Ch('دافع عن القرية', (g) {
          if (g.power > 30 * (1 + g.here.level * 0.1)) {
            g.silver += 300;
            g.changeMood(15);
            return 'أنقذت القرية! كافأك الأهالي بـ300 فضة.';
          }
          g.changeHealth(-30);
          return 'قاتلت بشجاعة لكن أُصبت بشدة.';
        }),
        Ch('انجُ بنفسك', (g) {
          g.changeMood(-12);
          return 'نجوت لكن الضمير يؤلمك.';
        }),
      ],
      w: 0.6),
  Ev('old_age', 'نذير الأجل',
      'تشعر بتعب ثقيل في عظامك. ربما لم يبقَ لك الكثير.',
      (g) => g.age >= g.lifespan - 5,
      [
        Ch('استعمل حبة عمر', (g) {
          if (g.takeItem('longevity_pill')) {
            g.bonusLife += 4;
            g.toxin += 30;
            return 'زدتَ عمرك أربع سنوات!';
          }
          return 'لا تملك حبة عمر.';
        }),
        Ch('اجمع أسرتك', (g) {
          g.changeMood(10);
          return 'قضيت وقتاً ثميناً مع أحبائك.';
        }),
      ],
      w: 5),
  Ev('child_talent', 'موهبة الطفل',
      'لاحظ المعلم أن أحد أبنائك موهوب بشكل لافت.',
      (g) => g.children.any((c) => c.age >= 5 && c.age < 16),
      [
        Ch('ادعمه (200 فضة)', (g) {
          if (g.silver < 200) return 'لا مال كافٍ.';
          g.silver -= 200;
          final c = g.children.firstWhere((c) => c.age >= 5 && c.age < 16);
          c.skill = (c.skill + 15).clamp(0, 100);
          c.talent = (c.talent + 1).clamp(1, 10);
          return 'ازدادت مهارة ${c.name}.';
        }),
        Ch('اتركه يلعب', (g) {
          g.changeMood(5);
          return 'عاش طفولة سعيدة.';
        }),
      ],
      w: 1.0),
  Ev('herb_boom', 'وفرة أعشاب',
      'موسم نادر جعل الأعشاب تنمو بكثرة.',
      (g) => g.here.herbs.isNotEmpty,
      [
        Ch('اقطف ما تستطيع', (g) {
          final id = pick(g.here.herbs);
          final n = ri(3, 6);
          g.addItem(id, n);
          return 'جمعت $n × ${item(id).name}.';
        }),
      ],
      w: 0.8,
      icon: 'herb'),
];
