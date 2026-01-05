
import 'package:flutter/material.dart';
import 'package:myapp/data/models/council.dart';
import 'package:myapp/services/url_launcher_service.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

class CouncilTile extends StatelessWidget {
  final Council council;

  const CouncilTile({super.key, required this.council});

  @override
  Widget build(BuildContext context) {
    final UrlLauncherService urlLauncherService = UrlLauncherService();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final card = theme.cardColor;
    final border = theme.dividerColor;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.xl, vertical: AppDimens.xsTight),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: border),
      ),
      child: ListTile(
        leading: Icon(Icons.account_balance, color: Theme.of(context).primaryColor),
        title: Text(
          council.name,
          style: AppTextStyles.body,
        ),
        trailing: IconButton(
          icon: Icon(Icons.open_in_new, color: muted),
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
