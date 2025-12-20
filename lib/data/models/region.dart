import 'package:myapp/data/models/council.dart';

class Region {
  final String name;
  final List<Council> councils;

  Region({required this.name, required this.councils});
}
