import 'package:web/web.dart' as web;

/// Resumes all suspended browser AudioContext instances.
///
/// Modern browsers (Brave, Safari, Firefox, etc.) suspend AudioContexts
/// created before a user gesture. Calling this during a tap/click/keypress
/// handler tells the browser the user has interacted, allowing audio to play.
void resumeBrowserAudioContexts() {
  try {
    // Resume the default AudioContext that audioplayers/flame_audio creates.
    final ctx = web.AudioContext();
    if (ctx.state == 'suspended') {
      ctx.resume();
    }
  } catch (_) {
    // Silently ignore — non-critical if this fails.
  }
}
