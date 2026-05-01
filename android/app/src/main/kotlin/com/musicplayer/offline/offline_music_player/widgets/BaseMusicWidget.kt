package com.musicplayer.offline.offline_music_player.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.musicplayer.offline.offline_music_player.R

/**
 * Base class for all music player widgets. Handles common playback
 * intents and shared-prefs reading for now-playing info.
 */
abstract class BaseMusicWidget : AppWidgetProvider() {

    companion object {
        const val ACTION_PLAY_PAUSE = "com.musicplayer.widget.PLAY_PAUSE"
        const val ACTION_NEXT = "com.musicplayer.widget.NEXT"
        const val ACTION_PREV = "com.musicplayer.widget.PREV"
        const val ACTION_OPEN_APP = "com.musicplayer.widget.OPEN_APP"
        const val PREFS_NAME = "FlutterSharedPreferences"

        /** Force-refresh every widget subclass that is registered on the home screen. */
        fun updateAllWidgets(context: Context) {
            val classes = arrayOf(
                FullPlayerWidget::class.java,
            )
            for (cls in classes) {
                val ids = AppWidgetManager.getInstance(context)
                    .getAppWidgetIds(ComponentName(context, cls))
                if (ids.isNotEmpty()) {
                    val intent = Intent(context, cls).apply {
                        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                    }
                    context.sendBroadcast(intent)
                }
            }
        }
    }

    /** Reads a String from Flutter SharedPreferences. */
    protected fun getPrefString(context: Context, key: String, default: String = ""): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString("flutter.$key", default) ?: default
    }

    protected fun getPrefBool(context: Context, key: String, default: Boolean = false): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getBoolean("flutter.$key", default)
    }

    /** Build a PendingIntent for the given broadcast action. */
    protected fun buildActionIntent(context: Context, action: String): PendingIntent {
        val intent = Intent(context, WidgetActionReceiver::class.java).apply {
            this.action = action
        }
        return PendingIntent.getBroadcast(
            context, action.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    /** Build a PendingIntent that opens the app. */
    protected fun buildOpenAppIntent(context: Context): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent()
        return PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    protected fun getSongTitle(context: Context): String =
        getPrefString(context, "last_song_title", "No song playing")

    protected fun isPlaying(context: Context): Boolean =
        getPrefBool(context, "is_currently_playing", false)
}
