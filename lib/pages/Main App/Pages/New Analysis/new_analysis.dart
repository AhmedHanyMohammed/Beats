import 'package:flutter/material.dart';
import 'new_analysis_handler.dart';
import '../../../../components/containers.dart';


class NewAnalysisPage extends StatelessWidget {
  NewAnalysisPage({super.key});

  final NewAnalysisHandler handler = NewAnalysisHandler(); // singleton

  void _showSnack(BuildContext context, String m) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final contentPadding = EdgeInsets.fromLTRB(16, 16, 16, 16 + kBottomNavigationBarHeight + bottomSafe);

    return AnimatedBuilder(
      animation: handler,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: contentPadding,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gender
                maleFemaleSelector(
                  isMale: handler.gender == Gender.male,
                  onSelect: (isMale) => handler.setGender(isMale ? Gender.male : Gender.female),
                ),
                const SizedBox(height: 12),
                // Age
                ageSelectorCard(
                  age: handler.age,
                  onChanged: handler.setAge,
                ),
                const SizedBox(height: 12),
                // Conditions
                conditionsChecklistCard(
                  conditions: handler.conditions,
                  onToggle: (k, v) => handler.toggleCondition(k, v),
                ),
                const SizedBox(height: 12),
                // ECG input
                ecgInputCard(
                  busy: handler.busy,
                  onCapture: () async {
                    await handler.captureECG();
                    if (!context.mounted) return;
                    _showSnack(
                      context,
                      handler.ecgFile != null
                          ? 'ECG captured'
                          : (handler.ecgLabel ?? 'No capture'),
                    );
                  },
                  onSelect: () async {
                    await handler.selectECG();
                    if (!context.mounted) return;
                    _showSnack(
                      context,
                      handler.ecgFile != null
                          ? 'ECG selected'
                          : (handler.ecgLabel ?? 'No selection'),
                    );
                  },
                  label: handler.ecgLabel,
                ),
                const SizedBox(height: 12),
                // Summary + analyze
                analysisSummaryCard(
                  genderLabel: handler.gender == Gender.male ? 'Male' : 'Female',
                  age: handler.age,
                  score: handler.cha2ds2VascScore,
                  selectedConditions: handler.conditions.entries
                      .where((e) => e.value)
                      .map((e) => e.key)
                      .toList(),
                  busy: handler.busy,
                  onAnalyze: () => handler.analyze(context),
                  errorMessage: handler.errorMessage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
