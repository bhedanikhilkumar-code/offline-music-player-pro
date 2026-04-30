package com.musicplayer.offline.offline_music_player

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import com.musicplayer.equalizer.EqualizerPlugin

class MainActivity: AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!flutterEngine.plugins.has(EqualizerPlugin::class.java)) {
            flutterEngine.plugins.add(EqualizerPlugin())
        }
    }
}
