import 'package:flutter/material.dart';
import 'analysis.dart';
import '../../../components/styling.dart';

enum Gender { male, female }

class NewAnalysisPage extends StatefulWidget {
  const NewAnalysisPage({super.key});

  @override
  State<NewAnalysisPage> createState() => _NewAnalysisPageState();
}

class _NewAnalysisPageState extends State<NewAnalysisPage> {
  Gender _gender = Gender.male;
  int _age = 60;

  final Map<String, bool> _conditions = {
    'Congestive heart failure': false,
    'Hypertension': false,
    'Diabetes mellitus': false,
    'Stroke/TIA/thromboembolism': false,
    'Vascular disease': false,
  };

  String? _ecgSourceLabel; // e.g., "Captured" or "Selected: file.ext"

  void _captureECG() {
    // TODO: Integrate camera capture (e.g., image_picker with Source.camera)
    setState(() {
      _ecgSourceLabel = 'Captured (stub)';
    });
    _showSnackBar('Camera capture not implemented. Stub set.');
  }

  void _selectECG() {
    // TODO: Integrate file picker (e.g., file_picker to select ECG/PDF/image)
    setState(() {
      _ecgSourceLabel = 'Selected file (stub)';
    });
    _showSnackBar('File picker not implemented. Stub set.');
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static const maleColor = Color(0xFF6BD9E7);
  static const femaleColor = Color(0xFFCF9BFB);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final contentPadding = EdgeInsets.fromLTRB(16, 16, 16, 16 + kBottomNavigationBarHeight + bottomSafe);
    // Reuse navbar background color for cards
    final navBarColor = NavigationBarTheme.of(context).backgroundColor
        ?? theme.bottomNavigationBarTheme.backgroundColor
        ?? theme.colorScheme.surface;

    // Content-only: no Scaffold/AppBar here. WidgetTree provides them.
    return SingleChildScrollView(
      padding: contentPadding, // keeps content above the sticky navbar
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gender card (height: 57)
            SizedBox(
              width: 336,
              height: 57,
              child: Card(
                margin: EdgeInsets.zero,
                color: navBarColor, // navbar-matching
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Male option
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _gender = Gender.male),
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(Icons.male, color: maleColor),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Male'),
                              const Spacer(),
                              Radio<Gender>(
                                value: Gender.male,
                                groupValue: _gender,
                                onChanged: (v) => setState(() => _gender = v!),
                                activeColor: primaryColor, // primary on select
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Female option
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _gender = Gender.female),
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            children: [
                              // enlarged to 24x24, keep fixed purple color
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(Icons.female, color: femaleColor),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Female'),
                              const Spacer(),
                              Radio<Gender>(
                                value: Gender.female,
                                groupValue: _gender,
                                onChanged: (v) => setState(() => _gender = v!),
                                activeColor: primaryColor, // primary on select
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Age card (height: 187) — imitates the reference
            SizedBox(
              width: 336,
              height: 187,
              child: Card(
                margin: EdgeInsets.zero,
                color: navBarColor, // navbar-matching
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Age', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      // Current age badge-like display
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('$_age years', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Slider with divisions 60..89
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          activeTrackColor: primaryColor,
                          inactiveTrackColor: primaryColor.withOpacity(0.25),
                          thumbColor: primaryColor,
                          overlayColor: primaryColor.withOpacity(0.15),
                          // Hide tick marks (the "dots")
                          activeTickMarkColor: Colors.transparent,
                          inactiveTickMarkColor: Colors.transparent,
                          valueIndicatorColor: primaryColor,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                          valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                        ),
                        child: Slider(
                          value: _age.toDouble(),
                          min: 60,
                          max: 89,
                          divisions: 29,
                          label: '$_age',
                          onChanged: (v) => setState(() => _age = v.round()),
                        ),
                      ),
                      // Min / Max labels
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('60', style: TextStyle(fontSize: 12)),
                          Text('89', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Comorbidities card (height: 316)
            SizedBox(
              width: 336,
              height: 316,
              child: Card(
                margin: EdgeInsets.zero,
                color: navBarColor, // navbar-matching
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Does the patient have a history of the following:',
                          style: buttonTextStyle.copyWith(fontSize: 16, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: _conditions.keys.map((key) {
                            return CheckboxListTile(
                              title: Text(key),
                              value: _conditions[key],
                              onChanged: (v) => setState(() => _conditions[key] = v ?? false),
                              activeColor: primaryColor, // primary on select
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                              dense: true,
                              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ECG input card (width 336)
            SizedBox(
              width: 336,
              child: Card(
                margin: EdgeInsets.zero,
                color: navBarColor, // navbar-matching
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('ECG Input', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _captureECG,
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Capture'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: primaryColor),
                                foregroundColor: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectECG,
                              icon: const Icon(Icons.attach_file_outlined),
                              label: const Text('Select'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: primaryColor),
                                foregroundColor: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_ecgSourceLabel != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Selected: $_ecgSourceLabel',
                          style: theme.textTheme.bodySmall?.copyWith(color: primaryColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Analyze button card (width 336)
            SizedBox(
              width: 336,
              child: Card(
                margin: EdgeInsets.zero,
                color: navBarColor, // navbar-matching
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AnalysisPage()),
                        );
                      },
                      child: const Text('Analyze ECG'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
