import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../components/containers.dart';
import 'package:beats/components/styling.dart';
import 'package:beats/components/notifiers.dart';

class AnalysisPage extends StatelessWidget {
  final Map<String, dynamic> payload;
  final String? aiText;
  final String? aiModel;
  final String? aiRequestId;
  // Structured fields
  final String? apixabanRecommendation; // 'yes' | 'no'
  final String? justification;
  final List<String>? comprehensiveAnalysis;
  final String? interpretationSummary;

  const AnalysisPage({
    super.key,
    required this.payload,
    this.aiText,
    this.aiModel,
    this.aiRequestId,
    this.apixabanRecommendation,
    this.justification,
    this.comprehensiveAnalysis,
    this.interpretationSummary,
  });

  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(payload);
    final theme = Theme.of(context);

    Widget buildAiResultCard() {
      final rec = (apixabanRecommendation ?? '').toLowerCase();
      Color chipColor;
      String chipLabel;
      if (rec == 'yes') {
        chipColor = Colors.green.shade600;
        chipLabel = 'Apixaban: Yes';
      } else if (rec == 'no') {
        chipColor = Colors.red.shade600;
        chipLabel = 'Apixaban: No';
      } else {
        chipColor = Colors.grey;
        chipLabel = 'Apixaban: Unknown';
      }

      return analysisCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Analysis', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              children: [
                Chip(
                  label: Text(chipLabel, style: const TextStyle(color: Colors.white)),
                  backgroundColor: chipColor,
                ),
              ],
            ),
            if ((justification ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Justification', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(justification!),
            ],
            if ((comprehensiveAnalysis ?? const []).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Comprehensive Analysis', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in comprehensiveAnalysis!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            if ((interpretationSummary ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Interpretation Summary', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(interpretationSummary!),
            ],
            const SizedBox(height: 8),
            if (aiModel != null || aiRequestId != null)
              Text(
                [
                  if (aiModel != null) 'Model: $aiModel',
                  if (aiRequestId != null) 'Request: $aiRequestId',
                ].join('  •  '),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            if ((apixabanRecommendation ?? justification ?? interpretationSummary) == null && (comprehensiveAnalysis == null || comprehensiveAnalysis!.isEmpty))
              Text(
                'No AI result available. Please verify your API key and connection.',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'ECG Apixaban Advisor',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Structured AI result
            buildAiResultCard(),
            const SizedBox(height: 24),
            // Optional legacy AI text (collapsed into card if you wish)
            if ((aiText ?? '').isNotEmpty) ...[
              analysisCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Raw AI Text', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(aiText!, style: const TextStyle(height: 1.35)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            analysisCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Payload', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(pretty, style: const TextStyle(fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Pop first, then switch tab on the next frame to avoid context ancestry issues
              Navigator.of(context).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                selectedPageNotifier.value = 0; // Home index in Navbar
              });
            },
            child: const Text('Done'),
          ),
        ),
      ),
    );
  }
}
