
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.xl),
      child: Row(
        children: [
          Image.asset('assets/tanzania_flag.png', height: AppDimens.iconBoxSm),
          const SizedBox(width: AppDimens.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanzania Regions',
                style: AppTextStyles.appBar.copyWith(color: Colors.white),
              ),
              Text(
                'Explore all 31 regions & councils',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
