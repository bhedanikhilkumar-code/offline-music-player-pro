package com.musicplayer.offline.offline_music_player

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.engine.FlutterEngine
import com.musicplayer.equalizer.EqualizerPlugin

class MainActivity: FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return AudioServicePlugin.getFlutterEngine(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!flutterEngine.plugins.has(EqualizerPlugin::class.java)) {
            flutterEngine.plugins.add(EqualizerPlugin())
        }
    }
}
