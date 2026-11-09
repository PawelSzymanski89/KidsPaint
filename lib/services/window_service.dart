// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/legacy.dart';

class WindowService with WindowListener {
  WindowService._();
  static final WindowService instance = WindowService._();

  static const String _prefX = 'window_x';
  static const String _prefY = 'window_y';
  static const String _prefWidth = 'window_width';
  static const String _prefHeight = 'window_height';
  static const String _prefMaximized = 'window_maximized';
  static const String _prefFullScreen = 'window_fullscreen';

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux)) {
      return;
    }

    try {
      await windowManager.ensureInitialized();
      windowManager.addListener(this);

      final prefs = await SharedPreferences.getInstance();
      final double? x = prefs.getDouble(_prefX);
      final double? y = prefs.getDouble(_prefY);
      final double width = prefs.getDouble(_prefWidth) ?? 1280;
      final double height = prefs.getDouble(_prefHeight) ?? 840;
      final bool isMaximized = prefs.getBool(_prefMaximized) ?? false;
      final bool isFullScreen = prefs.getBool(_prefFullScreen) ?? false;

      const windowOptions = WindowOptions(
        size: Size(1280, 840),
        minimumSize: Size(800, 600),
        title: 'KidsPaint',
        titleBarStyle: TitleBarStyle.hidden,
        windowButtonVisibility: false,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setTitleBarStyle(
          TitleBarStyle.hidden,
          windowButtonVisibility: false,
        );
        await windowManager.setSize(Size(width, height));
        if (x != null && y != null) {
          await windowManager.setPosition(Offset(x, y));
        } else {
          await windowManager.center();
        }
        if (isFullScreen) {
          await windowManager.setFullScreen(true);
        } else if (isMaximized) {
          await windowManager.maximize();
        }
        await windowManager.show();
        await windowManager.focus();
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('WindowService init error: $e');
    }
  }

  Future<void> toggleFullScreen() async {
    if (!_isDesktop) return;
    final isFull = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFull);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefFullScreen, !isFull);
  }

  Future<void> toggleMaximize() async {
    if (!_isDesktop) return;
    final isMax = await windowManager.isMaximized();
    if (isMax) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    await _saveState();
  }

  bool get _isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  @override
  void onWindowMoved() {
    _saveState();
  }

  @override
  void onWindowResized() {
    _saveState();
  }

  @override
  void onWindowMaximize() {
    _saveState();
  }

  @override
  void onWindowUnmaximize() {
    _saveState();
  }

  Future<void> _saveState() async {
    if (!_isDesktop || !_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFull = await windowManager.isFullScreen();
      final isMax = await windowManager.isMaximized();
      await prefs.setBool(_prefFullScreen, isFull);
      await prefs.setBool(_prefMaximized, isMax);

      if (!isMax && !isFull) {
        final pos = await windowManager.getPosition();
        final size = await windowManager.getSize();
        await prefs.setDouble(_prefX, pos.dx);
        await prefs.setDouble(_prefY, pos.dy);
        await prefs.setDouble(_prefWidth, size.width);
        await prefs.setDouble(_prefHeight, size.height);
      }
    } catch (_) {}
  }
}
