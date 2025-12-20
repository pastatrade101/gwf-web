class Region {
  final String name;
  final List<Council> councils;

  Region({required this.name, required this.councils});
}

class Council {
  final String name;
  final String website;

  Council({required this.name, required this.website});
}

final List<Region> tanzaniaRegions = [
  Region(
    name: 'Arusha',
    councils: [
      Council(name: 'Arusha City Council', website: 'https://www.arushacc.go.tz/'),
      Council(name: 'Arusha District Council', website: 'https://www.arushadc.go.tz/'),
      Council(name: 'Karatu District Council', website: 'https://www.karatudc.go.tz/'),
      Council(name: 'Longido District Council', website: 'https://www.longidodc.go.tz/'),
      Council(name: 'Meru District Council', website: 'https://www.merudc.go.tz/'),
      Council(name: 'Monduli District Council', website: 'https://www.mondulidc.go.tz/'),
      Council(name: 'Ngorongoro District Council', website: 'https://www.ngorongorodc.go.tz/'),
    ],
  ),
  Region(
    name: 'Dar es Salaam',
    councils: [
      Council(name: 'Ilala Municipal Council', website: 'https://www.ilalamc.go.tz/'),
      Council(name: 'Kinondoni Municipal Council', website: 'https://www.kinondonimc.go.tz/'),
      Council(name: 'Temeke Municipal Council', website: 'https://www.temekemc.go.tz/'),
      Council(name: 'Kigamboni Municipal Council', website: 'https://www.kigambonimc.go.tz/'),
      Council(name: 'Ubungo Municipal Council', website: 'https://www.ubungomc.go.tz/'),
    ],
  ),
  Region(
    name: 'Dodoma',
    councils: [
      Council(name: 'Dodoma City Council', website: 'https://www.dodomacc.go.tz/'),
      Council(name: 'Bahi District Council', website: 'https://www.bahidc.go.tz/'),
      Council(name: 'Chamwino District Council', website: 'https://www.chamwinodc.go.tz/'),
      Council(name: 'Chemba District Council', website: 'https://www.chembadc.go.tz/'),
      Council(name: 'Kondoa District Council', website: 'https://www.kondoavijijini.go.tz/'),
      Council(name: 'Kongwa District Council', website: 'https://www.kongwadc.go.tz/'),
      Council(name: 'Mpwapwa District Council', website: 'https://www.mpwapwadc.go.tz/'),
    ],
  ),
  Region(
    name: 'Geita',
    councils: [
      Council(name: 'Geita Town Council', website: 'https://www.geitatc.go.tz/'),
      Council(name: 'Bukombe District Council', website: 'https://www.bukombedc.go.tz/'),
      Council(name: 'Chato District Council', website: 'https://www.chatodc.go.tz/'),
      Council(name: 'Mbogwe District Council', website: 'https://www.mbogwedc.go.tz/'),
      Council(name: 'Nyang\'hwale District Council', website: 'https://www.nyanghwaledc.go.tz/'),
    ],
  ),
  Region(
    name: 'Iringa',
    councils: [
      Council(name: 'Iringa Municipal Council', website: 'https://www.iringamc.go.tz/'),
      Council(name: 'Iringa District Council', website: 'https://www.iringadc.go.tz/'),
      Council(name: 'Kilolo District Council', website: 'https://www.kilolodc.go.tz/'),
      Council(name: 'Mufindi District Council', website: 'https://www.mufindidc.go.tz/'),
    ],
  ),
  Region(
    name: 'Kagera',
    councils: [
      Council(name: 'Bukoba Municipal Council', website: 'https://www.bukobamc.go.tz/'),
      Council(name: 'Biharamulo District Council', website: 'https://www.biharamulodc.go.tz/'),
      Council(name: 'Bukoba District Council', website: 'https://www.bukobadc.go.tz/'),
      Council(name: 'Karagwe District Council', website: 'https://www.karagwedc.go.tz/'),
      Council(name: 'Kyerwa District Council', website: 'https://www.kyerwadc.go.tz/'),
      Council(name: 'Missenyi District Council', website: 'https://www.missenyidc.go.tz/'),
      Council(name: 'Muleba District Council', website: 'https://www.mulebadc.go.tz/'),
      Council(name: 'Ngara District Council', website: 'https://www.ngaradc.go.tz/'),
    ],
  ),
  Region(
    name: 'Katavi',
    councils: [
      Council(name: 'Mpanda Town Council', website: 'https://www.mpandatc.go.tz/'),
      Council(name: 'Mlele District Council', website: 'https://www.mleledc.go.tz/'),
      Council(name: 'Mpanda District Council', website: 'https://www.mpandadc.go.tz/'),
    ],
  ),
  Region(
    name: 'Kigoma',
    councils: [
      Council(name: 'Kigoma-Ujiji Municipal Council', website: 'https://www.kigomaujijimc.go.tz/'),
      Council(name: 'Buhigwe District Council', website: 'https://www.buhigwedc.go.tz/'),
      Council(name: 'Kakonko District Council', website: 'https://www.kakonkodc.go.tz/'),
      Council(name: 'Kasulu District Council', website: 'https://www.kasuludc.go.tz/'),
      Council(name: 'Kasulu Town Council', website: 'https://www.kasulutc.go.tz/'),
      Council(name: 'Kibondo District Council', website: 'https://www.kibondodc.go.tz/'),
      Council(name: 'Uvinza District Council', website: 'https://www.uvinzadc.go.tz/'),
    ],
  ),
  Region(
    name: 'Kilimanjaro',
    councils: [
      Council(name: 'Moshi Municipal Council', website: 'https://www.moshimc.go.tz/'),
      Council(name: 'Hai District Council', website: 'https://www.haidc.go.tz/'),
      Council(name: 'Moshi District Council', website: 'https://www.moshidc.go.tz/'),
      Council(name: 'Mwanga District Council', website: 'https://www.mwangadc.go.tz/'),
      Council(name: 'Rombo District Council', website: 'https://www.rombodc.go.tz/'),
      Council(name: 'Same District Council', website: 'https://www.samedc.go.tz/'),
      Council(name: 'Siha District Council', website: 'https://www.sihadc.go.tz/'),
    ],
  ),
  Region(
    name: 'Lindi',
    councils: [
      Council(name: 'Lindi Municipal Council', website: 'https://www.lindimc.go.tz/'),
      Council(name: 'Kilwa District Council', website: 'https://www.kilwadc.go.tz/'),
      Council(name: 'Lindi District Council', website: 'https://www.lindidc.go.tz/'),
      Council(name: 'Liwale District Council', website: 'https://www.liwaldc.go.tz/'),
      Council(name: 'Nachingwea District Council', website: 'https://www.nachingweadc.go.tz/'),
      Council(name: 'Ruangwa District Council', website: 'https://www.ruangwadc.go.tz/'),
    ],
  ),
  Region(
    name: 'Manyara',
    councils: [
      Council(name: 'Babati Town Council', website: 'https://www.babatitc.go.tz/'),
      Council(name: 'Babati District Council', website: 'https://www.babatidc.go.tz/'),
      Council(name: 'Hanang District Council', website: 'https://www.hanangdc.go.tz/'),
      Council(name: 'Kiteto District Council', website: 'https://www.kitetodc.go.tz/'),
      Council(name: 'Mbulu District Council', website: 'https://www.mbuludc.go.tz/'),
      Council(name: 'Simanjiro District Council', website: 'https://www.simanjirodc.go.tz/'),
    ],
  ),
  Region(
    name: 'Mara',
    councils: [
      Council(name: 'Musoma Municipal Council', website: 'https://www.musomamc.go.tz/'),
      Council(name: 'Bunda District Council', website: 'https://www.bundadc.go.tz/'),
      Council(name: 'Butiama District Council', website: 'https://www.butiamadc.go.tz/'),
      Council(name: 'Musoma District Council', website: 'https://www.musomadc.go.tz/'),
      Council(name: 'Rorya District Council', website: 'https://www.roryadc.go.tz/'),
      Council(name: 'Serengeti District Council', website: 'https://www.serengetidc.go.tz/'),
      Council(name: 'Tarime District Council', website: 'https://www.tarimedc.go.tz/'),
    ],
  ),
  Region(
    name: 'Mbeya',
    councils: [
      Council(name: 'Mbeya City Council', website: 'https://www.mbeyacc.go.tz/'),
      Council(name: 'Busokelo District Council', website: 'https://www.busokelodc.go.tz/'),
      Council(name: 'Chunya District Council', website: 'https://www.chunyadc.go.tz/'),
      Council(name: 'Kyela District Council', website: 'https://www.kyeladc.go.tz/'),
      Council(name: 'Mbarali District Council', website: 'https://www.mbaralidc.go.tz/'),
      Council(name: 'Rungwe District Council', website: 'https://www.rungwedc.go.tz/'),
    ],
  ),
  Region(
    name: 'Morogoro',
    councils: [
      Council(name: 'Morogoro Municipal Council', website: 'https://www.morogoromc.go.tz/'),
      Council(name: 'Gairo District Council', website: 'https://www.gairodc.go.tz/'),
      Council(name: 'Kilombero District Council', website: 'https://www.kilomberodc.go.tz/'),
      Council(name: 'Kilosa District Council', website: 'https://www.kilosadc.go.tz/'),
      Council(name: 'Malinyi District Council', website: 'https://www.malinyidc.go.tz/'),
      Council(name: 'Morogoro District Council', website: 'https://www.morogorodc.go.tz/'),
      Council(name: 'Mvomero District Council', website: 'https://www.mvomerodc.go.tz/'),
      Council(name: 'Ulanga District Council', website: 'https://www.ulangadc.go.tz/'),
    ],
  ),
  Region(
    name: 'Mtwara',
    councils: [
      Council(name: 'Mtwara Municipal Council', website: 'https://www.mtwaramc.go.tz/'),
      Council(name: 'Masasi District Council', website: 'https://www.masasidc.go.tz/'),
      Council(name: 'Masasi Town Council', website: 'https://www.masasitc.go.tz/'),
      Council(name: 'Mtwara District Council', website: 'https://www.mtwaradc.go.tz/'),
      Council(name: 'Nanyumbu District Council', website: 'https://www.nanyumbudc.go.tz/'),
      Council(name: 'Newala District Council', website: 'https://www.newaladc.go.tz/'),
      Council(name: 'Tandahimba District Council', website: 'https://www.tandahimbadc.go.tz/'),
    ],
  ),
  Region(
    name: 'Mwanza',
    councils: [
      Council(name: 'Ilemela Municipal Council', website: 'https://www.ilemelamc.go.tz/'),
      Council(name: 'Nyamagana Municipal Council', website: 'https://www.nyamaganamc.go.tz/'),
      Council(name: 'Kwimba District Council', website: 'https://www.kwimbadc.go.tz/'),
      Council(name: 'Magu District Council', website: 'https://www.magudc.go.tz/'),
      Council(name: 'Misungwi District Council', website: 'https://www.misungwidc.go.tz/'),
      Council(name: 'Sengerema District Council', website: 'https://www.sengeremadc.go.tz/'),
      Council(name: 'Ukerewe District Council', website: 'https://www.ukerewedc.go.tz/'),
    ],
  ),
  Region(
    name: 'Njombe',
    councils: [
      Council(name: 'Njombe Town Council', website: 'https://www.njombetc.go.tz/'),
      Council(name: 'Ludewa District Council', website: 'https://www.ludewadc.go.tz/'),
      Council(name: 'Makambako Town Council', website: 'https://www.makambakotc.go.tz/'),
      Council(name: 'Makete District Council', website: 'https://www.maketedc.go.tz/'),
      Council(name: 'Njombe District Council', website: 'https://www.njombedc.go.tz/'),
      Council(name: 'Wanging\'ombe District Council', website: 'https://www.wangingombedc.go.tz/'),
    ],
  ),
  Region(
    name: 'Pwani',
    councils: [
      Council(name: 'Kibaha Town Council', website: 'https://www.kibahatc.go.tz/'),
      Council(name: 'Bagamoyo District Council', website: 'https://www.bagamoyodc.go.tz/'),
      Council(name: 'Chalinze District Council', website: 'https://www.chalinzedc.go.tz/'),
      Council(name: 'Kibaha District Council', website: 'https://www.kibahadc.go.tz/'),
      Council(name: 'Kisarawe District Council', website: 'https://www.kisarawedc.go.tz/'),
      Council(name: 'Mafia District Council', website: 'https://www.mafiadc.go.tz/'),
      Council(name: 'Mkuranga District Council', website: 'https://www.mkurangadc.go.tz/'),
      Council(name: 'Rufiji District Council', website: 'https://www.rufijidc.go.tz/'),
    ],
  ),
  Region(
    name: 'Rukwa',
    councils: [
      Council(name: 'Sumbawanga Municipal Council', website: 'https://www.sumbawamc.go.tz/'),
      Council(name: 'Kalambo District Council', website: 'https://www.kalambodc.go.tz/'),
      Council(name: 'Nkasi District Council', website: 'https://www.nkasidc.go.tz/'),
      Council(name: 'Sumbawanga District Council', website: 'https://www.sumbawadc.go.tz/'),
    ],
  ),
  Region(
    name: 'Ruvuma',
    councils: [
      Council(name: 'Songea Municipal Council', website: 'https://www.songeamc.go.tz/'),
      Council(name: 'Mbinga District Council', website: 'https://www.mbingadc.go.tz/'),
      Council(name: 'Mbinga Town Council', website: 'https://www.mbingatc.go.tz/'),
      Council(name: 'Namtumbo District Council', website: 'https://www.namtumbodc.go.tz/'),
      Council(name: 'Nyasa District Council', website: 'https://www.nyasadc.go.tz/'),
      Council(name: 'Songea District Council', website: 'https://www.songeadc.go.tz/'),
      Council(name: 'Tunduru District Council', website: 'https://www.tundurudc.go.tz/'),
    ],
  ),
  Region(
    name: 'Shinyanga',
    councils: [
      Council(name: 'Shinyanga Municipal Council', website: 'https://www.shinyangamc.go.tz/'),
      Council(name: 'Kahama Town Council', website: 'https://www.kahamatc.go.tz/'),
      Council(name: 'Kishapu District Council', website: 'https://www.kishapudc.go.tz/'),
      Council(name: 'Msalala District Council', website: 'https://www.msalaladc.go.tz/'),
      Council(name: 'Shinyanga District Council', website: 'https://www.shinyangadc.go.tz/'),
      Council(name: 'Ushetu District Council', website: 'https://www.ushetudc.go.tz/'),
    ],
  ),
  Region(
    name: 'Simiyu',
    councils: [
      Council(name: 'Bariadi Town Council', website: 'https://www.bariaditc.go.tz/'),
      Council(name: 'Busega District Council', website: 'https://www.busegadc.go.tz/'),
      Council(name: 'Itilima District Council', website: 'https://www.itilimadc.go.tz/'),
      Council(name: 'Maswa District Council', website: 'https://www.maswadc.go.tz/'),
      Council(name: 'Meatu District Council', website: 'https://www.meatudc.go.tz/'),
    ],
  ),
  Region(
    name: 'Singida',
    councils: [
      Council(name: 'Singida Municipal Council', website: 'https://www.singidamc.go.tz/'),
      Council(name: 'Ikungi District Council', website: 'https://www.ikungidc.go.tz/'),
      Council(name: 'Iramba District Council', website: 'https://www.irambadc.go.tz/'),
      Council(name: 'Manyoni District Council', website: 'https://www.manyonidc.go.tz/'),
      Council(name: 'Mkalama District Council', website: 'https://www.mkalamadc.go.tz/'),
      Council(name: 'Singida District Council', website: 'https://www.singidadc.go.tz/'),
    ],
  ),
  Region(
    name: 'Songwe',
    councils: [
      Council(name: 'Vwawa Town Council', website: 'https://www.vwawatc.go.tz/'),
      Council(name: 'Ileje District Council', website: 'https://www.ilejedc.go.tz/'),
      Council(name: 'Mbozi District Council', website: 'https://www.mbozidc.go.tz/'),
      Council(name: 'Momba District Council', website: 'https://www.mombadc.go.tz/'),
      Council(name: 'Tunduma Town Council', website: 'https://www.tundumatc.go.tz/'),
    ],
  ),
  Region(
    name: 'Tabora',
    councils: [
      Council(name: 'Tabora Municipal Council', website: 'https://www.taboramc.go.tz/'),
      Council(name: 'Igunga District Council', website: 'https://www.igungadc.go.tz/'),
      Council(name: 'Kaliua District Council', website: 'https://www.kaliuadc.go.tz/'),
      Council(name: 'Nzega District Council', website: 'https://www.nzegadc.go.tz/'),
      Council(name: 'Sikonge District Council', website: 'https://www.sikongedc.go.tz/'),
      Council(name: 'Urambo District Council', website: 'https://www.urambodc.go.tz/'),
      Council(name: 'Uyui District Council', website: 'https://www.uyuidc.go.tz/'),
    ],
  ),
  Region(
    name: 'Tanga',
    councils: [
      Council(name: 'Tanga City Council', website: 'https://www.tangacc.go.tz/'),
      Council(name: 'Handeni District Council', website: 'https://www.handenidc.go.tz/'),
      Council(name: 'Handeni Town Council', website: 'https://www.handenitc.go.tz/'),
      Council(name: 'Kilindi District Council', website: 'https://www.kilindidc.go.tz/'),
      Council(name: 'Korogwe District Council', website: 'https://www.korogwedc.go.tz/'),
      Council(name: 'Korogwe Town Council', website: 'https://www.korogwetc.go.tz/'),
      Council(name: 'Lushoto District Council', website: 'https://www.lushotodc.go.tz/'),
      Council(name: 'Mkinga District Council', website: 'https://www.mkingadc.go.tz/'),
      Council(name: 'Muheza District Council', website: 'https://www.muhezadc.go.tz/'),
      Council(name: 'Pangani District Council', website: 'https://www.panganidc.go.tz/'),
    ],
  ),
];
