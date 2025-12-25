import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_style.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isCupertino(context)) {
      final materialTheme = Theme.of(context);

      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: materialTheme.brightness,
          primaryColor: materialTheme.colorScheme.primary,
          barBackgroundColor: materialTheme.colorScheme.surface,
          scaffoldBackgroundColor: materialTheme.colorScheme.surface,
          textTheme: CupertinoTextThemeData(
            textStyle: materialTheme.textTheme.bodyMedium,
            navTitleTextStyle: materialTheme.textTheme.titleMedium,
          ),
        ),
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(title),
            trailing: actions == null || actions!.isEmpty
                ? null
                : Row(mainAxisSize: MainAxisSize.min, children: actions!),
          ),
          child: SafeArea(child: body),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
