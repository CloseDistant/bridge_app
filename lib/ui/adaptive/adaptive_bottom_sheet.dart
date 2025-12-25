import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_style.dart';

class AdaptiveSheetAction<T> {
  const AdaptiveSheetAction({
    required this.label,
    this.value,
    this.isDefault = false,
    this.isDestructive = false,
  });

  final String label;
  final T? value;
  final bool isDefault;
  final bool isDestructive;
}

class AdaptiveBottomSheet {
  const AdaptiveBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useSafeArea = true,
  }) {
    if (PlatformStyle.isCupertino(context)) {
      return showCupertinoModalPopup<T>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (context) {
          return SafeArea(
            top: false,
            child: CupertinoPopupSurface(child: builder(context)),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      showDragHandle: true,
      builder: builder,
    );
  }

  static Future<T?> showActions<T>(
    BuildContext context, {
    String? title,
    String? message,
    required List<AdaptiveSheetAction<T>> actions,
    String cancelText = '取消',
  }) {
    if (PlatformStyle.isCupertino(context)) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: title == null ? null : Text(title),
            message: message == null ? null : Text(message),
            actions: actions
                .map(
                  (a) => CupertinoActionSheetAction(
                    isDefaultAction: a.isDefault,
                    isDestructiveAction: a.isDestructive,
                    onPressed: () => Navigator.of(context).pop(a.value),
                    child: Text(a.label),
                  ),
                )
                .toList(growable: false),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(cancelText),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (title != null || message != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: <Widget>[
                      if (title != null)
                        Text(title, style: theme.textTheme.titleMedium),
                      if (message != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: actions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final a = actions[index];
                    final color = a.isDestructive
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface;

                    return ListTile(
                      title: Text(a.label, style: TextStyle(color: color)),
                      onTap: () => Navigator.of(context).pop(a.value),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
