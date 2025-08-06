import 'package:flutter/material.dart';
import 'dart:io';

/// Utility class for screen-related operations and responsive design
class ScreenUtils {
  static late MediaQueryData _mediaQueryData;
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _devicePixelRatio;

  /// Initialize screen utils with context
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    _devicePixelRatio = _mediaQueryData.devicePixelRatio;
  }

  /// Get screen width
  static double get screenWidth => _screenWidth;

  /// Get screen height
  static double get screenHeight => _screenHeight;

  /// Get screen size
  static Size get screenSize => Size(_screenWidth, _screenHeight);

  /// Get device pixel ratio
  static double get devicePixelRatio => _devicePixelRatio;

  /// Check if device is in landscape mode
  static bool get isLandscape => _screenWidth > _screenHeight;

  /// Check if device is in portrait mode
  static bool get isPortrait => _screenHeight > _screenWidth;

  /// Get status bar height
  static double get statusBarHeight => _mediaQueryData.padding.top;

  /// Get bottom padding (safe area)
  static double get bottomPadding => _mediaQueryData.padding.bottom;

  /// Get percentage of screen height
  static double heightPercent(double percent) => _screenHeight * (percent / 100);

  /// Get percentage of screen width
  static double widthPercent(double percent) => _screenWidth * (percent / 100);

  /// Check if device is tablet
  static bool get isTablet {
    final double shortestSide = _screenWidth < _screenHeight ? _screenWidth : _screenHeight;
    return shortestSide > 600;
  }

  /// Check if device is mobile
  static bool get isMobile => !isTablet;

  /// Get responsive font size
  static double responsiveFontSize(double fontSize) {
    final double scaleFactor = _screenWidth / 375; // Base width: iPhone 6/7/8
    return fontSize * scaleFactor;
  }

  /// Get responsive width based on design width
  static double responsiveWidth(double width, {double designWidth = 375}) {
    return (_screenWidth / designWidth) * width;
  }

  /// Get responsive height based on design height
  static double responsiveHeight(double height, {double designHeight = 812}) {
    return (_screenHeight / designHeight) * height;
  }

  /// Get safe area height (excluding status bar and bottom padding)
  static double get safeAreaHeight => _screenHeight - statusBarHeight - bottomPadding;

  /// Get safe area width
  static double get safeAreaWidth => _screenWidth - _mediaQueryData.padding.left - _mediaQueryData.padding.right;

  /// Check if device has notch
  static bool get hasNotch => statusBarHeight > 24;

  /// Get text scale factor
  static double get textScaleFactor => _mediaQueryData.textScaleFactor;

  /// Check if device is iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if device is Android
  static bool get isAndroid => Platform.isAndroid;
}

/// Extension on BuildContext for easy access to screen utilities
extension ScreenUtilsExtension on BuildContext {
  /// Get screen height
  double get screenHeight {
    return MediaQuery.of(this).size.height;
  }

  /// Get screen width
  double get screenWidth {
    return MediaQuery.of(this).size.width;
  }

  /// Get screen size
  Size get screenSize {
    return MediaQuery.of(this).size;
  }

  /// Check if device is in landscape mode
  bool get isLandscape {
    return MediaQuery.of(this).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  bool get isPortrait {
    return MediaQuery.of(this).orientation == Orientation.portrait;
  }

  /// Get status bar height
  double get statusBarHeight {
    return MediaQuery.of(this).padding.top;
  }

  /// Get bottom padding (safe area)
  double get bottomPadding {
    return MediaQuery.of(this).padding.bottom;
  }

  /// Check if device is tablet
  bool get isTablet {
    final double shortestSide = screenWidth < screenHeight ? screenWidth : screenHeight;
    return shortestSide > 600;
  }

  /// Check if device is mobile
  bool get isMobile => !isTablet;

  /// Get percentage of screen height
  double heightPercent(double percent) => screenHeight * (percent / 100);

  /// Get percentage of screen width
  double widthPercent(double percent) => screenWidth * (percent / 100);

  /// Get responsive font size
  double responsiveFontSize(double fontSize) {
    final double scaleFactor = screenWidth / 375; // Base width: iPhone 6/7/8
    return fontSize * scaleFactor;
  }

  /// Get responsive width based on design width
  double responsiveWidth(double width, {double designWidth = 375}) {
    return (screenWidth / designWidth) * width;
  }

  /// Get responsive height based on design height
  double responsiveHeight(double height, {double designHeight = 812}) {
    return (screenHeight / designHeight) * height;
  }

  /// Get safe area height (excluding status bar and bottom padding)
  double get safeAreaHeight => screenHeight - statusBarHeight - bottomPadding;

  /// Get safe area width
  double get safeAreaWidth {
    final padding = MediaQuery.of(this).padding;
    return screenWidth - padding.left - padding.right;
  }

  /// Check if device has notch
  bool get hasNotch => statusBarHeight > 24;

  /// Get text scale factor
  double get textScaleFactor => MediaQuery.of(this).textScaleFactor;

  /// Get device pixel ratio
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;
} 