import 'package:get/get.dart';

enum AdminUnitType { council, district }

class AdminUnitSite {
  final String name;
  final String? website;
  final AdminUnitType type;

  const AdminUnitSite({
    required this.name,
    required this.type,
    this.website,
  });
}

class RegionSites {
  final String regionName;
  final String? regionWebsite;
  final List<AdminUnitSite> items; // councils + districts

  const RegionSites({
    required this.regionName,
    this.regionWebsite,
    required this.items,
  });

  List<AdminUnitSite> get councils =>
      items.where((x) => x.type == AdminUnitType.council).toList();

  List<AdminUnitSite> get districts =>
      items.where((x) => x.type == AdminUnitType.district).toList();
}

class WebsitesController extends GetxController {
  final regions = <RegionSites>[].obs;

  final query = ''.obs;

  // expanded region
  final expandedRegion = RxnString();

  // active tab: 0 regions, 1 councils, 2 districts
  final tabIndex = 0.obs;
  final showDirectoryDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSeed();
  }

  void loadSeed() {
    final list = _seedData.map((region) {
      final name = region['name'] as String;
      final regionWebsite = region['regionWebsite'] as String?;
      final councils = region['councils'] as List<Map<String, String?>>;
      final items = councils
          .map((c) => AdminUnitSite(
                name: c['name'] ?? '',
                website: c['website'],
                type: _inferType(c['name'] ?? ''),
              ))
          .toList();
      return RegionSites(
        regionName: name,
        regionWebsite: regionWebsite,
        items: items,
      );
    }).toList();

    regions.assignAll(list);
  }

  AdminUnitType _inferType(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('district council')) return AdminUnitType.district;
    return AdminUnitType.council;
  }

  static const List<Map<String, Object?>> _seedData = [
    {
      'name': 'Arusha',
      'regionWebsite': 'https://arusha.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Arusha City Council', 'website': 'https://arushacc.go.tz'},
        {'name': 'Arusha District Council', 'website': null},
        {'name': 'Meru District Council', 'website': 'https://merudc.go.tz'},
        {'name': 'Karatu District Council', 'website': 'https://karatudc.go.tz'},
        {'name': 'Longido District Council', 'website': null},
        {'name': 'Monduli District Council', 'website': 'https://mondulidc.go.tz'},
        {'name': 'Ngorongoro District Council', 'website': 'https://ngorongorodc.go.tz'},
      ],
    },
    {
      'name': 'Dar es Salaam',
      'regionWebsite': 'https://dsm.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Ilala Municipal Council', 'website': 'https://ilala.go.tz'},
        {'name': 'Kinondoni Municipal Council', 'website': 'https://kinondonimc.go.tz'},
        {'name': 'Temeke Municipal Council', 'website': 'https://temekemc.go.tz'},
        {'name': 'Kigamboni Municipal Council', 'website': 'https://kigambonimc.go.tz'},
        {'name': 'Ubungo Municipal Council', 'website': 'https://ubungomc.go.tz'},
      ],
    },
    {
      'name': 'Dodoma',
      'regionWebsite': 'https://dodoma.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Dodoma City Council', 'website': 'https://dodomacc.go.tz'},
        {'name': 'Bahi District Council', 'website': 'https://bahidc.go.tz'},
        {'name': 'Chamwino District Council', 'website': 'https://chamwinodc.go.tz'},
        {'name': 'Chemba District Council', 'website': 'https://chembadc.go.tz'},
        {'name': 'Kondoa District Council', 'website': 'https://kondoadc.go.tz'},
        {'name': 'Kongwa District Council', 'website': 'https://kongwadc.go.tz'},
        {'name': 'Mpwapwa District Council', 'website': 'https://mpwapwadc.go.tz'},
      ],
    },
    {
      'name': 'Geita',
      'regionWebsite': 'https://geita.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Geita Town Council', 'website': 'https://geitatc.go.tz'},
        {'name': 'Bukombe District Council', 'website': 'https://bukombedc.go.tz'},
        {'name': 'Chato District Council', 'website': 'https://chatodc.go.tz'},
        {'name': 'Mbogwe District Council', 'website': 'https://mbogwedc.go.tz'},
        {'name': "Nyang'hwale District Council", 'website': 'https://nyanghwaledc.go.tz'},
      ],
    },
    {
      'name': 'Iringa',
      'regionWebsite': 'https://iringa.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Iringa Municipal Council', 'website': 'https://iringamc.go.tz'},
        {'name': 'Iringa District Council', 'website': null},
        {'name': 'Kilolo District Council', 'website': 'https://kilolodc.go.tz'},
        {'name': 'Mufindi District Council', 'website': 'https://mufindidc.go.tz'},
        {'name': 'Mafinga Town Council', 'website': 'https://mafingatc.go.tz'},
      ],
    },
    {
      'name': 'Kagera',
      'regionWebsite': 'https://kagera.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Bukoba Municipal Council', 'website': 'https://bukobamc.go.tz'},
        {'name': 'Bukoba District Council', 'website': null},
        {'name': 'Biharamulo District Council', 'website': 'https://biharamulodc.go.tz'},
        {'name': 'Karagwe District Council', 'website': 'https://karagwedc.go.tz'},
        {'name': 'Kyerwa District Council', 'website': 'https://kyerwadc.go.tz'},
        {'name': 'Missenyi District Council', 'website': 'https://missenyidc.go.tz'},
        {'name': 'Muleba District Council', 'website': 'https://mulebadc.go.tz'},
        {'name': 'Ngara District Council', 'website': 'https://ngaradc.go.tz'},
      ],
    },
    {
      'name': 'Katavi',
      'regionWebsite': 'https://katavi.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Mpanda Municipal Council', 'website': 'https://mpandamc.go.tz'},
        {'name': 'Mpanda District Council', 'website': null},
        {'name': 'Mlele District Council', 'website': 'https://mleledc.go.tz'},
      ],
    },
    {
      'name': 'Kigoma',
      'regionWebsite': 'https://kigoma.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Kigoma Ujiji Municipal Council', 'website': 'https://kigomaujijimc.go.tz'},
        {'name': 'Kigoma District Council', 'website': null},
        {'name': 'Kasulu Town Council', 'website': 'https://kasulutc.go.tz'},
        {'name': 'Kasulu District Council', 'website': null},
        {'name': 'Kibondo District Council', 'website': 'https://kibondodc.go.tz'},
        {'name': 'Kakonko District Council', 'website': 'https://kakonkodc.go.tz'},
        {'name': 'Buhigwe District Council', 'website': 'https://buhigwedc.go.tz'},
        {'name': 'Uvinza District Council', 'website': 'https://uvinzadc.go.tz'},
      ],
    },
    {
      'name': 'Kilimanjaro',
      'regionWebsite': 'https://kilimanjaro.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Moshi Municipal Council', 'website': 'https://moshimc.go.tz'},
        {'name': 'Moshi District Council', 'website': null},
        {'name': 'Hai District Council', 'website': 'https://haidc.go.tz'},
        {'name': 'Rombo District Council', 'website': 'https://rombodc.go.tz'},
        {'name': 'Same District Council', 'website': 'https://samedc.go.tz'},
        {'name': 'Mwanga District Council', 'website': 'https://mwangadc.go.tz'},
        {'name': 'Siha District Council', 'website': 'https://sihadc.go.tz'},
      ],
    },
    {
      'name': 'Lindi',
      'regionWebsite': 'https://lindi.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Lindi Municipal Council', 'website': 'https://lindimc.go.tz'},
        {'name': 'Lindi District Council', 'website': null},
        {'name': 'Kilwa District Council', 'website': 'https://kilwadc.go.tz'},
        {'name': 'Liwale District Council', 'website': 'https://liwaledc.go.tz'},
        {'name': 'Nachingwea District Council', 'website': 'https://nachingweadc.go.tz'},
        {'name': 'Ruangwa District Council', 'website': 'https://ruangwadc.go.tz'},
      ],
    },
    {
      'name': 'Manyara',
      'regionWebsite': 'https://manyara.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Babati Town Council', 'website': 'https://babatitc.go.tz'},
        {'name': 'Babati District Council', 'website': null},
        {'name': 'Hanang District Council', 'website': 'https://hanangdc.go.tz'},
        {'name': 'Kiteto District Council', 'website': 'https://kitetodc.go.tz'},
        {'name': 'Mbulu District Council', 'website': 'https://mbuludc.go.tz'},
        {'name': 'Simanjiro District Council', 'website': 'https://simanjirodc.go.tz'},
      ],
    },
    {
      'name': 'Mara',
      'regionWebsite': 'https://mara.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Musoma Municipal Council', 'website': 'https://musomamc.go.tz'},
        {'name': 'Musoma District Council', 'website': null},
        {'name': 'Bunda District Council', 'website': 'https://bundadc.go.tz'},
        {'name': 'Butiama District Council', 'website': 'https://butiamadc.go.tz'},
        {'name': 'Rorya District Council', 'website': 'https://roryadc.go.tz'},
        {'name': 'Serengeti District Council', 'website': 'https://serengetidc.go.tz'},
        {'name': 'Tarime District Council', 'website': 'https://tarimedc.go.tz'},
      ],
    },
    {
      'name': 'Mbeya',
      'regionWebsite': 'https://mbeya.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Mbeya City Council', 'website': 'https://mbeyacc.go.tz'},
        {'name': 'Mbeya District Council', 'website': null},
        {'name': 'Rungwe District Council', 'website': 'https://rungwedc.go.tz'},
        {'name': 'Kyela District Council', 'website': 'https://kyeladc.go.tz'},
        {'name': 'Chunya District Council', 'website': 'https://chunyadc.go.tz'},
        {'name': 'Mbarali District Council', 'website': 'https://mbaralidc.go.tz'},
        {'name': 'Busokelo District Council', 'website': 'https://busokelodc.go.tz'},
      ],
    },
    {
      'name': 'Morogoro',
      'regionWebsite': 'https://morogoro.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Morogoro Municipal Council', 'website': 'https://morogoromc.go.tz'},
        {'name': 'Morogoro District Council', 'website': null},
        {'name': 'Kilosa District Council', 'website': 'https://kilosadc.go.tz'},
        {'name': 'Kilombero District Council', 'website': 'https://kilomberodc.go.tz'},
        {'name': 'Ifakara Town Council', 'website': 'https://ifakaratc.go.tz'},
        {'name': 'Ulanga District Council', 'website': 'https://ulangadc.go.tz'},
        {'name': 'Mvomero District Council', 'website': 'https://mvomerodc.go.tz'},
        {'name': 'Gairo District Council', 'website': 'https://gairodc.go.tz'},
        {'name': 'Malinyi District Council', 'website': 'https://malinyidc.go.tz'},
      ],
    },
    {
      'name': 'Mtwara',
      'regionWebsite': 'https://mtwara.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Mtwara Municipal Council', 'website': 'https://mtwaramc.go.tz'},
        {'name': 'Mtwara District Council', 'website': null},
        {'name': 'Masasi Town Council', 'website': 'https://masasitc.go.tz'},
        {'name': 'Masasi District Council', 'website': null},
        {'name': 'Newala District Council', 'website': 'https://newaladc.go.tz'},
        {'name': 'Tandahimba District Council', 'website': 'https://tandahimbadc.go.tz'},
        {'name': 'Nanyumbu District Council', 'website': 'https://nanyumbudc.go.tz'},
      ],
    },
    {
      'name': 'Mwanza',
      'regionWebsite': 'https://mwanza.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Nyamagana Municipal Council', 'website': 'https://nyamaganamc.go.tz'},
        {'name': 'Ilemela Municipal Council', 'website': 'https://ilemelamc.go.tz'},
        {'name': 'Magu District Council', 'website': 'https://magudc.go.tz'},
        {'name': 'Misungwi District Council', 'website': 'https://misungwidc.go.tz'},
        {'name': 'Kwimba District Council', 'website': 'https://kwimbadc.go.tz'},
        {'name': 'Sengerema District Council', 'website': 'https://sengeremadc.go.tz'},
        {'name': 'Ukerewe District Council', 'website': 'https://ukerewedc.go.tz'},
      ],
    },
    {
      'name': 'Njombe',
      'regionWebsite': 'https://njombe.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Njombe Town Council', 'website': 'https://njombetc.go.tz'},
        {'name': 'Njombe District Council', 'website': null},
        {'name': 'Makambako Town Council', 'website': 'https://makambakotc.go.tz'},
        {'name': 'Makete District Council', 'website': 'https://maketedc.go.tz'},
        {'name': 'Ludewa District Council', 'website': 'https://ludewadc.go.tz'},
        {"name": "Wanging'ombe District Council", 'website': 'https://wangingombedc.go.tz'},
      ],
    },
    {
      'name': 'Pwani',
      'regionWebsite': 'https://pwani.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Kibaha Town Council', 'website': 'https://kibahatc.go.tz'},
        {'name': 'Kibaha District Council', 'website': null},
        {'name': 'Bagamoyo District Council', 'website': 'https://bagamoyodc.go.tz'},
        {'name': 'Kisarawe District Council', 'website': 'https://kisaraweadc.go.tz'},
        {'name': 'Mkuranga District Council', 'website': 'https://mkurangadc.go.tz'},
        {'name': 'Rufiji District Council', 'website': 'https://rufijidc.go.tz'},
        {'name': 'Mafia District Council', 'website': 'https://mafiadc.go.tz'},
      ],
    },
    {
      'name': 'Rukwa',
      'regionWebsite': 'https://rukwa.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Sumbawanga Municipal Council', 'website': 'https://sumbawangamc.go.tz'},
        {'name': 'Sumbawanga District Council', 'website': null},
        {'name': 'Nkasi District Council', 'website': 'https://nkasiadc.go.tz'},
        {'name': 'Kalambo District Council', 'website': 'https://kalambodc.go.tz'},
      ],
    },
    {
      'name': 'Ruvuma',
      'regionWebsite': 'https://ruvuma.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Songea Municipal Council', 'website': 'https://songeamc.go.tz'},
        {'name': 'Songea District Council', 'website': null},
        {'name': 'Mbinga District Council', 'website': 'https://mbingadc.go.tz'},
        {'name': 'Tunduru District Council', 'website': 'https://tundurudc.go.tz'},
        {'name': 'Namtumbo District Council', 'website': 'https://namtumbodc.go.tz'},
        {'name': 'Nyasa District Council', 'website': 'https://nyasadc.go.tz'},
      ],
    },
    {
      'name': 'Shinyanga',
      'regionWebsite': 'https://shinyanga.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Shinyanga Municipal Council', 'website': 'https://shinyangamc.go.tz'},
        {'name': 'Shinyanga District Council', 'website': null},
        {'name': 'Kahama Town Council', 'website': 'https://kahatc.go.tz'},
        {'name': 'Kahama District Council', 'website': null},
        {'name': 'Kishapu District Council', 'website': 'https://kishapudc.go.tz'},
      ],
    },
    {
      'name': 'Simiyu',
      'regionWebsite': 'https://simiyu.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Bariadi District Council', 'website': 'https://bariadidc.go.tz'},
        {'name': 'Busega District Council', 'website': 'https://busegadc.go.tz'},
        {'name': 'Itilima District Council', 'website': 'https://itilimadc.go.tz'},
        {'name': 'Maswa District Council', 'website': 'https://maswadc.go.tz'},
        {'name': 'Meatu District Council', 'website': 'https://meatudc.go.tz'},
      ],
    },
    {
      'name': 'Singida',
      'regionWebsite': 'https://singida.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Singida Municipal Council', 'website': 'https://singidamc.go.tz'},
        {'name': 'Singida District Council', 'website': null},
        {'name': 'Iramba District Council', 'website': 'https://irambadc.go.tz'},
        {'name': 'Ikungi District Council', 'website': 'https://ikungidc.go.tz'},
        {'name': 'Manyoni District Council', 'website': 'https://manyonidc.go.tz'},
        {'name': 'Mkalama District Council', 'website': 'https://mkalamadc.go.tz'},
      ],
    },
    {
      'name': 'Songwe',
      'regionWebsite': 'https://songwe.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Mbozi District Council', 'website': 'https://mbozidc.go.tz'},
        {'name': 'Momba District Council', 'website': 'https://mombadc.go.tz'},
        {'name': 'Ileje District Council', 'website': 'https://ilejedc.go.tz'},
        {'name': 'Songwe District Council', 'website': null},
      ],
    },
    {
      'name': 'Tabora',
      'regionWebsite': 'https://tabora.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Tabora Municipal Council', 'website': 'https://taboramc.go.tz'},
        {'name': 'Tabora District Council', 'website': null},
        {'name': 'Igunga District Council', 'website': 'https://igungadc.go.tz'},
        {'name': 'Nzega District Council', 'website': 'https://nzegadc.go.tz'},
        {'name': 'Urambo District Council', 'website': 'https://urambodc.go.tz'},
        {'name': 'Uyui District Council', 'website': 'https://uyuidc.go.tz'},
        {'name': 'Sikonge District Council', 'website': 'https://sikongedc.go.tz'},
        {'name': 'Kaliua District Council', 'website': 'https://kaliuadc.go.tz'},
      ],
    },
    {
      'name': 'Tanga',
      'regionWebsite': 'https://tanga.go.tz',
      'councils': <Map<String, String?>>[
        {'name': 'Tanga City Council', 'website': 'https://tangacc.go.tz'},
        {'name': 'Korogwe Town Council', 'website': 'https://korogwetc.go.tz'},
        {'name': 'Korogwe District Council', 'website': null},
        {'name': 'Handeni Town Council', 'website': 'https://handenitc.go.tz'},
        {'name': 'Handeni District Council', 'website': null},
        {'name': 'Lushoto District Council', 'website': 'https://lushotodc.go.tz'},
        {'name': 'Muheza District Council', 'website': 'https://muhezadc.go.tz'},
        {'name': 'Pangani District Council', 'website': 'https://panganidc.go.tz'},
      ],
    },
  ];

  // totals (for directory card)
  int get totalRegions => regions.length;
  int get totalCouncils => regions.fold(0, (sum, r) => sum + r.councils.length);
  int get totalDistricts => regions.fold(0, (sum, r) => sum + r.districts.length);

  // region filtering (for Regions tab)
  List<RegionSites> get filteredRegions {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return regions;

    return regions
        .map((r) {
      final regionMatch = r.regionName.toLowerCase().contains(q);
      final regionUrlMatch =
          (r.regionWebsite ?? '').toLowerCase().contains(q);
      if (regionMatch || regionUrlMatch) return r;

      final filteredItems = r.items.where((it) {
        final n = it.name.toLowerCase();
        final w = (it.website ?? '').toLowerCase();
        return n.contains(q) || w.contains(q);
      }).toList();

      return RegionSites(
        regionName: r.regionName,
        regionWebsite: r.regionWebsite,
        items: filteredItems,
      );
    })
        .where((r) => r.items.isNotEmpty || r.regionName.toLowerCase().contains(q))
        .toList();
  }

  // global filtering (for Councils tab / Districts tab)
  List<AdminUnitSite> filteredByType(AdminUnitType type) {
    final q = query.value.trim().toLowerCase();

    final all = regions.expand((r) => r.items).where((it) => it.type == type).toList();
    if (q.isEmpty) return all;

    return all.where((it) {
      final n = it.name.toLowerCase();
      final w = (it.website ?? '').toLowerCase();
      return n.contains(q) || w.contains(q);
    }).toList();
  }

  void toggleRegion(String regionName) {
    expandedRegion.value = (expandedRegion.value == regionName) ? null : regionName;
  }

  void toggleDirectoryDetails() {
    showDirectoryDetails.value = !showDirectoryDetails.value;
  }
}
