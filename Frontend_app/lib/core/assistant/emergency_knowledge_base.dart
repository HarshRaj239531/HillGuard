class EmergencyProtocol {
  final String id;
  final String title;
  final String category;
  final String shortSummary;
  final List<String> immediateActionSteps;
  final List<String> criticalWarnings;
  final List<String> whatNotToDo;
  final String medicalRationale;
  final List<String> triggerKeywords;

  const EmergencyProtocol({
    required this.id,
    required this.title,
    required this.category,
    required this.shortSummary,
    required this.immediateActionSteps,
    required this.criticalWarnings,
    required this.whatNotToDo,
    required this.medicalRationale,
    required this.triggerKeywords,
  });
}

class EmergencyKnowledgeBase {
  static const List<EmergencyProtocol> protocols = [
    // 1. CLOUDBURST & FLASH FLOOD SURVIVAL
    EmergencyProtocol(
      id: 'proto-cloudburst',
      title: 'Cloudburst & Sudden Flash Flood Protocol',
      category: 'Severe Meteorological Hazards',
      shortSummary: 'Sudden intense torrential downpour (>100mm/hr) leading to instant gully debris flows and bridge washaways.',
      immediateActionSteps: [
        'Move IMMEDIATELY uphill and away from ravines, seasonal water channels (jhoras), and river embankments.',
        'Gain at least 30 to 50 meters of vertical elevation above valley floor on a vegetated, non-fractured rock ridge.',
        'Do NOT cross swollen streams, even if water appears shallow (15 cm of moving water sweeps an adult; 30 cm sweeps a car).',
        'If trapped on an island/spur, anchor to sturdy mature trees using climbing rope or clothing tied together.',
        'Monitor water color: If clear stream suddenly turns muddy brown or carries twigs/leaves, a debris flow surge is seconds away.',
      ],
      criticalWarnings: [
        'Never seek shelter under culverts, road underpasses, or dry riverbeds — these become instant hydraulic death traps.',
        'Steep mountain gullies amplify water velocity up to 40 km/h with crushing boulder loads.',
      ],
      whatNotToDo: [
        'Do NOT attempt to drive through flowing water across mountain dips or submerged causeways.',
        'Do NOT wait to gather heavy belongings before seeking high ground.',
      ],
      medicalRationale: 'Primary causes of mortality in cloudbursts are blunt force hydraulic trauma from rolling boulders and high-velocity drowning.',
      triggerKeywords: ['cloudburst', 'flash flood', 'flood', 'heavy rain', 'torrential', 'drowning', 'water rising', 'river overflow', 'jhora'],
    ),

    // 2. LANDSLIDE & DEBRIS ENTRAPMENT
    EmergencyProtocol(
      id: 'proto-landslide',
      title: 'Landslide & Escarpment Collapse Escape',
      category: 'Geological Hazards',
      shortSummary: 'Slope failure, rotational slip, or debris torrent on mountain cuts and retaining walls.',
      immediateActionSteps: [
        'Run PERPENDICULAR to the slide path (laterally sideways toward stable ridges), NEVER run downhill in front of the slide.',
        'Listen for the rumble: Landslides are preceded by cracking trees, rolling stones, and a deep freight-train roar.',
        'If trapped inside a collapsing building: Curl into a tight fetal ball under a reinforced table or doorframe to protect head/neck.',
        'If partially buried in mud: Create an air pocket in front of your face with cupped hands before the mud compacts.',
        'Conserve energy and air: Tap rhythmically on metal pipes or rocks with a stone (three taps) — sound travels much farther than shouting.',
      ],
      criticalWarnings: [
        'Secondary slides occur within 20 to 60 minutes after the initial collapse as tension head-scarp loses toe support.',
        'Wet mud slurry acts like wet cement; it rapidly compresses the ribcage, causing positional asphyxia.',
      ],
      whatNotToDo: [
        'Do NOT re-enter a slide area to inspect property or vehicles until declared stable by geotechnical teams.',
        'Do NOT walk on fresh debris piles — they may be liquified quicksand underneath.',
      ],
      medicalRationale: 'Extricated victims face crush syndrome (rhabdomyolysis); releasing trapped limbs after >15 min requires medical hydration.',
      triggerKeywords: ['landslide', 'mudslide', 'rockfall', 'trapped in mud', 'debris', 'slope collapse', 'buried', 'crack in wall'],
    ),

    // 3. HYPOTHERMIA & COLD EXPOSURE SHOCK
    EmergencyProtocol(
      id: 'proto-hypothermia',
      title: 'Hypothermia & Mountain Cold Exposure',
      category: 'Wilderness Medicine',
      shortSummary: 'Rapid loss of core body temperature caused by wet clothes, wind chill, and monsoon night temperatures below 12°C.',
      immediateActionSteps: [
        'Remove ALL wet clothing immediately. Wet cotton drains body heat 25 times faster than dry air.',
        'Create a "Burrito Wrap": Layer dry clothes/tarpaulins/plastic bags with an insulation layer (leaves, newspapers, blankets).',
        'Protect core zones: Cover head, neck, groin, and armpits where major blood vessels are superficial.',
        'Provide passive rewarming: Share body heat skin-to-skin inside a sleeping bag or dry tarpaulin.',
        'If conscious and shivering: Administer warm, sweet fluids (sugar tea, hot water with salt/glucose).',
      ],
      criticalWarnings: [
        'If shivering STOPS and victim becomes confused or drowsy, this is SEVERE HYPOTHERMIA (Medical Emergency).',
        'Handle victim extremely gently: Rough movement can trigger fatal ventricular fibrillation (cardiac arrest).',
      ],
      whatNotToDo: [
        'Do NOT rub frostbitten or cold extremities — ice crystals in tissue will tear cellular walls.',
        'Do NOT give alcohol or coffee — they dilate peripheral vessels, causing catastrophic core temperature drop.',
        'Do NOT apply direct high heat (boiling water or open fire) directly to cold skin.',
      ],
      medicalRationale: 'Cold blood pooling in extremities returning rapidly to the heart triggers "afterdrop" cardiac arrest.',
      triggerKeywords: ['cold', 'hypothermia', 'shivering', 'wet clothes', 'freezing', 'frostbite', 'numb fingers', 'unconscious cold'],
    ),

    // 4. CUT OFF FROM HOSPITAL - TRAUMA & BLEEDING
    EmergencyProtocol(
      id: 'proto-trauma',
      title: 'Remote Mountain Trauma & Arterial Bleeding',
      category: 'First-Aid Without Hospital',
      shortSummary: 'Severe lacerations, open fractures, and heavy bleeding when roads are cut off and ambulance cannot reach.',
      immediateActionSteps: [
        'Control Bleeding FIRST: Apply hard, uninterrupted DIRECT PRESSURE over wound using clean cloth or folded shirt for 5 full minutes.',
        'If blood spurts bright red (arterial): Place an improvised TOURNIQUET 5 to 7 cm above the wound (between wound and heart). Tighten using a stick windlass until bleeding stops completely.',
        'Write time of tourniquet application on the victim\'s forehead (e.g., "TK 14:30").',
        'Immobilize fractures: Splint broken bone using rigid tree branches, rolled cardboard, or trekking poles padded with shirts. Tie above and below the joint.',
        'Position victim for shock: Lay flat on back with legs elevated 30 cm (unless head/chest injury suspected). Cover to prevent hypothermia.',
      ],
      criticalWarnings: [
        'Tourniquets must NOT be loosened or removed by non-surgeons once applied, or trapped toxins will surge into kidneys.',
        'Do NOT push exposed bone fragments back into the flesh.',
      ],
      whatNotToDo: [
        'Do NOT remove the first dressing if blood soaks through — add more layers on top and press harder.',
        'Do NOT give solid food or water to a victim needing potential emergency surgery.',
      ],
      medicalRationale: 'Exsanguinating arterial hemorrhage causes irreversible shock within 3 minutes; immediate mechanical occlusion is mandatory.',
      triggerKeywords: ['bleeding', 'blood', 'artery', 'fracture', 'broken bone', 'cut off from hospital', 'tourniquet', 'first aid', 'wound'],
    ),

    // 5. STRANDED VEHICLE IN MOUNTAIN ROAD CUT-OFF
    EmergencyProtocol(
      id: 'proto-stranded',
      title: 'Stranded Vehicle on Blocked Mountain Pass',
      category: 'Road & Highway Survival',
      shortSummary: 'Vehicle trapped between two landslides or road washaways on highway with zero cellular reception.',
      immediateActionSteps: [
        'Stay WITH the vehicle: A vehicle is an insulated shelter and far easier for helicopters and rescue patrols to locate than an individual on foot.',
        'Park safely: Move car away from overhang cut slopes or sheer valley drop-offs to prevent falling rock damage.',
        'Conserve fuel: Run engine for 10 minutes every hour to heat cabin and recharge battery. Ensure exhaust tailpipe is 100% free of mud/snow.',
        'Ventilate slightly: Crack down-wind window 1 cm when heater runs to prevent deadly Carbon Monoxide (CO) poisoning.',
        'Signal distress: Hang a brightly colored cloth/towel on the radio antenna or side mirror.',
      ],
      criticalWarnings: [
        'Running vehicle heater in a mud/snow-blocked tailpipe causes fatal Carbon Monoxide buildup in under 15 minutes.',
        'Do NOT wander into the forest in dense mountain fog; disorientation and cliff falls are leading causes of lost traveler deaths.',
      ],
      whatNotToDo: [
        'Do NOT leave headlights on continuously when engine is stopped — dead battery leaves you without starter or horn.',
        'Do NOT attempt to walk mountain pass at night during active rainfall.',
      ],
      medicalRationale: 'Cabin shelter protects against wind chill index, lowering metabolic demand and preventing exposure dehydration.',
      triggerKeywords: ['stranded', 'car stuck', 'blocked road', 'overnight in car', 'no signal car', 'traffic jam landslide', 'out of fuel'],
    ),

    // 6. SAFE WATER SOURCING & SILT FLUID PURIFICATION
    EmergencyProtocol(
      id: 'proto-water',
      title: 'Emergency Water Sourcing & Silt Purification',
      category: 'Survival Sustenance',
      shortSummary: 'Purifying muddy monsoon stream water when village pipes are destroyed by landslides.',
      immediateActionSteps: [
        'Flocculate and Settle: Collect muddy water in a bucket/bottle and let sit undisturbed for 2 hours so heavy silt drops to bottom.',
        'Filter through Cloth: Pour the clearer top water through 4 to 6 folds of a clean cotton shirt or bandana.',
        'Boil Vigorous Rolling Boil: Boil filtered water for at least 3 minutes (water boils at lower temperatures at high mountain altitude).',
        'Improvised Charcoal Filtration: Pack plastic bottle with layers of sand, crushed wood charcoal from fire, and pebbles for gravity filter.',
        'Harvest Rain: Catch rainfall directly off a clean taut plastic sheet or umbrella into clean containers.',
      ],
      criticalWarnings: [
        'Never drink flood water directly from active landslide gullies — it carries toxic mineral slurry, agricultural runoff, and animal carcasses.',
      ],
      whatNotToDo: [
        'Do NOT drink stream water flowing past village sewer pipes or dead livestock.',
      ],
      medicalRationale: 'Acute waterborne gastroenteritis and leptospirosis cause lethal dehydration within 36 hours in isolated zones.',
      triggerKeywords: ['water', 'drinking water', 'thirsty', 'purify water', 'dirty water', 'muddy water', 'boil water'],
    ),

    // 7. ALPINE DISTRESS SIGNALS (NO NETWORK CALL FOR HELP)
    EmergencyProtocol(
      id: 'proto-signaling',
      title: 'Alpine Emergency Distress Signaling (No Signal)',
      category: 'Distress Communication',
      shortSummary: 'Standard international mountain distress codes to signal search helicopters and ground search parties.',
      immediateActionSteps: [
        'The International Alpine Distress Signal: SIX blasts on a whistle (or 6 flashes of a flashlight/mirror) within ONE minute, followed by 1 MINUTE PAUSE. Repeat.',
        'Response to Alpine Signal: Three blasts/flashes per minute indicates rescue party has heard you and is homing in.',
        'Ground-to-Air Helicopter Signaling: Stand in an open clearing. Spread both arms high in a "Y" shape ("YES - NEED ASSISTANCE"). An "X" stamped in rocks indicates medical emergency.',
        'Emergency Mirror Flash: Angle smartphone screen or compact mirror to reflect sunlight towards distant mountain ridges or aircraft.',
        'Smoke Signals: Three small fires in a straight line or triangle using damp leaves for thick white smoke.',
      ],
      criticalWarnings: [
        'Never stand under unstable trees or cliffs when signaling helicopters — rotor downwash creates a localized 120 km/h wind that shears branches.',
      ],
      whatNotToDo: [
        'Do NOT wave with only one arm raised (that signals "No assistance needed / All clear" to search pilots).',
      ],
      medicalRationale: 'Rhythmic auditory and optical intervals cut through mountain ambient wind noise and river roar.',
      triggerKeywords: ['sos', 'signal', 'help', 'rescue', 'call for help', 'whistle', 'helicopter', 'mirror', 'flash'],
    ),
  ];

  static EmergencyProtocol? findBestMatch(String query) {
    final lower = query.toLowerCase().trim();
    int bestScore = 0;
    EmergencyProtocol? bestMatch;

    for (final proto in protocols) {
      int score = 0;
      for (final kw in proto.triggerKeywords) {
        if (lower.contains(kw)) {
          score += 5;
        }
      }
      if (lower.contains(proto.title.toLowerCase())) {
        score += 10;
      }
      if (lower.contains(proto.category.toLowerCase())) {
        score += 3;
      }
      if (score > bestScore) {
        bestScore = score;
        bestMatch = proto;
      }
    }

    return bestMatch ?? protocols.first;
  }
}
