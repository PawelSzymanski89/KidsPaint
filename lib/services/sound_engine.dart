import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TuxSoundEngine {
  TuxSoundEngine._();
  static final TuxSoundEngine instance = TuxSoundEngine._();

  AudioPlayer? _player;
  AudioPlayer? _paintPlayer;
  bool _muted = false;
  bool enabled = true;

  bool get isMuted => _muted;
  void toggleMute() {
    _muted = !_muted;
  }

  AudioPlayer _getPlayer() {
    return _player ??= AudioPlayer();
  }

  AudioPlayer _getPaintPlayer() {
    return _paintPlayer ??= AudioPlayer();
  }

  Future<void> playSound(String soundFile) async {
    if (!enabled || _muted) return;
    try {
      final path = soundFile.contains('/') ? soundFile : 'tuxpaint/sounds/$soundFile';
      final player = _getPlayer();
      await player.stop();
      await player.play(AssetSource(path));
    } on MissingPluginException {
      // In headless test environments, silently ignore missing native audio channel
      enabled = false;
    } catch (e) {
      debugPrint('TuxSoundEngine play error ($soundFile): $e');
    }
  }

  Future<void> playPaintSound() async {
    if (!enabled || _muted) return;
    try {
      const sounds = ['tuxpaint/sounds/paint1.wav', 'tuxpaint/sounds/paint2.wav', 'tuxpaint/sounds/paint3.wav'];
      final chosen = sounds[(DateTime.now().millisecondsSinceEpoch ~/ 200) % sounds.length];
      final player = _getPaintPlayer();
      await player.stop();
      await player.play(AssetSource(chosen));
    } on MissingPluginException {
      enabled = false;
    } catch (_) {}
  }

  void playToolClick() => playSound('click.wav');
  void playColorClick() => playSound('bleep.wav');
  void playUndo() => playSound('harp.wav');
  void playRedo() => playSound('return.wav');
  void playClear() => playSound('youcannot.wav');
  void playStamp() => playSound('stamp.wav');
  void playLineStart() => playSound('line_start.wav');
  void playLineEnd() => playSound('line_end.wav');
  void playFill() => playSound('fill.wav');
  void playEraser() => playSound('eraser1.wav');
  void playTuxGiggle() => playSound('giggle.wav');
}
