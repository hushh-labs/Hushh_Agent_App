import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardUtils {
  /// Dismisses the keyboard by unfocusing the current focus node
  static void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Prevents keyboard event errors by wrapping text field operations
  static void safeTextFieldOperation(VoidCallback operation) {
    try {
      operation();
    } catch (e) {
      // Silently ignore keyboard-related errors
      if (!e.toString().contains('KeyUpEvent') && 
          !e.toString().contains('KeyDownEvent') &&
          !e.toString().contains('HardwareKeyboard')) {
        rethrow;
      }
    }
  }

  /// Safely dispose of focus nodes to prevent keyboard event issues
  static void safeFocusNodeDispose(FocusNode? focusNode) {
    try {
      focusNode?.dispose();
    } catch (e) {
      // Silently ignore disposal errors
    }
  }

  /// Creates a safer text input configuration
  static InputDecoration getSafeInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsets? contentPadding,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );
  }
} 