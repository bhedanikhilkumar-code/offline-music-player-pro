package com.musicplayer.offline.offline_music_player

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.engine.FlutterEngine
import com.musicplayer.equalizer.EqualizerPlugin

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        AudioServicePlugin.getFlutterEngine(this)
        super.onCreate(savedInstanceState)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return AudioServicePlugin.getFlutterEngine(context)
    }

    override fun getCachedEngineId(): String? {
        AudioServicePlugin.getFlutterEngine(this)
        return AudioServicePlugin.getFlutterEngineId()
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!flutterEngine.plugins.has(EqualizerPlugin::class.java)) {
            flutterEngine.plugins.add(EqualizerPlugin())
        }
    }
}
