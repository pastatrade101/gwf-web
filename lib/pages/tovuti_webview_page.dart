import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';

class TovutiWebViewPage extends StatefulWidget {
  const TovutiWebViewPage({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<TovutiWebViewPage> createState() => _TovutiWebViewPageState();
}

class _TovutiWebViewPageState extends State<TovutiWebViewPage> {
  late final WebViewController _controller;
  var _progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(widget.title, style: AppTextStyles.appBar, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.text),
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(AppDimens.progressHeight),
          child: _progress < 100
              ? LinearProgressIndicator(
                  value: _progress / 100.0,
                  minHeight: AppDimens.progressHeight,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                )
              : const SizedBox(height: AppDimens.progressHeight),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
