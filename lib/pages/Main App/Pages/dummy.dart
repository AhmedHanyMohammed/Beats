import 'package:beats/routes/local_storage.dart';

class DummyData {
  DummyData._();

  static void seedInMemory() {
    final ls = LocalStorage.instance;
    final current = ls.analyses.value;
    if (current.isNotEmpty) return; // Respect existing data

    final now = DateTime.now();

    final d1 = SavedAnalysis(
      id: '${now.subtract(const Duration(minutes: 45)).microsecondsSinceEpoch}',
      createdAt: now.subtract(const Duration(minutes: 45)),
      payload: {
        'patientAge': 72,
        'patientSex': 'Male',
        'chf': true,
        'htn': true,
        'dm': false,
        'stroke': false,
        'vascular': true,
        'cha2ds2VascScore': 4,
      },
      apixabanRecommendation: 'yes',
      justification: 'Elevated CHA2DS2-VASc; stroke risk reduction is prioritized.',
      comprehensiveAnalysis: const [
        'Irregularly irregular pattern suggesting AF',
        'Hypertension and vascular disease add risk',
      ],
      interpretationSummary: 'AF likely with risk factors; anticoagulation favored.',
      aiModel: 'ui-demo',
      aiRequestId: 'ui-demo-1',
    );

    final d2 = SavedAnalysis(
      id: '${now.subtract(const Duration(days: 1, hours: 1)).microsecondsSinceEpoch}',
      createdAt: now.subtract(const Duration(days: 1, hours: 1)),
      payload: {
        'patientAge': 65,
        'patientSex': 'Female',
        'chf': false,
        'htn': true,
        'dm': true,
        'stroke': false,
        'vascular': false,
        'cha2ds2VascScore': 3,
      },
      apixabanRecommendation: 'no',
      justification: 'Borderline profile; consider lifestyle and diagnostics first.',
      comprehensiveAnalysis: const [
        'Regular rhythm on preview',
        'Hypertension and diabetes present',
      ],
      interpretationSummary: 'Conservative follow-up reasonable.',
      aiModel: 'ui-demo',
      aiRequestId: 'ui-demo-2',
    );

    // Assign without persisting: only for UI preview
    ls.analyses.value = [d1, d2];
  }
}

