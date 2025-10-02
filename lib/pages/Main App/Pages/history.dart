import 'package:flutter/material.dart';
import 'package:beats/routes/local_storage.dart';
import 'package:beats/components/styling.dart';
import 'New Analysis/analysis.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$y-$m-$d  $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SavedAnalysis>>(
      valueListenable: LocalStorage.instance.analyses,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return const Center(child: Text('No saved analyses yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 327),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AnalysisPage(
                                payload: item.payload,
                                aiModel: item.aiModel,
                                aiRequestId: item.aiRequestId,
                                apixabanRecommendation: item.apixabanRecommendation,
                                justification: item.justification,
                                comprehensiveAnalysis: item.comprehensiveAnalysis,
                                interpretationSummary: item.interpretationSummary,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    linkTextStyleBuilder('Atrial fibrillation detected'),
                                    const SizedBox(height: 2),
                                    // Date/time text
                                    Text(
                                      _formatDate(item.createdAt),
                                      style: baseTextStyle.copyWith(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 18, color: primaryColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
