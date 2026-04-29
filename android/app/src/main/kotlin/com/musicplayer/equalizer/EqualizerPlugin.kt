package com.musicplayer.equalizer

import android.media.audiofx.BassBoost
import android.media.audiofx.Equalizer
import android.media.audiofx.Virtualizer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class EqualizerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null
    private var virtualizer: Virtualizer? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.musicplayer.equalizer")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        release()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                val sessionId = call.argument<Int>("sessionId") ?: 0
                try {
                    release()
                    equalizer = Equalizer(0, sessionId).apply {
                        enabled = false
                    }
                    bassBoost = BassBoost(0, sessionId).apply {
                        enabled = false
                    }
                    virtualizer = Virtualizer(0, sessionId).apply {
                        enabled = false
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("INIT_ERROR", e.message, null)
                }
            }
            "setEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                try {
                    equalizer?.enabled = enabled
                    bassBoost?.enabled = enabled
                    virtualizer?.enabled = enabled
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            "setBandLevel" -> {
                val band = call.argument<Int>("band") ?: 0
                val level = call.argument<Int>("level") ?: 0
                try {
                    equalizer?.let { eq ->
                        if (band in 0 until eq.numberOfBands) {
                            eq.setBandLevel(band.toShort(), level.toShort())
                        }
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            "setBassBoost" -> {
                val strength = call.argument<Int>("strength") ?: 0
                try {
                    bassBoost?.setStrength(strength.toShort())
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            "setVirtualizer" -> {
                val strength = call.argument<Int>("strength") ?: 0
                try {
                    virtualizer?.setStrength(strength.toShort())
                    result.success(true)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            "release" -> {
                release()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun release() {
        try {
            equalizer?.release()
            bassBoost?.release()
            virtualizer?.release()
        } catch (_: Exception) {}
        equalizer = null
        bassBoost = null
        virtualizer = null
    }
}
