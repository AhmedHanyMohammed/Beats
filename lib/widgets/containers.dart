import 'package:flutter/material.dart';
import 'styling.dart';

final Widget beatsLogo = SizedBox(
  width: 185.5,
  height: 70,
  child: Image.asset(
    'assets/icons/Logo.png',
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
