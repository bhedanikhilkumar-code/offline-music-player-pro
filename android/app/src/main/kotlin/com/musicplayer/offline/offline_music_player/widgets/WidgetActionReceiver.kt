package com.musicplayer.offline.offline_music_player.widgets

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.view.KeyEvent

/**
 * Receives widget button taps and forwards them as media-button
 * events so AudioService / MediaSession handles them correctly.
 */
class WidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        val keyCode = when (action) {
            BaseMusicWidget.ACTION_PLAY_PAUSE -> KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE
            BaseMusicWidget.ACTION_NEXT -> KeyEvent.KEYCODE_MEDIA_NEXT
            BaseMusicWidget.ACTION_PREV -> KeyEvent.KEYCODE_MEDIA_PREVIOUS
            BaseMusicWidget.ACTION_OPEN_APP -> {
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (launchIntent != null) context.startActivity(launchIntent)
                return
            }
            else -> return
        }

        // Send media key event via MediaSession
        try {
            val msm = context.getSystemService(Context.MEDIA_SESSION_SERVICE) as? MediaSessionManager
            val controllers = msm?.getActiveSessions(null) ?: emptyList()
            for (controller in controllers) {
                if (controller.packageName == context.packageName) {
                    controller.dispatchMediaButtonEvent(KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
                    controller.dispatchMediaButtonEvent(KeyEvent(KeyEvent.ACTION_UP, keyCode))
                    BaseMusicWidget.updateAllWidgets(context)
                    return
                }
            }
        } catch (_: SecurityException) {
            // Notification listener not granted — fall back to broadcast
        }

        // Fallback: send a regular media button broadcast
        val downEvent = KeyEvent(KeyEvent.ACTION_DOWN, keyCode)
        val upEvent = KeyEvent(KeyEvent.ACTION_UP, keyCode)
        val downIntent = Intent(Intent.ACTION_MEDIA_BUTTON).putExtra(Intent.EXTRA_KEY_EVENT, downEvent)
        val upIntent = Intent(Intent.ACTION_MEDIA_BUTTON).putExtra(Intent.EXTRA_KEY_EVENT, upEvent)
        context.sendBroadcast(downIntent)
        context.sendBroadcast(upIntent)

        BaseMusicWidget.updateAllWidgets(context)
    }
}
