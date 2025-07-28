import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Development helper utilities for debugging and testing
class DevelopmentHelper {
  static const String _tag = 'DevelopmentHelper';

  /// Check if app is running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Check if app is running in release mode
  static bool get isReleaseMode => kReleaseMode;

  /// Check if app is running in profile mode
  static bool get isProfileMode => kProfileMode;

  /// Check if running on physical device
  static bool get isPhysicalDevice => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Check if running on emulator/simulator
  static bool get isEmulator => !isPhysicalDevice && !kIsWeb;

  /// Check if running on web
  static bool get isWeb => kIsWeb;

  /// Log message with timestamp (debug mode only)
  static void log(String message, {String? tag}) {
    if (isDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log('[$timestamp] ${tag ?? _tag}: $message');
    }
  }

  /// Log error with stack trace (debug mode only)
  static void logError(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (isDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log(
        '[$timestamp] ERROR ${tag ?? _tag}: $message',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log warning (debug mode only)
  static void logWarning(String message, {String? tag}) {
    if (isDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log('[$timestamp] WARNING ${tag ?? _tag}: $message');
    }
  }

  /// Log info (debug mode only)
  static void logInfo(String message, {String? tag}) {
    if (isDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log('[$timestamp] INFO ${tag ?? _tag}: $message');
    }
  }

  /// Print object details in a formatted way (debug mode only)
  static void printObject(Object? obj, {String? label}) {
    if (isDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log('[$timestamp] ${label ?? 'OBJECT'}: ${obj.toString()}');
    }
  }

  /// Print widget tree information (debug mode only)
  static void debugWidgetTree(BuildContext context, {String? label}) {
    if (isDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log('[$timestamp] WIDGET_TREE ${label ?? ''}: ${context.widget.toString()}');
    }
  }

  /// Measure and log execution time of a function (debug mode only)
  static Future<T> measureTime<T>(
    Future<T> Function() function, {
    required String operationName,
  }) async {
    if (!isDebugMode) {
      return await function();
    }

    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      log('Operation "$operationName" completed in ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      logError('Operation "$operationName" failed after ${stopwatch.elapsedMilliseconds}ms', error: e);
      rethrow;
    }
  }

  /// Measure and log execution time of a synchronous function (debug mode only)
  static T measureTimeSync<T>(
    T Function() function, {
    required String operationName,
  }) {
    if (!isDebugMode) {
      return function();
    }

    final stopwatch = Stopwatch()..start();
    try {
      final result = function();
      stopwatch.stop();
      log('Sync operation "$operationName" completed in ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      logError('Sync operation "$operationName" failed after ${stopwatch.elapsedMilliseconds}ms', error: e);
      rethrow;
    }
  }

  /// Show debug banner widget (debug mode only)
  static Widget debugBanner({
    required Widget child,
    String? message,
    Color color = Colors.red,
  }) {
    if (!isDebugMode) {
      return child;
    }

    return Banner(
      message: message ?? 'DEBUG',
      location: BannerLocation.topStart,
      color: color,
      child: child,
    );
  }

  /// Show development overlay with debug info (debug mode only)
  static Widget developmentOverlay({
    required Widget child,
    bool showFPS = false,
    bool showMemory = false,
  }) {
    if (!isDebugMode) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: 50,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DEBUG MODE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Platform: ${Platform.operatingSystem}',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                if (showFPS)
                  Text(
                    'FPS Monitor Active',
                    style: TextStyle(color: Colors.green, fontSize: 10),
                  ),
                if (showMemory)
                  Text(
                    'Memory Monitor Active',
                    style: TextStyle(color: Colors.orange, fontSize: 10),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Conditional execution (debug mode only)
  static T? debugOnly<T>(T Function() function) {
    if (isDebugMode) {
      return function();
    }
    return null;
  }

  /// Conditional execution (release mode only)
  static T? releaseOnly<T>(T Function() function) {
    if (isReleaseMode) {
      return function();
    }
    return null;
  }

  /// Get device information
  static Map<String, dynamic> getDeviceInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'isPhysicalDevice': isPhysicalDevice,
      'isEmulator': isEmulator,
      'isWeb': isWeb,
      'buildMode': isDebugMode ? 'debug' : (isReleaseMode ? 'release' : 'profile'),
    };
  }

  /// Print device information (debug mode only)
  static void printDeviceInfo() {
    if (isDebugMode) {
      final info = getDeviceInfo();
      log('Device Info: $info');
    }
  }

  /// Create a test button for development (debug mode only)
  static Widget? testButton({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    if (!isDebugMode) {
      return null;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.red,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }

  /// Create a development floating action button (debug mode only)
  static Widget? devFloatingActionButton({
    required VoidCallback onPressed,
    IconData icon = Icons.bug_report,
    String tooltip = 'Development Action',
  }) {
    if (!isDebugMode) {
      return null;
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: Colors.orange,
      child: Icon(icon, color: Colors.white),
    );
  }

  /// Assert condition with custom message (debug mode only)
  static void debugAssert(bool condition, String message) {
    if (isDebugMode && !condition) {
      logError('Assertion failed: $message');
      assert(condition, message);
    }
  }

  /// Breakpoint helper (debug mode only)
  static void breakpoint({String? message}) {
    if (isDebugMode) {
      log('BREAKPOINT: ${message ?? 'Debug breakpoint reached'}');
      // This will pause execution in debug mode
      developer.debugger();
    }
  }
} 