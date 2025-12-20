
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/data/models/council.dart';
import 'package:myapp/services/url_launcher_service.dart';

class CouncilTile extends StatelessWidget {
  final Council council;

  const CouncilTile({super.key, required this.council});

  @override
  Widget build(BuildContext context) {
    final UrlLauncherService urlLauncherService = UrlLauncherService();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(Icons.account_balance, color: Theme.of(context).primaryColor),
        title: Text(
          council.name,
          style: GoogleFonts.nunito(),
        ),
        trailing: IconButton(
          icon: Icon(Icons.open_in_new, color: Colors.grey.shade500),
          onPressed: () async {
            try {
              await urlLauncherService.launchURL(council.website);
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString())),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
