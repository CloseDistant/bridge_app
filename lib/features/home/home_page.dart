import 'package:flutter/material.dart';

import '../../theme/tokens/app_space.dart';
import '../../ui/adaptive/adaptive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Bridge App',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Adaptive UI Skeleton',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpace.space16),
              AdaptiveButton(
                label: 'Show Dialog',
                onPressed: () async {
                  final ok = await AdaptiveDialog.showConfirm(
                    context,
                    title: 'Confirm',
                    message: 'This dialog adapts per platform.',
                  );

                  if (!context.mounted) return;

                  final text = ok == true ? 'Confirmed' : 'Cancelled';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(text)));
                },
              ),
              const SizedBox(height: AppSpace.space12),
              AdaptiveButton(
                label: 'Show Bottom Sheet',
                variant: AdaptiveButtonVariant.tonal,
                onPressed: () async {
                  final result = await AdaptiveBottomSheet.showActions<String>(
                    context,
                    title: 'Actions',
                    message: 'This sheet adapts per platform.',
                    actions: const <AdaptiveSheetAction<String>>[
                      AdaptiveSheetAction(label: 'Edit', value: 'edit'),
                      AdaptiveSheetAction(
                        label: 'Delete',
                        value: 'delete',
                        isDestructive: true,
                      ),
                    ],
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Action: ${result ?? "none"}')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
