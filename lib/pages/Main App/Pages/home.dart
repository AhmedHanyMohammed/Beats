import 'package:flutter/material.dart';
import 'package:beats/components/styling.dart';
import 'package:beats/components/notifiers.dart';
import 'package:beats/routes/local_storage.dart';
import 'package:beats/components/containers.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _buildConditionSummary(Map<String, dynamic> payload) {
    final conditions = <String>[];
    if (payload['chf'] == true) conditions.add('CHF');
    if (payload['htn'] == true) conditions.add('Hypertension');
    if (payload['dm'] == true) conditions.add('Diabetes');
    if (payload['stroke'] == true) conditions.add('Stroke/TIA');
    if (payload['vascular'] == true) conditions.add('Vascular disease');
    if (conditions.isEmpty) return 'No conditions selected';
    return conditions.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // Greeting from current logged-in user (UI only) centered
            Center(
              child: ValueListenableBuilder<String>(
                valueListenable: userFirstNameNotifier,
                builder: (context, first, _) {
                  return Text('Welcome, DR. $first 👋', style: headingTextStyle, textAlign: TextAlign.center);
                },
              ),
            ),
            const SizedBox(height: 40),
            // Upload or Capture ECG card (standardized card)
            analysisCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload or Capture ECG', style: headingTextStyle),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 233,
                        height: 38,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF117FBC),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            selectedPageNotifier.value = 1; // New Analysis tab
                          },
                          icon: const Icon(Icons.add, color: Colors.white, size: 20),
                          label: Text('New ECG Analysis', style: buttonTextStyle.copyWith(fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Recent Results card (standardized card)
            analysisCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Results', style: headingTextStyle),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<List<SavedAnalysis>>(
                      valueListenable: LocalStorage.instance.analyses,
                      builder: (context, items, _) {
                        if (items.isEmpty) {
                          return Text('No recent analyses yet', style: baseTextStyle);
                        }
                        final latest = items.first;
                        final p = latest.payload;
                        final age = p['patientAge'];
                        final sex = p['patientSex'];
                        final cond = _buildConditionSummary(p);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            recentResultImage(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Age: ${age ?? '-'}', style: baseTextStyle.copyWith(color: Colors.black)),
                                  const SizedBox(height: 4),
                                  Text('Gender: ${sex ?? '-'}', style: baseTextStyle.copyWith(color: Colors.black)),
                                  const SizedBox(height: 4),
                                  Text('Conditions: $cond', style: baseTextStyle.copyWith(color: Colors.black)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
