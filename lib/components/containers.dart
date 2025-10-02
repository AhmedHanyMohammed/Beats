import 'package:flutter/material.dart';
import 'styling.dart';

final Widget beatsLogo = SizedBox(
  width: 185.5,
  height: 70,
  child: Image.asset(
    'assets/images/Logo.png',
    fit: BoxFit.contain,
  ),
);


Widget buildLabeledInput({
  required String label,
  required String hint,
  required TextEditingController controller,
  bool isPassword = false,
  bool obscure = false,
  VoidCallback? onToggle,
  TextInputType? keyboardType,
}) {
  final type = keyboardType ?? (isPassword ? TextInputType.visiblePassword : TextInputType.text);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      SizedBox(
        height: 48,
        child: TextField(
          controller: controller,
          keyboardType: type,
          obscureText: isPassword ? obscure : false,
          style: baseTextStyle,
          decoration: InputDecoration(
            border: buildInputBorder15(),
            enabledBorder: buildInputBorder15(),
            focusedBorder: buildInputBorder15(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            hintText: hint,
            hintStyle: isPassword
                ? baseTextStyle.copyWith(color: secondaryColorMuted, fontSize: 30)
                : baseTextStyle.copyWith(color: secondaryColorMuted),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: primaryColor),
                    onPressed: onToggle ?? () {},
                  )
                : null,
          ),
        ),
      ),
    ],
  );
}


Widget buildForgotPasswordLink({required VoidCallback onTap}) {
  return Align(
    alignment: Alignment.centerRight,
    child: GestureDetector(
      onTap: onTap,
      child: linkTextStyleBuilder('Forgot password?'),
    ),
  );
}


Widget proceedButton({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
  bool showSuccess = false,
}) {
  return SizedBox(
    width: 327,
    height: 48,
    child: FilledButton(
      onPressed: (isLoading || showSuccess) ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: primaryColor,
        disabledBackgroundColor: primaryColor.withAlpha(128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : showSuccess
              ? const Icon(Icons.check, color: Colors.white)
              : Text(text, style: buttonTextStyle),
    ),
  );
}


Widget secondOptionText({
  required String prompt,
  required String actionText,
  required VoidCallback onTap,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(prompt, style: baseTextStyle.copyWith(fontSize: 14, color: secondaryColor)),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: onTap,
        child: linkTextStyleBuilder(actionText),
      ),
    ],
  );
}

Widget navBackButton(BuildContext context, {Widget? fallback}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else if (fallback != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => fallback),
          );
        }
      },
    ),
  );
}

// Generic analysis card wrapper (standardized to match History style)
Widget analysisCard({
  required Widget child,
  double? width,
  double? height,
  EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  Color? color,
  double radius = 15,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
}) {
  return SizedBox(
    width: width ?? double.infinity,
    height: height,
    child: Card(
      margin: margin,
      color: color ?? Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Padding(padding: padding, child: child),
    ),
  );
}

// Reusable image for Recent Results with fallback
Widget recentResultImage({double width = 110, double height = 80, BoxFit fit = BoxFit.cover}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.asset(
      'assets/images/Recent_Result.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stack) {
        // Fallback to logo if the image can't be loaded
        return Container(
          width: width,
          height: height,
          color: Colors.white,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/Logo.png',
            width: width * 0.6,
            height: height * 0.6,
            fit: BoxFit.contain,
          ),
        );
      },
    ),
  );
}

// Male/Female selector (stateless, no enum dependency)
Widget maleFemaleSelector({
  required bool isMale,
  required void Function(bool isMale) onSelect,
  Color? cardColor,
}) {
  return analysisCard(
    // ...existing code...
    color: cardColor,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onSelect(true),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(Icons.male, color: Color(0xFF6BD9E7)),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Male'),
                const Spacer(),
                Radio<bool>(
                  value: true,
                  groupValue: isMale,
                  onChanged: (v) => onSelect(true),
                  activeColor: primaryColor,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () => onSelect(false),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(Icons.female, color: Color(0xFFCF9BFB)),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Female'),
                const Spacer(),
                Radio<bool>(
                  value: false,
                  groupValue: isMale,
                  onChanged: (v) => onSelect(false),
                  activeColor: primaryColor,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Age selector card
Widget ageSelectorCard({
  required int age,
  required ValueChanged<int> onChanged,
  int min = 60,
  int max = 89,
  Color? cardColor,
}) {
  final divisions = (max - min);
  return analysisCard(
    // ...existing code...
    color: cardColor,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    child: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final primary08 = primaryColor.withValues(alpha: 0.08);
        final primary25 = primaryColor.withValues(alpha: 0.25);
        final primary15 = primaryColor.withValues(alpha: 0.15);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
          children: [
            Text('Age', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(color: primary08, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text('$age years', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: primaryColor,
                  inactiveTrackColor: primary25,
                  thumbColor: primaryColor,
                  overlayColor: primary15,
                  activeTickMarkColor: Colors.transparent,
                  inactiveTickMarkColor: Colors.transparent,
                  valueIndicatorColor: primaryColor,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                  showValueIndicator: ShowValueIndicator.never,
                ),
                child: Slider(
                  value: age.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: divisions,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$min', style: const TextStyle(fontSize: 12)),
                Text('$max', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        );
      },
    ),
  );
}

// Conditions checklist
Widget conditionsChecklistCard({
  required Map<String, bool> conditions,
  required void Function(String key, bool value) onToggle,
  Color? cardColor,
  double height = 240,
}) {
  return analysisCard(
    // ...existing code...
    height: height,
    color: cardColor,
    padding: const EdgeInsets.all(8),
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
            children: [
              for (final key in conditions.keys)
                CheckboxListTile(
                  key: ValueKey('cond_$key'),
                  title: Text(key),
                  value: conditions[key],
                  onChanged: (v) => onToggle(key, v ?? false),
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                  dense: true,
                  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ECG input card
Widget ecgInputCard({
  required bool busy,
  required VoidCallback onCapture,
  required VoidCallback onSelect,
  String? label,
  Color? cardColor,
}) {
  return analysisCard(
    // ...existing code...
    color: cardColor,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ECG Input', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: busy ? null : onCapture,
              child: SizedBox(
                width: double.infinity,
                height: 169,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/Capture ECG.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Or,',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: busy ? null : onSelect,
              child: SizedBox(
                width: double.infinity,
                height: 169,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/Select ECG File.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: 12),
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: primaryColor)),
            ],
          ],
        );
      },
    ),
  );
}

// Summary + analyze button
Widget analysisSummaryCard({
  required String genderLabel,
  required int age,
  required int score,
  required List<String> selectedConditions,
  required bool busy,
  required VoidCallback onAnalyze,
  String? errorMessage,
  Color? cardColor,
}) {
  return analysisCard(
    // ...existing code...
    color: cardColor,
    padding: const EdgeInsets.all(12),
    child: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(genderLabel)),
                Chip(label: Text('Age: $age')),
                Chip(label: Text('Score: $score')),
                for (final c in selectedConditions)
                  Chip(label: Text(c.split(' ').first)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: busy ? null : onAnalyze,
                icon: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(busy ? 'Processing...' : 'Analyze'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: theme.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        );
      },
    ),
  );
}
