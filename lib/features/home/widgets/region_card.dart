
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/data/models/region.dart';
import 'package:myapp/features/home/widgets/council_tile.dart';

class RegionCard extends StatelessWidget {
  final Region region;

  const RegionCard({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            region.name[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          region.name,
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${region.councils.length} councils',
          style: GoogleFonts.nunito(color: Colors.grey.shade600),
        ),
        children: region.councils
            .map((council) => CouncilTile(council: council))
            .toList(),
      ),
    );
  }
}
