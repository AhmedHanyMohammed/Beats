// filepath: c:\Users\ahmed\OneDrive\Desktop\GIU\flutter code files\Beats\lib\routes\message_handler.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized user-friendly message utilities.
/// Use MessageHandler.friendly(error) to turn raw errors into human-friendly text,
/// and showErrorSnackbar/showErrorDialog to present them consistently.
class MessageHandler {
  MessageHandler._();

  // Maps any error to a short, user-friendly message (no codes unless essential).
  static String friendly(Object error) {
    final raw = error.toString();

    // Network/timeouts
    if (error is TimeoutException) {
      return 'The request took too long. Please try again.';
    }
    if (error is SocketException) {
      return "Couldn't connect to the server. Check your internet connection and try again.";
    }

    // HttpException or text with status hints
    if (error is HttpException) {
      return _fromHttpMessage(error.message);
    }
    // Common AI configuration/auth messages
    final low = raw.toLowerCase();
    if (low.contains('ai_api_key is not set') || low.contains('incorrect api key')) {
      return "AI service isn't configured correctly on this device. Please set a valid AI key or contact support.";
    }
    if (low.contains('ai request timed out')) {
      return "The AI service didn't respond in time. Please try again.";
    }
    if (low.contains('network error calling ai')) {
      return "We couldn't reach the AI service. Please check your connection and try again.";
    }

    // Server error pattern thrown by ApiRoutes._throwIfError
    if (low.startsWith('exception: server error') || low.startsWith('server error')) {
      return _fromHttpMessage(raw);
    }

    // Fallback: trim technical clutter, keep it polite
    return _clean(raw);
  }

  static String _fromHttpMessage(String message) {
    final low = message.toLowerCase();
    // Try to find a status code if present
    int? code;
    final match = RegExp(r'(\b|:|\s)(\d{3})(\b)').firstMatch(low);
    if (match != null) {
      code = int.tryParse(match.group(2) ?? '');
    }

    if (code != null) {
      switch (code) {
        case 400:
        case 422:
          return "Some details don't look right. Please review your input and try again.";
        case 401:
          if (low.contains('ai')) {
            return 'AI service key is invalid or missing. Please update the key or contact support.';
          }
          return "You're not signed in or your session expired. Please sign in and try again.";
        case 403:
          return "You don't have permission to do that.";
        case 404:
          return "We couldn't find what you're looking for.";
        case 409:
          return 'This conflicts with something that already exists.';
        case 429:
          return 'Too many attempts right now. Please wait a moment and try again.';
        default:
          if (code >= 500 && code <= 599) {
            return 'The server had a problem. Please try again later.';
          }
      }
    }

    // No code detected — provide a general friendly line, possibly using hints.
    if (low.contains('timeout')) {
      return 'The request took too long. Please try again.';
    }
    if (low.contains('unauthorized') || low.contains('forbidden')) {
      return "You don't have permission to do that.";
    }

    return _clean(message);
  }

  static String _clean(String s) {
    // Remove common noisy prefixes
    var out = s;
    for (final p in const [
      'Exception: ',
      'HttpException: ',
      'FormatException: ',
      'SocketException: ',
    ]) {
      if (out.startsWith(p)) out = out.substring(p.length);
    }
    // Truncate super long bodies, keep first ~220 chars
    if (out.length > 220) out = out.substring(0, 220).trimRight() + '…';
    // If still too technical, use a generic fallback
    final low = out.toLowerCase();
    if (low.contains('stack trace') || low.contains('errno') || low.contains('code')) {
      return 'Something went wrong. Please try again.';
    }
    return out.isNotEmpty ? out : 'Something went wrong. Please try again.';
  }

  static void showErrorSnackbar(BuildContext context, Object error, {String? fallback}) {
    if (!context.mounted) return;
    final text = friendly(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text.isNotEmpty ? text : (fallback ?? 'Something went wrong. Please try again.'))),
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context, {
    String title = 'Oops',
    required Object error,
    String? fallback,
  }) async {
    if (!context.mounted) return;
    final text = friendly(error);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(text.isNotEmpty ? text : (fallback ?? 'Something went wrong. Please try again.')),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  /// Optionally log developer details without exposing to users.
  static void devLog(Object error, [StackTrace? st]) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (st != null) debugPrint(st.toString());
    }
  }
}
