import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/drawing_action.dart';
import '../services/i18n.dart';
import '../services/sound_engine.dart';

enum KidsTool {
  brush,
  stamps,
  lines,
  shapes,
  magic,
  fill,
  coloring,
  eraser,
}

/// Core state controller for KidsPaint canvas.
/// Enforces Tier 2 Scoped Subtree state management, infinite undo/redo,
/// full Tux Paint sound engine synchronization, and zero memory leaks.
class DrawingController extends ChangeNotifier {
  // Infinite Undo / Redo stacks
  final List<DrawingAction> _undoStack = <DrawingAction>[];
  final List<DrawingAction> _redoStack = <DrawingAction>[];

  // Active in-progress stroke / line / shape preview
  List<Offset>? _activePoints;
  Offset? _lineStart;
  Offset? _lineCurrent;

  // Current tool configuration
  KidsTool _currentTool = KidsTool.brush;
  Color _currentColor = const Color(0xFFE63946);
  double _currentStrokeSize = 28.0;
  bool _isRainbow = false;
  String _selectedStampAsset = 'assets/tuxpaint/stamps/tux/tux-yes2.png';
  String _selectedStampCategory = 'tux';
  String _selectedBrushAsset = 'assets/tuxpaint/brushes/aa_round_24.png';
  ShapeType _selectedShape = ShapeType.circle;
  bool _shapeFilled = true;
  int _stampSizeLevel = 2; // 1: Small, 2: Medium, 3: Large, 4: Giant
  MagicType _selectedMagic = MagicType.grass;
  String? _selectedStarterAsset;

  // Tux penguin message
  String _tuxMessage = I18n.instance.tuxWelcome;

  // Getters
  List<DrawingAction> get history => List<DrawingAction>.unmodifiable(_undoStack);
  List<Offset>? get activePoints => _activePoints != null ? List<Offset>.unmodifiable(_activePoints!) : null;
  Offset? get lineStart => _lineStart;
  Offset? get lineCurrent => _lineCurrent;
  KidsTool get currentTool => _currentTool;
  Color get currentColor => _currentColor;
  double get currentStrokeSize => _currentStrokeSize;
  bool get isRainbow => _isRainbow;
  String get selectedStampAsset => _selectedStampAsset;
  String get selectedStampCategory => _selectedStampCategory;
  String get selectedBrushAsset => _selectedBrushAsset;
  ShapeType get selectedShape => _selectedShape;
  bool get shapeFilled => _shapeFilled;
  int get stampSizeLevel => _stampSizeLevel;
  MagicType get selectedMagic => _selectedMagic;
  String? get selectedStarterAsset => _selectedStarterAsset;
  String get tuxMessage => _tuxMessage;

  double get stampSizeInPixels {
    switch (_stampSizeLevel) {
      case 1:
        return 55.0;
      case 2:
        return 92.0;
      case 3:
        return 138.0;
      case 4:
        return 188.0;
      default:
        return 92.0;
    }
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int get undoCount => _undoStack.length;
  int get redoCount => _redoStack.length;

  void setTuxMessage(String msg) {
    _tuxMessage = msg;
    notifyListeners();
  }

  void toggleAudioMute() {
    TuxSoundEngine.instance.toggleMute();
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    I18n.instance.setLanguage(lang);
    _updateTuxTipForCurrentTool();
    notifyListeners();
  }

  void _updateTuxTipForCurrentTool() {
    switch (_currentTool) {
      case KidsTool.brush:
        _tuxMessage = I18n.instance.tuxBrushTip;
      case KidsTool.stamps:
        _tuxMessage = I18n.instance.tuxStampTip;
      case KidsTool.lines:
        _tuxMessage = I18n.instance.tuxLinesTip;
      case KidsTool.shapes:
        _tuxMessage = I18n.instance.tuxShapesTip;
      case KidsTool.magic:
        _tuxMessage = I18n.instance.tuxMagicTip;
      case KidsTool.fill:
        _tuxMessage = I18n.instance.tuxFillTip;
      case KidsTool.coloring:
        _tuxMessage = I18n.instance.tuxColoringTip;
      case KidsTool.eraser:
        _tuxMessage = I18n.instance.tuxEraserTip;
    }
  }

  // Tool selection with audio feedback
  void setTool(KidsTool tool) {
    if (_currentTool == tool) return;
    _currentTool = tool;
    TuxSoundEngine.instance.playToolClick();
    _updateTuxTipForCurrentTool();
    notifyListeners();
  }

  void setColor(Color color) {
    _currentColor = color;
    _isRainbow = false;
    TuxSoundEngine.instance.playColorClick();
    notifyListeners();
  }

  void setRainbow(bool rainbow) {
    _isRainbow = rainbow;
    TuxSoundEngine.instance.playColorClick();
    notifyListeners();
  }

  void setStrokeSize(double size) {
    _currentStrokeSize = size;
    TuxSoundEngine.instance.playToolClick();
    notifyListeners();
  }

  void setStamp(String assetPath) {
    _selectedStampAsset = assetPath;
    TuxSoundEngine.instance.playToolClick();
    notifyListeners();
  }

  void setStampSizeLevel(int level) {
    _stampSizeLevel = level.clamp(1, 4);
    TuxSoundEngine.instance.playToolClick();
    notifyListeners();
  }

  void setStampCategory(String category) {
    _selectedStampCategory = category;
    TuxSoundEngine.instance.playToolClick();
    notifyListeners();
  }

  void setBrush(String assetPath) {
    _selectedBrushAsset = assetPath;
    TuxSoundEngine.instance.playToolClick();
    notifyListeners();
  }

  void setShape(ShapeType shape, {bool? filled}) {
    _selectedShape = shape;
    if (filled != null) _shapeFilled = filled;
    TuxSoundEngine.instance.playToolClick();
    notifyListeners();
  }

  void setMagic(MagicType magic) {
    _selectedMagic = magic;
    TuxSoundEngine.instance.playToolClick();
    notifyListeners();
  }

  void setStarter(String? starterAsset) {
    _selectedStarterAsset = starterAsset;
    _undoStack.clear();
    _redoStack.clear();
    TuxSoundEngine.instance.playTuxGiggle();
    notifyListeners();
  }

  // Active Stroke Lifecycle
  void startStroke(Offset point) {
    _activePoints = <Offset>[point];
    if (_currentTool == KidsTool.eraser) {
      TuxSoundEngine.instance.playEraser();
    } else if (_currentTool == KidsTool.brush) {
      TuxSoundEngine.instance.playPaintSound();
    } else if (_currentTool == KidsTool.magic) {
      _playMagicSound(_selectedMagic);
    }
    notifyListeners();
  }

  void updateStroke(Offset point) {
    if (_activePoints == null) return;
    _activePoints!.add(point);
    notifyListeners();
  }

  void endStroke() {
    if (_activePoints == null || _activePoints!.isEmpty) {
      _activePoints = null;
      notifyListeners();
      return;
    }

    DrawingAction action;
    if (_currentTool == KidsTool.magic) {
      action = MagicAction(
        magicType: _selectedMagic,
        points: List<Offset>.from(_activePoints!),
        color: _currentColor,
        strokeWidth: _currentStrokeSize,
        isLarge: _currentStrokeSize > 40,
      );
    } else {
      action = StrokeAction(
        points: List<Offset>.from(_activePoints!),
        color: _currentColor,
        strokeWidth: _currentStrokeSize,
        isRainbow: _isRainbow,
        isEraser: _currentTool == KidsTool.eraser,
        brushAsset: _currentTool == KidsTool.eraser ? null : _selectedBrushAsset,
      );
    }

    _undoStack.add(action);
    _redoStack.clear();
    _activePoints = null;
    notifyListeners();
  }

  // Lines Tool Lifecycle
  void startLine(Offset start) {
    _lineStart = start;
    _lineCurrent = start;
    TuxSoundEngine.instance.playLineStart();
    notifyListeners();
  }

  void updateLine(Offset current) {
    _lineCurrent = current;
    notifyListeners();
  }

  void endLine() {
    if (_lineStart != null && _lineCurrent != null) {
      final action = LineAction(
        start: _lineStart!,
        end: _lineCurrent!,
        color: _currentColor,
        strokeWidth: _currentStrokeSize,
        brushAsset: _selectedBrushAsset,
        isRainbow: _isRainbow,
      );
      _undoStack.add(action);
      _redoStack.clear();
      TuxSoundEngine.instance.playLineEnd();
    }
    _lineStart = null;
    _lineCurrent = null;
    notifyListeners();
  }

  void addStamp(Offset position) {
    final action = StampAction(
      position: position,
      assetPath: _selectedStampAsset,
      size: stampSizeInPixels,
    );
    _undoStack.add(action);
    _redoStack.clear();
    TuxSoundEngine.instance.playStamp();
    notifyListeners();
  }

  void addShape(Offset start, Offset end) {
    final action = ShapeAction(
      start: start,
      end: end,
      shapeType: _selectedShape,
      color: _currentColor,
      strokeWidth: _currentStrokeSize,
      isFilled: _shapeFilled,
    );
    _undoStack.add(action);
    _redoStack.clear();
    TuxSoundEngine.instance.playToolClick();
    notifyListeners();
  }

  void addFill(Offset position, {ui.Image? filledImage}) {
    final action = FillAction(
      position: position,
      color: _currentColor,
      filledImage: filledImage,
    );
    _undoStack.add(action);
    _redoStack.clear();
    TuxSoundEngine.instance.playFill();
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();
    _redoStack.add(action);
    TuxSoundEngine.instance.playUndo();
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();
    _undoStack.add(action);
    TuxSoundEngine.instance.playRedo();
    notifyListeners();
  }

  void clearCanvas() {
    if (_undoStack.isEmpty) return;
    _undoStack.add(const ClearCanvasAction());
    _redoStack.clear();
    TuxSoundEngine.instance.playClear();
    notifyListeners();
  }

  void _playMagicSound(MagicType type) {
    switch (type) {
      case MagicType.grass:
        TuxSoundEngine.instance.playSound('tuxpaint/magic/sounds/grass.wav');
      case MagicType.rainbow:
      case MagicType.realRainbow:
        TuxSoundEngine.instance.playSound('tuxpaint/magic/sounds/rainbow.wav');
      case MagicType.bricks:
        TuxSoundEngine.instance.playSound('tuxpaint/magic/sounds/brick.wav');
      case MagicType.chalk:
        TuxSoundEngine.instance.playSound('tuxpaint/magic/sounds/chalk.wav');
      case MagicType.blur:
        TuxSoundEngine.instance.playSound('tuxpaint/magic/sounds/blur.wav');
      case MagicType.rails:
        TuxSoundEngine.instance.playSound('tuxpaint/magic/sounds/rails.wav');
      case MagicType.foam:
        TuxSoundEngine.instance.playSound('tuxpaint/magic/sounds/foam.ogg');
      case MagicType.confetti:
        TuxSoundEngine.instance.playSound('tuxpaint/magic/sounds/confetti.ogg');
      case MagicType.flower:
        TuxSoundEngine.instance.playSound('tuxpaint/magic/sounds/flower_click.ogg');
    }
  }
}
